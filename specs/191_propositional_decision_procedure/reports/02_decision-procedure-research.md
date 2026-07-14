# Research Report: Propositional Decision Procedure (Task 191)

**Task**: #191 — Propositional fragment decision procedure
**Date**: 2026-07-14
**Session**: sess_1784042334_6ccc8d
**Supersedes/extends**: `01_decision-procedure-seed.md` (seed report; several of its codebase claims are now stale — corrected below)

## Summary

Build a **verified, reflective tautology prover**: a deep-embedded propositional formula type (`PropForm`), a computable tautology checker, and a Kalmar-style soundness proof producing object-level `DerivationTree`s. This yields (a) a `prop_decide` tactic that closes schematic propositional goals (`⊢ A.imp (B.imp A)` for arbitrary formulas `A B`, including modal/temporal subformulas treated opaquely), and (b) a genuine `Decidable (|-! p)` instance for concrete propositional formulas. All prerequisites (Prop-valued `Derivable`, deduction theorem, `classical_merge`, trivial frame, semantic soundness) already exist sorry-free in the codebase.

**Key correction to the seed report's approach**: the seed's Option A (truth-table over `Atom` + `Decidable` instance, driven by `decide`) cannot close the library's actual goals, which are *schematic* (`∀ A B : Formula, ⊢ ...`) — `decide` cannot evaluate a tautology check over free `Formula` variables. Proof-by-reflection with a meta-level reification tactic is the correct architecture; the seed's truth-table idea survives as the checker on the deep embedding.

## Current State (verified 2026-07-14)

### Prerequisites — all in place

| Item | Location | Status |
|------|----------|--------|
| Prop-valued `Derivable fc G p := Nonempty (DerivationTree fc G p)` (task 181) | `Theories/Bimodal/ProofSystem/Derivable.lean:62`, notation `G |-! p` (:80), `Derivable.weaken` (:140) | DONE |
| Deduction theorem | `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:320` (`noncomputable def deduction_theorem`) | DONE (noncomputable) |
| Kalmar merge step: `classical_merge (P Q) : ⊢ (P.imp Q).imp ((P.neg.imp Q).imp Q)` | `Theories/Bimodal/Theorems/Propositional/Connectives.lean:43` | DONE — this is exactly the case-merge lemma Kalmar's proof needs |
| Classical helpers: `lem` (Core.lean:45), `ecq : [A, A.neg] ⊢ B` (Core.lean:192), `raa : ⊢ A.imp (A.neg.imp B)` (Core.lean:252), `ni`/`ne` (context-level negation intro/elim, Reasoning.lean:41/65), `double_negation`, contraposition family | `Theories/Bimodal/Theorems/Propositional/{Core,Connectives,Reasoning}.lean` | DONE |
| Trivial single-state frame + total-domain history | `TaskFrame.trivial_frame`, `WorldHistory.universal_trivialFrame` (`Theories/Bimodal/Semantics/WorldHistory.lean:172`) | DONE — needed for the completeness direction |
| Semantic soundness `Γ ⊢ φ → Γ ⊨ φ` | `Theories/Bimodal/Metalogic/Soundness.lean:1023` | DONE |
| Formula/Atom: 6-constructor `Formula` (`Syntax/Formula.lean:70`), `Atom = {base : String, fresh_index : Option Nat}` with `DecidableEq` (`Syntax/Atom.lean:69`), `Formula.atoms : Formula → Finset Atom` (`Formula.lean:700`) | | DONE |
| Tactic infrastructure: `modal_search`, `propositional_search`, `tm_auto` elabs | `Theories/Bimodal/Automation/Tactics/Commands.lean` | DONE — pattern to copy for `prop_decide` |

Notes vs. seed report: `Theorems/Propositional.lean` (1712 lines) has been split into the directory `Theorems/Propositional/{Core,Connectives,Reasoning}.lean`; `Automation/ProofSearch.lean` is now `Automation/ProofSearch/{Core,Strategies}.lean`.

### What already exists — and why it does NOT satisfy task 191

`Theories/Bimodal/Metalogic/Decidability/` (6,637 lines, sorry-free) contains a **tableau-based semi-decision procedure** for the full bimodal logic: `decide` (DecisionProcedure.lean:122) returns `.valid proof | .invalid countermodel | .timeout`, with `ProofExtraction.lean` building real `DerivationTree`s on success. However:

