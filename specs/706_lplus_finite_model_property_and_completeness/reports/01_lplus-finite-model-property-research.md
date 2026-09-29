# Research Report: Task #706

**Task**: 706 - lplus_finite_model_property_and_completeness
**Started**: 2026-09-29T23:25:16Z
**Completed**: 2026-09-29T23:55:00Z
**Effort**: ~2.5 hours (forced research-only round; one Lean probe compiled, seven declarations)
**Dependencies**: 695 (landed: `plusValidZTime_iff_plusValidInt`), 696 (landed). Task 703 plan v2 and round-2 report read as inputs; task 703 is NOT yet recorded as a dependency, per the filing's SEQUENCING note
**Sources/Inputs**: - Codebase (`FormalSystem/PlusLanguage/{Formula,PlusTruth,PlusValidity,PlusIntTransfer,PlusPasting,PlusDeterminism,Subformulas}.lean`, `FormalSystem/Semantics/{IntNormalForm,ShiftSet,TaskFrame,FrameProperty}.lean`, `FormalSystem/Metalogic/Decidability/{IntPresentation,FMP/**,BiLasso/README.md,WitnessFamily/README.md,WitnessFamily/Sharing/{Skeleton,Fulfil}.lean,WitnessFamily/Compression/Family.lean,PlusWitnessFamily/{Agreement,Closure}.lean,PlusWitnessFamily/Compression/{Types,Saturate,Extract}.lean}`); the archived evidence probe `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`; task 703 artifacts (`reports/02_semantics-first-compression-research.md`, `plans/02_lplus-certificate-limits-graph-certificate.md`, `probes/*.lean`); one new probe compiled with `lake env lean` against the built tree; literature corpus (`~/Projects/Literature/sources/reynolds_2001`, `emerson_and_halpern_-_1986_-_...`, `vardi_1996`, `piterman_2007`, `schewe_2009`); the paired repository `/home/benjamin/Projects/ModelChecker` (read-only: `specs/TODO.md` entries 200 and 219, `code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`, `BimodalTools/README.md` in this repository for the wire contract)
**Artifacts**: - `specs/706_lplus_finite_model_property_and_completeness/reports/01_lplus-finite-model-property-research.md` (this report); `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean` (compiled, sorry-free)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Q1 is answered first, negatively, and machine-checked: the certificate type in task 703's
  plan v2 (Phases 13-16) is the wrong shape for completeness.** A `PlusGraphCertificate`
  presents `FrameOver.ofStep` on the finite carrier `Fin n`. `probes/NoFiniteCarrierModel.lean`
  proves that the `⊡`-free formula `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` is ℤ-time satisfiable
  (`not_plusValidZTime_neg_θ`) and is satisfied at no history and time of **any** regular ℤ-frame
  with a `Finite` world-state carrier (`no_finite_carrier_sat`, `no_ofStep_sat`). Hence
  `not_finite_carrier_fmp`: no certificate class whose soundness lands
  `PlusWitnessFamily.PlusRefutes` by presenting a finite-carrier frame can certify every ℤ-time
  non-validity. Axioms: `[propext, Classical.choice, Quot.sound]`, no `sorry`.
- **The failure is inherited from L, and L already shows the way out.** The same witness is the
  archived `Probe476.fmp_false` for `Formula`, and the landed L-side decidability
  (`exists_witnessFamily_of_not_validZTime`) certifies `θ.neg` with a family whose presented frame
  has an **infinite** carrier, finitely presented as eventually periodic, time-stamped lassos. Plan
  v2's "period one, no time origin" design (703 round-2 candidate H) therefore regresses coverage
  below the landed L class on `⊡`-free targets. The concrete amendment (Section Q1.4): a
  three-segment **time-sliced** graph (`back`/`mid`/`fwd` lists of slice graphs with slice
  labels) presenting a frame on `ℤ × Fin n` built the way `SharingSkeleton.frame` already is, with
  liveness computed on the window and required **tail-stable**, and with the `witness` field
  dropped. A period-one certificate is the special case with one slice and empty `mid`.
- **Staging through the CTL-like fragment cannot rescue the finite-graph shape.** The probe also
  proves `not_finite_carrier_fmp_fragment` for `θ' := □(p ∨ ⊡Fp ∨ ⊡Pp) ∧ □(p → ⊡¬Pp)`, in which
  every `⊡` and `□` governs a state formula or a single temporal operator. The amended, sliced
  shape is needed already for the fragment.
- **The finite model property for the amended class is open for full L⁺, and the only known
  proof route is infeasible here.** Full L⁺ over ℤ-frames is at least CTL\*-hard (the reduction of
  703 round-2 section 1.6 is sound in both directions, argued in Q4), and the two-sided `⊡`
  factors into one-sided universal path conditions (Q5), so the route is Emerson–Jutla /
  Reynolds: deterministic ω-automata (Safra/Piterman) plus a Rabin "banning" construction. Nothing
  of that exists in the tree or in Mathlib. The direct construction on the product of the state
  graph with the Hintikka types fails at the classical point (a quotient creates a path that
  postpones an eventuality forever; a four-state example is given in Q2). For the CTL-like
  fragment a tableau-with-ranks construction is plausible but must additionally produce
  eventually periodic time-stamped structure, which has no literature counterpart.
- **Bound order.** For the sliced class: slice width is expected doubly exponential in the closure
  size `κ`, and a singly exponential width with the fixpoint checker would place a 2EXPTIME-hard
  problem in co-NEXPTIME. The tail period obtained by the natural argument is a further exponential
  up (`2^(n·2^κ)`), which is a proof artefact, not a known necessity. **No bound is proved and none
  should be committed to a plan.**
