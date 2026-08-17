# Implementation Plan: Machine-check CO ⊬ Prior-U (Reynolds gap axiom independence)

- **Task**: 419 - Machine-check the CO-does-not-derive-Reynolds independence result
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: None outstanding (420, 438, 439 satisfied; `scripts/check-paper-definitions.sh` exits 0)
- **Research Inputs**: `specs/419_machine_check_co_reynolds_independence/reports/01_co-not-derives-prior-u.md`
- **Artifacts**: plans/01_machine-check-co-independence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land the tree's first machine-checked independence result: a `TaskModel` in which every instance
of the paper's CO axiom is true but `Axiom.prior_U_gap p` is false, yielding
`¬ Derivable FrameClass.Dense Γ priorUGapFormula` for CO-only contexts (S1) and, on top of that, a
bespoke CO-closed derivation system whose soundness over the same model gives the unqualified
schema-level claim (S2). The countermodel is fixed and hand-verified by research: the **periodic
clock frame** `D = ℚ`, `W = ℚ ⧸ ℤ`, `w ⇒_x u ⟺ u = w + ⟦x⟧`, with the symmetric arc valuation
`|q| < √2/4`. Definition of done: three new modules under
`FormalSystem/Metalogic/Independence/` compile sorry-free in a full `lake build`, S1 and S2 are
proved, and the refuted Stavi/ℚ-accumulation sketch in `Axioms.lean`'s Layer 9 prose is replaced
with a correct note.

### Research Integration

The plan is built directly on `reports/01_co-not-derives-prior-u.md` and inherits its resolved
questions rather than re-deriving them. Four findings are load-bearing and must not be
re-litigated during implementation:

- **F1 (Spherical is not a threat).** The sketch's ℚ lives in the temporal order `D`, constrained
  only by `def:temporal-order` ("a nontrivial totally ordered abelian group"), which ℚ satisfies.
  The paper's Spherical non-example puts *its* ℚ in the world-state carrier `W`; `def:frame#Spherical`
  quantifies over families of fibers and segments (all subsets of `W`) and says nothing about `D`.
  Gappy time is untouched. This does not gate any phase below.
- **F2 (the named witness is refuted, not merely unverified).** In the ℚ-flow with isolated `¬φ`
  points accumulating at an irrational from above, `ξ := ¬U(¬p,p) ∧ F(U(¬p,p))` has truth set
  `{t < √2}` and `CO(ξ)` is false at `0`. Three natural repairs fail identically — some U/S-formula
  always recovers the cut. The "classical Stavi US-vs-FO phenomenon" framing is a red herring.
  Phase 6 corrects the prose on this basis.
- **F3 (no frame-level countermodel can exist).** Under `def:frame-validity`'s all-valuations
  quantifier, frame-validity of CO on a dense flow forces gap-freeness and hence Prior-U validity.
  The theorem is therefore stated over a fixed `TaskModel`, matching Reynolds' own printed
  "definably Dedekind-complete" caveat.
- **F4/F5 (the working countermodel and its generalization).** `respects_task` at duration 1 alone
  forces every total history on the clock frame to be 1-periodic, hence truth is 1-periodic, hence
  `Hψ → Gψ` and a fortiori every CO instance holds everywhere. The quotient's torsion is
  load-bearing: on the un-quotiented line frame the time shift moves worlds and the argument
  collapses. The general content is routed through a reusable `LoopingDuration` lemma.

Already done and explicitly **not** re-planned: the converse direction (`co_derived` in
`FormalSystem/Theorems/DedekindDerived.lean`, `co_valid` in
`FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`) is sorry-free; the `possible_worlds.tex`
re-anchoring (zero occurrences remain in the Lean tree, and both formerly-cited sites already carry
`\aitem[CO]{TMP-CO}` verbatim); and the Stavi/Reynolds literature acquisition pass, downgraded to
optional and to be attempted only if Phase 5 stalls.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied and no ROADMAP.md consultation was requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- A `TaskFrame ℚ` clock frame with all `TaskFrame` obligations discharged, sorry-free.
- A reusable `LoopingDuration` abstraction yielding history periodicity, truth periodicity, and
  CO-validity over any Archimedean `D`.