- Its "decidability theorem" is `validity_decidable (φ) : (⊨ φ) ∨ ¬(⊨ φ) := Classical.em _` (Correctness.lean:72-75) — classical, not constructive.
- There is **no `Decidable` instance for `Derivable` anywhere** in the codebase (verified by grep), and no completeness/termination proof for the tableau algorithm.
- It is fuel-bounded and can time out; `decide`-the-tactic cannot use it.

So task 191's niche is intact: a *verified* (sound + complete, kernel-checkable) decision procedure for the propositional fragment. Nothing resembling `PropForm`/Kalmar/reflection exists in the repo (grep for `Kalmar|PropForm|reify|prop_decide` is empty).

## Recommended Approach: Proof by Reflection with Kalmar Soundness

### Architecture (4 components)

**1. Deep embedding + checker** (pure, computable, kernel-friendly):

```lean
inductive PropForm : Type
  | var : Nat → PropForm
  | fls : PropForm
  | imp : PropForm → PropForm → PropForm
  deriving DecidableEq, Repr

def PropForm.eval (v : Nat → Bool) : PropForm → Bool
  | .var n => v n
  | .fls => false
  | .imp f g => !f.eval v || g.eval v

def PropForm.vars : PropForm → List Nat          -- deduplicated
def PropForm.isTaut (f : PropForm) : Bool        -- fold over f.vars, branch v[n]:=true/false
```

Use `Nat` variables (NOT `Atom`): kernel `decide` reduces `Nat.decEq` fast, whereas `Atom` drags `String` equality through the kernel. `isTaut` by structural recursion on the deduplicated var list (`tautoAux : List Nat → (Nat → Bool) → Bool`) — no `Finset.pi` needed (answers seed Q3).

**2. Denotation into the object logic**:

```lean
def PropForm.denote (env : Nat → Formula) : PropForm → Formula
  | .var n => env n
  | .fls => Formula.bot
  | .imp f g => (f.denote env).imp (g.denote env)
```

**3. Kalmar soundness** (the hard part, ~60% of effort):

```lean
-- Step lemma, by induction on f:
def kalmar_step (f : PropForm) (env : Nat → Formula) (v : Nat → Bool)
    (vars : List Nat) (hsub : f.vars ⊆ vars) :
    (litCtx env v vars) ⊢ (litDenote env v f)
-- where litCtx env v vars = vars.map (fun n => if v n then env n else (env n).neg)
--       litDenote env v f = if f.eval v then f.denote env else (f.denote env).neg

-- Variable elimination, by induction on vars, then main theorem:
theorem tautology_derivable (f : PropForm) (h : f.isTaut = true)
    (env : Nat → Formula) : |-! f.denote env
```

Induction cases of `kalmar_step`:
- `var n`: `DerivationTree.assumption` (literal is in `litCtx`).
- `fls`: `eval = false` always; goal is `Γ ⊢ ¬⊥` = `Γ ⊢ ⊥.imp ⊥` = weakened `identity` (Combinators.lean).
- `imp f g`, 3 subcases by truth values:
  - `g` true: goal `Γ ⊢ φ.imp ψ` from `Γ ⊢ ψ` via `prop_s` + mp.
  - `f` false: goal `Γ ⊢ φ.imp ψ` from `Γ ⊢ ¬φ` via the `¬φ → (φ → ψ)` direction of `raa`/`ecq` (already derivable; `Theorems/Propositional/Core.lean` has the pieces — flip `raa : ⊢ A.imp (A.neg.imp B)` with `theorem_flip` from Combinators).
  - `f` true, `g` false: goal `Γ ⊢ ¬(φ.imp ψ)` from `Γ ⊢ φ` and `Γ ⊢ ¬ψ`. Needs one **new helper**: `⊢ φ.imp (ψ.neg.imp (φ.imp ψ).neg)` — derivable in ~10-20 lines via `ni` (from `(φ→ψ) :: Γ' ⊢ ψ` and `⊢ ¬ψ` weakened) + `deduction_theorem`. This is the only genuinely new object-level lemma required.

Variable elimination: for the head var `n` of the list, instantiate `kalmar_step` with `v[n]:=true` and `v[n]:=false`, apply `deduction_theorem` to each to move the literal into an implication, then `classical_merge (env n) (f.denote env)` + two `mp`s. `classical_merge` was evidently built for exactly this.

Because `env : Nat → Formula` is universally quantified, **the result is fully schematic**: components mapped to `□A`, `U(A,B)`, or arbitrary formulas work automatically. No `isPropositional` gate and no substitution lemma needed for the tactic path. This strictly subsumes the seed's Option A and also closes goals like `⊢ (□A).imp (□A)` that Option A cannot express.

