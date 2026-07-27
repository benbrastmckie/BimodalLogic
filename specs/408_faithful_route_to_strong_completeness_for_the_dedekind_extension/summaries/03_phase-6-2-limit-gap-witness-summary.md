# Phase 6.2 — The definable-gap discharge of LimitFutureWitness

- **Plan**: `plans/03_strong-completeness-dedekind-v3.md`, Phase 6.2
- **Status**: `[COMPLETED]`
- **Date**: 2026-07-27

## What landed

### 1. Predicate repair (`Bundle/RealExtensionBundle.lean`)

`BFMCS.LimitFutureWitness` now restricts its real quantifier to **unselected** points:

```lean
def BFMCS.LimitFutureWitness {fc : FrameClass} (B : BFMCS (fc := fc) Rat) (root : Formula) :
    Prop :=
  ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ φ : Formula,
    φ ∈ deferralClosure root →
    Formula.someFuture φ ∈ limitMCSBelow fam.mcs r → ∃ s : Rat, r < (s : ℝ) ∧ φ ∈ fam.mcs s
```

The all-`r` form is false: at `r = (p : ℝ)` where `S_φ = {q | φ ∈ m q}` attains a maximum, the
hypothesis holds and the conclusion fails. The sole consumer,
`BFMCS.toRealBundle_restricted_temporally_coherent`, already carries `hx` in scope inside its
unselected branch, so the call site changed by one argument (`… (t + δ) hx φ hdc hFφ'`). No other
line of that file changed apart from the predicate's docstring, which retains the original
counterexample paragraph verbatim and adds the unselectedness rationale plus the pointer to the
discharge.

### 2. The general gap lemma

`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGapWitness.lean` (new, 209 lines),
namespace `FormalSystem.Metalogic.BXCanonical.Chronicle`:

- `limitFutureWitness_of_priorU` — takes `(hfc : FrameClass.Dedekind ≤ fc)`, unrestricted Until
  coherence in both directions, an unselected `r`, and `F φ ∈ limitMCSBelow m r`; produces a
  rational strictly above `r` carrying `φ`.
- `cantor_bfmcs_dense_limit_future_witness` — the instantiation at `cantorBfmcsDense`.

The proof is Reynolds 1992's Theorem 3 argument (printed p.176) applied at `χ := F φ` rather
than at `φ`: `χ`'s truth region below the gap is the interval `(-∞, r)`, so the Prior-U
antecedent `U(⊤, χ)` is free — the exact step that was unavailable at the `φ` level, where the
`φ`-points merely accumulate. Steps C–D follow Reynolds' Lemma 3 (printed p.178). The obligation
being discharged is Burgess 1984's prophecy-at-a-gap claim (printed pp.109–110), whose own proof
routes through a continuity axiom, which is why the obligation cannot be dissolved by changing
the limit construction.

Four named steps, as the plan required:

| Step | Content |
|---|---|
| A | `χ ∈ m q` for every rational `q` with `(q : ℝ) < r`, via `limitMCSBelow_cofinal_below` |
| B | `χ.neg ∈ m u` for every rational `u` with `r < (u : ℝ)`, via negation completeness |
| C | The Prior-U consequent at each rational below `r`: `conj_mcs` + `theorem_in_mcs (DerivationTree.axiom [] _ (Axiom.prior_U_gap χ) hfc)` + `implication_property` |
| D | Contradiction: the Until witness `u` must lie below `r`, where Step A gives `χ`, forcing `K⁺(¬χ)` at `u`; but `hUb` on `(u, r)` supplies the `U(⊤, ¬¬χ)` that `K⁺(¬χ)` excludes |

Irrationality of `r` is consumed exactly twice, as predicted: Step A (upgrading `(s : ℝ) ≤ r` to
`<`) and Step D (excluding `(u : ℝ) = r`).

### 3. The self-root instantiation

`cantor_bfmcs_dense_restricted_fuc` / `_buc` are polymorphic in `root` and their proofs discard
the closure-membership argument, because the underlying resolution lemmas take formula arguments
unconstrained. Instantiating at `root := Formula.untl α β` and discharging the side condition
with `self_mem_subformulaClosure` recovers **unrestricted** Until coherence for the Cantor dense
chronicle. It elaborated with no signature friction. **No chronicle declaration was modified.**

## Verification

| Check | Result |
|---|---|
| `lake build` (full) | green, 1900 jobs |
| `#print axioms limitFutureWitness_of_priorU` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms cantor_bfmcs_dense_limit_future_witness` | `[propext, Classical.choice, Quot.sound]` |
| Live sorries outside `Boneyard/` | exactly 1, at `WeakCanonical/Transfer.lean:1242` (unchanged baseline) |
| New sorries | 0 |
| Vacuous definitions introduced | 0 |
| New axioms | 0 |

## Additions beyond the task list

Both forced by the proof, neither a design change:

- `htop : ∀ q, Formula.top ∈ m q` via `identity (fc := fc) Formula.bot`, since `⊤`-guards are
  needed at four `hUb` call sites.
- `hSFf` / `hSFb`, the specialisations of `hUf` / `hUb` to `someFuture` (`F ψ = U(ψ, ⊤)`), which
  is the form Steps A–C actually consume.

`push Not` was used in place of the now-deprecated `push_neg`.

## Deviation

The plan named `FormalSystem/Metalogic/BXCanonical/Chronicle.lean` as the import-line target. No
such aggregator exists; the aggregator for the `Chronicle/` directory is
`FormalSystem/Metalogic/BXCanonical.lean`, where the one import line was added. Path correction
only — the plan's intent (pull the new module into the default target with one import line) is met
exactly. Annotated inline in the plan.

## Standing directive satisfied

The docstring of `consequence_completeness_dedekind_of_engine`
(`Metalogic/StrongCompleteness.lean`) now states the three facts explicitly and separately:
infinitary strong completeness is a *strictly different* statement; it is provably out of reach
for any finitary proof system by non-compactness (a derivation cites finitely many premises, so
strong completeness for a finitary relation entails compactness, and the Dedekind-complete
consequence relation is not compact — refuted, not merely unproved); and it is not expressible in
this tree at all, since `Context := List Formula` is the premise type of `Derivable`,
`DerivationTree`, and `SemanticConsequenceDedekindDense` alike.

## Commits

| SHA | Message |
|---|---|
| `fda1b96c9` | `task 408 phase 6.2.1: LimitFutureWitness predicate repair and call site` |
| `caa013c0c` | `task 408 phase 6.2.2: definable-gap discharge of the future-witness obligation` |
| `a269939f6` | `task 408 phase 6.2: definable-gap discharge complete` |

## What this unblocks

Phase 6.1's residual hypothesis is closed. Phase 8's `countermodel_dedekind_dense` can discharge
its `BFMCS.LimitFutureWitness` binder with `cantor_bfmcs_dense_limit_future_witness`, and its new
`(hfc : FrameClass.Dedekind ≤ fc)` hypothesis is `by decide` at the
`completeness_dedekind_engine` instantiation point.