- A machine-checked refutation of `Axiom.prior_U_gap p` at a concrete point of a concrete model.
- Statement S1: `¬ Derivable FrameClass.Dense Γ priorUGapFormula` for CO-instance contexts.
- Statement S2: `¬ Nonempty (CoDerivation priorUGapFormula)` for a CO-closed system that includes
  `temporal_duality`, closing the schema-level claim without caveat.
- Corrected Layer 9 prose in `FormalSystem/ProofSystem/Axioms.lean` plus a forward pointer from
  `co_derived`'s docstring.

**Non-Goals**:
- Any edit under `/home/benjamin/Philosophy/Papers/` — the paper is read-only ground truth. The
  paper-side consequence (`def:TMplus-c` too weak for the completeness corollary, fix.md C4
  option 2) is recorded in prose only.
- Adding an `Axiom.co` constructor or a new `FrameClass` element for the paper's TM⁺_c. The
  official Dedekind basis stays the Reynolds triple; the CO system is local to the new module and
  the target frame class is `.Dense` (research D6, D7).
- Refuting `Axiom.prior_S_gap` or `Axiom.sep` in the same model (research R7). Cheap once the
  machinery exists, but deliberately excluded so it cannot block completion; record as a follow-up
  in the implementation summary.
- Authoring `.claude/context/project/lean4/patterns/independence-via-countermodel.md` (research
  "Context Extension Recommendations"). `.claude/**` is a disposable deploy artifact; such a
  document belongs in `agent-system/extensions/**` and is a separate task.
- Weakening `CoDerivation` by dropping `temporal_duality` to make Phase 5 land. That would silently
  change what is being claimed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mathlib quotient ergonomics on `ℚ ⧸ AddSubgroup.zmultiples (1:ℚ)` (decidability, `Quotient.lift` well-definedness) | M | M | State the valuation as an existential over representatives (`∃ q, ⟦q⟧ = w ∧ \|(q:ℝ)\| < α`) so it is well-defined by construction and needs no `lift`. Fallback 1: `AddCircle (1:ℚ)`. Fallback 2: a hand-rolled `Quotient` (~30 lines). Do not drag in the topological instance stack. |
| The `box` case of truth periodicity needs *all* total histories periodic, not just the one in play | H | M | Lemma A is a frame-level fact, so the hypothesis is uniformly available. State Lemma B with `τ` universally quantified *inside* the induction, not fixed outside it. |
| `temporal_duality` in S2 requires the model isomorphic to its own time-reversal | H | M | The arc is symmetric about `0` precisely for this; `w ↦ -w` on `ℚ ⧸ ℤ` preserves `V(p)` and reverses durations. Do not "simplify" the arc to an asymmetric one. If the mirror lemma exceeds budget, mark Phase 5 `[BLOCKED]` and escalate — never drop the constructor. |
| Irrationality plumbing (`∀ q : ℚ, \|(q:ℝ)\| ≠ √2/4`) | M | M | Derive from `irrational_sqrt_two`; keep all cut reasoning in ℝ via casts and `exists_rat_btwn` rather than juggling `2q² ≠ 1` in ℚ. |
| Reviewer objection: "the model is degenerate — it validates `Hψ → Gψ`" | L | H | Correct and harmless; independence witnesses are routinely non-intended models. Pre-empt it explicitly in the module docstring: the frame satisfies all four `def:frame` axioms and every base/dense axiom holds by `soundness_dense`. |
| Scope creep into `FrameClass` / `Axiom` | M | M | Target `.Dense` only (D7) and record the TM⁺_c gap in prose. No new `Axiom` constructor (D6). |
| Aggregator wiring breaks the root build | M | L | Wiring is isolated to Phase 4, which carries `Verification Tier: full`. Note `autoImplicit := false` is in force; no lakefile change is needed. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5, 6 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: The periodic clock frame [IN PROGRESS]