Computability note: `deduction_theorem` is `noncomputable`, so `kalmar_step`/`tautology_derivable` are `noncomputable def`s when tree-valued. Recommendation: state the main results tree-valued (`Nonempty (⊢ ...)` or noncomputable `⊢ ...`) and provide both interfaces — a noncomputable `def` for `⊢ φ` (Type) goals and a `theorem` for `|-! φ` (Prop) goals. Existing library goals are `⊢ φ` (Type), so the tactic will close them with the noncomputable def (fine — `lem`, `classical_merge` etc. are already `def`s whose bodies use `deduction_theorem`).

**4a. Tactic `prop_decide`** (meta-level, in `Automation/Tactics/`):
1. Parse goal: accept `⊢ φ` (`DerivationTree .Base [] φ`), `⊢[fc] φ`, and `|-! φ` shapes.
2. Reify `φ` into `(f : PropForm) × (env : Nat → Formula)`: recurse through `imp`/`bot` syntactically; assign each maximal non-imp/bot subterm (atom, box, untl, snce, or opaque variable `A`) a fresh var index, deduplicating by `Expr` equality. Build `env` as a closed function `fun n => match n with | 0 => e₀ | 1 => e₁ | _ => Formula.bot`.
3. Assert `f.isTaut = true` and close it `by decide` (f is a closed literal term — always reduces).
4. Apply `tautology_derivable` (or the tree-valued variant) with the two arguments.

Use **kernel `decide`, not `native_decide`**: `native_decide` introduces the `Lean.ofReduceBool` axiom, which the project's zero-axiom policy and `lean_verify` checks would flag (answers seed Q2). Performance is a non-issue: library tautologies have ≤ 5 distinct components → ≤ 32 assignments (answers seed Q1).

**4b. `Decidable` instance for concrete propositional formulas** (the "verified decision procedure" deliverable):

```lean
def Formula.isPropositional : Formula → Bool   -- atom/bot/imp only
def Formula.reify (p : Formula) : PropForm × (Nat → Formula)  -- computable, via p.atoms

-- Completeness direction:
theorem derivable_tautology (p : Formula) (hp : p.isPropositional = true)
    (h : |-! p) : (p.reify).1.isTaut = true

def instDecidableDerivable (p : Formula) (hp : p.isPropositional = true) :
    Decidable (|-! p) := ...
```

Completeness proof route (semantic, cheap — do NOT prove algorithmic tableau completeness):
given an assignment `v` falsifying `p`, instantiate the existing soundness theorem (Soundness.lean:1023, `Γ = []`) at `D := ℤ`, `F := TaskFrame.trivial_frame`, `M.valuation := fun _ a => v a = true`, `τ := WorldHistory.universal_trivialFrame ()`, `Omega := Set.univ` (trivially `ShiftClosed`, Truth.lean:327). Prove a 3-case truth lemma `truth_at M univ τ t q ↔ eval v (reify q) = true` by induction restricted to atom/bot/imp (the `box/untl/snce` cases are dismissed by `isPropositional`). The atom case is `∃ ht : True, v a = true` — trivial with the total domain of `universal_trivialFrame`. Contradiction with validity.

Answer to seed Q5: use an explicit hypothesis-carrying `def` (not a typeclass instance) — instances with `isPropositional p = true` side conditions don't fire reliably; users reach decidability through `prop_decide` anyway.

### Rejected alternatives

