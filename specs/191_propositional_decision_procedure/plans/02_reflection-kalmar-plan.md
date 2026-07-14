# Implementation Plan: Task #191 — Propositional Decision Procedure

- **Task**: 191 - Propositional decision procedure
- **Status**: [NOT STARTED]
- **Effort**: 32 hours
- **Dependencies**: None (all in-tree prerequisites verified DONE and sorry-free: task 181 `Derivable`, `deduction_theorem`, `classical_merge`, `trivial_frame`/`universal_trivialFrame`, `Soundness.lean`)
- **Research Inputs**: reports/02_decision-procedure-research.md (authoritative; supersedes reports/01_decision-procedure-seed.md)
- **Artifacts**: plans/02_reflection-kalmar-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build a verified, reflective tautology prover for the propositional fragment of TM: a deep-embedded `PropForm` (Nat-indexed vars), a computable `isTaut` checker, and a Kalmar-style soundness proof `isTaut f = true → ∀ env, ⊢ f.denote env` producing object-level `DerivationTree`s. Because the soundness theorem is schematic in `env : Nat → Formula`, modal/temporal subformulas are handled opaquely for free — this is why proof-by-reflection is mandatory and truth-table + bare `decide` is rejected (cannot close schematic goals like `∀ A B, ⊢ A.imp (B.imp A)`). Deliverables: 4 new files under `Metalogic/Decidability/Propositional/`, a `prop_decide` tactic in `Automation/Tactics/`, a `Decidable (|-! p)` construction for concrete propositional formulas, tests, and import wiring. Definition of done: `lake build` green, zero `sorry`, zero new axioms (kernel `decide` only — `native_decide` is forbidden, it adds `Lean.ofReduceBool`), tests exercising schematic and concrete goals pass.

### Research Integration

From reports/02_decision-procedure-research.md:
- Architecture: reify → check (`decide` on closed `PropForm`) → apply Kalmar soundness. Mirrors `Mathlib.Tactic.Ring` reflection pattern.
- Reuse inventory (all sorry-free, verified 2026-07-14): `Derivable` wrapper (`ProofSystem/Derivable.lean:62`, notation `|-!` at :80, `Derivable.weaken` :140); `deduction_theorem` (`Metalogic/Core/DeductionTheorem.lean:320`, noncomputable); `classical_merge` (`Theorems/Propositional/Connectives.lean:43` — exactly the Kalmar case-merge step); `lem`/`ecq`/`raa` (`Theorems/Propositional/Core.lean:45/192/252`); `ni`/`ne` (`Theorems/Propositional/Reasoning.lean:41/65`); `trivial_frame` + `universal_trivialFrame` (`Semantics/WorldHistory.lean:172`); semantic soundness (`Metalogic/Soundness.lean:1023`).
- Exactly ONE new object-level lemma is required: `⊢ φ.imp (ψ.neg.imp (φ.imp ψ).neg)` (~10-20 lines via `ni` + `deduction_theorem`).
- The existing `Metalogic/Decidability/` tableau is classical-only (`Classical.em`) and fuel-bounded — do NOT verify it; task 191's niche is the kernel-checkable propositional procedure.
- Completeness direction is semantic (trivial-frame countermodel via existing soundness), NOT algorithmic tableau completeness.

### Prior Plan Reference

No prior plan (this is the first plan for task 191; artifact round 2 follows research report 02).

### Roadmap Alignment

No roadmap context provided for this planning run.

## Goals & Non-Goals

**Goals**:
- `PropForm` deep embedding with computable `eval`/`vars`/`isTaut` that kernel `decide` reduces fast (Nat vars, not `Atom`/String).
- Kalmar soundness: `tautology_derivable (f) (h : f.isTaut = true) (env) : |-! f.denote env`, plus a tree-valued (noncomputable `⊢ f.denote env`) variant, both schematic in `env` and stated at general `{fc : FrameClass}` where feasible.
- `prop_decide` tactic closing `⊢ φ`, `⊢[fc] φ`, and `|-! φ` goals whose implication/bot skeleton is tautologous, treating box/untl/snce/opaque subterms as reified variables.
- `Decidable (|-! p)` construction for concrete formulas with `isPropositional p = true` (hypothesis-carrying `def`, not a typeclass instance), with the completeness direction via trivial-frame countermodel.
- Zero `sorry`, zero new axioms; every phase gated by `lake build`.