**Goal**: A sorry-free `clockFrame : TaskFrame ℚ` over `W = ℚ ⧸ ℤ` with every `TaskFrame`
obligation discharged, plus the reference history.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/ClockFrame.lean` with a module docstring stating
      the construction, its purpose (independence witness), and the pre-emption of the
      "degenerate model" objection.
- [ ] Define `ClockState := ℚ ⧸ AddSubgroup.zmultiples (1:ℚ)` (research D5; `AddCircle (1:ℚ)` and a
      hand-rolled `Quotient` are the sanctioned fallbacks, in that order).
- [ ] Define `clockFrame : TaskFrame ℚ` with `WorldState := ClockState` and
      `TaskRel w x u := u = w + ⟦x⟧`.
- [ ] Discharge `nonempty` (`⟦0⟧`).
- [ ] Discharge `nullity_identity` (`TaskRel w 0 u ↔ w = u`).
- [ ] Discharge `comp` — the full biconditional; both directions take `u := w + ⟦x⟧`, so
      interpolation is immediate from determinism.
- [ ] Discharge `converse` (`u = w + ⟦d⟧ ↔ w = u + ⟦-d⟧`).
- [ ] Discharge `serial` (`u := w + ⟦x⟧`, `v := w - ⟦x⟧`).
- [ ] Discharge `limit` — for `u ≠ w`, the representative distance `min(d, 1-d)` is a positive
      rational; take `x` strictly below it.
- [ ] Discharge `spherical` — every `Fib(w,x)` is a singleton and a segment is an intersection of
      two singletons, so a directed family of nonempty such sets forces them all equal and
      `⋂₀ 𝒮` is that singleton.
- [ ] Define `clockHistory : WorldHistory clockFrame` with `τ₀(t) = ⟦t⟧`, and prove
      `clockHistory_isTotal`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The phase is estimated at ~180 lines and asserts that `TaskFrame` presents
**two data fields** (`WorldState`, `TaskRel`) and **seven proof obligations** (`nonempty`,
`nullity_identity`, `comp`, `converse`, `serial`, `limit`, `spherical`). Confirm at implementation
time by reading the `structure TaskFrame` declaration in
`FormalSystem/Semantics/TaskFrame.lean` and enumerating its fields before writing the instance; if
the field set differs, discharge the actual set and record the deviation rather than matching the
count asserted here. `RegionFrame.lean`'s `regionFrame` is the worked deterministic-clock precedent
to crib the axiom discharges from.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/ClockFrame.lean` - new file (frame, history, totality)

**Verification**:
- `lake build FormalSystem.Metalogic.Independence.ClockFrame` succeeds with zero errors.
- Zero `sorry` in the new file (`grep -c sorry`).
- `example : Nonempty (TaskFrame ℚ) := ⟨clockFrame⟩` elaborates.

---

### Phase 2: The looping-duration lemmas [NOT STARTED]

**Goal**: The reusable generalization — any frame carrying a looping duration validates every CO
instance — proved once and instantiated at `clockFrame`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/LoopingDuration.lean`.
- [ ] Define `LoopingDuration F π : Prop := π ≠ 0 ∧ ∀ w u, F.TaskRel w π u ↔ u = w`.
- [ ] Lemma A (history periodicity): from a looping duration, every total history satisfies
      `τ.states (x + π) = τ.states x`, via `respects_task` at `(x, x + π)` alone. Do not route
      through any characterization of `H_F`.
- [ ] Lemma B (truth periodicity): `TruthAt M τ t φ ↔ TruthAt M τ (t + π) φ` by induction on
      `Formula`, with `τ` and `t` universally quantified *inside* the induction. Cases: atom
      (Lemma A; the domain conjunct is vacuous by totality), `bot`, `imp`, `box` (quantifies over
      all total `σ`, each periodic by Lemma A), `untl`, `snce` (reindex witness and guard interval
      by `s ↦ s ± π`, an order-isomorphism of `D`).
- [ ] Lemma C: with `[Archimedean D]`, derive `Hψ → Gψ` at every point (given `Hψ` at `t` and
      `s > t`, pick `n` with `s - n·π < t`, then `n` applications of Lemma B), and hence
      `TruthAt M τ t (Formula.co ψ)` for every `ψ`.
- [ ] Record the past-mirror (`Gψ → Hψ`) as a corollary — it is free here and is used by Phase 5.
- [ ] Prove `clockFrame` carries the looping duration `π = 1` and instantiate Lemmas A/B/C at it.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Estimated ~200 lines, asserting **six** cases in the `Formula` induction for
Lemma B. Confirm by reading the `Formula` inductive in `FormalSystem/Syntax/Formula.lean` and the
`TruthAt` clauses in `FormalSystem/Semantics/Truth.lean` before starting the induction; cover
whatever constructors actually exist and note any divergence from six.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/LoopingDuration.lean` - new file (definition, Lemmas A/B/C,
  clock instantiation)