- **Verify the existing tableau** (`Metalogic/Decidability/`): would require termination + algorithmic completeness proofs for the full bimodal tableau — an order of magnitude more work, and still fuel-bounded. Keep it as the semi-decision fallback for modal goals (task 192 dispatch).
- **Truth-table over `Atom` with `Decidable` + bare `decide`** (seed Option A as stated): fails on schematic goals (free `Formula` metavariables don't reduce); `String`-keyed kernel evaluation is slower; still delivered as component 4b, but via `PropForm`.
- **Analytic tableau for the propositional fragment** (seed Option B): unnecessary — at ≤ 5 vars the 2^n checker is instant, and Kalmar gives the derivation-construction for free.

## Concrete File Targets

| File | Content | Est. size |
|------|---------|-----------|
| `Theories/Bimodal/Metalogic/Decidability/Propositional/PropForm.lean` (new) | `PropForm`, `eval`, `vars`, `isTaut`, `denote`, eval/denote lemmas | ~180 lines |
| `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (new) | neg-imp helper lemma, `litCtx`/`litDenote`, `kalmar_step`, var elimination, `tautology_derivable` | ~350-450 lines |
| `Theories/Bimodal/Metalogic/Decidability/Propositional/Decidable.lean` (new) | `isPropositional`, `reify`, trivial-model truth lemma, `derivable_tautology`, `instDecidableDerivable` | ~250 lines |
| `Theories/Bimodal/Automation/Tactics/PropDecide.lean` (new) | reification metaprogram + `prop_decide` elab (mirror the elab pattern of `Commands.lean:104-160`) | ~150 lines |
| `Theories/Bimodal/Metalogic/Decidability.lean`, `Automation/Tactics/` umbrella imports | wire-up | ~5 lines |
| `Tests/BimodalTest/...PropDecideTest.lean` (new) | `prop_decide` on lem/peirce/raa/de-morgan/schematic-modal goals; `Decidable` instance on concrete formulas | ~120 lines |

## Suggested Phasing (~30-40h total, matches seed estimate)

1. **PropForm + checker** (4-6h): definitions, `isTaut_iff_forall_eval` characterization lemma, `decide`-reducibility smoke tests.
2. **Kalmar step lemma** (10-14h, hard part): the one new object lemma `⊢ φ.imp (ψ.neg.imp (φ.imp ψ).neg)`, `litCtx` machinery (membership/weakening — reuse `Derivation.lean` weakening, `Derivable.weaken`), `kalmar_step` induction.
3. **Variable elimination + `tautology_derivable`** (4-6h): `deduction_theorem` + `classical_merge` composition.
4. **Concrete decidability** (6-8h): `reify`, trivial-model truth lemma, `derivable_tautology`, `instDecidableDerivable`.
5. **`prop_decide` tactic + tests + docs** (4-6h): reification elab, goal-shape handling (`⊢`/`|-!`), test suite, README note pointing task 192 at the new entry point.

Phases 4 and 5 are independent of each other (both depend on 1-3) and can be reordered; if scope must shrink, Phase 4 is the cut candidate (the tactic is the high-value deliverable; the `Decidable` instance is the publishable completeness claim).

## Risks / Verification Notes

- **Noncomputability contagion**: `deduction_theorem` is noncomputable → Kalmar defs are noncomputable. Acceptable: results are proofs, never executed. Document in module header.
- **`litCtx` bookkeeping**: Kalmar contexts change as variables are eliminated; keep `litCtx` list-ordered to match `deduction_theorem`'s `(A :: Γ)` convention and eliminate the *head* variable each round to avoid permutation lemmas. Verify early (Phase 2, first tool calls) that `DerivationTree` weakening in `ProofSystem/Derivation.lean` (cf. `weakening_height_succ` at :237) has a usable general form; `Derivable.weaken` (Derivable.lean:140) covers the Prop side.
- **`if-then-else` in the step lemma statement**: wrap in `litDenote` def and prove `simp` lemmas for the true/false branches, otherwise the induction gets ugly.
- **Reification determinism**: dedup opaque subterms by definitional `Expr` comparison (`isDefEq` can loop on metavariables; plain structural equality after `whnf` suffices here).
- **Frame class generality**: state everything at `{fc : FrameClass}` (propositional axioms have `minFrameClass = Base ≤ fc`), so `prop_decide` also closes `⊢[fc] φ` goals. `classical_merge` is stated at Base — check whether it generalizes or lift via `DerivationTree.lift`.
- **Zero-debt**: no step above requires `sorry` or new axioms; every listed prerequisite was verified present and sorry-free in the current tree.

## Dependencies

- **Consumed (all DONE)**: task 181 (`Derivable`), `DeductionTheorem.lean`, `Theorems/Propositional/*`, `Soundness.lean`, `trivial_frame`/`universal_trivialFrame`.
- **Consumers**: task 192 (`tm_prove` master dispatch) should route propositional-skeleton goals to `prop_decide` first, then fall back to `modal_search`/tableau.

## References

- `specs/191_propositional_decision_procedure/reports/01_decision-procedure-seed.md` — seed report
- `Theories/Bimodal/ProofSystem/Axioms.lean` — `prop_k`, `prop_s`, `ex_falso`, `peirce` (complete Hilbert basis for CPL)
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean:72` — existing classical-only decidability (the gap this task fills)
- Kalmar, L. (1935) — completeness proof by truth-table cases; textbook form in Mendelson, *Introduction to Mathematical Logic*, Lemma 1.13/Prop 1.14
- Mathlib reflection precedents: `Mathlib.Tactic.Ring` (reify-check-apply architecture); Lean core `decide` kernel reduction
