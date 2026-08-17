# Decision: `untl` / `snce` Argument Order — Paper Footnote vs. Lean Tree

**Status**: **DECIDED (2026-08-17) — the Lean tree was aligned to the paper.** `Formula.untl` and
`Formula.snce` now take the **guard first and the event second**, matching
`def:BLplus-semantics`'s `(since)` / `(until)` clauses and the already-guard-first Typst manual.
The change was a uniform argument swap of the two constructors and every call site — 3,711
occurrences across 152 files of live scope — carried out as a rename-forced migration so that any
unmigrated reference became a hard compiler error rather than a silent meaning change.

This resolves the divergence in the direction the record below said was "not on the table". The
reasoning that put it off the table was wrong, and is **explicitly retracted** in its own section
below rather than deleted, so that a future reader does not rediscover it as live reasoning.

**Raised by**: the total-history-validity refactor
(`specs/414_refactor_semantics_to_total_history_validity/plans/03_omega-free-totality-refactor.md`,
Phase 2), which needed to cite `def:BLplus-semantics` and found the footnote describing this
repository backwards.

**Resolved by**: the guard-first migration
(`specs/448_migrate_snce_untl_to_guard_first_order/plans/01_guard-first-migration.md`).

---

## What was decided, and what it cost

Neither option (A) nor option (B) offered below was taken. A third option — the one the record
declared out of scope — was taken instead: **change the Lean convention**, leaving the paper
untouched as read-only ground truth.

The migration is **meaning-preserving by construction**. A uniform swap of a binary constructor's
two arguments, applied to the definition and to every site that builds or destructures it, is an
isomorphism on the term algebra; no phase introduced a `sorry` and no proof changed shape.

Verified outcome:

| Gate | Result |
|---|---|
| `lake build` | green, 2,457 jobs, exit 0 — identical job count to the pre-migration baseline |
| Per-file `sorry` census | byte-identical to `baseline/sorry-baseline.txt` — 335 occurrences across 98 files, zero delta |
| Axiom declarations | unchanged at 7 in live scope (9 repo-wide) |
| Gate A — role-keyed `toJson` oracle | regenerated `machine-appendix.jsonl` byte-identical to the pre-migration baseline apart from the metadata stamp line |
| Gate B — `schema_string` | byte-identical with **no** transform applied (see below) |
| `untlQ` / `snceQ` migration residue | 0 |
| `scripts/typst-sync-check.sh` | PASS on all three checks |

Gate B is worth recording precisely because the plan predicted otherwise. `prettyPrint` is
positional (`U(event, guard)` prefix), so the plan expected every `U(a,b)` to become `U(b,a)` and
budgeted a documented transform before comparison. Measured: the transform is the **identity**,
because `prettyPrint` was made role-stable rather than left positional
(`| .untl ψ φ => "U(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"`,
`Automation/DataExport.lean:138-139`). It still emits the event first — it now reads the event out
of the second constructor position. Both oracles therefore reduce to byte-identity.

## Three renderings now coexist, and each is named where it appears

The single most confusing thing about this area, before and after the migration, is that the
codebase carries three different orderings of the same two roles. All three are legitimate; the
defect was never that they differed but that comments named a "convention" without saying which
rendering they meant. Each site now says so explicitly.

| Rendering | Order | Where it comes from |
|---|---|---|
| `untl(g, e)`, `snce(g, e)` | **guard** first, event second | the constructor's own argument order (`Syntax/Formula.lean`), matching `def:BLplus-semantics` |
| `U(e, g)`, `S(e, g)` (prefix) | **event** first, guard second | `Formula.prettyPrint`'s output, the `schema_string` field of the machine appendix, and `asUntil?`/`asSince?`'s returned pair |
| `φ U ψ`, `φ S ψ` (infix) | **guard** first, event second | the paper's and the Typst manual's infix notation |

The prefix form is deliberately *not* the constructor order. Flipping it to match — or switching
`prettyPrint` to infix `(φ U ψ)` to match the manual — is a dataset-format change with downstream
consumers, and is explicitly deferred (see "Deferred consequences" below).

---