**Verification**:
- `lake build FormalSystem.Metalogic.Independence.LoopingDuration` succeeds.
- Zero `sorry` in the new file.
- `∀ ψ M τ t, τ.IsTotal → TruthAt M τ t (Formula.co ψ)` is proved for `clockFrame` models.

---

### Phase 3: The Prior-U refutation in the arc model [NOT STARTED]

**Goal**: A concrete model on `clockFrame` in which `Axiom.prior_U_gap p` is false at time `0`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` with a module docstring
      covering the statement, the F3 reason it is model-level rather than frame-level, and the
      degenerate-model pre-emption.
- [ ] Define `α := Real.sqrt 2 / 4` and prove `Irrational α` and `0 < α < 1/2` from
      `irrational_sqrt_two`. Keep all cut reasoning in ℝ via casts.
- [ ] Define `clockModel : TaskModel clockFrame` with
      `valuation w p := ∃ q : ℚ, ⟦q⟧ = w ∧ |(q:ℝ)| < α` — an existential over representatives, so
      no `Quotient.lift` well-definedness obligation arises.
- [ ] Prove the arc characterization along `clockHistory`: `p` true at `t` iff `∃ n : ℤ, |t - n| < α`.
- [ ] Membership fact 1: `U(⊤, p)` at `0`, witness `s = 1/4 < α`.
- [ ] Membership fact 2: `F(¬p)` at `0`, witness `s = 1/2` (`|1/2 - n| ≥ 1/2 > α` for every `n`).
- [ ] Membership fact 3 (the substantive one): no rational `s` admits `p` throughout `(0,s)` and
      satisfies the consequent. If `s > α`, `exists_rat_btwn` gives a rational in
      `(α, min(s, 1-α))` where `p` fails, forcing `s < α`; at such `s`, `p(s)` holds so `¬p(s)`
      fails, and `U(⊤, ¬¬p)` holds at `s` (any rational in `(s, α)`), so `K⁺(¬p)(s)` fails.
- [ ] Conclude `¬ TruthAt clockModel clockHistory 0 (priorUGapFormula p)`, where
      `priorUGapFormula` is the local abbreviation matching `Axiom.prior_U_gap`'s statement
      verbatim.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Estimated ~200 lines and asserts **three** membership facts suffice to refute
the axiom. Confirm at implementation time by reading `Axiom.prior_U_gap`'s exact statement in
`FormalSystem/ProofSystem/Axioms.lean` and the `untl` clause in `FormalSystem/Semantics/Truth.lean`
(event-first / guard-second: `U(A,B)` at `t` iff `∃ s > t` with `A` at `s` and `B` throughout
`(t,s)`) and transcribing the local abbreviation from them character-for-character — do not
reconstruct the formula from the prose in this plan.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` - new file (constants, model, arc
  characterization, three membership facts, refutation)

**Verification**:
- `lake build FormalSystem.Metalogic.Independence.CoNotPriorU` succeeds.
- Zero `sorry` in the new file.
- The refutation `¬ TruthAt clockModel clockHistory 0 (priorUGapFormula p)` is proved.

---

### Phase 4: Statement S1 and module wiring [NOT STARTED]

**Goal**: The first machine-checked independence theorem in the tree, wired into the library.

**Tasks**:
- [ ] In `CoNotPriorU.lean`, state
      `theorem co_not_derives_prior_U_gap (Γ : Context) (hΓ : ∀ ψ ∈ Γ, ∃ χ, ψ = Formula.co χ) : ¬ Derivable FrameClass.Dense Γ priorUGapFormula`.
- [ ] Prove it on the `not_derivable_nil_bot` template: `rintro ⟨d⟩`; apply `soundness_dense` at
      `clockModel`/`clockHistory`/`0` with `h_ctx` supplied by Phase 2's Lemma C; contradict
      Phase 3's refutation. `ℚ` is `DenselyOrdered`, so base and density axioms come free.
- [ ] Add a docstring stating precisely what is and is not claimed: dense base + finitely many CO
      instances as context ⊬ `prior_U_gap`; the schema-level claim is S2 (Phase 5); no frame-level
      claim is possible (F3).
- [ ] Create the aggregator `FormalSystem/Metalogic/Independence.lean` importing the three new
      modules.
- [ ] Add one `import FormalSystem.Metalogic.Independence` line to `FormalSystem/Metalogic.lean`.
      No lakefile change.

**Timing**: 1 hour

