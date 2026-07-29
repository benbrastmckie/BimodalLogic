# Design: compactness feasibility, the recommended route, and the Discrete non-compactness witness

**Source**: `reports/01_strong-completeness-architecture-gap-analysis.md` §3 and §4.3 (authoritative).
**Status**: design proposal. **Nothing in this document exists in the tree.**
**Intended consumers**: the spawned tasks N4 (symbolic `S1`, the gate) and N5 (symbolic `D1`).

---

## STANDING CONSTRAINT BANNER

> Every Lean fragment in this document is a **design proposal held inside a `specs/` document**,
> not a tree edit. At the time of writing, a separate session owns task 418 and holds the
> advisory build lock `.lake/.task-418-build.lock`. While that lock is held:
>
> - **MUST NOT** run `lake build`, `lake clean`, `lake exe`, or the `lean_build` MCP tool.
> - **MUST NOT** create, edit, or delete any file under `FormalSystem/` or `Tests/`.
> - **PERMITTED**: read-only `lean-lsp` queries and `Read`/`Grep`/`Glob` over the tree.
>
> The downstream implementer inherits this constraint **only if the lock is still held** when
> the task is dispatched. Check `.lake/.task-418-build.lock` before assuming it applies.

---

## 0. The two questions, kept apart

Earlier framing conflated two separable questions. The rest of this document depends on keeping
them apart, because **their verdicts have opposite signs**:

- **(Q1) Mathematical** — is `⊨_Base` / `⊨_Dense` compact?
- **(Q2) Architectural** — does the existing BXCanonical chronicle machinery deliver a
  model-existence theorem for arbitrary `SetConsistent` sets?

**Q1 verdict: likely-but-unproved.** **Q2 verdict: NO.** That is precisely why the recommended
route abandons the chronicle for this purpose rather than extending it.

---

## Q2 — the chronicle route does not reach model existence. VERDICT: NO.

The obstruction is **not a missing lemma**; it is the architecture of the truth lemma. This is a
structural finding, and it is the single most important negative result in this document.

Every countermodel in this tree is produced by
`fully_restricted_parametric_completeness_from_neg_membership`
(`FormalSystem/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:417`, verified present),
whose three coherence hypotheses are all **root-relative**:

| Hypothesis | Location (verified) | Quantifies only over |
|---|---|---|
| `BFMCS.RestrictedTemporallyCoherent root` | `Bundle/TemporalCoherence.lean:308` | `φ ∈ deferralClosure root` |
| `BFMCS.RestrictedForwardUntilSinceCoherent root` | `Bundle/TemporalCoherence.lean:558` | `subformulaClosure root` |
| `BFMCS.RestrictedBackwardUntilSinceCoherent root` | `Bundle/TemporalCoherence.lean:589` | `subformulaClosure root` |

Both closures return a **`Finset`**, verified directly:

- `def subformulaClosure (phi : Formula) : Finset Formula` — `Syntax/SubformulaClosure/Closure.lean:36`
- `def deferralClosure (phi : Formula) : Finset Formula` — `Syntax/SubformulaClosure/TemporalFormulas.lean:276`

A strong completeness argument for an infinite `Γ` needs the truth lemma at **every** `ψ ∈ Γ`,
hence coherence over `⋃_{ψ ∈ Γ} subformulaClosure ψ` — a countably infinite set, not a `Finset`.

The tree states explicitly *why* the unrestricted version is not available. Quoted verbatim from
`FormalSystem/Metalogic/Bundle/TemporalCoherence.lean:293-298` (re-read this session, matches):

> The existing `TemporalCoherentFamily` quantifies forward_F/backward_P over ALL formulas.
> Proving this for a chain construction requires bounding F-nesting depth, which is
> unbounded in full MCS chains. The restricted variant only quantifies over
> `deferralClosure(root)`, where F-nesting IS bounded (by `maxFDepthInClosure`),
> making the coherence proof achievable via the BXCanonical chain construction's
> bounded subformula closure.

**The bounded F-nesting depth of the root closure is load-bearing for the construction, and it is
exactly what an infinite premise set destroys.** `BFMCS.temporally_coherent_implies_restricted`
(`TemporalCoherence.lean:319`, verified present) exists but points the wrong way: it derives the
restricted form from the unrestricted one, not the converse.

So the substantive obligation on this route would be "construct a BFMCS satisfying
`TemporallyCoherent` / `ForwardUntilSinceCoherent` / `BackwardUntilSinceCoherent` **unrestricted**"
— i.e. re-do the chronicle construction with an unbounded eventuality schedule. That is a research
programme, not a phase.