- **Recommendation.** Amend task 703's Stage 2 before Phase 13 is built; re-scope this task to
  landing the two refutations as library declarations beside
  `PlusWitnessFamily/Incompleteness.lean`, restating the finite model property for the sliced
  class, and proving that the landed L family embeds (completeness of the sliced class on the
  `⊡`-free fragment); record the full-L⁺ finite model property as **blocked** on ω-automata
  infrastructure, with the obstruction a theorem; file the fragment's finite model property as its
  own research-first successor. This is raised as a non-blocking user decision.

## Context & Scope

This is the research round of Stage 3 of the L⁺ completeness programme, run alone as
`/orchestrate 706 --research`. The dispatch asks seven questions in order, with Q1 to be answered
first because task 703 Stage 2 builds the certificate type. Task 703 is currently `[PLANNED]` at
plan v2 with nothing of Stage 1 or Stage 2 landed, so an amendment is still free.

Scope boundaries honoured:

- Research only. No file under `FormalSystem/` was edited; task 703's plan was not revised.
- The probe is under `specs/706_.../probes/` and imports only `FormalSystem`.
- Soundness is untouched: `plusTruth_iff_mem` and `plusRefutes_of_certifies` are read, not
  proposed for change.
- No `.orchestrator-handoff.json` was written.

### Verification labels

| Label | Meaning |
|---|---|
| **[checked]** | Proved in `probes/NoFiniteCarrierModel.lean`, which compiles sorry-free against the built tree; axioms listed |
| **[landed]** | A declaration already in the tree, cited by name |
| **[archived]** | A declaration in an archived evidence probe that `scripts/check-evidence-probes.sh` compile-checks |
| **[argued]** | A paper argument in this report, not machine-checked |
| **[literature]** | Read from the literature corpus, cited by the paper's own labels |

## Findings

### Q1 — Certificate-shape check

#### Q1.1 The finite-carrier finite model property fails for L⁺ **[checked]**