**Non-Goals**:
- Verifying the existing bimodal tableau (`Metalogic/Decidability/DecisionProcedure.lean`) — kept as semi-decision fallback for modal goals.
- Decidability for the full bimodal logic; substitution lemmas; `isPropositional` gate on the tactic path (schematic env makes it unnecessary).
- `native_decide` or any new axiom.
- Task 192 (`tm_prove` dispatch) integration beyond a README/docstring pointer.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `litCtx` bookkeeping requires permutation lemmas | H | M | Keep `litCtx` list-ordered matching `deduction_theorem`'s `(A :: Γ)` convention; eliminate the HEAD variable each round; verify `Derivation.lean` weakening generality in the first tool calls of Phase 2 |
| `if-then-else` in step-lemma statement makes induction ugly | M | H | Wrap in `litDenote`/`litCtx` defs with `simp` lemmas for true/false branches (Phase 2 deliverable, before the induction starts) |
| Noncomputability contagion from `deduction_theorem` | L | H | Accepted: mark Kalmar tree-valued defs `noncomputable`, provide `theorem` interface for `|-!` (Prop) goals; document in module header |
| `classical_merge` stated only at `Base` frame class | M | M | Check generality in Phase 4; if fixed at Base, lift via `DerivationTree.lift` or state main theorem at Base and lift the result |
| Reification nondeterminism (dedup of opaque subterms) | M | M | Dedup by structural `Expr` equality after `whnf`; avoid `isDefEq` (can loop on metavariables) |
| `decide` fails to reduce `isTaut` on a closed term | H | L | Phase 1 smoke test: `example : (PropForm.isTaut peirceForm) = true := by decide` gates the phase; keep `eval`/`isTaut` structural (no `Finset.pi`, no well-founded recursion) |
| Trivial-model truth lemma fights `Truth.lean` definitions | M | M | Restrict induction to atom/bot/imp (box/untl/snce cases dismissed by `isPropositional`); use `Omega := Set.univ` (trivially ShiftClosed, `Truth.lean:327`) and total domain of `universal_trivialFrame` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |

Phases within the same wave can execute in parallel. Phase 5 (concrete decidability) and Phase 6 (tactic + tests) are mutually independent; if scope must shrink, Phase 5 is the cut candidate (the tactic is the high-value deliverable).

### Phase 1: PropForm deep embedding + computable checker [NOT STARTED]

**Goal**: Sorry-free `PropForm.lean` with the deep embedding, evaluator, tautology checker, denotation, and the characterization lemma; kernel `decide` reducibility demonstrated.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Decidability/Propositional/PropForm.lean` with module docstring (state the reflection architecture and the noncomputability note)
- [ ] `inductive PropForm : Type | var : Nat → PropForm | fls | imp : PropForm → PropForm → PropForm` deriving `DecidableEq, Repr`
- [ ] `PropForm.eval (v : Nat → Bool) : PropForm → Bool` (imp case: `!f.eval v || g.eval v`)
- [ ] `PropForm.vars : PropForm → List Nat` (deduplicated; plain structural recursion — NO `Finset.pi`)
- [ ] `tautoAux : List Nat → (Nat → Bool) → Bool` (structural recursion on var list, branching `v[n] := true/false`) and `PropForm.isTaut (f) : Bool := tautoAux f.vars v₀`
- [ ] `PropForm.denote (env : Nat → Formula) : PropForm → Formula` (`.var n => env n`, `.fls => Formula.bot`, `.imp f g => (f.denote env).imp (g.denote env)`)
- [ ] Characterization lemma `isTaut_iff_forall_eval : f.isTaut = true ↔ ∀ v, f.eval v = true` (the auxiliary invariant: `tautoAux vars v = true ↔ ∀ v' agreeing with v off vars, eval v' = true`)
- [ ] Supporting lemmas: `eval` depends only on `vars` (agreement lemma), `mem_vars` membership characterization
- [ ] `decide` smoke tests in the file: Peirce, K, and a 5-var tautology close via `by decide` on `isTaut _ = true`
- [ ] Gate: `lake build Theories.Bimodal.Metalogic.Decidability.Propositional.PropForm` green, zero `sorry`

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Propositional/PropForm.lean` (new, ~180 lines)

**Verification**:
- `lake build` green; `grep -c sorry` returns 0 for the new file
- Smoke `example : ... := by decide` compiles (proves kernel reducibility without `native_decide`)

---