**Depends on**: 2, 3

**Verification Tier**: full

**Scope Hypothesis**: Asserts the wiring is exactly **one new aggregator file plus one import
line**, with **no lakefile change**. Confirm by inspecting how the sibling
`FormalSystem/Metalogic/Decidability.lean` aggregator is wired alongside its `Decidability/`
directory and by checking `lakefile.lean` for any explicit module enumeration before assuming the
import line suffices.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` - add S1 theorem and docstring
- `FormalSystem/Metalogic/Independence.lean` - new aggregator
- `FormalSystem/Metalogic.lean` - one import line

**Verification**:
- Full `lake build` succeeds from a clean-ish state (this is the phase that touches the root import
  graph).
- Zero `sorry` across `FormalSystem/Metalogic/Independence/`.
- `lean_verify` on the fully qualified S1 name reports no unexpected axioms (no `sorryAx`).

---

### Phase 5: Statement S2 — the CO-closed derivation system [NOT STARTED]

**Goal**: The unqualified schema-level claim, including closure under `temporal_duality`.

**Tasks**:
- [ ] Define a bespoke `inductive CoDerivation : Formula → Type` local to `CoNotPriorU.lean`, with
      constructors: any `Axiom` whose `minFrameClass ≤ .Dense`; `Formula.co χ` for every `χ`; and
      mirrors of `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`.
      (S1 cannot express this because `DerivationTree`'s three rule constructors are restricted to
      the empty context.)
- [ ] Prove the time-reversal mirror lemma: `w ↦ -w` on `ℚ ⧸ ℤ` is an automorphism of
      `clockFrame` that preserves `V(p)` (the arc is symmetric about `0`) and reverses durations,
      giving `M ≅ M^rev`; conclude `TruthAt M τ t φ.swapTemporal ↔ TruthAt M^rev τ' t' φ` in the
      form `temporal_duality` needs.
- [ ] Prove soundness of `CoDerivation` over `clockModel` at `clockHistory`/`0`: axioms via
      `soundness_dense`'s axiom lemmas, CO instances via Phase 2's Lemma C, the three standard
      rules by the usual arguments, `temporal_duality` by the mirror lemma.
- [ ] Conclude `¬ Nonempty (CoDerivation priorUGapFormula)`.
- [ ] Update the S1 docstring's "the schema-level claim is S2" pointer to name the landed theorem.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Estimated ~200 lines and asserts the constructor set above is exactly the
closure needed. Confirm at implementation time by reading `DerivationTree`'s constructor list in
`FormalSystem/ProofSystem/Derivation.lean` and mirroring **every** rule constructor found there
(minus `assumption`/`weakening`, which the empty-context schema form does not need); if a
constructor exists that this plan did not name, mirror it rather than omitting it.

**Escalation contract**: if the mirror lemma exceeds budget, mark this phase `[BLOCKED]` with the
mirror lemma named as the blocker target and escalate. Do **not** weaken `CoDerivation` by dropping
`temporal_duality` — that silently changes what is being claimed. Phase 6 must still run.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` - `CoDerivation`, mirror lemma, soundness,
  S2 theorem

**Verification**:
- `lake build FormalSystem.Metalogic.Independence.CoNotPriorU` succeeds.
- Zero `sorry` in the file.
- `lean_verify` on the S2 name reports no `sorryAx`.

---

### Phase 6: Correct the Layer 9 prose and add the forward pointer [NOT STARTED]

**Goal**: Remove the refuted ℚ-accumulation/Stavi sketch from `Axioms.lean` and point both
directions of the CO/Reynolds relationship at their machine-checked artifacts.

**Tasks**:
- [ ] In `FormalSystem/ProofSystem/Axioms.lean`, Layer 9, replace the paragraph beginning "The
      CONVERSE is NOT claimed" — specifically the sentence naming the ℚ-flow with isolated `¬φ`
      points accumulating at an irrational and the "classical Stavi US-vs-FO phenomenon" framing —
      with: (i) the now-machine-checked statement and a pointer to
      `FormalSystem.Metalogic.Independence.CoNotPriorU`; (ii) an explicit note that the previous
      sketch's witness was **refuted**, not merely unverified, giving the reason in one sentence
      (`ξ := ¬U(¬p,p) ∧ F(U(¬p,p))` defines the cut, so `CO(ξ)` fails there) so it is not
      re-attempted; (iii) a one-line note that the countermodel is a fixed model, not a frame,
      because frame-validity of CO forces gap-freeness.