> **DIRECTIVE**: No chronicle-based model-existence work is to be planned or spawned. Neither this
> task nor any task it spawns may propose "extend the chronicle truth lemma to infinite premise
> sets" as a phase. The single-formula countermodel engines do not suffice for model existence,
> and neither does a mild generalization of them.

---

## Q1 — the compactness argument. VERDICT: likely, not proved.

### The structural evidence

The semantics has a feature that makes an ultraproduct argument unusually clean: **`TruthAt` never
mentions `TaskRel`, `respects_task`, or `convex`.** Verified verbatim from
`FormalSystem/Semantics/Truth.lean:128-137`:

```lean
def TruthAt (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAt M Omega τ t φ → TruthAt M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → TruthAt M Omega σ t φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M Omega τ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M Omega τ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M Omega τ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M Omega τ r ψ
```

The frame's algebraic content reaches the truth definition **only through the atom clause**, which
is a plain binary relation `A_p(σ, t)`.

Two consequences:

1. **Every binder of `valid` and `ValidDense` is first-order** over the two-sorted signature
   `⟨Ω, D; <, +, 0, sh, (A_p)⟩`: `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`,
   `Nontrivial` (`∃x, x ≠ 0`), `DenselyOrdered` (`∀ x y, x < y → ∃ z, x < z < y`). And `TruthAt`
   is a literal standard translation into that signature. First-order compactness therefore
   *predicts* that `⊨_Base` and `⊨_Dense` are compact.
2. **The two provably non-compact classes are exactly the two carrying a non-elementary binder.**
   `ValidDiscrete` (`Validity.lean:187`) carries `IsSuccArchimedean`/`IsPredArchimedean`;
   `ValidDedekind` (:241) and `ValidDedekindDense` (:276) carry the least-upper-bound `Prop`
   `(_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)`. Neither is preserved by
   ultraproducts. This is not a coincidence — it is the same phenomenon, seen from the
   model-theoretic side, that is already recorded as settled for those two classes.

That correspondence is the strongest single piece of evidence available without doing the work,
and it is why Base/Dense compactness rates **likely** rather than open-ended.

---

## Representation theorem (shift sets)

Stated in both directions. This is the whole content of the gate task N4 (`S1`).

```lean
/-
FORWARD DIRECTION — a shift set induces a task model.

Let ⟨Ω, D, sh, A⟩ be a *shift set*:
  · D  : an ordered abelian group
  · Ω  : a nonempty type
  · sh : Ω → D → Ω          -- a D-action on Ω
  · A  : Atom → Ω → Prop

Define:
  WorldState  := Ω
  TaskRel w d u := (u = sh w d)
  domain      := Set.univ
  states σ t  := sh σ t
  valuation w p := A p w
  Omega       := Set.range (fun σ => h_σ)     -- the induced history family

Claim: `nullity_identity`, `forward_comp`, `converse`, `convex`, and `respects_task` all hold
BY CONSTRUCTION; `Omega` is `ShiftClosed` because `sh` is an action; and `TruthAt` in this model
is determined by `A` alone.
-/

/-
REVERSE DIRECTION — a task model induces a shift set.

From any `(F, M, Omega, h_sc : ShiftClosed Omega)` take:
  Ω        := Omega
  sh σ Δ   := WorldHistory.timeShift σ Δ      -- lands in Omega by shift-closure
  A p σ    := TruthAt M Omega σ 0 (Formula.atom p)

Compatibility `A_p (sh σ Δ) t ↔ A_p σ (t + Δ)` is supplied by
`FormalSystem.Semantics.TimeShift.time_shift_preserves_truth`.
-/
```

**Verified anchors for the reverse direction**: `ShiftClosed` is defined at `Truth.lean:333`;
`time_shift_preserves_truth` is at `Truth.lean:446`, inside `namespace TimeShift` (opened at
`Truth.lean:357`, closed at :692) within `namespace FormalSystem.Semantics` (:91) — so its fully
qualified name is `FormalSystem.Semantics.TimeShift.time_shift_preserves_truth`. Its statement
takes `(h_sc : ShiftClosed Omega)` explicitly, confirming shift-closure is exactly the hypothesis
that makes the reverse construction land inside `Omega`.

---

## Route (Route B) — four steps

Ordered; each step is sized for one or more agent runs.