### Phase 2: Kalmar prerequisites — negated-implication helper + literal machinery [NOT STARTED]

**Goal**: The single new object-level lemma plus the `litCtx`/`litDenote` definitions and their simp/membership/weakening toolkit, so the Phase 3 induction is mechanical.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (imports PropForm, Derivable, DeductionTheorem, Theorems/Propositional)
- [ ] FIRST tool calls: verify usable general weakening for `DerivationTree` contexts (`ProofSystem/Derivation.lean`, cf. `weakening_height_succ` :237) and confirm `Derivable.weaken` (`Derivable.lean:140`) covers the Prop side; record findings in a file comment
- [ ] Prove the ONE new object-level lemma `neg_imp_intro : ⊢ φ.imp (ψ.neg.imp (φ.imp ψ).neg)` via `ni` (from `(φ.imp ψ) :: Γ' ⊢ ψ` with `⊢ ψ.neg` weakened) + `deduction_theorem` (~10-20 lines; noncomputable def is acceptable)
- [ ] Define `litDenote (env) (v) (f : PropForm) : Formula := if f.eval v then f.denote env else (f.denote env).neg`
- [ ] Define `litCtx (env) (v) (vars : List Nat) : List Formula := vars.map (fun n => if v n then env n else (env n).neg)`
- [ ] `simp` lemmas for `litDenote` true/false branches and `litCtx` cons/membership (avoid raw if-then-else leaking into the induction)
- [ ] Literal-membership lemma: `n ∈ vars → litDenote env v (.var n) ∈ litCtx env v vars`
- [ ] Context-agreement lemma: `litCtx` unchanged under valuation update at a var not in the list (needed for head-variable elimination in Phase 4)
- [ ] Gate: `lake build` green, zero `sorry`

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (new, first ~120 lines of eventual ~400)

**Verification**:
- `lake build` green; `neg_imp_intro` sorry-free; `lean_verify` on it shows no new axioms
- `simp [litDenote]`/`simp [litCtx]` close branch-normalization test examples in the file

---

### Phase 3: Kalmar step lemma (main induction) [NOT STARTED]

**Goal**: `kalmar_step` proved sorry-free by induction on `PropForm` — the hard core of the task.

**Tasks**:
- [ ] State `kalmar_step (f : PropForm) (env : Nat → Formula) (v : Nat → Bool) (vars : List Nat) (hsub : f.vars ⊆ vars) : (litCtx env v vars) ⊢ (litDenote env v f)` (noncomputable def, tree-valued; Prop corollary via `Nonempty.intro`)
- [ ] Case `var n`: `DerivationTree.assumption` using the Phase 2 literal-membership lemma
- [ ] Case `fls`: `eval = false` always; goal is `Γ ⊢ ⊥.imp ⊥` — weakened `identity` (Theorems/Combinators)
- [ ] Case `imp f g`, subcase `g.eval v = true`: from IH `Γ ⊢ ψ` get `Γ ⊢ φ.imp ψ` via `prop_s` axiom + mp
- [ ] Case `imp f g`, subcase `f.eval v = false`: from IH `Γ ⊢ ¬φ` get `Γ ⊢ φ.imp ψ` via flipped `raa` (`theorem_flip` from Combinators on `raa : ⊢ A.imp (A.neg.imp B)`) / `ecq`
- [ ] Case `imp f g`, subcase `f.eval v = true, g.eval v = false`: from IHs `Γ ⊢ φ` and `Γ ⊢ ¬ψ` get `Γ ⊢ ¬(φ.imp ψ)` via Phase 2's `neg_imp_intro` + two mps
- [ ] Keep every case pinned to `litDenote` simp normal forms; no `sorry` placeholders survive the phase
- [ ] Gate: `lake build` green, `lean_verify` on `kalmar_step` (no new axioms)

**Timing**: 6 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (extend, ~150 lines added)

**Verification**:
- `lake build` green; `kalmar_step` compiles with all three imp subcases discharged
- `lean_verify` reports only the standard axioms already accepted by the project (i.e., none new)

---

### Phase 4: Variable elimination + tautology_derivable [NOT STARTED]

**Goal**: Complete the Kalmar argument: eliminate variables one at a time with `deduction_theorem` + `classical_merge`, yielding the schematic main theorem.