## The claim in the paper

**The footnote this record was raised about has been retired and is no longer quoted here.** It
lived on the `3f56a996…` wave of `def:BLplus-semantics`, was revised by the paper on the
`f40f514e…` wave, and was removed outright on the live `edde7517…` wave (2026-08-17). Described
rather than quoted: it asserted that the repository's `snce`/`untl` constructors put the guard
first and the event second, and — correctly — that the paper's own infix `$\varphi\since\psi$`
does the same. Its defect was the attribution: at the time, the Lean tree did the opposite. Both
halves are now moot, the first because the sentence is gone and the second because the tree was
migrated to match. The verbatim text survives only in frozen task archives
(`specs/archive/414_…/reports/03_total-history-validity-refactor.md` and
`specs/archive/444_…/definitions-of-record-444.md`), which are historical records of completed
work and are deliberately not rewritten.

The clauses the footnote annotated — still live, and unchanged byte-for-byte across all three
waves — verbatim from the current anchor
(sha256 `edde75176efc0936c96f8d9eb18628929c2dd3bdb1aa1c21d4a88af90276314a`):

> `\item[($\since$)] $\M,\tau,x \vDash \varphi\since\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for
> some time $z < x$ where $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $z < y < x$.`
>
> `\item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for
> some time $z > x$ where $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $x < y < z$.`

**The paper's own infix notation is guard-first, and always was.** In `φ S ψ` the witnessed event
is `ψ` (the second argument) and the guard is `φ` (the first). This is corroborated inside the
paper by `def:BLplus-defined` (also tracked, sha256
`2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e`):

> `\item[\bf Past:] $\past\varphi \coloneq \top\since\varphi$.`
> `\item[\bf Future:] $\future\varphi \coloneq \top\until\varphi$.`

— guard `⊤` first, event `φ` second.

**This is the convention the Lean tree now follows**, and `def:BLplus-defined`'s four derived
operators match the Lean definitions character for character: `somePast φ = snce ⊤ φ`,
`someFuture φ = untl ⊤ φ`, `next φ = untl ⊥ φ`, `prev φ = snce ⊥ φ`. At the time this record was
raised, the tree did the opposite — see the historical section below.

## What the Lean tree did before the migration (historical)

**This section describes the pre-migration tree and is retained as the record of what was
escalated.** The code quoted below no longer exists; see "What was decided" above for the current
state. As of 2026-08-17 the constructors read `| untl : Formula → Formula → Formula` with the
docstring "**Argument 1 is the guard, argument 2 is the event**", and `TruthAt`'s clauses read
`| Formula.untl ψ φ => ∃ s, t < s ∧ TruthAt … s φ ∧ ∀ r, t < r → r < s → TruthAt … r ψ` —
guard-first, matching the paper.

`FormalSystem/Syntax/Formula.lean:83-90` — the constructors as they then stood, with their own
docstrings naming the roles explicitly:

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

## ~~Why the event-first reading is load-bearing (four dependents, verified in-tree)~~ — RETRACTED

