# Research Report: Task #690

**Task**: 690 - Build the stability condition (C5) `StabFaithful` on the branching witness frame
**Started**: 2026-09-28T00:00:00Z
**Completed**: 2026-09-28T00:00:00Z
**Effort**: large (multi-phase implementation; see Cost Accounting)
**Dependencies**: None blocking. Territory overlap with concurrent tasks 623 and 684 on four
registration/aggregator files — see Risks & Mitigations.
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/WitnessFamily/` and its `Sharing/` subtree,
  `FormalSystem/PlusLanguage/`, `FormalSystem/Syntax/`,
  `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean`,
  `FormalSystem/Metalogic/Independence/StabUndefinable.lean`
- lean-lsp MCP (`lean_local_search`) for declaration existence checks
- Prior artifacts: `specs/683_state_sharing_witness_structure_and_c3/` report and plan (the
  recorded exclusion of (C5) and its stated reasons)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`, section "(C5), the
  stability clause: not here, and why"

**Artifacts**:
- `specs/690_stability_condition_over_branching_frame/reports/01_stability-condition-branching-frame.md`

**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- **The condition itself is settled, finitary and decidable.** `StabFaithful` is
  `⊡φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`. It is *not* a quantifier over walks: the branching
  agreement theorem `Sharing/Agreement.lean:211 truth_iff_mem` makes truth a function of the
  **position** `(θ.idx (s+t), s+t)` alone and independent of the thread, and
  `Histories.lean:101 total_eq_thread` makes every world history a thread trace. Together these
  collapse the semantic clause `∀ σ, τ.state t = σ.state t → …` to a quantifier over
  `Fin |lassos|` at one time. Decidability is then the (C0) `AtomCoherent` template of
  `Sharing/Decide.lean:347-420` verbatim, with `Formula.atom` replaced by `PlusFormula.stab`.
  **The hard constraint "no condition may quantify over walks" is satisfied by construction.**

- **The task description's cost estimate for the L⁺ closure layer is off by roughly an order of
  magnitude, in the favourable direction.** The description cites "roughly 2,257 lines of analogue
  on the `Formula` side". That is the whole of `FormalSystem/Syntax/SubformulaClosure/` (four
  modules). The certificate stack imports only `SubformulaClosure/Closure.lean` (358 lines) and
  uses exactly **nine** declarations from it: `subformulaClosure`, `self_mem_subformulaClosure`,
  the decidable-membership instance, and the seven projections. `closureWithNeg`,
  `diamondSubformulas`, `closure_all_past` and `closure_all_future` have **zero** uses across the
  entire `WitnessFamily/` tree (verified by grep). The L⁺ closure requirement is
  `PlusFormula.subformulas` (a 7-arm structural recursion) plus those nine declarations with a
  `stab` arm added: **≈250 lines, not 2,257**.

- **A cleaner reuse mechanism than polymorphism exists, and it is bigger than the description
  claims.** Not only do `Sharing/{Basic,Thread,Frame,Histories}.lean` (1,065 lines) mention
  `Formula` zero times — they also use `.L`, `.lab` and `.bx` **zero** times. Their entire content
  depends on nothing but `lassos.length` and the three representative-map segments. That licenses
  a **label-free `SharingSkeleton`** factoring: extract `(n, n_pos, repBack, repMid, repFwd,
  repBack_ne, repFwd_ne, rep_idem)` into its own structure, restate `rep`/`share`/`Thread`/
  `Step`/`ReachN`/`shareSetoid`/`WorldState`/`Conn`/`RelZ`/`frame`/`hist`/`total_eq_thread` on it,
  and both the `Formula` and the `PlusFormula` families project to the same skeleton. This needs
  **no type parameter, no `DecidableEq α`, and no `deriving` gymnastics**, which the polymorphic
  alternative does need.