| Step | Content | Symbolic task |
|---|---|---|
| 1 | Prove the representation theorem above, **both directions**, so the model class becomes shift sets. | `S1` — **the gate** |
| 2 | Build a bespoke ultraproduct of shift sets over an ultrafilter on the index type `{L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}`. | `S2` |
| 3 | Prove a Łoś lemma for `TruthAt` by induction on `Formula` — six cases (`atom`, `bot`, `imp`, `box`, `untl`, `snce`), each mechanical except `box`. | `S3` |
| 4 | Conclude `ModelExistenceDense` / `ModelExistenceBase`, hence `CompactDense` / `CompactBase`, hence strong completeness via `design/01_set-consequence-layer.md` §5. | `S4`, then `S5-Dense` / `S5-Base` |

### Why not Mathlib's `FirstOrder.Language`?

Formalizing the standard translation into Mathlib's `FirstOrder.Language` was considered and
**rejected**. Mathlib's first-order framework is **single-sorted**, while the signature here is
genuinely two-sorted (`Ω` for histories, `D` for times). Encoding a two-sorted structure into a
single-sorted language requires sort predicates, relativized quantifiers, and a relativization
lemma for every clause of the translation — and the encoding cost would dominate the entire
proof. A bespoke ultraproduct of shift sets keeps the two sorts native and pays only for the
instances it actually needs.

---

## Risks

Four named risks, each with its Mathlib or tree coordinate. These are **risks, not blockers** —
they are the places where the estimate is soft.

### R1 — Dependent ultraproduct of carriers (largest unknown)

Each finite subset `L` may be satisfied over a **different** carrier `D_L`. The ultraproduct is
therefore dependent, and Mathlib's ordered instances live on the **non-dependent** germ type:

- `.lake/packages/mathlib/Mathlib/Order/Filter/FilterProduct.lean:92` gives `LinearOrder β*` for
  an `Ultrafilter` — but only for the non-dependent `Filter.Germ l β`.
- The dependent `Filter.Product ε` (`Mathlib/Order/Filter/Germ/Basic.lean:100`) has **no**
  ordered-group instances.

Two ways out: (a) a bespoke quotient of `∀ i, D i` with roughly 15 hand-supplied instances, or
(b) a prior normalization step forcing a common carrier. Estimated at one phase-sized file, but
this is the single largest unknown in the whole estimate.

### R2 — The `box` case of Łoś

`box` quantifies over the whole history sort `Ω*`, so the induction needs

```
(∀ σ* ∈ Ω*, P σ*)  ↔  ∀*i, (∀ σ ∈ Ω_i, P_i σ)
```

The `←` direction is immediate. The `→` direction needs a **choice-function argument** to
assemble a pointwise counterexample. Standard, but it is the step where a careless statement of
the ultraproduct would silently fail.

### R3 — `Type` vs `Type*`

`valid` and its siblings deliberately use `Type`, not `Type*`. Verified verbatim at
`Validity.lean:77`: "Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs."
The ultraproduct quotient **must land in `Type`**. With the index type in `Type` this is fine,
but the phase should assert it **early** rather than discover it at assembly time.

### R4 — Honest uncertainty

There is **no compactness proof here** — only an argument from the elementarity of the binder
lists plus the representation theorem. If `TruthAt` had any clause quantifying over subsets of
`D`, or if `ShiftClosed` / `τ ∈ Omega` could not be captured by the shift action, the argument
would collapse. All six `TruthAt` clauses (`Truth.lean:128-137`), `ShiftClosed` (:333),
`WorldHistory` (`WorldHistory.lean:75-104`) and `TaskFrame` (`TaskFrame.lean:99-128`) were read
directly and none of them does — but a formalization could still surface a mis-read clause.

**Verdict: promising, not certain.**

---

## GATING RULE

This section is **imperative** and binds every downstream task and every future plan.

> ### The rule
>
> The representation theorem (`S1`, spawned as task N4) is a **cheap feasibility gate** for the
> entire ultraproduct branch.
>
> 1. **The expensive branch MUST NOT be spawned before the gate returns positive.** `S2`
>    (ultraproduct carrier), `S3` (Łoś lemma), `S4` (compactness), `S5-Dense`, and `S5-Base` are
>    **not authorized** as tasks, phases, or dispatches until `S1` has landed and passed.
> 2. **"Gate passed" means exactly this evidence, and nothing weaker**: a **sorry-free** Lean
>    statement of **both directions** of the representation theorem, verified by
>    `#print axioms` on each direction reporting **no `sorryAx`**. A statement that type-checks
>    with a `sorry` body does not pass. A proof of only the forward direction does not pass. A
>    prose argument that the theorem "should hold" does not pass.
> 3. **Cancel condition**: if `S1` fails — either direction is refuted, or the construction
>    cannot be stated without an additional non-elementary hypothesis — then **Route B is
>    refuted** and the whole ultraproduct branch is **cancelled**, not retried. In that event the
>    correct response is to record the refutation and re-open the Q1 question, **not** to spawn
>    `S2` anyway on the hope that the gap can be patched downstream.
>
> The reason for the gate, stated plainly: `S1` is cheap and `S2` is expensive. Spawning `S2`-`S5`
> now would commit plan budget to a branch that `S1` can refute in a single run.