> **RETRACTED 2026-08-17. The argument below is wrong. It is preserved, struck through, because a
> reader who deletes it would be liable to reconstruct it.**
>
> **The error**: each row evaluates a dependent's *current, unswapped text* under a *guard-first
> reading*. That is not what a uniform swap does. A uniform swap rewrites the definition **and**
> every call site together, so `someFuture φ = untl φ ⊤` does not become "`untl φ ⊤` read
> guard-first" (which would indeed be a `K⁺`-shaped formula) — it becomes `someFuture φ = untl ⊤ φ`,
> whose guard-first reading is exactly `F φ`, the meaning the name and docstring always claimed.
> The same correction applies to all four rows. Each dependent was never an obstacle; each was
> simply one more site to swap. The measured outcome bears this out: the migration touched 3,711
> occurrences across 152 files, changed no proof, introduced no `sorry`, and left the role-keyed
> `toJson` oracle byte-identical.
>
> **Row by row, what actually happened**:
>
> - `someFuture` — now `def someFuture (φ) := Formula.untl Formula.top φ`. Guard-first reads
>   `∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ⊤`, i.e. `F φ`. Matches `def:BLplus-defined`'s
>   `\future φ := ⊤ \until φ` character for character — which the *old* form did not.
> - `somePast` — now `Formula.snce Formula.top φ`; the exact past mirror, matching
>   `\past φ := ⊤ \since φ`.
> - `kPlus` — now `(Formula.untl φ.neg Formula.top).neg`, still transcribing Reynolds'
>   `K⁺A = ¬U(⊤, ¬A)`. The claim that guard-first "would collapse it to `G φ`" is the same error:
>   the operand moved into the guard position along with the swap, so the documented meaning is
>   preserved exactly. `kMinus` likewise.
> - `Axiom.dense_indicator` — now `(Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg`,
>   i.e. `¬(⊥ U ⊤)` guard-first: `∃ s > t, ⊤ ∧ ∀ r ∈ (t,s), ⊥`, satisfiable exactly when `(t,s)` is
>   empty. That is the *same* successor-gap condition the soundness argument turns on. The
>   Dense-vs-Dedekind separation is untouched and the whole argument remains non-vacuous.
>
> The generalisation worth keeping: **a uniform swap of a binary constructor's arguments across its
> definition and all of its uses cannot change meaning.** Any argument that it does must be
> holding some sites fixed while swapping others, and is therefore an argument about a
> *half-finished* migration, not about the migration.

The original argument follows, struck through.

~~Flipping the Lean convention is **not** a mechanical rename. At minimum these four break, each in a
way that silently changes meaning rather than failing to compile:~~