`probes/NoFiniteCarrierModel.lean` (349 lines; compile with
`lake env lean specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
from the repository root, about three seconds):

| Declaration | Statement | Axioms |
|---|---|---|
| `Probe706.θ_eq_ofFormula` | `θ = ofFormula ψL`: the witness is `⊡`-free | — (`decide`) |
| `Probe706.not_plusValidZTime_neg_θ` | `¬ PlusValidZTime θ.neg` | `[propext, Classical.choice, Quot.sound]` |
| `Probe706.no_finite_carrier_sat` | `∀ (F : FrameOver intOrder) [F.IsRegular] [Finite F.WorldState] M τ t, ¬ PlusTruthAt M τ t θ` | same |
| `Probe706.no_ofStep_sat` | the same at `FrameOver.ofStep R fwd bwd` on any `[Finite W] [Nonempty W]` — the frame Phase 13 defines and Phase 17 quantifies over | same |
| `Probe706.not_finite_carrier_fmp` | `¬ ∀ φ, ¬ PlusValidZTime φ → ∃ F [IsRegular] [Finite WorldState] M τ t, ¬ PlusTruthAt M τ t φ` | same |
| `Probe706.not_plusValidZTime_neg_θ'` | `¬ PlusValidZTime θ'.neg`, `θ'` in the CTL-like fragment | same |
| `Probe706.no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment` | the finite-carrier failure for `θ'` | same |

The argument, in the order the probe runs it, for `θ = A ∧ C` with `A := □(p ∨ Fp ∨ Pp)` and
`C := □(p → ¬Pp)` (primitive syntax in the Appendix):

1. `□` is history- and time-independent (`plusBox_const` **[landed]**, used here in the form
   "shift the history so that time `t` reads any chosen time"), so `A` says every history meets
   `p` somewhere and `C` says a `p`-time has no earlier `p`-time on the same history.
2. Take the target history `τ`; it meets `p` at some `a`. Every time `b < a` on `τ` is `p`-free.
3. Pigeonhole (`Finite.exists_ne_map_eq_of_infinite`) on the states `τ.path (a - 1 - i)`,
   `i : ℕ`, gives `x < y ≤ a - 1` with `τ.path x = τ.path y`.
4. The cycle `τ.path (x + n % (y - x))` is a bi-infinite step path, hence a history
   (`FrameOver.worldHistoryOfStepPath`, i.e. `mem_HF_iff_adjacent` **[landed]**, the fact S1 of
   703's round-2 report), and it never meets `p`. This contradicts `A`.

Nothing about `⊡` enters; the only facts used are limit closure over ℤ (S1) and finiteness of the
carrier. The positive half puts `θ` on the shift set with carrier `ℤ`, `sh w d = w + d` and `p`
true exactly at state `0`; `⊡` collapses there because histories through a state are unique
(`Probe706.S_hist_unique`, from `ShiftSet.total_eq_orbit` **[landed]**), which is how the
fragment witness `θ'` is put on the same model.

#### Q1.2 Why this is the type, not the bound

`PlusGraphCertificate` (plan v2, Lean Challenge Statements) carries `n`, `n_pos`,
`stepR : Fin n → Fin n → Bool`, `stepR_fwd`, `stepR_bwd`, and Phase 13 defines
`G.frame := FrameOver.ofStep (fun w u => G.stepR w u = true) …`. These five fields are literally
`IntPresentation`'s `card`, `card_pos`, `step`, `fwd`, `bwd`
(`Metalogic/Decidability/IntPresentation.lean:86`) **[landed]**, and `IntPresentation.toFibre` is
the same `ofStep`. Phase 16's soundness instantiates `PlusWitnessFamily.PlusRefutes` at
`G.frame.toTaskFrame`. So a certified `G` for `[] ⊢ [θ.neg]` would give a model of `θ` on a
finite-carrier regular ℤ-frame, which `no_ofStep_sat` forbids. No bound on `n`, no change to the
checker's clauses, and no liveness formulation repairs this: the presented frame's carrier is
finite by construction, and that alone is fatal.

This is the L-side fact the tree already records **[archived]**: `Probe476.fmp_false`
(`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`,
compile-checked by `scripts/check-evidence-probes.sh`, last re-verified 2026-09-27) refutes the
finite-`IntPresentation` candidate-list hypothesis for `Formula` with the same `ψ`, and
`BiLasso/README.md` draws the conclusion "the remaining route to decidability is the
presentation-free witness family, not a finite presentation". 703's round-2 report, written from
the semantics, missed this because its S1-S5 analysis is time-homogeneous: "period one and no time
origin" (its 1.3) is exactly what `θ` forbids. A countermodel to `θ.neg` must have a time at which
something happens once, so its state space cannot be time-homogeneous and finite.

#### Q1.3 What plan v2's Stage 2 would still deliver, and what it loses

- Phase 17, completeness relative to finite models, remains true and is not affected.
- But the class is **strictly weaker than the landed L class on `⊡`-free targets**: the L family
  certifies every ℤ-time non-validity of L (`exists_witnessFamily_of_not_validZTime`,
  `WitnessFamily/Compression/Family.lean:153` **[landed]**), including `ψL.neg`, which no
  `PlusGraphCertificate` can certify. An export contract to the paired model checker built on the
  finite graph would refuse countermodels the current lasso-family contract already carries.
- The export expectation relayed in 703 round 2 ("the search bound is a bound on the number of
  world states") is therefore wrong in kind: there is no finite number of world states to bound.

#### Q1.4 The amendment to task 703's plan v2, stated concretely

**Reason**: `Probe706.no_ofStep_sat`. **Where**: the Lean Challenge Statements block and Phases
13-17, before Phase 13 is started. **What**:

1. *Carrier becomes time-sliced.* Replace `stepR`, `stepR_fwd`, `stepR_bwd`, `stateLab`,
   `stateLab_sub` by three segments of slices, decoded by the same three-segment readout
   `PlusGraphPath` already uses (`WitnessFamily/Compression/Extract.lean`'s `getD_mapC`,
   `readout_backC`, `readout_midC`, `readout_fwdC`):

   ```lean
   /-- One time slice: the edge relation to the next slice and the state labelling of this slice. -/
   structure PlusSlice (n : ℕ) (C : Finset PlusFormula) where
     edge : Fin n → Fin n → Bool
     lab : Fin n → Finset PlusFormula
     lab_sub : ∀ w, lab w ⊆ C

   structure PlusSlicedCertificate (Γ Del : PlusContext) where
     n : ℕ
     n_pos : 0 < n
     back : List (PlusSlice n (plusClosureOf (Γ ++ Del)))   -- leftward period, left-to-right
     mid : List (PlusSlice n (plusClosureOf (Γ ++ Del)))    -- the window [0, |mid|)
     fwd : List (PlusSlice n (plusClosureOf (Γ ++ Del)))    -- rightward period, left-to-right
     back_ne : back ≠ []
     fwd_ne : fwd ≠ []
     bx : PlusFormula → Bool
     target : PlusGraphPath n (plusClosureOf (Γ ++ Del))
     targetTime : ℤ
   ```

   Derived: `G.slice : ℤ → PlusSlice n C` (readout), `G.edge t w u := (G.slice t).edge w u`,
   `G.slab t w := (G.slice t).lab w`. Bi-seriality is per slice, `∀ t w, ∃ u, G.edge t w u = true`
   and `∀ t w, ∃ v, G.edge (t - 1) v w = true`, **decided on the window** `[-nb, nm + nf)` and
   extended to all `t` by periodicity, exactly as `coherent_iff_window` does on the L side.
2. *The `witness` field is dropped.* Its index set would be `ℤ × Fin n`, infinite. It was
   redundant already in plan v2: with both directions of the liveness characterization proved
   (Phase 14's `mem_live_of_path` and `exists_path_of_mem_live`), "`⊡χ ∉ slab t w`" is
   "some live position over `(t, w)` omits `χ`", and a live position **is** a witness path.
3. *The presented frame has carrier `ℤ × Fin n`.* Build it as `SharingSkeleton.frame` is built
   (`WitnessFamily/Sharing/Skeleton.lean:1404`): a literal `FrameOver intOrder` with a two-sided
   relation `(t, w) —d→ (t + d, u)` iff a `d`-step `edge`-path exists, reflection by symmetry,
   *Limit* by `TaskFrame.limit_of_succOrder` at the zero-duration law, and *Saturation* by
   `TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean:2222`), whose docstring names
   exactly this case: infinite carrier, finite fibres. `FrameOver.ofStep` cannot be used; it
   requires `[Finite W]`. A generic `FrameOver.ofSlicedStep` would be the reusable form.
   Histories are the offset step paths `σ t = (t + k, w_t)` with `edge (t + k) w_t w_(t+1)`; by
   shift invariance (`plusTruthAt_timeShift` **[landed]**) every truth question can be asked at
   offset `0`, so positions are `(t, w)` with `t` the slice time.
4. *Positions and liveness are two-regime.* Positions are `(t, w, h)` with `h` a Hintikka type
   over the subformulas agreeing with `slab t w`. Backward liveness in the back tail and forward
   liveness in the forward tail are fixpoints on the **folded** tail graphs (an infinite backward
   path from a back-tail position stays in the tail, so folding by `nb` is exact). Forward
   liveness from the back tail is **not** periodic in `t` in general: it depends on the distance to
   the window. Example (four states): back tail slice `{a, b}` with edges `a→a`, `a→b`, `b→b`,
   `q` true at `b` only; `mid = [c]` with `a→c`, `b→c`; forward tail `{d}` with `c→d`, `d→d`.
   Then `⊡(XX¬q)` is true at `(-1, a)` (the only continuation is `c, d, …`) and false at
   `(-2, a)` (via `a, b`). So the checker must not read the tail's `⊡`-labels at one residue only.
   Let `Φ_back` be the one-period transfer of live-position sets through the back tail (with
   pending eventualities carried on the type). The true forward-live sets at `t = -k·nb` are
   `Φ_back^k (L₀)` with `L₀` computed from the window and forward tail; this sequence is eventually
   periodic (subsets of `Fin n × H` are finite). **Require the certificate to be tail-stable**:
   the checker computes `L₀`, then `Φ_back L₀`, and demands `Φ_back L₀ = L₀` (mirror for the
   forward tail). A certificate whose tails are not yet stable is re-presented with the pre-period
   absorbed into `mid` and the period multiplied by the cycle length; the frame is unchanged, so
   truth is unchanged. This keeps the checker one `Φ` application beyond plan v2's fixpoints and
   makes every clause decidable on the window.
5. *`Certifies` keeps four groups* (existential from liveness, universal, box, target), all read
   on the window under tail-stability. Phase 15's "no clause may quantify over a time in a way that
   would need alignment" survives: nothing is aligned, the slice time is the only time.
6. *Phase 17 becomes "completeness relative to tail-stable sliced models"*, and a **new Phase
   17b**: the landed L family embeds. A `WitnessFamily [] [φ]` with `k` lassos is a sliced
   certificate with `n = k`, edges `i → i` only, `slab t i` the atoms and `bx`-boxes of
   `(lassos i).lab t`, tails and window from the lassos' common periods (their product, as
   `perBack` in `PlusWitnessFamily/Decide.lean:181` already computes). With
   `plusTruthAt_ofFormula` **[landed]** this yields
   `∀ φ : Formula, ¬ PlusValidZTime (ofFormula φ) → ∃ G : PlusSlicedCertificate [] [ofFormula φ], G.Certifies`,
   restoring parity with L and proving the class is not vacuous on branching-free targets.
7. *Cost.* Phases 13-15 grow by roughly the tail-stability mechanism and the sliced frame
   (+8-12 h on plan v2's 10 h); Phase 16 is unchanged in shape; Phase 17b is new (~4 h). The
   finite-graph case is recovered as `back = fwd = [slice]`, `mid = []`, so nothing is lost.

**Alternative amendment, same content, different substrate.** Keep the landed `SharingSkeleton`
(share-classes of `(index, time)` pairs, periodic in both tails, frame already built, histories
already characterized by `SharingSkeleton.total_eq_thread`) and replace the all-threads (C2') by
computed liveness on the folded class graph. This is 703 round-2's candidates G and H combined. It
reuses more landed code but inherits the row-against-absolute-time representation whose costs
(a), (b), (d) the round-2 report diagnosed. The sliced graph is recommended because a slice is
the natural unit and the model checker's registry already folds by period.

### Q2 — The two routes, and what each needs that the tree lacks

**Route A: deterministic automata** (Emerson and Jutla 1988 via Reynolds 2001 **[literature]**,
`reynolds_2001/sec01`: "we let a deterministic Rabin linear automaton loose in the background and
we impose an elaborate banning mechanism as we go along … in the limit, the step-by-step
construction produces many more paths than were ever chosen explicitly").

- What it is here. For each `⊡ψ` in the closure, with the state formulas of `ψ` atomized
  (`stab_state_only`, `Atomization.lean` **[landed]**), `ψ` is an LTL-with-past formula over
  state atoms, and "all histories through `w` satisfy `ψ`" factors by Q5 into one-sided
  conditions "no forward path from `w` is accepted by `N_f^h`" and "no backward path into `w` is
  accepted by `N_b^h`", for each origin type `h`. Each `N` is the nondeterministic Büchi automaton
  whose states are Hintikka types, whose transitions are `PlusLocalCoherentSeqLab`'s one-step
  clauses and whose acceptance is `PlusFulfillingSeqLab` — that automaton **is** landed
  (`PlusWitnessFamily/Compression/Types.lean:228,250`). The universal condition is its
  complement, which needs determinization (Safra; Piterman 2007 `piterman_2007` for the tight
  `n^{2n+2}` Büchi-to-parity bound; Schewe 2009 `schewe_2009` for complementation) so that the
  automaton state can be carried as a **label** on the finite structure, turning the universal
  path condition into a local safety condition plus one global acceptance ("banning").
- What the tree lacks: any ω-automaton, determinization, complementation, Rabin/parity
  acceptance, the finite-model theorem for tree automata, and the two-way adaptation for
  bi-infinite paths on non-tree frames. Mathlib has none of it. The nearest formalizations are
  Isabelle/AFP's Büchi complementation and LTL-to-DRA developments, each on the order of 10^4
  lines. This route is a multi-month project on its own and is not a candidate for a plan here.
- Decidability in principle, for the record **[argued]**: L⁺ truth is invariant under two-way
  bisimulation of the state graph, so a countermodel unravels to a two-way tree in which
  histories through a node are pairs of a backward branch and a forward branch; MSO over such
  trees is decidable (Rabin), and `⊡` is MSO-definable there. This is the Emerson–Halpern 1986
  reduction of CTL\* to SnS and gives non-elementary complexity. Not formalizable; not useful for
  a bound.

**Route B: direct construction on the product of the state graph with the Hintikka types.**

- What it is. Positions `(w, h)`; a quotient of the countermodel by the *bundle* (the set of
  realized types at a state) or by a finer invariant; liveness computed on the quotient.
- Where it fails **[argued]**, the classical point. A quotient by types has an edge `h → h''`
  whenever some node of type `h` has a successor of type `h''`, but consecutive edges need not be
  realized by consecutive nodes. Example: a node `a` of type `h` with successors `b_n`, `n ≥ 1`,
  each followed by a chain of `n` guard-nodes then an event-node; every node satisfies
  `⊡(g U e)`, all `b_n` and chain nodes share one type `h₁`, so the quotient has a self-loop
  `h₁ → h₁` and a path postponing `e` forever; the computed liveness then declares `⊡(g U e)`
  false at `[a]`, and the quotient is not a countermodel. Refining the invariant to bundles does
  not help: the postponing path is built from realized *edges*, and the bundle does not record
  distances. This is what Reynolds' quotation describes and what 703 round 2 section 1.6 already
  recorded. No finite invariant of a node that is a function of its realized types alone can
  prevent it; the automaton state is the extra information that does.
- What it needs that the tree lacks, if restricted to a fragment where it works: see Q3.

**Decision**: neither route yields a plannable proof of the full-L⁺ finite model property now.
Route A is the correct route and is out of reach; Route B is refuted for full L⁺ and is the
route for the fragment.

### Q3 — Stage through the CTL-like fragment, or go at full L⁺

- **Going at full L⁺ directly is not available** without Route A (Q2).
- **The fragment does not rescue the finite-graph shape** **[checked]**:
  `not_finite_carrier_fmp_fragment`. So the fragment's finite model property must also be
  stated for the sliced class, and its proof must produce eventually periodic, time-stamped
  structure. That is new relative to the CTL small-model literature (Emerson and Halpern 1985
  build time-homogeneous Kripke models by unwinding a pruned tableau). The ℤ-time analogue needs
  the tableau to be run on slices and the two tails to be closed by a type-recurrence cut, as
  the L side does for a single history (`exists_plusLabelledLasso_of_history_realized`
  **[landed]**).
- **Fragment definition that makes Route B work**: state formulas
  `S ::= atom | ⊥ | S → S | □S | ⊡(S U S) | ⊡(S S S)` (`X`, `F`, `G` and their past mirrors are
  instances), the target an arbitrary L⁺ formula whose `⊡`- and `□`-subformulas are of this
  shape. Both `□` and `⊡` must be restricted: `□ψ` for a path formula `ψ` is `⊡ψ` at every state,
  and on a branching structure it is exactly the universal path condition Route B cannot
  quotient. This means the fragment does **not** contain L (`θ` is outside it), so "fragment
  first" does not subsume the L side; parity with L comes from the embedding of Q1.4 item 6
  instead.
- **Why Route B works on the fragment** **[argued]**: `⊡(g U e)` at `w` is witnessed by a
  well-founded ordinal rank on the tree of `g`-paths from `w` (no finite-branching assumption is
  needed); choosing, for each type, a node of minimal rank makes the type-level successor graph
  acyclic for that eventuality, which is the fulfilling-DAG condition the landed `AUFix.lfp`
  (`WitnessFamily/Sharing/Fulfil.lean:242` **[landed]**) computes. The existential side
  `¬⊡(g U e)` needs one path, kept explicitly. The construction is the Emerson–Halpern tableau
  unwinding with a per-eventuality DAG of depth at most the number of types, giving slice width
  singly exponential in `κ`.
- **Effort**: with the amended Stage 2 landed, the fragment's finite model property is a
  60-100 hour formalization with a real risk in the periodic-tail closure. It is the right first
  target for a Stage 3 successor and should be filed as its own research-first task once the
  sliced certificate exists to state it against.

**Decision**: stage through the fragment, but only after the class is amended; do not plan the
fragment's proof in this task.

### Q4 — The true order of the state bound

- **What is proved**: nothing for L⁺ beyond the per-history segment bound
  `plusCompressionBound` (`PlusWitnessFamily/Compression/Extract.lean:116` **[landed]**), singly
  exponential in `κ := |plusClosureOf (Γ ++ Del)|`, which bounds the target path's and any
  witness path's segments and is unaffected by this report.
- **The 2EXPTIME lower bound** **[argued]**, completing 703 round-2 section 1.6 in both
  directions. Translate CTL\* by `A ↦ ⊡`, `X ↦ ⊥ U ·`, non-strict `U` by `e ∨ (g ∧ (g U e))`.
  (⇒) A rooted total Kripke structure becomes bi-serial by one fresh state with a self-loop and an
  edge to the root; forward paths from the original states are unchanged; `⊡` at `(σ, t)` with
  `σ t = w` ranges over histories through `w`, whose futures are exactly the forward paths from `w`
  (S1, S4), and the translation is pure-future so its truth depends only on the future
  (`truth_congr_agreeFrom` **[landed]**). (⇐) From a ℤ-model of the translation at `(σ, t)`, the
  Kripke structure of the state graph forward-reachable from `σ t` satisfies the CTL\* formula at
  `σ t`, by the same two facts read backwards; CTL\* satisfiability is over arbitrary, possibly
  infinite, structures, so no finiteness is needed. Hence L⁺ ℤ-time validity is 2EXPTIME-hard
  (Vardi and Stockmeyer 1985, as reported in `reynolds_2001/sec01` **[literature]**). This is
  only load-bearing for the complexity picture; nothing in the recommendation depends on it, so
  it is not formalized (it would need a CTL\* semantics in the tree).
- **What follows for a certificate class**. If every non-validity had a sliced certificate with
  `n`, `nb`, `nm`, `nf ≤ 2^{poly(κ)}`, then, since the checker runs in time polynomial in
  `n · 2^κ · (nb + nm + nf)`, non-validity would be in NEXPTIME and validity in co-NEXPTIME, so
  2EXPTIME ⊆ co-NEXPTIME. That is not refuted, but it is disbelieved (it is the exponential
  analogue of EXPTIME ⊆ co-NP). **Doubly exponential slice width is therefore the honest
  expectation** for full L⁺, and singly exponential for the fragment (CTL is EXPTIME-complete).
- **Tail periods**. The natural proof of tail-stability (Q1.4 item 4) iterates `Φ` on subsets of
  `Fin n × H`, so pre-period plus period are at most `2^(n · 2^κ)`: with `n` doubly exponential
  this is a third exponential. That is an artefact of that argument; the L side achieves singly
  exponential periods by cutting at type recurrences along one history, and a type-recurrence cut
  on slices may do the same. **No order for the periods is claimed.**
- **Interaction noted by the dispatch**: the reduction is sound (above), so a singly exponential
  certificate for full L⁺ would be a complexity-theoretic surprise, not a formalization target.

### Q5 — Past operators, the global box, and the two-sided stability modal

**[argued]**, resting on landed facts. None raises the complexity above CTL\*'s.

- *Two-sidedness factors.* Histories through `w` at `t` are pasts × futures (S4, `paste`
  **[landed]**), and a Hintikka labelling of a bi-infinite path with origin type `h` is a
  backward half and a forward half agreeing at the origin (S5, `truth_paste_of_type_eq`, checked
  in 703's `probes/TypePreservingPaste.lean`). So, with `N_b^h`, `N_f^h` as in Q2,
  `⊡¬ψ` at `w` ⟺ `∀ρ∀σ. ⋀_h (ρ ∉ L(N_b^h) ∨ σ ∉ L(N_f^h))` ⟺ `⋀_h ((∀ρ. ρ ∉ L(N_b^h)) ∨ (∀σ. σ ∉ L(N_f^h)))`,
  because `∀ρ∀σ (P ρ ∨ Q σ)` is `(∀ρ P ρ) ∨ (∀σ Q σ)`. Each disjunct is a one-sided CTL\*-style
  universal path condition; the backward one is the forward one on the reversed graph
  (`reflectTime` **[landed]**). The cost is a factor `|H| ≤ 2^κ`, absorbed in the double
  exponential. This is exactly why plan v2's `live = fwdLive ∩ bwdLive` is the right shape.
- *Past operators* are the mirror image and add nothing beyond the reversed automaton; the
  landed `snce` clauses and `plusTruth_snce_pred` are that mirror.
- *The global box* is a universal modality: `□χ ↔ ∀w. ⊡χ at w` (`box_stab_iff`,
  `plusBox_const` **[landed]**). In a certificate it is one Boolean per formula checked against
  every live position of every slice, a conjunction over the finite structure, not a new
  quantifier alternation. Its one effect is that components not reachable from the target matter
  (a `□`-failure may be witnessed elsewhere), which a graph certificate presents anyway.
- *Bi-seriality and limit closure* make the histories exactly the step paths, so the semantics is
  CTL\*-with-branching-past over bi-serial graphs; the Ockhamist logics in the corpus
  (`reynolds-2003-ockhamist`, `reynolds_2002_axioms_for_branching_time`) use bundles, which S1
  forbids, and are a different, generally harder, setting.

### Q6 — The fragment the old `PlusSharingWitnessFamily` class covers

Left **open**, explicitly. What falls out of Q1 and 703's refutations is only a necessary
condition: a target is certifiable by the landed class only if it has a countermodel that is a
finite, eventually periodic sharing structure **all of whose threads are fulfilling** (the
(C2') demand), i.e. a structure with no cycle carrying a pending eventuality with an exit
(703 round 2, 2.5). `θ.neg` (from this report) has such a countermodel (one lasso, no sharing);
`phi0` and `phi1` (703's probes) do not. No syntactic characterization is offered.

### Q7 — Effect on the paired model checker

Read-only findings from `/home/benjamin/Projects/ModelChecker` (`specs/TODO.md` entry 200
`[BLOCKED]`, entry 219; `theory_lib/bimodal/docs/ADEQUACY.md` rows A1, A1-Γ, A3) and this
repository's `BimodalTools/README.md` (wire contract: `lassos: [{back, mid, fwd}]`, `bx`,
`target`).

- Entry 200 currently expects from task 703 "a compression bound" and "the verified side's
  branching structure", and its ADEQUACY chain sets search bounds from the L-side
  `compressionBound` with the registry folding `back`/`fwd` by exact modulus.
- **What to relay**:
  1. The finite-graph certificate of 703's plan v2 must **not** become an export contract: it
     cannot represent countermodels the current lasso-family contract already represents
     (`θ.neg`, a `⊡`-free target).
  2. The intended L⁺ contract is the **time-sliced graph** of Q1.4: per slice, an edge matrix and
     a state labelling; three segments `back`/`mid`/`fwd` of slices; one target path and time;
     `bx`. The current lasso family is the special case of `k` lassos with edges `i → i` only, so
     the wire format is a strict extension, not a replacement.
  3. The search bound is a tuple `(n, nb, nm, nf)`: slice width and three segment lengths. **No
     bound on `n` is proved for any L⁺ target**, and none should be configured from a formula
     yet. For `⊡`-free targets the landed L bounds apply unchanged (at most `|C| + 1` lassos,
     segments at most `compressionBound`), and the registry's period-folding caveat (ADEQUACY
     §7.1(iii-a), `WitnessFamily/README.md`) carries over to `nb`/`nf`.
  4. Liveness is computed by the verified checker; the checker also requires tail-stability
     (Q1.4 item 4), so a search that finds a countermodel with unstable tails must re-present it
     with the pre-period moved into `mid` and the period multiplied — the same divisor-period
     sweep the registry already performs for A3.
  5. The never-report-validity discipline stands: an empty search at any bound licenses nothing
     for L⁺ targets containing `⊡`, and will until a finite model property is proved.

### Codebase Patterns

- `FrameOver.worldHistoryOfStepPath` / `mem_HF_iff_adjacent` (`Semantics/IntNormalForm.lean`)
  turn any bi-infinite step path into a history; the probe's pumping argument is that lemma plus
  `Finite.exists_ne_map_eq_of_infinite`. The same device closed 703's refutation.
- `SharingSkeleton.frame` (`WitnessFamily/Sharing/Skeleton.lean:1404`) is the template for a
  `FrameOver intOrder` on an infinite, time-stamped carrier: *Limit* by
  `TaskFrame.limit_of_succOrder`, *Saturation* by `TaskFrame.saturation_of_fib_finite`. The
  amended certificate's frame is this template on `ℤ × Fin n`.
- `ShiftSet.total_eq_orbit` makes `⊡` collapse on deterministic presentations; the probe's
  `stab_iff_S` is `stab_iff_of_deterministic` (`PlusLanguage/PlusDeterminism.lean:123`) proved
  locally, because `ShiftSet.frame` carries no `Deterministic` instance.
- `plusTruthAt_ofFormula` (`PlusLanguage/PlusValidity.lean:168`) transports every L-side
  countermodel to L⁺; `θ_eq_ofFormula` is `decide`, so the derived operators mirror as the
  README promises.
- `AUFix.lfp` is the universal-until fixpoint the fragment construction's fulfilling-DAG
  condition computes; it is not the existential fair-path fixpoint, as plan v2 already notes.

### External Resources

- Reynolds 2001, "An Axiomatization of Full Computation Tree Logic", §1 (`reynolds_2001/sec01`):
  Emerson–Sistla 1984 automata route; Emerson–Jutla 1988 deterministic double exponential upper
  bound; Vardi–Stockmeyer 1985 lower bound; the limit-closure discussion quoted in Q2.
- Emerson and Halpern 1986 (`emerson_and_halpern_-_1986_-_...`): R-generability (suffix, fusion
  and limit closure), the property S1 gives regular ℤ-frames.
- Piterman 2007 (`piterman_2007`), Schewe 2009 (`schewe_2009`), Vardi 1996 (`vardi_1996`): the
  determinization, complementation and automata-theoretic LTL results Route A would need.
- `~/Projects/Literature/index.json` has no entry for Emerson–Sistla 1984, Emerson–Jutla 1988,
  Vardi–Stockmeyer 1985 or Emerson–Halpern 1985 (CTL small models); they are cited here only as
  Reynolds 2001 reports them.

### Recommendations

1. **Amend task 703's plan v2 before Phase 13** as in Q1.4 (reason: `Probe706.no_ofStep_sat`),
   via `/revise 703`; carry the fragment witness `θ'` into the plan's record so the sliced shape
   is justified for the fragment too.
2. **Re-scope this task's implementation** to what research supports:
   - land `no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp`,
     `not_plusValidZTime_neg_θ` and the `θ'` family as library declarations beside
     `PlusWitnessFamily/Incompleteness.lean` (a new `FiniteCarrier.lean`), pinned in
     `docs/theorem-index.md` and `scripts/check-module-invariants.sh` per the C2/C15 invariants;
   - restate the finite model property for the sliced class as the programme's open statement,
     with **no bound**, in the module docstring;
   - after the amended Stage 2 lands: prove the L-family embedding (Q1.4 item 6), which makes the
     sliced class complete on the `⊡`-free fragment. This is the only completeness theorem for
     L⁺ this research supports.
3. **Mark the finite model property for full L⁺ `[BLOCKED]`** with the obstruction recorded:
   the refuted finite-carrier statement is a theorem (item 2); the sliced statement is open and
   its only known proof route needs ω-automata determinization, absent from the tree and Mathlib.
4. **File the fragment's finite model property as a research-first successor** after the sliced
   certificate exists, with the tableau-with-ranks route of Q3 as its starting point and the
   periodic-tail closure as its named risk.
5. **Relay Q7 to the paired repository** by updating its entry 200's blocker text: the finite
   graph is withdrawn as a contract, the sliced graph is the target, no width bound exists.
6. **Do not commit any bound to a plan.** The dispatch's rule stands and this report gives no
   number to commit.
7. **Sorry-free throughout.** Everything in item 2 is a transcription of a compiled probe plus a
   finite construction; nothing needs a placeholder or an axiom.

## Decisions

- **D1. Q1 is answered negatively and reported first**, as the dispatch requires; the answer is a
  compiled probe, not an argument.
- **D2. The amendment is stated against 703's plan, not applied.** This round is research only
  and 703's plan is another task's artifact.
- **D3. The full-L⁺ finite model property is recorded as open with an infeasible known route**,
  not as refuted: `not_finite_carrier_fmp` refutes the finite-carrier statement only. The sliced
  statement has no counterexample and none is expected.
- **D4. No literature extraction protocol was run**: the task cites no proof to transcribe, and
  the literature route (Route A) is recorded as out of reach rather than extracted step by step.
- **D5. A non-blocking user decision is raised**, because re-scoping a sibling task (703) and
  blocking this task's headline are programme-level choices the artifacts cannot make on their own,
  while nothing is lost by proceeding on the recommendation until the user reads it.
- **D6. No `.orchestrator-handoff.json` is written.** The outcome is returned through
  `.return-meta.json` only.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | Task 703 Stage 2 is implemented against plan v2 before the amendment is taken | High | This report is filed before 703 moves past `[PLANNED]`; recommendation 1 names `/revise 703` |
| R2 | The tail-stability design (Q1.4 item 4) has a gap not visible without building it | Medium | It is stated as a design with its failure mode exhibited; Phase 14's scope hypothesis should be re-pointed at it, with the four-state example as the test fixture |
| R3 | The sliced class is also incomplete for full L⁺ for a reason not yet seen | Medium | No candidate counterexample was found; the class contains every eventually periodic time-stamped countermodel, and every known finite-model theorem for branching time produces one. Until a proof exists, the class is called complete only on the `⊡`-free fragment |
| R4 | The 2EXPTIME reduction has a gap | Low | Both directions are argued in Q4 from S1 and S4; it affects the complexity picture only |
| R5 | The probe drifts as the tree evolves | Low | It imports `FormalSystem` only; add it to `scripts/check-evidence-probes.sh` when its theorems are landed, or land them |
| R6 | The paired repository builds against the finite-graph shape from 703's plan text | Medium | Recommendation 5 |

## Tactic Survey Results

No open goal of the library was under investigation; the survey records what closed the probe's
goals.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `θ = ofFormula ψL` (closed terms, `DecidableEq`) | `decide` | success | default |
| Extract the two conjuncts of `A.and C` from `PlusTruthAt` | `by_contra` + definitional unfolding | success | `PlusTruthAt` unfolds through `.and`/`.neg`/`.imp` by iota |
| Pigeonhole on `ℕ → W` with `[Finite W]` | `Finite.exists_ne_map_eq_of_infinite` | success | no `Fintype` needed |
| Modular arithmetic for the pumped cycle | `omega` | success | after `Int.emod_nonneg`, `Int.emod_lt_of_pos`, `Int.emod_add_mul_ediv`, `Int.add_mul_emod_self_left` as facts |
| Cancel `+ t` on `ShiftSet` states (defeq `ℤ`) | `omega` | fail, then `add_right_cancel` | `omega` does not see through `S.frame.WorldState` |
| `⊡` collapse on the shift set | `ShiftSet.total_eq_orbit` + `congrArg` | success | states of `S.hist w` reduce definitionally to `w + t` |
| Finiteness instance at `FrameOver.ofStep` | `haveI : Finite (…).WorldState := ‹Finite W›` | success | instance synthesis does not unfold `ofStep`; same note as `IntPresentation.toFibre_isRegular` |

## Context Extension Recommendations

- **Topic**: The finite-carrier finite model property fails over ℤ-time, for L and L⁺.
  **Gap**: The fact is recorded only in an archived probe and a README paragraph; two research
  rounds (703 round 2, this one) had to rediscover its consequence for certificate design.
  **Recommendation**: add `context/project/logic/domain/ztime-no-finite-carrier-fmp.md` with the
  witness `θ`, the pumping argument, and the rule "a ℤ-time certificate class must present an
  infinite, finitely presented carrier".
- **Topic**: ℤ-time semantics as a graph semantics (already recommended by 703 round 2).
  **Gap**: unchanged; this round adds that the graph must be time-sliced, not time-homogeneous.
  **Recommendation**: fold this report's Q1.2 into the same note.
- **Topic**: Probing with `lake env lean` (already recommended by 703 round 2).
  **Gap**: unchanged; the probe here compiled in about three seconds with no build.

## Appendix

### Probe

`specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`,
compiled from the repository root with `lake env lean <file>`. Output: no errors, and
`#print axioms` reports `[propext, Classical.choice, Quot.sound]` for
`not_plusValidZTime_neg_θ`, `no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp`,
`not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment`.

### The witnesses, in primitive syntax

```
top  := ⊥ → ⊥            Fp := untl top p          Pp := snce top p
A    := □(¬p → (¬Fp → Pp))                          C  := □(p → (Pp → ⊥))
θ    := ¬(A → ¬C)
A'   := □(¬p → (¬⊡Fp → ⊡Pp))                        C' := □(p → ⊡(Pp → ⊥))
θ'   := ¬(A' → ¬C')
```

`θ = ofFormula ψL` by `decide`; `θ'` is `θ` with `⊡` inserted under each `□` at the temporal
subformulas. Both are satisfied on the shift set `ℤ` with `p` true exactly at `0`, at
`(S.hist 0, 0)`.

### Files read

| File | Why |
|---|---|
| 703 `reports/02_...`, `plans/02_...` (Overview, Goals, Challenge Statements, Phases 13-18) | The certificate type under review and the round-2 findings |
| `PlusLanguage/{Formula,PlusTruth,PlusValidity,PlusIntTransfer,PlusDeterminism,Subformulas}.lean` | Syntax, clauses, `ofFormula` transfer, `⊡` collapse, closure |
| `Semantics/{IntNormalForm,ShiftSet,TaskFrame,FrameProperty}.lean` | Step paths, `ofStep` and its `[Finite]` requirement, shift sets, `saturation_of_fib_finite` |
| `Metalogic/Decidability/{IntPresentation.lean,BiLasso/README.md,WitnessFamily/README.md,FMP/README.md}` | The finite-presentation refutation for L and the L-side route |
| `WitnessFamily/Sharing/{Skeleton,Fulfil}.lean` | The infinite-carrier frame template; `AUFix` |
| `WitnessFamily/Compression/Family.lean`, `PlusWitnessFamily/Compression/{Types,Saturate,Extract}.lean` | The landed L completeness theorem and the L⁺ type machinery |
| `specs/archive/476_.../fmp-hypothesis-is-false.lean` | The archived witness, ported |
| ModelChecker `specs/TODO.md` (200, 219), `bimodal/docs/ADEQUACY.md`; `BimodalTools/README.md` | The paired repository's expectations and the wire contract |

### Searches

- Repository: `PlusGraphCertificate` (no hits: Stage 2 not started), `ofStep`, `Finite W`,
  `saturation_of_fib_finite`, `limit_of_succOrder`, `exists_witnessFamily_of_not_validZTime`,
  `stab_iff_of_deterministic`, `total_eq_orbit`, `finite model|FMP`.
- Literature corpus: `double exponential`, `limit clos`, `determini[sz]ation`, `Safra`,
  `Hintikka`, `small model`, `finite model property`, `Emerson`, `Jutla`, `Stockmeyer`.
- Mathlib: `Finite.exists_ne_map_eq_of_infinite` (`Mathlib/Data/Fintype/Pigeonhole.lean:74`),
  confirmed by compilation. No rate-limited search tool was needed.