**Tasks**:
- [ ] Variable-elimination lemma by induction on `vars`: for head var `n`, instantiate `kalmar_step` at `v[n] := true` and `v[n] := false`, apply `deduction_theorem` to each (moving the head literal into an implication — head-elimination avoids permutation lemmas), then `classical_merge (env n) (f.denote env)` + two `mp`s
- [ ] Check whether `classical_merge` (`Connectives.lean:43`) is stated at general `{fc}` or fixed at Base; if Base-only, lift via `DerivationTree.lift` or state the elimination at Base and generalize the final result
- [ ] Main theorem (tree-valued): `noncomputable def tautology_derivable' (f) (h : f.isTaut = true) (env) : ⊢ f.denote env` (using `isTaut_iff_forall_eval` from Phase 1 to feed the elimination)
- [ ] Prop interface: `theorem tautology_derivable (f) (h : f.isTaut = true) (env) : |-! f.denote env`
- [ ] Generalize to `⊢[fc]` where the lift permits (propositional axioms have `minFrameClass = Base ≤ fc`); document any Base-only residue
- [ ] Sanity examples in-file: derive `⊢ A.imp (B.imp A)` and `⊢ ((□A).imp (□A))` for free variables `A B : Formula` by manual reification (no tactic yet)
- [ ] Gate: `lake build` green, zero `sorry`, `lean_verify` on `tautology_derivable`

**Timing**: 4 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (extend to final ~400-450 lines)

**Verification**:
- `lake build` green; the two schematic sanity examples compile
- `lean_verify tautology_derivable` shows no new axioms (kernel-only pipeline confirmed)

---

### Phase 5: Concrete decidability — reify, truth lemma, Decidable instance [NOT STARTED]

**Goal**: The publishable completeness claim: `Decidable (|-! p)` for concrete propositional formulas, with the falsity direction via trivial-frame countermodel through the EXISTING soundness theorem (no tableau verification).

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Decidability/Propositional/Decidable.lean`
- [ ] `Formula.isPropositional : Formula → Bool` (atom/bot/imp only)
- [ ] Computable `Formula.reify (p : Formula) : PropForm × (Nat → Formula)` via `p.atoms` (`Formula.lean:700`) with a round-trip lemma `(p.reify).1.denote (p.reify).2 = p` under `isPropositional p = true`
- [ ] Trivial-model truth lemma by 3-case induction (atom/bot/imp; box/untl/snce dismissed by `isPropositional`): at `D := ℤ`, `F := TaskFrame.trivial_frame`, `M.valuation := fun _ a => v a = true`, `τ := WorldHistory.universal_trivialFrame ()`, `Omega := Set.univ`, prove `truth_at M univ τ t q ↔ eval v (reify q) = true`; atom case reduces to `∃ ht : True, v a = true` via the total domain
- [ ] Completeness direction `derivable_tautology (p) (hp : isPropositional p = true) (h : |-! p) : (p.reify).1.isTaut = true`: from a falsifying assignment `v`, instantiate `Soundness.lean:1023` at `Γ = []` with the model above and derive the contradiction
- [ ] `def instDecidableDerivable (p) (hp : p.isPropositional = true) : Decidable (|-! p)` — hypothesis-carrying `def`, NOT a typeclass instance (side-conditioned instances don't fire reliably); dispatch on `(p.reify).1.isTaut` using `tautology_derivable` + round-trip for the true branch and `derivable_tautology` (contrapositive) for the false branch
- [ ] Gate: `lake build` green, zero `sorry`, `lean_verify` (no new axioms; `Classical.choice` from existing soundness machinery is acceptable — no `ofReduceBool`)

**Timing**: 6 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Decidable.lean` (new, ~250 lines)

**Verification**:
- `lake build` green; an in-file `example` decides a concrete tautology and a concrete non-tautology (e.g., `p.imp q` underivable) via `instDecidableDerivable`

---

### Phase 6: prop_decide tactic, tests, wiring [NOT STARTED]