- **There are two genuinely viable architectures with a ~4x cost gap, and the choice is the
  user's.** Route 1 is the full L⁺-indexed certificate the `Sharing/README.md` section (c) already
  specifies (≈2,400–3,900 new Lean lines; leaves the shipped deterministic export contract
  literally untouched; adds a new parallel export). Route 2 runs the **existing** `Formula`
  certificate on an atomized target via `Conservativity/Plus/Atomization.lean`'s `atomize`, adding
  (C5) as a condition on stab-atoms paired with their atomized inner formulas (≈600–900 lines; but
  it states (C5) at `Formula` and adds one field to the *shipping* certificate). The task
  description forbids re-opening the JSON export contract without an explicit decision, and Route 2
  does exactly that — so this is raised as a **blocking** `user_decision`, with **Route 1
  recommended**.

- **A sorry-free path exists for every component.** No component of either route requires `sorry`,
  a new axiom, or deferral. The single highest-risk item (the `A[g U e]` fixpoint in
  `Sharing/Fulfil.lean`, 1,669 lines) is ~1,270 lines of *position-graph* machinery that the
  skeleton factoring reaches too, leaving ~400 label-dependent lines to re-index.

---

## Context & Scope

**What was researched.** Whether (C5) `StabFaithful` can be stated, decided and *validated* on the
branching witness frame that landed under
`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/`, and at what cost — given that the
stability modal `⊡` is `PlusLanguage.PlusFormula.stab`, a constructor of an inductive disjoint
from `Syntax.Formula`, on which the entire certificate stack is monomorphic.

**Constraints taken as binding** (from the dispatch):

1. Decidability must be preserved; no condition may quantify over the branching structure's
   infinitely many walks.
2. The deterministic bi-lasso device must keep working byte-identically, and its JSON export
   contract must not be re-opened without an explicit decision.
3. No vacuous or box-shaped `StabFaithful` at `Formula` to make a signature typecheck; no
   `sorry`-bodied `def` carrying a prose statement.
4. Zero-debt: no `sorry`, no new axiom, no "fix it in a follow-up".