| Dependent | Location | Why it depends on event-first |
|---|---|---|
| `someFuture` | `Formula.lean:131` — `def someFuture (φ) := Formula.untl φ Formula.top` | Event-first reads this as `∃ s > t, φ(s) ∧ ⊤` = "F φ", which is what the name and docstring claim. Under a guard-first reading it would instead mean "φ holds throughout some initial future interval" — a `K⁺`-shaped formula, not `F`. |
| `somePast` | `Formula.lean:141` — `def somePast (φ) := Formula.snce φ Formula.top` | Exact past mirror of the above. |
| `kPlus` (`K⁺`) | `Formula.lean:180` — `def kPlus (φ) := (Formula.untl Formula.top φ.neg).neg` | Transcribes Reynolds' `K⁺A = ¬U(⊤, ¬A)`. Event-first makes this `¬(∃ s > t, ⊤ ∧ ∀ r ∈ (t,s), ¬φ)` = "φ holds arbitrarily soon in the future" — the documented meaning (`Formula.lean:164-169`, sourced to Reynolds 1992 p.168 and GHR 1994 §10.3.1). Guard-first would collapse it to `¬F(¬φ)` = `G φ`. |
| `Axiom.dense_indicator` | `ProofSystem/Axioms.lean:354-355` — `Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg`, i.e. `¬U(⊤,⊥)` | The soundness argument at `Semantics/Validity.lean:228-231` turns on `U(⊤,⊥)` being **true on ℤ** "because every point has an immediate successor". That is the event-first reading: `∃ s > t, ⊤ ∧ ∀ r ∈ (t,s), ⊥`, satisfiable exactly when `(t,s)` is empty — a successor gap. Under guard-first, `U(⊤,⊥)` would be `∃ s > t, ⊥ ∧ …`, i.e. outright false everywhere, and the whole Dense-vs-Dedekind separation argument (`Axioms.lean:350-353`'s conservativity note, `Validity.lean:225-274`) would be vacuous. |

~~`kMinus` (`Formula.lean:193`) is the past dual of `kPlus` and carries the same dependency.~~

## ~~The decision requested of the user~~ — SUPERSEDED

**SUPERSEDED 2026-08-17.** Neither option below was taken; see "What was decided" at the top. The
options are retained for the record.

~~Pick one:~~

- **(A) Correct the paper's footnote.** Change it to describe the repository as event-first /
  guard-second (or drop the claim about "the repository's constructors" and describe only the
  paper's own infix notation, which is already accurate). The paper is **read-only ground truth
  from this repository's side** — editing it is an explicit charter non-goal here, so this can only
  be done by the user, in the paper's own repository.
- **(B) Accept the divergence as documented.** The paper keeps guard-first infix, the Lean tree
  keeps event-first prefix, and the translation is the argument swap. This record plus the caveat in
  `specs/paper-definitions-of-record.md`'s `def:BLplus-semantics` entry are the documentation.

~~**Not on the table:** changing the Lean convention. The four dependents above make that a semantic
rewrite of the temporal fragment (and of the Dense/Dedekind soundness argument), not a rename, for
zero mathematical gain. Any implementer who reads the footnote and "fixes" the Lean tree to match it
would be introducing four silent meaning changes.~~ — **retracted; this is exactly what was done,
and it was a rename.**

## The superseded footnote quotation is retired

The `\footnote` quoted verbatim at the top of this record **no longer exists in the paper**. The
live tracked anchor for `def:BLplus-semantics` is
`edde75176efc0936c96f8d9eb18628929c2dd3bdb1aa1c21d4a88af90276314a` (re-pinned 2026-08-17), and its
body is **footnote-free**: it carries the two `($\since$)` / `($\until$)` clauses and nothing else.
The paper had already revised the footnote once (2026-08-12) before removing it entirely.

Consequently the whole footnote-attribution dispute is moot on both sides. The paper no longer
makes any claim about this repository's constructors, and this repository's constructors now match
the paper's clauses anyway. The quotation is retained above **only** as the historical record of
what was escalated; it must not be cited as current paper text. The corresponding caveat in
`specs/paper-definitions-of-record.md`'s `def:BLplus-semantics` entry has been rewritten to
describe the footnote-free anchor.

## Deferred consequences (recorded so the follow-on work has an inventory)

The migration was deliberately scoped to the argument order alone. Four consequences were
identified and deferred rather than folded in:

- **Identifier-name drift (D2)** — **219 distinct identifiers** in live scope carry an
  `untl_`/`snce_` segment whose name encodes a position that has now moved: `untl_left_mono_thm`,
  `snce_event_congr`, `replace_untl_with_top` / `replace_untl_with_bot`, `untl_args`,
  `closure_untl_left`, and so on. After the swap, `*_left` names the **guard** and
  `*_event_congr` names **position 2**. Renaming in the same pass would have defeated the
  zero-residue grep gate (which relies on `untl`/`snce` tokens being absent between the rename and
  the rename-back), made the diff unreviewable, and risked colliding with the temporary-name
  substitution. 219 is the starting inventory for the follow-on task.
- **`toJson` key-order flip (D1)** — the emitted key order stays `"event"` then `"guard"`. This is
  what made the oracle byte-identical and therefore auditable; flipping it to guard-first
  positional is a dataset-format version bump with real downstream consumers
  (`DatasetExport.lean`'s S-expression parser, the training-data pipeline,
  `typst/chapters/ax-machine-appendix.typ`'s shape table) and is orthogonal to argument order.
- **Boneyard exclusion (D3)** — both archive trees, `FormalSystem/Boneyard/` and
  `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/`, were excluded entirely: **1,934
  occurrences across 51 files**, none of which any compiler checks (0 of 379 built oleans lie
  under a Boneyard path, and no live module imports one). Rewriting unverifiable code is pure
  added risk, so instead each tree's `README.md` now carries a convention banner recording that
  its contents predate this migration and read **event-first**, and that resurrecting any file
  requires swapping its constructor arguments first.
- **Incidental comment tier (D4)** — 391 order-neutral prose mentions were left untouched. The
  mandatory tier (comments that state or depend on the convention) was migrated in full.

## Consequences for citation

- `def:BLplus-semantics` may now be cited **without** a convention caveat. The Lean tree and the
  paper agree, and the anchor is footnote-free.
- The anchor remains tracked and drift-linted; `scripts/check-paper-definitions.sh` continues to
  guard it.
- Docstrings at the `untl`/`snce` constructors and at `TruthAt`'s clauses now name the roles
  explicitly and cite `def:BLplus-semantics` directly; they cross-reference this record for the
  history rather than for a live caveat.
