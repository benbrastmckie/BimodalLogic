# Escalation: `untl` / `snce` Argument Order — Paper Footnote vs. Lean Tree

**Status**: **OPEN — awaiting a user decision.** Nothing in the Lean tree is being changed either
way. This record exists so that the divergence is visible and dated rather than rediscovered by
each implementer who reads the paper's footnote and assumes the repository matches it.

**Raised by**: the total-history-validity refactor
(`specs/414_refactor_semantics_to_total_history_validity/plans/03_omega-free-totality-refactor.md`,
Phase 2), which needed to cite `def:BLplus-semantics` and found the footnote describing this
repository backwards.

---

## The claim in the paper

`def:BLplus-semantics` is now a tracked anchor in `specs/paper-definitions-of-record.md`
(sha256 `3f56a996ad17e1318eb1c448b3af7d3a5bc583785df739045ce274ba6d8be59b`). Its `\footnote`
reads, verbatim:

> `Although the axioms of \textbf{TM}$^+$ are drawn from the Burgess-Xu (BX) system, the
> repository's \texttt{snce}/\texttt{untl} constructors follow the Pnueli convention with the guard
> as the first argument and the event as the second: $\varphi\since\psi$ means $\psi$ held at some
> past time with $\varphi$ holding throughout the interval since, and $\varphi\until\psi$ means
> $\psi$ will hold at some future time with $\varphi$ holding throughout the interval until $\psi$
> holds.`

The clauses the footnote annotates, also verbatim from the same anchor:

> `\item[($\since$)] $\M,\tau,x \vDash \varphi\since\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for
> some time $z < x$ where $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $z < y < x$.`
>
> `\item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for
> some time $z > x$ where $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $x < y < z$.`

**The footnote is an accurate description of the paper's own infix notation.** In `φ S ψ` the
witnessed event is `ψ` (the second argument) and the guard is `φ` (the first). This is corroborated
inside the paper by `def:BLplus-defined` (also now tracked, sha256
`2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e`):

> `\item[\bf Past:] $\past\varphi \coloneq \top\since\varphi$.`
> `\item[\bf Future:] $\future\varphi \coloneq \top\until\varphi$.`

— guard `⊤` first, event `φ` second.

**What the footnote gets wrong is the attribution.** It asserts this is "the repository's
`snce`/`untl` constructors". It is not.

## What the Lean tree actually does

`FormalSystem/Syntax/Formula.lean:83-90` — the constructors, with their own docstrings naming the
roles explicitly:

```lean
  /-- Until U(φ, ψ) — Burgess convention: φ = event (eventually true), ψ = guard (holds in between).
      "ψ holds until φ becomes true": ∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ψ(r). -/
  | untl : Formula → Formula → Formula
  /-- Since S(φ, ψ) — Burgess convention: φ = event (was true), ψ = guard (held in between).
      "ψ has held since φ was true": ∃ s < t, φ(s) ∧ ∀ r ∈ (s,t), ψ(r). -/
  | snce : Formula → Formula → Formula
```

`FormalSystem/Semantics/Truth.lean:134-137` — the truth clauses, which are what actually binds:

```lean
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M Omega τ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M Omega τ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M Omega τ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M Omega τ r ψ
```

The **first** argument is witnessed at the existential time; the **second** is quantified over the
open interval. That is **event-first / guard-second** — the mirror image of the footnote's claim.

The *shape* of the clause matches the paper exactly (one existential on the correct side of the
evaluation point, one universal over the open interval strictly between). Only the argument roles
are swapped. This is a notational divergence, not a semantic one: every paper formula has a Lean
counterpart, obtained by swapping the two arguments.

## Why the event-first reading is load-bearing (four dependents, verified in-tree)

Flipping the Lean convention is **not** a mechanical rename. At minimum these four break, each in a
way that silently changes meaning rather than failing to compile:

| Dependent | Location | Why it depends on event-first |
|---|---|---|
| `someFuture` | `Formula.lean:131` — `def someFuture (φ) := Formula.untl φ Formula.top` | Event-first reads this as `∃ s > t, φ(s) ∧ ⊤` = "F φ", which is what the name and docstring claim. Under a guard-first reading it would instead mean "φ holds throughout some initial future interval" — a `K⁺`-shaped formula, not `F`. |
| `somePast` | `Formula.lean:141` — `def somePast (φ) := Formula.snce φ Formula.top` | Exact past mirror of the above. |
| `kPlus` (`K⁺`) | `Formula.lean:180` — `def kPlus (φ) := (Formula.untl Formula.top φ.neg).neg` | Transcribes Reynolds' `K⁺A = ¬U(⊤, ¬A)`. Event-first makes this `¬(∃ s > t, ⊤ ∧ ∀ r ∈ (t,s), ¬φ)` = "φ holds arbitrarily soon in the future" — the documented meaning (`Formula.lean:164-169`, sourced to Reynolds 1992 p.168 and GHR 1994 §10.3.1). Guard-first would collapse it to `¬F(¬φ)` = `G φ`. |
| `Axiom.dense_indicator` | `ProofSystem/Axioms.lean:354-355` — `Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg`, i.e. `¬U(⊤,⊥)` | The soundness argument at `Semantics/Validity.lean:228-231` turns on `U(⊤,⊥)` being **true on ℤ** "because every point has an immediate successor". That is the event-first reading: `∃ s > t, ⊤ ∧ ∀ r ∈ (t,s), ⊥`, satisfiable exactly when `(t,s)` is empty — a successor gap. Under guard-first, `U(⊤,⊥)` would be `∃ s > t, ⊥ ∧ …`, i.e. outright false everywhere, and the whole Dense-vs-Dedekind separation argument (`Axioms.lean:350-353`'s conservativity note, `Validity.lean:225-274`) would be vacuous. |

`kMinus` (`Formula.lean:193`) is the past dual of `kPlus` and carries the same dependency.

## The decision requested of the user

Pick one:

- **(A) Correct the paper's footnote.** Change it to describe the repository as event-first /
  guard-second (or drop the claim about "the repository's constructors" and describe only the
  paper's own infix notation, which is already accurate). The paper is **read-only ground truth
  from this repository's side** — editing it is an explicit charter non-goal here, so this can only
  be done by the user, in the paper's own repository.
- **(B) Accept the divergence as documented.** The paper keeps guard-first infix, the Lean tree
  keeps event-first prefix, and the translation is the argument swap. This record plus the caveat in
  `specs/paper-definitions-of-record.md`'s `def:BLplus-semantics` entry are the documentation.

**Not on the table:** changing the Lean convention. The four dependents above make that a semantic
rewrite of the temporal fragment (and of the Dense/Dedekind soundness argument), not a rename, for
zero mathematical gain. Any implementer who reads the footnote and "fixes" the Lean tree to match it
would be introducing four silent meaning changes.

## Until this is resolved

- Cite `def:BLplus-semantics` **with** this caveat attached. It is a tracked, drift-linted anchor,
  so if the paper's footnote is later corrected, `scripts/check-paper-definitions.sh` will report
  case (c) on that anchor and this record can be closed.
- Docstrings introduced by the total-history-validity refactor at the `untl`/`snce` clauses
  cross-reference this file.