**What was not researched.** No build was run. The working tree carries modifications only under
`specs/` (verified via the session's git status), and two sibling research dispatches (623, 684)
are live on the same tree this cycle; starting a `lake build` would both cost ~40 minutes and risk
attributing a sibling's in-flight edit to this task. Every claim below is grounded in file reads,
greps and `lean_local_search`, not in a compile.

---

## Findings

### Codebase Patterns

#### F1. The exact shape of (C5), derived independently and confirmed against the prior plan

`PlusTruth.lean:93` gives the semantic clause:

```lean
| .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ
```

On the branching frame the three ingredients that finitize this are all landed:

| Ingredient | Location | What it gives |
|---|---|---|
| `share_of_cls_eq` | `Sharing/Frame.lean:100` | `S.cls i u = S.cls j v → u = v ∧ S.share u i j` |
| `total_eq_thread` | `Sharing/Histories.lean:101` | every `σ : WorldHistory S.frame` is `S.hist θ s` for some thread `θ`, offset `s` |
| `truth_iff_mem` | `Sharing/Agreement.lean:211` | truth along `S.hist θ s` at `t` ↔ membership at the **position** `(θ.idx (s+t), s+t)` — the thread drops out |

`truth_iff_mem` is the load-bearing one: because its right-hand side is a function of the position
and not of the thread, any two histories through the same position agree on every closure formula.
So `∀ σ through the state` reduces to `∀ j : Fin |lassos| with share u i j`, with `Thread.const S j`
(`Sharing/Thread.lean:105`) supplying a witnessing history for each such `j`. Hence:

```lean
def StabFaithful (S : PlusSharingWitnessFamily Γ Δ) : Prop :=
  ∀ (i : Fin S.lassos.length) (u : ℤ) (φ : PlusFormula),
    PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Δ) →
      (PlusFormula.stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u)
```

This is **exactly** the form the superseded task-683 plan pinned at its line 430 before the
exclusion, derived here independently from the semantics. That agreement is corroboration, not
inheritance.

**Consistency with `stab_state_only` is automatic.** `share u` is an equivalence relation (it is
the kernel of `rep u`, `Sharing/README.md`), so (C5) immediately yields
`share u i j → (⊡φ ∈ L i u ↔ ⊡φ ∈ L j u)` — the label-level reading of
`PlusTruth.lean:332 stab_state_only`. No side condition is needed and none is generated.

#### F2. Decidability is the (C0) template, not new work

`Sharing/Decide.lean` decides (C0) `AtomCoherent` in a seven-step pattern over ~80 lines
(`:347-420`): `atomClauseAt` (per-constructor clause) → `atomCoherentData` (at explicit data) →
`AtomCoherentAt` (at one time) → `atomCoherent_iff_at` (closure-gating) → `atomCoherentAt_congr`
(per-time congruence) → `atomCoherent_iff_window` (the window collapse, `:494`) →
`decidableAtomCoherent` (`:516`).

(C5) has the **same quantifier signature as (C0)**: a same-time, `share`-gated biconditional over
one representative map and one label row. Its per-time datum is `(S.rep u, fun i => S.L i u)` —
identical to (C0)'s. So `stabClauseAt`/`stabFaithfulData`/`StabFaithfulAt`/`stabFaithful_iff_at`/
`stabFaithfulAt_congr`/`stabFaithful_iff_window`/`decidableStabFaithful` is a line-for-line
transcription against the same `cohWindowLo`/`cohWindowHi` window (`Decide.lean:264,267`) and the
same `exists_window_repr` (`:277`). **No new window arithmetic and no new fixpoint are needed.**

Note that (C5) is *cheaper* than (C1') `LocalCoherentShare`, which needs three label rows
(`t-1`, `t`, `t+1`) and two representative maps; (C5) needs one of each.

**Choice-freedom is preserved.** `Sharing/Decide.lean` contains no `open Classical` (verified), and
`WitnessFamily/README.md` records that all instances compute. The (C5) instance above computes for
the same reason (C0)'s does. This is a real constraint on the design — see D3.

#### F3. The `stab` case of the truth lemma is the `box` case with `share`-gating

`Sharing/Agreement.lean:232-245` proves the `box` case in fourteen lines using exactly two moves:
`Thread.const` + `Thread.const_idx` for the forward direction, and
`total_eq_thread` + `WorldHistory.ext_state` for the backward direction. The `stab` case uses the
same two moves, with `S.cls i u = S.cls j v` (rather than "any history") gating which positions are
reachable:

- **(→)** Given `∀ σ` with matching state, `φ` true. For `j` with `share u i j`, take
  `Thread.const S j` at offset `s`; `hist_state` + `cls_eq` give the state match; IH gives
  `φ ∈ L j u`. Then `StabFaithful` gives `stab φ ∈ L i u`.
- **(←)** Given `stab φ ∈ L i u` and `σ` with matching state: `total_eq_thread` gives
  `σ = S.hist θ' s'` via `WorldHistory.ext_state`; `share_of_cls_eq` turns the state match into
  `share u i (θ'.idx (s'+t))`; `StabFaithful` gives membership; IH concludes.

Estimated 15–20 lines. **This is the lowest-risk item in the whole task**, and it is the theorem
that makes (C5) a pinned obligation rather than a signature.

#### F4. `Sharing/{Basic,Thread,Frame,Histories}` depend on no labels at all

Measured (grep counts over the four files):

| Module | Lines | `Formula` | `.L ` | `.lab` | `.bx` |
|---|---|---|---|---|---|
| `Basic.lean` | 254 | 0 | 0 | 0 | 0 |
| `Thread.lean` | 273 | 0 | 0 | 0 | 0 |
| `Frame.lean` | 397 | 0 | 0 | 0 | 0 |
| `Histories.lean` | 141 | 0 | 0 | 0 | 0 |
| **total** | **1,065** | | | | |

Reading the definitions confirms what the counts suggest: `rep` (`Sharing/Basic.lean`) is
`Periodic.unrollOf S.repBack S.repMid S.repFwd`, `share u i j := rep u i = rep u j`, `Thread` is a
`Fin n`-valued function with a `share`-step field, `shareSetoid` is on `Fin n × ℤ`, and `hist` is
built from `cls` and `conn_thread`. **Nothing reads a label.**

This is a stronger fact than "86 percent language-agnostic": these modules are *certificate*-
agnostic. They are a theory of a periodic representative structure on `Fin n × ℤ`, and the witness
family is only one consumer.

#### F5. `LabelledLasso` is already almost language-agnostic

`WitnessFamily/Basic.lean:75-160` declares `LabelledLasso (C : Finset Formula)` and every one of its
lemmas (`lab`, `nb`/`nm`/`nf`, `nb_pos`, `lab_sub_back_length`, `lab_add_fwd_length`,
`lab_subset`) goes through `Periodic.unrollOf` and `Finset` subset reasoning only — no
constructor is ever matched. Only the **type** `Finset Formula` is monomorphic.

#### F6. An entirely different route exists: atomization

`FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean` already carries
`atomize (e : Encoding) : PlusFormula → Formula` (`:92-99`), which is structural on the six L
constructors and maps `.stab χ ↦ .atom (e.ι (.inr χ))`, together with
`plusTruthAt_iff_atomize` (`:160`). `PlusTruthAt` takes the **same** `TaskModel F` as `TruthAt`, so
the certificate's own model needs no rebuilding to be read in L⁺.

This makes Route 2 (below) possible: keep the `Formula` certificate and constrain the stab-atoms.
Two obstructions were found and both are surmountable but non-trivial:

- **The closure trap.** `subformulaClosure (atomize e (⊡χ)) = {atom (e.ι (inr χ))}` — it does *not*
  contain `atomize e χ`. A (C5) referring to `atomize e χ ∈ L j u` would therefore be forced
  false everywhere by `subset_closureOf`, i.e. **vacuous in exactly the way the dispatch
  forbids**. The fix is an *expanded* target context that appends the atomizations of every
  `⊡`-subformula's inner formula. That reintroduces a `PlusFormula.subformulas` requirement — but
  only as a list construction, not a closure theory with projections.
- **`Encoding` is not computable data.** `Encoding.nonempty` (`:74`) goes through
  `Classical.choice`, and `Encoding.ι : Atom ⊕ PlusFormula → Atom` is not finitely presentable.
  A (C5) mentioning `e` would not decide computably, breaking the invariant of F2. The fix is to
  carry the pairing as finite data — a `List (Atom × Formula)` mapping each stab-atom to its
  inner atomization — with `e` appearing only in the correspondence *theorem*, never in the
  checked condition. **That finite list is a new certificate field, hence a JSON export change on
  the shipping path.**

#### F7. A non-vacuity witness already has a blueprint

`Metalogic/Independence/StabUndefinable.lean` separates `⊡Fp` from `Fp`: `Fp` holds at both points
while `⊡Fp` fails wherever a state is shared by a history that never reaches `p`. Transcribed to a
`SharingWitnessFamily`, the witness is a two-lasso family sharing a state at `u = 0`, with `p`
labelled on lasso 0 at `t = 1` and nowhere on lasso 1. Then `Fp ∈ L 0 0` but `⊡Fp ∉ L 0 0`, while
the deterministic diagonal (`Specialize.lean`'s `toSharing`) collapses (C5) to `⊡φ ↔ φ`. This gives
both halves of non-vacuity — the branching instance where (C5) bites, and the diagonal instance
where it degenerates — with an existing model as the design source.

### External Resources

No Mathlib gap was found. The decidability work reuses `Finset`, `Fin`, `Decidable` instances and
`Int` arithmetic already imported by `Sharing/Decide.lean` (`Mathlib.Data.Fintype.Pi`,
`Mathlib.Data.Int.SuccPred`, `Mathlib.Order.SuccPred.LinearLocallyFinite`,
`Mathlib.Data.Int.Interval`). `lean_local_search` confirms no `PlusFormula`-side subformula or
closure declaration exists anywhere in the repository (`subformulas PlusFormula` → 0 results), so
that layer is genuinely new rather than hidden somewhere.

An existing in-repo precedent for a *language-polymorphic* layer is
`FormalSystem/Semantics/TruthClauses.lean` (`TruthEnv L`, one class per primitive operator,
`StabClauses` already the L⁺ tier). It is cited below in D2 as the reason polymorphism was
considered seriously and the reason it was nevertheless rejected for the certificate layers.

### Recommendations

#### Route 1 (RECOMMENDED) — the L⁺-indexed certificate, over a label-free skeleton

This is what `Sharing/README.md` section "(c) What a follow-up needs" already specifies, executed
with the F4 factoring so that 1,065 lines are reused rather than duplicated.

**Stage A — `SharingSkeleton` (no behaviour change, must be byte-identical downstream).**
New `Sharing/Skeleton.lean` carrying `(n : ℕ, n_pos : 0 < n, repBack, repMid, repFwd,
repBack_ne, repFwd_ne, rep_idem)`. Move the content of `Sharing/{Basic,Thread,Frame,Histories}`
onto it; leave in those four files only `def skeleton (S : SharingWitnessFamily Γ Δ) :
SharingSkeleton` plus thin re-export abbreviations so that **every existing downstream name and
statement is unchanged**. Verification: `lake build` green, `#print axioms` unchanged on every
landed goal, and the deterministic path's `#guard`s in `WitnessFamily/Examples.lean` still fire.

**Stage B — the L⁺ syntax/closure layer.** `PlusFormula.subformulas` (7 arms),
`plusSubformulaClosure`, `plusClosureOf`, `mem_plusClosureOf`, `self_mem_plusClosureOf`, and eight
projections (`imp_left`, `imp_right`, `box`, `untl_left`, `untl_right`, `snce_left`, `snce_right`,
**`stab`**), plus the decidable-membership instance. ≈250 lines. Site it under
`FormalSystem/PlusLanguage/` or a new `FormalSystem/PlusLanguage/Subformulas.lean` — note the
module invariant that nothing under `PlusLanguage/` imports `Semantics/`, which this layer
respects (it is pure syntax).

**Stage C — the L⁺ certificate datatypes.** `PlusLabelledLasso`, `PlusWitnessFamily`,
`PlusSharingWitnessFamily` (the last projecting to `SharingSkeleton`). Transcribed from
`WitnessFamily/Basic.lean` and the label-bearing half of `Sharing/Basic.lean`. ≈300 lines.

**Stage D — the six conditions.** (C0) `PlusAtomCoherent`, (C1') `PlusLocalCoherentShare` (with an
added no-op `stab` position in the clause enumeration), (C2') `PlusThreadFulfilling`, (C3)
`PlusBoxFaithful`, (C4) `PlusTarget`, and **(C5) `StabFaithful`** exactly as in F1, plus the two
unconditional reductions to the deterministic conditions. ≈300 lines.

**Stage E — decidability.** `Sharing/Decide.lean` re-indexed (≈650 lines, of which ~90 are the new
(C5) window collapse per F2) and `Sharing/Fulfil.lean` re-indexed. Fulfil's ~1,270 lines of
position-graph and fixpoint machinery should be factored onto `SharingSkeleton` in Stage A if the
factoring reaches them; otherwise it is duplicated. **This is the one place where the estimate
range is wide** (≈500 vs ≈1,700 new lines) and it should be settled by an explicit
measurement phase before Stage E is sized.

**Stage F — agreement and the refutation interface.** `plusTruth_iff_mem` (seven constructor
cases; six transcribed, the `stab` case per F3), `PlusRefutes`, `plusRefutes_of_certifies`,
`decidablePlusCertifies`. ≈450 lines.

**Stage G — non-vacuity and the diagonal.** The `⊡Fp` two-lasso witness of F7, and the
specialization showing (C5) collapses to `⊡φ ↔ φ` on the diagonal (recovering
`stab_iff_of_deterministic` inside the device). ≈250 lines.

**Total: ≈2,400–3,900 new Lean lines**, in seven phases each of which can end green.

**What Route 1 does not touch**: `back`, `mid`, `fwd`, `bx`, `lassos`, `repBack`, `repMid`,
`repFwd` on the *existing* `SharingWitnessFamily` — the shipping JSON export contract is unchanged
in name, meaning and shape. The L⁺ certificate is a **new** export alongside it, which a consumer
adopts only when it wants `⊡`.

#### Route 2 (viable, ~4x cheaper, needs the user's blessing) — atomization

Run the **existing** `Formula` `SharingWitnessFamily` at an expanded atomized target
`Γ' := plusTargetAtomization e (Γ⁺ ++ Δ⁺)`, and add:

```lean
/-- `P` pairs each stab-atom with the atomization of its inner formula. -/
def StabFaithful (S : SharingWitnessFamily Γ' Δ') (P : List (Atom × Formula)) : Prop :=
  ∀ (i : Fin S.lassos.length) (u : ℤ), ∀ pr ∈ P,
    (Formula.atom pr.1 ∈ S.L i u ↔ ∀ j, S.share u i j → pr.2 ∈ S.L j u)
```

plus the correspondence theorem `PlusTruthAt M τ t χ ↔ TruthAt M τ t (atomize e χ)` for the
certificate's own model `M`, by induction on `χ` with the `stab` case discharged by
`StabFaithful` + `total_eq_thread` + `truth_iff_mem`. ≈600–900 lines, **zero re-indexing**, and
all five existing conditions and their decision procedures reused unchanged.

**Why it still needs a decision, and why it is not recommended.** (i) It adds the pairing `P` as a
new field on the *shipping* certificate — an additive but real re-opening of the JSON export
contract, which the dispatch says must not happen without an explicit decision. (ii) It states
`StabFaithful` at `Formula`. It is emphatically **not** vacuous (F6's closure trap is fixed by the
expanded target) and **not** box-shaped (it is `share`-gated, not global), and it is pinned by a
real theorem rather than prose — but it is the *shape* the dispatch warns against, and reading the
dispatch's intent as permitting it would be a guess. (iii) The expanded-target closure lemma
(`atomize e ψ ∈ closureOf Γ'` for every L⁺-subformula `ψ` of the target) is the one genuinely
novel proof in the route and carries more risk than anything in Route 1.

#### Route 3 (considered and rejected) — polymorphic label type

Generalize `LabelledLasso`/`WitnessFamily`/`SharingWitnessFamily` over `α : Type` with
`[DecidableEq α]`, indexed by `C : Finset α`. `Semantics/TruthClauses.lean` is an in-repo
precedent for exactly this style at the semantics layer.

Rejected because the payoff and the cost land in different places. What genuinely generalizes —
`Sharing/{Basic,Thread,Frame,Histories}` — needs **no type parameter at all** (F4), so the
skeleton factoring captures that win more cheaply and with less risk. What does *not* generalize —
`Predicates`, `Decide`, `Fulfil`, `Agreement` — needs **exhaustive constructor case analysis**
(`cases ψ with | atom … | bot … | …` in `atomClauseAt`; `induction ψ with` in `truth_iff_mem`).
A typeclass bundling operators cannot supply exhaustiveness; supplying it would require a
`CasesOn`-style view plus its completeness lemma, which is comparable work to the duplication it
saves, while putting a refactor underneath the shipping deterministic path. Additionally,
`LabelledLasso` carries `deriving DecidableEq`, which is fragile under a `structure … extends`
chain with a type parameter and a `Finset α` index.

---

## Literature Proof Structure

Not applicable. No paper, textbook or external formalization is referenced by this task. The
authoritative source is in-repository: the JPL manuscript reference `def:BLstar-semantics` is
already transcribed into `FormalSystem/PlusLanguage/PlusTruth.lean`'s `stab` clause, and this task
consumes that Lean clause directly rather than the prose. No literature-extraction protocol was
invoked.

---

## Decisions

**D1. (C5)'s statement is settled and is not an open design question.**
`⊡φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`, closure-gated on `stab φ`. Derived here from
`PlusTruth.lean:93` + `total_eq_thread` + `truth_iff_mem` + `share_of_cls_eq`, and independently
matching the form the superseded task-683 plan pinned. No plan should re-litigate the statement;
it should only choose the datatype it is stated over.

**D2. Route 3 (polymorphism) is rejected on the reasoning in the Recommendations section.** This is
the agent's own call and is not raised to the user: the codebase answers it (F4 shows the
generalizable part needs no parameter; the `cases`/`induction` sites show the rest cannot be
generalized by a typeclass).

**D3. (C5) must not mention `Encoding`.** Any form of the condition that quantifies over
`χ : PlusFormula` behind a non-invertible encoding, or that carries an `Encoding` as a parameter,
destroys the "all decision instances compute, no `open Classical`" property that
`WitnessFamily/README.md` records and `Sharing/Decide.lean` maintains. Route 1's form quantifies
over `PlusFormula` gated by `plusClosureOf` membership, which is a `Finset PlusFormula` and
therefore enumerable; Route 2's form must carry the pairing as finite data. Either is fine; an
`Encoding`-parameterized condition is not.

**D4. No `sorry`-tolerant path is recommended anywhere.** Every stage of Route 1 and every
component of Route 2 has a complete proof sketch above. The one item whose *size* is uncertain
(Fulfil's re-index, Stage E) is uncertain in line count, not in provability: it is a transcription
of an already-proved development onto a second inductive. If a plan finds it cannot be completed,
the correct response is to decompose Stage E further, not to `sorry` it.

**D5. The dispatch's "2,257 lines of analogue" figure is corrected to ≈250 lines**, with the
evidence in F1's Executive Summary bullet and the grep counts. A plan should size Stage B against
the corrected figure. The correction is favourable and does not change the recommended route.

---

## Risks & Mitigations

**R1 — Territory collision with concurrent tasks 623 and 684 on registration files.**
Route 1 creates new modules, and this repository registers every module in `FormalSystem.lean`
(623's declared scope) and in a per-directory aggregator. Siting the new tree under
`WitnessFamily/` would touch `WitnessFamily.lean` (684's scope); siting it as a sibling under
`Decidability/` would touch `Decidability.lean` (623's scope). `docs/theorem-index.md` and
`scripts/check-module-invariants.sh` are also 623's.
*Mitigation*: write all new Lean modules first and register them in a **final, separately
committed phase**, after re-reading each registration file immediately beforehand and staging only
this task's own hunks (never a directory or glob `git add`). If a foreign uncommitted modification
or a build not started by this task is observed, stop and report rather than proceeding.

**R2 — Stage A must be provably behaviour-preserving.**
The `SharingSkeleton` factoring edits four files that the shipping deterministic path depends on.
*Mitigation*: keep every existing name and statement in place as a thin re-export; make the phase's
acceptance criteria "green `lake build`, unchanged `#print axioms` output on every landed goal,
`WitnessFamily/Examples.lean`'s `#guard`s still fire, and no diff in any downstream file". If any
of those fails, Stage A is reverted and Route 1 proceeds by duplicating the 1,065 lines instead —
a fallback that costs lines but carries no risk to the deterministic path.

**R3 — Stage E (Fulfil) is the wide-variance item.**
≈500 lines if the position graph factors onto the skeleton, ≈1,700 if not.
*Mitigation*: make the first objective of Stage E a **measurement**, not a transcription: grep the
1,669 lines for label dependence exactly as F4 did for the substrate, and size the rest from the
measured number. Do not commit a phase budget for Stage E before that measurement exists.

**R4 — Module-invariant script C8.**
`scripts/check-module-invariants.sh` enforces "every subdirectory has exactly one sibling
aggregator". A new subdirectory needs its aggregator `.lean` created in the same commit.
*Mitigation*: include the aggregator in the new-module phase, and run the invariant script before
declaring any phase green.

**R5 — Axiom census.**
The repository pins `#print axioms` output for named goals. New declarations must stay within
`[propext, Classical.choice, Quot.sound]`.
*Mitigation*: the (C5) statement, its decidability instance and the `stab` truth case all go
through the same machinery as (C0) and the `box` case, which already meet the census; add the new
goals' census lines to the script in the registration phase.

**R6 — Deploy-freshness warning in the dispatch.**
The deployed `.claude/` tree is stale relative to the source store for the `core`, `lean` and
`typst` extensions. No command in this report was taken from a deployed extension file.
*Mitigation*: implementation phases that rely on a documented `.claude/` command should verify it
against the source store named by `.claude-extensions.json`, or redeploy via
`bash .claude/scripts/deploy-headless.sh`. Do not hand-patch under `.claude/**`.

---

## Tactic Survey Results

- Not applicable (no tactic survey performed).

No proof goal for (C5) exists yet at any datatype — the L⁺ certificate type does not exist, so
there is no position at which to run `lean_multi_attempt`, `lean_goal` or `lean_hammer_premise`.
Running the survey against the `Formula`-side analogues would have produced results about
already-proved goals and no information about the new ones. The survey belongs to the
implementation phases, where the relevant positions will exist; the highest-value places to run it
are the `stab` case of `plusTruth_iff_mem` (F3) and the `stabFaithful_iff_window` collapse (F2),
both of which have closely-matched landed analogues whose tactic scripts are the first candidates
to try verbatim.

---

## Context Extension Recommendations

- **Topic**: label-free reuse of the branching substrate.
  **Gap**: `Sharing/README.md` documents the branching device thoroughly but records the substrate
  as "language-agnostic" without recording that it is also **label**-agnostic (zero uses of `.L`,
  `.lab`, `.bx`), which is the stronger fact that licenses the `SharingSkeleton` factoring.
  **Recommendation**: whichever phase lands Stage A should add a short section to
  `Sharing/README.md` naming the skeleton and the measurement behind it, so a future reader does
  not re-derive it.

- **Topic**: the certificate stack's actual dependency on `Syntax/SubformulaClosure/`.
  **Gap**: nothing records that the stack uses nine declarations from one of four modules, which is
  why the "2,257 lines" figure propagated into this task's description.
  **Recommendation**: a one-paragraph note in `WitnessFamily/README.md` listing the nine
  declarations the stack actually consumes.

---

## Appendix

### Search queries and verifications used

- `lean_local_search "subformulas PlusFormula"` → 0 results (confirms no L⁺ subformula layer
  exists anywhere in the repository).
- `lean_local_search "atomize"` → 10 results, all in
  `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean` (confirms the Route 2 machinery and
  its single home).
- Grep: per-file counts of `Formula`, `.L `, `.lab`, `.bx` across `Sharing/*.lean` (the F4 table).
- Grep: usage counts across the whole `WitnessFamily/` tree for each declaration of
  `Syntax/SubformulaClosure/Closure.lean` (the F1/D5 correction). `closureWithNeg` 0,
  `diamondSubformulas` 0, `closure_all_past` 0, `closure_all_future` 0.
- Grep: `^import` across `WitnessFamily/**` — only `SubformulaClosure.Closure` is imported from
  the four-module `SubformulaClosure/` directory.
- Grep: `open Classical` in `Sharing/Decide.lean` → 0 (the D3 constraint).
- Grep: `StabFaithful` across `FormalSystem/` → 0 occurrences (the exclusion is real; all hits are
  in `specs/`).

### Key locations

| What | Where |
|---|---|
| `⊡` truth clause | `FormalSystem/PlusLanguage/PlusTruth.lean:93` |
| `stab_state_only` | `FormalSystem/PlusLanguage/PlusTruth.lean:332` |
| determinism collapse | `FormalSystem/PlusLanguage/PlusDeterminism.lean:104,123` |
| `PlusFormula` (7 constructors) | `FormalSystem/PlusLanguage/Formula.lean` |
| `share`, `rep` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean` |
| `Thread`, `Thread.const` | `.../Sharing/Thread.lean:105,113` |
| `shareSetoid`, `cls`, `share_of_cls_eq`, `frame` | `.../Sharing/Frame.lean:76,93,100,274` |
| `hist`, `total_eq_thread` | `.../Sharing/Histories.lean:76,101` |
| (C0)/(C1') conditions | `.../Sharing/Predicates.lean` |
| (C0) decision template | `.../Sharing/Decide.lean:347-420,494,516` |
| `truth_iff_mem`, `box` case, `Certifies` | `.../Sharing/Agreement.lean:211,232,329` |
| `LabelledLasso`, `WitnessFamily` | `.../WitnessFamily/Basic.lean:75,167` |
| `closureOf` + 7 projections | `.../WitnessFamily/Closure.lean` |
| `Formula.subformulas` | `FormalSystem/Syntax/Subformulas.lean:45` |
| `subformulaClosure` | `FormalSystem/Syntax/SubformulaClosure/Closure.lean:36` |
| `atomize`, `Encoding`, `plusTruthAt_iff_atomize` | `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean:92,66,160` |
| non-vacuity blueprint (`⊡Fp`) | `FormalSystem/Metalogic/Independence/StabUndefinable.lean` |
| export-contract statement | `.../WitnessFamily/README.md:123` |
| the recorded exclusion | `.../Sharing/README.md`, "(C5), the stability clause: not here, and why" |