- [ ] Retain the "CONSEQUENCE FOR THE PAPER" paragraph unchanged, and change only its opening
      conditional ("If the sketch is right") to reflect that the result is now established. No file
      under `Philosophy/Papers/` is edited.
- [ ] Add a short forward pointer to `co_derived`'s docstring in
      `FormalSystem/Theorems/DedekindDerived.lean`: the converse direction now has a
      machine-checked refutation, with the module named.
- [ ] Confirm every changed hunk lies inside a comment region and that no `--`/`/-- -/` boundary was
      crossed.

**Timing**: 45 minutes

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Asserts that exactly **two files** carry stale CO/Reynolds prose and that the
refuted sketch occupies a single identifiable paragraph in `Axioms.lean`'s Layer 9 block. Confirm
at implementation time with `grep -rn "Stavi\|accumulate at an irrational\|CONVERSE is NOT claimed"
--include=*.lean .` before editing; if a third site surfaces, correct it too rather than matching
the count asserted here.

**Sequencing note**: run this after Phase 5 when Phase 5 is `[COMPLETED]`, so the prose can cite S2
as well as S1. If Phase 5 is `[BLOCKED]`, this phase **must still run** and cite S1 only, adding one
sentence recording that the schema-level strengthening is outstanding. The research finding is that
the prose is wrong regardless of the outcome of Phase 5, so this phase is never skipped.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean` - Layer 9 prose block above `Axiom.prior_U_gap`
- `FormalSystem/Theorems/DedekindDerived.lean` - `co_derived` docstring forward pointer

**Verification**:
- `lake build FormalSystem.ProofSystem.Axioms` and
  `lake build FormalSystem.Theorems.DedekindDerived` both succeed (comment-only edits in files the
  whole tree imports — a cheap per-module build is the guard against a crossed comment boundary).
- `grep -n "Stavi" FormalSystem/ProofSystem/Axioms.lean` returns no hit asserting the refuted
  sketch as a live conjecture.
- The `\aitem[CO]{TMP-CO}` anchors already present in `DedekindDerived.lean` and `Formula.lean` are
  untouched.

---

## Testing & Validation

- [ ] Full `lake build` green at the end of Phase 4 and again at the end of the final phase.
- [ ] `grep -rn "sorry" FormalSystem/Metalogic/Independence/` returns zero matches.
- [ ] `lean_verify` on both `co_not_derives_prior_U_gap` (S1) and the S2 theorem reports no
      `sorryAx` and no unexpected axioms.
- [ ] `bash scripts/check-paper-definitions.sh` still exits 0 (all paper anchors relied on remain
      valid).
- [ ] `co_derived` in `FormalSystem/Theorems/DedekindDerived.lean` still compiles sorry-free — the
      converse direction must not be disturbed by any of this work.
- [ ] No file under `/home/benjamin/Philosophy/Papers/` appears in `git status`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/ClockFrame.lean` (new)
- `FormalSystem/Metalogic/Independence/LoopingDuration.lean` (new)
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` (new)
- `FormalSystem/Metalogic/Independence.lean` (new aggregator)
- `FormalSystem/Metalogic.lean` (one import line)
- `FormalSystem/ProofSystem/Axioms.lean` (Layer 9 prose correction)
- `FormalSystem/Theorems/DedekindDerived.lean` (docstring forward pointer)
- `specs/419_machine_check_co_reynolds_independence/summaries/01_machine-check-co-independence-summary.md`

## Rollback/Contingency

- Phases 1-3 are additive new files with no import into the library root; reverting is deleting the
  files. Nothing in the tree depends on them until Phase 4.
- Phase 4 is the only phase that touches the root import graph. If the full build breaks there,
  revert the one import line in `FormalSystem/Metalogic.lean` first — that restores the previous
  green build while leaving the new modules on disk for repair.
- Phase 5 has a declared escalation path (mark `[BLOCKED]`, name the mirror lemma as the blocker
  target) rather than a rollback; S1 from Phase 4 stands on its own and remains the first
  machine-checked independence result in the tree either way.
- Phase 6 is comment-only; reverting is a `git checkout` of the two files from the prior commit.
- All phases commit per green sub-step, so any single phase can be reverted independently.