---

## Discrete non-compactness witness

The negative half. Worth doing, cheap, and independent of everything else. It converts the prose
at `StrongCompleteness.lean:56-62` (verified present — the module docstring already states this
argument informally) into a machine-checked theorem, and it is what justifies the whole per-class
split.

Statement sketch (design proposal only):

```lean
/-- The premise set `{F p} ∪ {¬ Xⁿ p : n ∈ ℕ}`, where `X φ = Formula.next φ = untl φ bot`. -/
def archWitness (p : Atom) : Set Formula :=
  {(Formula.atom p).someFuture} ∪ {ψ | ∃ n : Nat, ψ = (Formula.next^[n] (Formula.atom p)).neg}

/-- Every finite subset is satisfiable over `ℤ`: place `p` beyond the largest `n` used. -/
theorem archWitness_finitely_satisfiable (p : Atom) (L : List Formula)
    (hL : ∀ ψ ∈ L, ψ ∈ archWitness p) : SatisfiableDiscreteSet {ψ | ψ ∈ L} := …

/-- No Archimedean discrete carrier satisfies the whole set: the `F p` witness lies at some
    finite successor distance, contradicting the corresponding `¬ Xⁿ p`. -/
theorem archWitness_not_satisfiable (p : Atom) : ¬ SatisfiableDiscreteSet (archWitness p) := …

/-- Hence `⊨_Discrete` is not compact, hence strong completeness is REFUTED for this class
    (a derivation cites only finitely many premises). -/
theorem discrete_consequence_not_compact : ¬ CompactDiscrete := …
```

### The load-bearing ingredient, verified

`Formula.next` genuinely is a next-step operator. Verified verbatim at
`FormalSystem/Syntax/Formula.lean:490`:

```lean
/-- Next-step operator: X(phi) = U(phi, bot) (Burgess convention: event first, guard second).
    X(phi) at t means phi holds at t+1 (event=phi at immediate successor, guard=bot vacuous). -/
def next (φ : Formula) : Formula := Formula.untl φ Formula.bot
```

Reading this through the `untl` clause of `TruthAt`: `∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ⊥` says exactly
that `s` is the **immediate successor** of `t` — the guard `⊥` forces the open interval `(t,s)` to
be empty. So `X` is a genuine next-step operator on discrete orders, with no extra hypothesis
needed.

The `¬ satisfiable` half is where `IsSuccArchimedean` does its work, via `Order.succ_iterate`-style
reachability lemmas in Mathlib. `SatisfiableDiscreteSet` and `CompactDiscrete` are the
`Discrete`-class analogues of `SatisfiableDenseSet` / `CompactDense` from
`design/01_set-consequence-layer.md` §5 — this witness therefore depends on the set-based layer
landing first (task N3).

### Not recommended here: an analogous Dedekind witness

An analogous non-compactness witness for the Dedekind classes is explicitly **NOT** recommended in
this scope. It belongs to task 408 (`faithful_route_to_strong_completeness_for_the_dedekind_extension`,
status `implementing`), and the class's non-compactness is already established. Duplicating it here
would create scope overlap with an in-flight task for no gain.

---

## Divergences from the research report

One, and it is a correction in the report's favour rather than against it:

- The report cites `.../ChronicleToCountermodelBasic.lean` line numbers for the Cantor machinery.
  Those anchors are relevant to `design/03_weak-terminus-status.md`, not to this document, and the
  two small line-number drifts found are recorded there.

Everything else cited above — the `TemporalCoherence.lean:293-298` quote, the two `Finset` return
types, `RestrictedParametricTruthLemma.lean:417`, all six `TruthAt` clauses, `Validity.lean:77`,
`Formula.lean:490`, `Truth.lean:333`/:446, and the two Mathlib ultraproduct coordinates — was
independently re-verified against the tree in this session and matched the report exactly.