**Goal**: User-facing `prop_decide` tactic (reify → `decide` → apply), test suite, and umbrella import wiring; task 192 pointer documented.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/Tactics/PropDecide.lean`, mirroring the elab pattern of `Automation/Tactics/Commands.lean:104-160`
- [ ] Goal-shape handling: accept `⊢ φ` (`DerivationTree .Base [] φ`), `⊢[fc] φ`, and `|-! φ` (route to tree-valued def or Prop theorem respectively)
- [ ] Reification metaprogram: recurse through `Formula.imp`/`Formula.bot` syntactically; assign each maximal non-imp/bot subterm (atom, box, untl, snce, opaque variable) a fresh var index; dedup by structural `Expr` equality after `whnf` (NOT `isDefEq`); build `env` as closed function `fun n => match n with | 0 => e₀ | ... | _ => Formula.bot`
- [ ] Assert `f.isTaut = true` and close with kernel `decide` (f is closed — always reduces); NEVER emit `native_decide`
- [ ] Apply `tautology_derivable'`/`tautology_derivable` with `f`, the `decide` proof, and `env`
- [ ] Create `Tests/BimodalTest/Metalogic/PropDecideTest.lean` (~120 lines): `prop_decide` closes lem, Peirce, raa, De Morgan-style, and schematic-modal goals (`⊢ (□A).imp (□A)`, goals mixing `untl`/`snce` opaquely, `⊢[fc]` shape, `|-!` shape); plus `instDecidableDerivable` checks on concrete formulas
- [ ] Wire umbrella imports: `Theories/Bimodal/Metalogic/Decidability.lean` gains the three `Propositional/*` imports; `Automation/Tactics` umbrella gains `PropDecide`; register the test file per `Tests/BimodalTest` convention
- [ ] Docstring/README note in `PropDecide.lean` header pointing task 192 (`tm_prove` dispatch): route propositional-skeleton goals to `prop_decide` first, then fall back to `modal_search`/tableau
- [ ] Gate: full `lake build` green (whole project, not just new targets), zero `sorry`, `lean_verify` on tactic-produced terms in tests

**Timing**: 5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/PropDecide.lean` (new, ~150 lines)
- `Tests/BimodalTest/Metalogic/PropDecideTest.lean` (new, ~120 lines)
- `Theories/Bimodal/Metalogic/Decidability.lean` (imports, ~3 lines)
- `Automation/Tactics` umbrella import file (~2 lines)

**Verification**:
- Full `lake build` green including tests; every listed test goal closes via `prop_decide`
- `#print axioms` / `lean_verify` on a test theorem confirms no `Lean.ofReduceBool` (kernel decide only)

## Testing & Validation

- [ ] Full `lake build` green after every phase (per-phase gate) and for the whole project at Phase 6
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/Decidability/Propositional/ Theories/Bimodal/Automation/Tactics/PropDecide.lean` returns nothing at each phase end
- [ ] `lean_verify` on `neg_imp_intro`, `kalmar_step`, `tautology_derivable`, `instDecidableDerivable`, and one tactic-produced test theorem: no new axioms, no `ofReduceBool`
- [ ] Schematic coverage: `prop_decide` closes `∀ A B : Formula, ⊢ A.imp (B.imp A)` and `⊢ (□A).imp (□A)` with free formula variables
- [ ] Concrete coverage: `instDecidableDerivable` returns `isTrue` on a concrete tautology and `isFalse` on a concrete non-tautology
- [ ] Kernel-`decide` performance sanity: a 5-var tautology (32 assignments) checks instantly

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Decidability/Propositional/PropForm.lean` (~180 lines)
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (~400-450 lines)
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Decidable.lean` (~250 lines)
- `Theories/Bimodal/Automation/Tactics/PropDecide.lean` (~150 lines)
- `Tests/BimodalTest/Metalogic/PropDecideTest.lean` (~120 lines)
- Umbrella import edits: `Theories/Bimodal/Metalogic/Decidability.lean`, `Automation/Tactics` umbrella (~5 lines)
- `specs/191_propositional_decision_procedure/summaries/02_reflection-kalmar-summary.md` (on completion)

## Rollback/Contingency

- All work is in NEW files plus ~5 lines of umbrella imports; rollback = delete the four new source files + test file and revert the import edits (no existing proofs are touched).
- Commit per green phase (`task 191 phase {P}: {name}`), so any failed phase reverts to the previous green commit without losing earlier phases.
- If Phase 3's `imp` induction stalls: the only escape hatches are strengthening Phase 2 machinery (more `litDenote` simp lemmas, weakening helpers) — do NOT introduce `sorry` or axioms; if genuinely blocked, mark the phase [BLOCKED] and surface via /spawn rather than degrading the zero-debt guarantee.
- If scope must shrink under time pressure: cut Phase 5 (concrete `Decidable`), keeping Phases 1-4 + 6 (the `prop_decide` tactic is the high-value deliverable); the wave table already isolates Phase 5.
