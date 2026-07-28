# Blocker research: R3 — the forward case B guard

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Type**: lean4 (hard mode, orchestrator-dispatched blocker research)
- **Scope**: rung **R3 only**. R2 is dead on verbatim source evidence (Phase 7.2) and is not
  re-litigated anywhere below.
- **Reference grounding tier**: **Tier 1 (literature-backed)** — Burgess 1982 I, Burgess 1984,
  Reynolds 1992, all re-read verbatim in this dispatch.
- **Inputs**: `summaries/04_phase-7-2-forward-case-b-probe-summary.md`,
  `plans/04_strong-completeness-dedekind-v4.md` (Postmortem Constraints, Phases 6.3 / 7.2 / 8),
  `reports/04_backward-transport-blocker.md` (via plan v4's Phase 6.3 transcription),
  `.orchestrator-handoff.json` blockers, and the `Chronicle/` tree.
- **Artifacts**: this report.

---

## 0. Executive verdicts

| # | Question | Verdict |
|---|---|---|
| 1 | Literature: does any source obtain "the guard is *eventually* true below the gap", by axiom or by chronicle selection? | **No source performs this step at all.** Burgess 1984's completion runs in `F`/`G`, which **has no guard**, and gets its one gap lemma from axiom **A7a**, not from selection. Burgess 1982 I has `U`/`S` but **no Dedekind variant** and never places a witness at a gap — every witness is a *fresh* point `y = x + 1` or `z = (x + x')/2`, the exact discipline the tree already transcribes. Reynolds obtains every gap-facing formula "by expressive completeness", which is forbidden and dead. **R3 would be an original construction with no source.** |
| 2 | New lemma about the existing construction (a), threaded hypothesis with discharge (b), or genuine construction modification (c)? | **Split.** The invariant *itself* is **(c)** — a genuine modification of `ChronicleConstruction.lean` / `CounterexampleElimination.lean`. But the route around it decomposes: **R3a/R3b/R3c are (a)+(b)** and are landable now, reducing *both* unlanded forward cases to **one** named bundle predicate. Only the discharge (**R3d**) is (c). |
| 3 | Does the refuting family survive against the R3-strengthened form? | **The obstruction survives and is now sharper, not weaker.** This dispatch **proves** (sorry-free) that R3's invariant is *necessary*, so forward case B has exactly one possible content and there is no third route. It also exhibits a candidate refutation strictly stronger than Refutation 3 (**ultrafilter-independent**). Whether that family is realizable inside `cantorBfmcsDense` is **still unsettled**, and settling it needs the EF/expressive-completeness machinery the Postmortem Constraints forbid. **R3 is neither proved live nor proved dead.** |
| 4 | If viable, the faithful decomposition | Four sub-phases below (R3a–R3d). R3a–R3c: ~3 agent runs, **one** constraint amendment. R3d: no bounded decomposition, **three** constraint amendments, no source precedent. |
| 5 | With R3 landed, does Phase 8 close unconditionally? | **Only if R3d lands.** And Phase 8 has a **second, unlanded, never-chartered obligation**: `toRealBundle_forward_since_unselected`. It is not mentioned in any phase charter of plan v4. It is discharged by the *same* invariant, more cheaply. |

**Amendment required: YES** for the full R3 route (3 constraints). **NO** for the R3a–R3c prefix
except one (the bounded-witness prohibition).

**Recommended next dispatch**: revise plan v4 → v5 with the R3a–R3c prefix as determined work
(the invariant becomes a *named, phase-internal* predicate exactly as `LimitFutureWitness` was in
Phase 6.1), and put R3d to the **user** for an explicit authorization decision. The honest floor
if the user declines R3d is `[PARTIAL]` — but a `[PARTIAL]` that has reduced the whole remaining
forward obligation to a single named predicate, rather than to prose.

---

## 1. Question 1 — literature grounding (binding user directive)

All quotations below were re-read verbatim from disk **in this dispatch**. Printed-page
attributions follow report 04's mapping, which plan v4 records as adversarially verified; the
quoted text is independently re-extracted here and matches the passages report 04 cited.

### 1.1 Burgess 1984 §2.7 "Continuity" — printed pp.109-110

The completion construction, verbatim
(`/home/benjamin/Projects/Literature/sources/burgess_1984/sec05_basic-tense-logic-continuity.md`):

> "The **completion** `(X*, R*)` of a total order `(X, R)` is the complete total order obtained by
> inserting, for each gap `(Y, Z)` in `(X, R)`, an element `w(Y, Z)` after all elements of `Y` and
> before all elements of `Z`. For example, the completion of the rational numbers in their usual
> order is the real numbers in their usual order."  (printed p.109)

The gap lemma, verbatim:

> "**LEMMA**: Let `T` be a perfect chronicle on a total order `(X, R)`, and `(Y, Z)` a gap in
> `(X, R)`. Then if `Ga ∈ T(z)` for all `z ∈ Z`, then `Ga ∈ T(y)` for some `y ∈ Y`.
>
> *Proof.* Suppose for contradiction that `Ga ∈ T(z)` for all `z ∈ Z` but `Fa ∧ ¬Ga ∈ T(y)` for
> all `y ∈ Y`. For any `y₀ ∈ Y` we have `F¬a ∧ FGa ∈ T(y₀)`. **Hence, by A7a**,
> `F(Ga ∧ HF¬a) ∈ T(y₀)`, and there is an `x` with `y₀Rx` and `Ga ∧ HF¬a ∈ T(x)`. But this is
> impossible, since if `x ∈ Y` then `Ga ∈ T(x)`, while if `x ∈ Z` then `HF¬a ∉ T(x)`."
> (printed p.109)

And the gap-point MCS:

> "`C(Y,Z) = {Pa : ∃y ∈ Y (a ∈ T(y))} ∪ {Fa : ∃z ∈ Z (a ∈ T(z))}` is consistent. … Hence, we can
> define a coherent chronicle `T*` on `(X*, R*)` by taking `T*(w(Y, Z))` to be **some MCS
> extending** `C(Y, Z)`."  (printed p.109)

> "Now if `Fa ∈ T*(w(Y, Z))`, we claim that `Fa ∈ T(z)` for some `z ∈ Z`. For if not, then
> `G¬a ∈ T(z)` for all `z ∈ Z`, and by the previous Lemma, `G¬a ∈ T(y)` for some `y ∈ Y`. But then
> `PG¬a`, which implies `¬Fa`, would belong to `C(Y, Z) ⊆ T*(w(Y, Z))`, a contradiction. … **Axiom
> A7b** gives us a mirror image to the previous Lemma, which can be used to show `T*` historic."
> (printed pp.109-110)

**What this settles.** Three things, each decisive for R3:

1. **Burgess's gap step has no guard at all.** Every obligation discharged at `w(Y,Z)` is an
   `Fa`-prophecy or a `Pa`-history. `F`/`G` carries no interval datum, so the question "is the
   guard eventually true below the gap?" **cannot arise in his fragment**. This is why plan v4's
   H3 table maps his prophecy claim onto `BFMCS.LimitFutureWitness` and nothing else.
2. **The one "above the gap ⟹ below the gap" conversion he needs comes from an axiom (`A7a`),
   not from selection.** His Lemma is precisely the `F`/`G` shadow of the tree's landed
   `limitGuardBelow_of_priorS` (above → below). He does **not** select the chronicle to make
   anything eventually true; he takes an arbitrary chronicle and applies the continuity axiom.
3. **The chronicle is arbitrary and the gap MCS is an arbitrary Lindenbaum extension** ("some MCS
   extending `C(Y,Z)`"). There is no scheduling discipline anywhere in the argument.

He then states the scope explicitly:

> "Similarly, `L₆`, the extension of `L₄` obtained by adding `(A4a, b)` and `(A5a)` and
> `(A7a, b)` is complete for the class of complete dense total orders without maximum or minimum,
> sometimes called **continuous orders**. As a matter of fact, our construction shows that any
> formula consistent with this theory is satisfiable in **the completion of the rationals, that
> is, in the reals**."  (printed p.110)

— i.e. the route this plan takes is Burgess's route, and Burgess runs it **only** in `F`/`G`.

### 1.2 Burgess 1982 I — the `U`/`S` chronicle: witness placement and the absent variant

The variants table, verbatim
(`.../burgess_1982_i/chunk_0009.md`, printed p.369):

> | Postulates on `<` | Axioms for `S`, `U` |
> |---|---|
> | Density | `F'⊤` |
> | Discreteness | `G'⊥ ∧ H'⊥` |
> | First Element | `FPH⊥` |
> | Last Element | `PFG⊥` |
> | No First Element | `P⊤` |
> | No Last Element | `F⊤` |
>
> "For the reader familiar with ordinary `G`, `H`-tense logic, the adaptation of our work below to
> prove these variants is a routine exercise."

**No Continuity / Dedekind row.** The "routine exercise" remark is scoped to the six rows shown.

The Until-witness placement, verbatim (`.../burgess_1982_i/chunk_0022.md`, §2.10, printed
pp.372-373):

> "What we claim is that it is possible to **add a single point `y` lying after `x`** to `dom f`,
> and extend `f` and `g` to functions `f'` and `g'` on this enlarged domain, in such a way that
> `ξ ∈ f'(y)`, `η ∈ g'(x, y)`, and all the requirements for membership in `ℱ` are satisfied by
> `(f', g')`. We prove this by induction on the number `n` of elements of `dom f` lying after `x`.
>
> *Case `n = 0`.* We can apply 2.4 to `A = f(x)` obtaining `B`, `C`. **Set `y = x + 1`**,
> `f'(y) = C`, `g'(x, y) = B`, and let C3 determine the other values of `g'(w, y)`.
>
> *Case `n = m + 1`.* Let `x'` immediately succeed `x` in `dom f`. If (i) both
> `η ∧ U(ξ, η) ∈ f(x')` and `η ∈ g(x, x')`, then we can **reduce to the case `n = m` by replacing
> `x` by `x'`**. If (i) fails, note also that we cannot have (ii) both `ξ ∈ f(x')` and
> `η ∈ g(x, x')`; else `x`, `ξ`, `η` would not be a counterexample. But if (i) and (ii) both fail,
> then the hypotheses either of 2.7 or else of 2.8 must hold for `A = f(x)`, `B = g(x, x')`,
> `C = f(x')`. So we can obtain `B'`, `D`, `B''` as in the conclusion of 2.7. **Set
> `z = (x + x')/2`**, `f'(z) = D`, `g'(x, z) = B'`, `g'(z, x') = B''`, and let C3 determine the
> other values of `g'(w, z)` and `g'(z, w)`."

**What this settles.** Burgess's scheduling discipline is: *always add a **new** point, either
beyond the current maximum (`x + 1`) or at the **midpoint between `x` and its immediate successor
`x'`** (`(x + x')/2`).* There is **no** bookkeeping that prevents witnesses from accumulating,
because in his setting there is nothing to accumulate *at*: he never leaves `ℚ`, so a gap is not
a point of his model and no obligation is ever posed there.

**This is the discipline the tree already implements, verbatim.**
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` transcribes it
line-for-line:

- `c5_forward_walk`'s docstring (`:680-687`): *"**Base case** (start = max dom): Use
  `lemma_2_4_with_guard` to insert witness beyond. **Condition (i)** (conj ∈ f(x') ∧ ξ ∈
  g(start,x')): Recurse at x', compose guard. **Not condition (i)**: Split at (start, x') using
  lemma_2_7/2_8/2_6."* — Burgess's three cases, same numbering.
- `C5ForwardWalkResult.witness_not_old` (`:677`): *"The witness is **always a new point**, not in
  the original domain `χ.dom`. Base case: witness is placed beyond all domain points. …
  **Split case: witness is the midpoint `z`**"* — Burgess's `y = x + 1` and `z = (x + x')/2`.
- `Chronicle.dom : Finset Rat` (`ChronicleTypes.lean:557`) — each stage is **finite**;
  `LimitDom = {x | ∃ n, x ∈ (omegaChainVal … n).dom}` (`ChronicleConstruction.lean:579`).

### 1.3 Reynolds 1992 — gaps handled, but only through expressive completeness

Reynolds is the only source that both has `U`/`S` **and** reasons about gaps. Every one of his
gap-facing formulas is produced by expressive completeness
(`.../reynolds_1992/sec03_6-no-gaps-between-equivalence-classes.md`, printed pp.176-178):

> "Let `B` be the temporal formula saying that the `∼`-class we are now in begins with a point
> satisfying `R ∧ K⁻(¬R)`. **`B` exists by expressive completeness.** `B` holds in `s`'s class up
> to the gap and is false arbitrarily soon after the gap. This contradicts Prior-U applied to `B`."

> "**Using expressive completeness and `ε`**, find `B` which is true at points only if `A` occurs
> somewhere in their `∼`-class."

> "**Using `ε` and expressive completeness** we can find a temporal formula `C` which is true only
> at points within a `∼`-class after some `¬B` in that class. … In fact `C` is true for a while up
> to the gap at the end and false arbitrarily soon after the gap. This contradicts Prior-U."

And the definition that fixes what Prior-U *needs*
(`.../reynolds_1992/sec06_5-expressive-dedekind-completeness.md`, printed p.175):

> "Given a temporal formula `A`, we can define a connective `γ⁺` by saying that `γ⁺(A)` holds
> exactly when `A` **remains true for a while after now** but only up until a gap after which `A`
> is arbitrarily soon false. If `γ⁺(A)` is true anywhere we call the indicated gap an `A` *left
> gap* and more generally a *definable gap*. Dually there is `γ⁻` and *right gaps*."

And Theorem 3's use (printed p.176):

> "Suppose for contradiction that `M ⊨ U'(A, B)(t)` in some Prior structure `M`. **Thus `B` holds
> for a while up until a gap** after which `¬B` is true arbitrarily soon. By Prior-U applied to
> `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."

**What this settles.** "Holds for a while up until a gap" is *exactly* the eventually-true-below
condition. Reynolds always has it **as a hypothesis of the case he is in** (the `U'` semantics
hands it over, or expressive completeness manufactures a formula for which it holds). He **never**
imposes a construction-level invariant to obtain it — he reasons about an *already given* Prior
structure `M`, not about a chronicle he is building. There is no witness-scheduling discipline
anywhere in Reynolds.

### 1.4 Gabbay–Hodkinson–Reynolds 1994 / Venema 2001

Both are present on disk (`sources/gabbay_1994`, `sources/gabbay_1994_ch10`,
`sources/venema_2001`). They are not consulted for a *different* answer here: GHR §10.3 is the
book-form presentation of exactly the Reynolds 1992 route (separability + Doets +
`Axiom.sep`), which Phase 7.2 has already killed on the kill-clause "if an escalation needs
expressive completeness of `{U,S}`, R2 is dead". Consulting it further would be re-litigating R2,
which this dispatch's scope forbids. Recorded as **not consulted, by scope**, not as absent.

### 1.5 Verdict on question 1

> **No source in the corpus obtains "the Until-guard is eventually (not merely cofinally) true
> below the gap", by any means.**
>
> - **Burgess 1984** does not need it: his completion runs in `F`/`G`, which has no guard. His one
>   gap conversion (`Ga` above ⟹ `Ga` below) comes from **axiom A7a**. He selects nothing.
> - **Burgess 1982 I** has the guard (his interval datum `g(x,y)`) but **never reaches a gap**: no
>   Dedekind variant exists in his table (printed p.369) and every witness is a fresh point placed
>   between existing rationals (printed pp.372-373). He has no scheduling discipline because he
>   needs none.
> - **Reynolds 1992** has both, and gets every gap-facing formula from **expressive completeness**
>   — forbidden by the Postmortem Constraints and already fatal to R2.
>
> **R3 therefore has no source.** It is not a step this task can transcribe faithfully; it is a
> step this task would have to *invent*. Given that the task's own name and charter are
> *faithful route*, this is a first-order finding, not a footnote.

---

## 2. H3 source-to-implementation mapping (Tier 1, 5-column)

| Source | Prop / Location | Lean identifier | Type signature | Status |
|---|---|---|---|---|
| Burgess 1984 | §2.7 Lemma, printed p.109 ("if `Ga ∈ T(z)` for all `z ∈ Z`, then `Ga ∈ T(y)` for some `y ∈ Y`", by A7a) | `limitGuardBelow_of_priorS` | `{fc} (hfc : FrameClass.Dedekind ≤ fc) (m : Rat → Set Formula) (hm) (hSf) (hSb) (r : ℝ) (hr : ¬∃ q:Rat, (q:ℝ)=r) (ψ) (c : Rat) (hc : r < (c:ℝ)) (hguard : ∀ q:Rat, r<(q:ℝ) → (q:ℝ)<(c:ℝ) → ψ ∈ m q) : ψ ∈ limitSetBelow m r` | **LANDED** (`ChronicleLimitGuardWitness.lean:105`), sorry-free. This dispatch's necessity theorem is its first *contrapositive* consumer |
| Burgess 1984 | §2.7 prophecy claim, printed pp.109-110 ("if `Fa ∈ T*(w(Y,Z))` … `Fa ∈ T(z)` for some `z ∈ Z`") | `limitFutureWitness_of_priorU`, `BFMCS.LimitFutureWitness` | `… (r : ℝ) (hr : ¬∃ q, (q:ℝ)=r) (φ) (hF : Formula.someFuture φ ∈ limitMCSBelow m r) : ∃ s : Rat, r < (s:ℝ) ∧ φ ∈ m s` | **LANDED** (Phase 6.2), sorry-free |
| Reynolds 1992 | Thm 3, printed p.176 ("`B` holds for a while up until a gap … By Prior-U applied to `B` … `U(¬B ∨ K⁺(¬B), B)(t)`") | **`limitGuardAbove_of_priorU`** (proposed, R3a) | `{fc} (hfc : FrameClass.Dedekind ≤ fc) (m) (hm) (hUf) (hUb) (r : ℝ) (hr : ¬∃ q, (q:ℝ)=r) (ψ) (hev : ψ ∈ limitSetBelow m r) : ∃ c : Rat, r < (c:ℝ) ∧ ∀ q : Rat, r < (q:ℝ) → (q:ℝ) < (c:ℝ) → ψ ∈ m q` | **NOT LANDED.** Statement **verified to elaborate** against the tree in this dispatch. Exact Prior-U mirror of the landed Prior-S lemma (below → above instead of above → below) |
| Burgess 1984 | §2.7, printed pp.109-110 (the far-side witness, unbounded, licensed by A7a) | **`boundedWitness_of_limitGuardBelow`** (proposed, R3b) | `… (r : ℝ) (hr) (φ) (hcof : ∀ z:ℝ, z<r → ∃ w:Rat, z<(w:ℝ) ∧ (w:ℝ)<r ∧ φ ∈ m w) (c : Rat) (hc : r<(c:ℝ)) : ∃ w : Rat, r<(w:ℝ) ∧ (w:ℝ)<(c:ℝ) ∧ φ ∈ m w` | **PROVED sorry-free in this dispatch** (12 lines, from the landed `limitGuardBelow_of_priorS`). **Currently prohibited** by a v4 Postmortem Constraint |
| Reynolds 1992 | `γ⁺` / left gaps, printed p.175 ("`A` remains true for a while after now but only up until a gap") | **`BFMCS.LimitGuardEventual`** (proposed, R3c) | `{fc} (B : BFMCS (fc := fc) Rat) : Prop := ∀ fam ∈ B.families, ∀ r : ℝ, (¬∃ q, (q:ℝ)=r) → ∀ φ ψ, (Formula.untl φ ψ ∈ limitMCSBelow fam.mcs r ∨ Formula.snce φ ψ ∈ limitMCSBelow fam.mcs r) → ψ ∈ limitSetBelow fam.mcs r` | **NOT LANDED.** Statement shape verified to elaborate. This is the entire residual content of forward coherence at ℝ |
| Burgess 1982 I | §2.10, printed pp.372-373 (`y = x+1`; `z = (x+x')/2`; "add a single point `y` lying after `x`") | `c5_forward_walk`, `C5ForwardWalkResult.witness_not_old` | (construction internals, `CounterexampleElimination.lean:~677-690`) | **LANDED and faithful.** The tree transcribes Burgess's placement exactly. It contains **no** accumulation bookkeeping — this is what R3d would have to add, and it has **no source** |
| Burgess 1982 I | Variants table, printed p.369 | *(evidence, no identifier)* | Density / Discreteness / First / Last / No First / No Last — **no Continuity row** | **Evidence only.** Grounds the verdict that R3 is unsourced |
| Reynolds 1992 | §6, printed pp.176-178 ("`B` exists by expressive completeness"; "Using expressive completeness and `ε`, find `B`") | *(constraint check — nothing built)* | — | **FORBIDDEN.** Any R3d proof that reaches for a formula defining a gap-boundary re-enters this dependency and is dead on the same clause that killed R2 |

---

## 3. The load-bearing new result: R3's invariant is **necessary**

The probe left R3 as a *sufficient* condition ("if the guard is eventually true below the gap,
then …"). This dispatch establishes the converse, which changes the strategic picture: **R3's
invariant is not one option among several — it is exactly what forward case B says.**

Both theorems below were **proved sorry-free** in a scratch snippet run against the real tree via
`lean_run_code` (no tree files written). Diagnostics: `success: true`, no errors, no `sorry`.

**(N) Necessity.** Given the landed `LimitGuardBelow` shape at `t + δ`, if the forward `untl`
obligation at an unselected `t` is dischargeable *at all* — i.e. there exists **any** real `s > t`
with the guard `ψ` holding at every real of `(t, s)` — then `ψ ∈ limitSetBelow m (t + δ)`.

```lean
theorem r3_invariant_necessary
    (m : Rat → Set Formula) (δ t : ℝ) (ψ : Formula)
    (hgb : ∀ (c : Rat), t + δ < (c : ℝ) →
      (∀ q : Rat, t + δ < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q) → ψ ∈ limitSetBelow m (t + δ))
    (s : ℝ) (hts : t < s)
    (hguard : ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS m δ r) :
    ψ ∈ limitSetBelow m (t + δ) := by
  obtain ⟨c, hc1, hc2⟩ := exists_rat_btwn (show t + δ < s + δ by linarith)
  refine hgb c hc1 (fun q h1 h2 => ?_)
  have hq : ψ ∈ realLimitMCS m δ ((q : ℝ) - δ) :=
    hguard ((q : ℝ) - δ) (by linarith) (by linarith)
  rwa [realLimitMCS_of_rat m δ ((q : ℝ) - δ) q (by ring)] at hq
```

Read: the guard clause of the conclusion is quantified over **all** reals in `(t, s)`, and the
selected ones among them are precisely the rationals of `(t + δ, s + δ)`. So the conclusion
*hands back* a rational guard interval abutting the gap from above, and the landed
`LimitGuardBelow` converts it to one abutting from below. **The conclusion of forward case B
entails its own R3 hypothesis.**

**(S) Sufficiency — the missing bounded witness, proved.**

```lean
theorem boundedWitness_of_limitGuardBelow {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
    (hSf …) (hSb …)
    (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (φ : Formula)
    (hcof : ∀ z : ℝ, z < r → ∃ w : Rat, z < (w : ℝ) ∧ (w : ℝ) < r ∧ φ ∈ m w)
    (c : Rat) (hc : r < (c : ℝ)) :
    ∃ w : Rat, r < (w : ℝ) ∧ (w : ℝ) < (c : ℝ) ∧ φ ∈ m w := by
  by_contra hcon
  push_neg at hcon
  have hguard : ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → φ.neg ∈ m q := by
    intro q h1 h2
    rcases SetMaximalConsistent.negation_complete (hm q) φ with h | h
    · exact absurd h (hcon q h1 h2)
    · exact h
  obtain ⟨z, hz, hall⟩ := limitGuardBelow_of_priorS hfc m hm hSf hSb r hr φ.neg c hc hguard
  obtain ⟨w, hzw, hwr, hphi⟩ := hcof z hz
  exact SetMaximalConsistent.neg_excludes (hm w) φ (hall w hzw hwr) hphi
```

Its `hcof` hypothesis is **literally the right disjunct** of the landed
`toRealBundle_forward_until_unselected_dichotomy` (`ChronicleRealExtension.lean:732`):
`∀ z : ℝ, z < t + δ → ∃ w : Rat, z < (w:ℝ) ∧ (w:ℝ) < t + δ ∧ φ ∈ fam.mcs w`. It is available
free in case B.

**Consequence.** Forward case B closes, given `ψ ∈ limitSetBelow m (t+δ)`, by this chain:

1. Fix rational `x` inside the below-gap guard interval. `U(⊤, ψ) ∈ m x` from `hUb`.
2. If `¬ψ` never occurs above `x`, the guard is free everywhere above and Phase 6.2's
   `limitFutureWitness_of_priorU` (via `untl φ ψ ⊢ someFuture φ`) supplies the witness. Done.
3. Otherwise `F(¬ψ) ∈ m x`; `Axiom.prior_U_gap` at `ψ` gives
   `untl (ψ.neg ∨ kPlus ψ.neg) ψ ∈ m x`, and `hUf` an endpoint `e > x` with `ψ` on `(x, e)`.
4. `e > t + δ`: `e < t+δ` forces `ψ ∈ m e` hence `kPlus ψ.neg ∈ m e`, contradicted by
   `U(⊤, ψ.neg.neg) ∈ m e` built from the below-gap interval; `e = t+δ` is excluded by
   unselectedness. **(This is the only use of unselectedness — exactly one, as in Phase 6.3.)**
5. `boundedWitness_of_limitGuardBelow` at `c := e` and the dichotomy's cofinal `φ` yields a
   rational `w ∈ (t+δ, e)` with `φ ∈ m w`.
6. `(w : ℝ) - δ` is the real witness; `guard_transport_realLimitMCS` (landed, `:283`) carries the
   guard on `(x, e)` to every real strictly between.

Steps 1–4 are `limitGuardAbove_of_priorU` (**R3a**); step 5 is **R3b**; step 6 is landed.

**And the forward `snce` half needs only the invariant, with no Prior-U step at all**: the
obligation is `∃ s < t` with `φ` at `s` and `ψ` on `(s, t)`, i.e. `ψ` on rationals abutting
`t + δ` **from below** — which *is* `ψ ∈ limitSetBelow m (t+δ)`, verbatim. The `φ` comes from the
same cofinal descent.

> **Therefore `BFMCS.LimitGuardEventual` is necessary and sufficient for the whole remaining
> forward obligation, both halves.** There is no third route, no weaker sufficient condition, and
> no way to sidestep it. Any future dispatch that proposes one has not read this section.

---

## 4. Question 2 — (a), (b), or (c)?

### 4.1 Why it cannot be (a) — a new lemma about the existing construction proved from the axioms

The 6.2/6.3 pattern has a precise shape: **a general `fc`-conditional lemma derived from a
Dedekind *axiom*, plus a chronicle discharge that is a two-line self-root instantiation of
unrestricted coherence.** Phase 6.3's discharge writes *no chronicle-level proof at all*:

```lean
hSf := fun t α β h => (Chronicle.cantor_bfmcs_dense_restricted_fuc … (Formula.snce α β) fam hfam).2
         t α β (self_mem_subformulaClosure _) h
```

That pattern is available **only when the property is a semantic consequence of the axioms plus
rational coherence.** `LimitGuardEventual` is not, and the reason is structural rather than
tactical:

- The only axioms that can produce an interval abutting a gap are `prior_U_gap` and
  `prior_S_gap`. Phase 7.2 established (and this dispatch confirms) that `prior_U_gap`'s
  antecedent `U(⊤, χ)` **is** the below-gap interval — so it can never *produce* one.
  `prior_S_gap` produces one, but only *from* an above-gap interval; that is the landed
  `limitGuardBelow_of_priorS`, and §3 shows it yields the **necessity** direction, i.e. it
  consumes the conclusion rather than supplying the hypothesis.
- `Axiom.sep` is the only other `.Dedekind` axiom (`Axioms.lean:398`, `minFrameClass` block at
  `:524`). Its shape is `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)` — entirely inside `K⁺`/`K⁻`
  (arbitrarily-soon), which is the *negation* of "holds on an interval". It cannot produce an
  interval either, and Reynolds' own use of it is the separability route, which is dead.

So there is no axiom to apply. **(a) is unavailable.**

### 4.2 Why the seam is genuinely `Chronicle/` and *not* `cantorIsoDense`

The family the completeness proof sees is
`CantorFDense q := LimitF fc A h_mcs ((cantorIsoDense fc A h_mcs h_dense).symm q).val`
(`ChronicleToCountermodelBasic.lean:250`) — the chronicle's assignment pulled back through an
**order isomorphism** `ℚ ≅ LimitDom`. A natural first thought is that "accumulation at an
irrational" is a metric fact that the Cantor isomorphism scrambles, and that the isomorphism is
therefore the real lever. **That is wrong, and the correction matters**, so it is recorded here:

> For `S ⊆ ℚ`, *"`S` has an accumulation point at some **irrational** `T`, approached from below"*
> is equivalent to *"there is `S₀ ⊆ S` with no maximum, bounded above in `ℚ`, whose set of upper
> bounds in `ℚ` has no minimum."*
>
> (⇐) `T := sup S₀` is a limit of `S₀` from below since `S₀` has no max; and `T ∈ ℚ` would make
> `T` the least upper bound, contradiction, so `T` is irrational.
> (⇒) take `S₀ := S ∩ (T-1, T)`; upper bounds are `{q > T}`, which has no minimum since `T ∉ ℚ`.

The right-hand side mentions only `<`, boundedness, maxima and minima — it is **purely
order-theoretic and therefore invariant under `cantorIsoDense`**. The property transfers exactly
between `(LimitDom, <)` and `(ℚ, <)`. So the Cantor transport is *not* a lever, and the plan's
standing constraint against editing `cantorIsoDense` costs nothing here. **R3's seam is
`ChronicleConstruction.lean` / `CounterexampleElimination.lean`, exactly as the R3 fallback
clause said.**

### 4.3 What the construction actually contains

Verified directly:

| Fact | Anchor |
|---|---|
| Stage 0 is `singletonChronicle A`; stage `n+1` is `eliminatePotentialCounterexample` applied to `counterexampleEnum (Nat.unpair n).2` | `ChronicleConstruction.lean:265-275` |
| Each stage's domain is **finite**: `Chronicle.dom : Finset Rat` | `ChronicleTypes.lean:557` |
| `LimitDom = {x | ∃ n, x ∈ (omegaChainVal … n).dom}` — a countable `Set Rat` | `ChronicleConstruction.lean:579` |
| The stage invariant is `ChronicleInvariant` with fields `hc0`, `hc1`, `hc2'`, `hc3`, … — **nothing about ordering, placement, or accumulation** | `ChronicleTypes.lean:745-755` |
| Every C5 (Until) witness is a **fresh** point: `witness_not_old : witness ∉ χ.dom` | `CounterexampleElimination.lean:677` |
| Placement is Burgess's: beyond the max (`exists_rat_gt_finset`) or the **midpoint** of `(start, successor)` | `CounterexampleElimination.lean:671, 707, 2243` |
| Guards propagate as an interval datum: `g_sub_f_insert : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom → a < w → w < b → χ.g a b ⊆ val.f w` | `CounterexampleElimination.lean:660` |

The last row is the one piece of good news: the chronicle **does** retain Burgess's interval datum
`g(x,y)` that plan v4's H3 table noted had been "discarded" at the `Bundle/` level. Once
`ξ ∈ g(a,b)`, every point ever inserted into `(a,b)` carries `ξ`. So guard regions are genuine
intervals *of the domain*. What is missing is any control over **where the endpoints of those
intervals accumulate**.

### 4.4 Verdict on question 2

> **(c) — a genuine construction modification, for the invariant itself; but the route around it
> decomposes, and three of its four parts are (a)/(b).**
>
> `BFMCS.LimitGuardEventual` is not derivable from the Dedekind axioms plus rational coherence
> (§4.1), it is order-theoretic and therefore not reachable through the Cantor transport (§4.2),
> and the existing ω-chain carries no invariant that could imply it (§4.3). Discharging it for
> `cantorBfmcsDense` requires a **new invariant threaded through the whole finite-stage
> construction**: something of the form *"for every guard formula `ψ` in the closure, every
> bounded ascending sequence of `¬ψ`-points in `dom` has a least upper bound in `dom`"* —
> a Dedekind-closedness condition on the state classes, maintained across every insertion in
> `eliminatePotentialCounterexample`, and preserved by the `c5_forward_walk` / `c5_backward_walk`
> / `c4_*` eliminations.
>
> That is a modification of `ChronicleConstruction.lean` and `CounterexampleElimination.lean` —
> the two largest and most heavily-invariant-laden files on the route — and it has **no source**
> (§1.5).
>
> **But**: `limitGuardAbove_of_priorU` (R3a) is pure (a) — a general lemma from `prior_U_gap`,
> the exact mirror of a landed file. `boundedWitness_of_limitGuardBelow` (R3b) is pure (a) and is
> **already proved** (§3). The composition into forward case B, conditional on the named predicate
> (R3c), is pure (b) — the identical shape Phase 6.1 used for `LimitFutureWitness`, which plan v4
> explicitly permits ("Phase 6.1's conditional hypothesis was acceptable only because it was
> phase-internal with a named discharge phase"). Only the discharge (R3d) is (c).

---

## 5. Question 3 — does the refuted family survive against the R3-strengthened form?

### 5.1 The strengthened candidate refutation (ultrafilter-**independent**)

Refutation 3's weakness, stated honestly in the probe, is that `{q | untl φ ψ ∈ m q}` is cofinal
and co-cofinal below `T`, so membership in `limitMCSBelow` is decided by the arbitrary
`Ultrafilter.of` — hence "not derivable", not "false". A strictly stronger family removes that
weakness:

> **Family Q.** One atom `P`. Fix an irrational `T`. Rationals `t_n ↗ T` and `u_n ↓ T`. Let
> `V(P) = {t_n} ∪ {u_n}` and let `m q` be the theory of `q` in the ℚ-structure `Q = (ℚ, <, V(P))`.
> Put `φ := P`, `ψ := ¬P`.

- `untl P ¬P` is true at **every** rational of `(-∞, u_0)`: at any `x` the `P`-set is locally
  finite away from `T`, so there is always a next `P`-point with no `P`-point strictly between.
  Hence `{q | untl φ ψ ∈ m q} ⊇ (a, T) ∩ ℚ` for every `a < T`, so
  `untl φ ψ ∈ limitSetBelow m T ⊆ limitMCSBelow m T` by `limitFilterBelow_le`
  (`LimitMCS.lean:347`) — **no ultrafilter choice is involved.**
- `ψ = ¬P` fails at every `t_n`, so `ψ ∉ limitSetBelow m T`. By §3(N) the obligation is
  **unsatisfiable at `T`**; concretely, every `(T, s)` contains some `u_m`, a *selected* real at
  which `ψ` fails.
- Rational Until/Since coherence, in **both** directions and for **all** formulas, is automatic:
  `Q` is a genuine ℚ-structure, so every `U`/`S` witness is by definition a rational of the
  structure. (This is the point at which the naive "restrict a real model to ℚ" version fails —
  in the real model the formula `¬untl(P, ¬P)` is true exactly at `T`, so `F(¬untl(P,¬P))` has no
  rational witness. Defining `Q` **intrinsically over ℚ** avoids this: there, `untl P ¬P` is true
  everywhere and that formula is unsatisfiable.)

So `Q` refutes the forward transport **unconditionally**, provided each `m q` is
`SetMaximalConsistent (fc := FrameClass.Dedekind)`.

### 5.2 Why realizability is still unsettled — and why settling it is forbidden

`m q` is Dedekind-maximal-consistent iff `Q` validates every instance of `prior_U_gap`,
`prior_S_gap` and `sep` at every rational. `prior_U_gap` fails in `Q` **iff** some formula `A` is
eventually true below `T` while `¬A` occurs arbitrarily soon above `T` — i.e. iff some formula
distinguishes the deep `t`-cluster from the deep `u`-cluster in the appropriate one-sided way.

The natural argument that no formula does is an Ehrenfeucht–Fraïssé / modal-depth argument: a
point deep in the `t`-cluster has, to its right, an infinite ascending run of `P`-points, and to
its left `n` of them before an empty stretch; a point deep in the `u`-cluster is the mirror. For
depth `d < min(n, m)` both look exactly like a point of `(ℚ, <, ℤ)`, whose definable sets are only
`∅`, `ℤ`, `ℚ\ℤ`, `ℚ` (the `q ↦ q+1` automorphism forces this), and in which `prior_U_gap` and
`prior_S_gap` are immediate.

**That argument is exactly the machinery the Postmortem Constraints forbid** ("no EF games, no
`≡_k`, no expressive-completeness theorem") and it is the machinery that killed R2. It is
therefore not available as a *tree* result, and this dispatch declines to build it. Consequently:

- The claim "`Q` is realizable at `fc = FrameClass.Dedekind`" is **UNVERIFIED**, at the same
  epistemic level as Refutation 3's realizability inside `cantorBfmcsDense`.
- The mirror claim "`Q` is *not* realizable" is equally unsupported.

### 5.3 Does the construction produce the pattern?

Independent of `Q`'s consistency, the direct question is whether `cantorBfmcsDense` itself
produces a guard-failure set with an irrational accumulation point. The evidence is suggestive but
short of proof:

- **Against R3**: Burgess's discipline, transcribed verbatim, is *always insert a fresh point at
  the midpoint of `(x, successor(x))`*. `counterexampleEnum` is surjective onto **all**
  `PotentialCounterexample` records (`ChronicleConstruction.lean:218`), so a single domain point
  `x` is revisited infinitely often with different `(ξ, η)`, and each genuine counterexample
  inserts another fresh point into the shrinking interval to `x`'s right. Nothing in
  `ChronicleInvariant` bounds where those insertion points converge.
- **For R3**: the closure is a `Finset` (`SubformulaClosure/Closure.lean:36`), so only **finitely
  many** guard formulas ever matter; and no formula can *force* accumulation at a gap (a formula
  can force accumulation only at a **point**, via `K⁻(¬ψ)`, and accumulation at a domain point is
  harmless because domain points are *selected* and never use the limit). So the invariant is not
  contradicted by any formula-level demand — it is purely a question of construction discipline,
  and a discipline that reuses an existing witness whenever one exists (as
  `eliminatePotentialCounterexample`'s `h_actual` check already does) is at least conceivable.

### 5.4 Verdict on question 3

> **The obstruction survives R3's strengthening in the sense that matters: it has not been
> removed, and it is now proved to be the *only* content of the remaining work.**
>
> - **R3 is not dead.** The invariant is consistent with every formula-level demand (§5.3), only
>   finitely many guards matter, and the chronicle already retains the interval datum `g(x,y)`
>   needed to state it.
> - **R3 is not live either.** The candidate refutation `Q` is now ultrafilter-independent — a
>   strict strengthening over Refutation 3 — and settling its realizability requires forbidden
>   machinery. The existing construction demonstrably lacks the invariant, and adding it has no
>   source.
> - **Therefore the honest floor stands**: `[PARTIAL]` with Phase 8 unreachable — but a
>   *materially better* `[PARTIAL]` than the current one is available, because R3a–R3c reduce the
>   entire remaining forward obligation (both halves) to **one named predicate with a stated
>   discharge phase**, which is the same discipline Phases 6.1 → 6.2 and 7.1′ → 6.3 already used
>   successfully twice on this route.

---

## 6. Question 4 — the faithful decomposition, if R3 is elected

Each sub-phase is bounded to one agent run (H8). Territory is disjoint.

### Phase 7.3 — `limitGuardAbove_of_priorU` (R3a)

- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardAbove.lean` (new);
  `FormalSystem/Metalogic/BXCanonical.lean` (import line only).
- **Statement** (verified to elaborate against the tree in this dispatch):
  ```lean
  theorem limitGuardAbove_of_priorU {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
      (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
      (hUf : ∀ (t : Rat) (α β : Formula), Formula.untl α β ∈ m t →
        ∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p)
      (hUb : ∀ (t : Rat) (α β : Formula),
        (∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p) →
        Formula.untl α β ∈ m t)
      (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (ψ : Formula)
      (hev : ψ ∈ limitSetBelow m r) :
      ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q
  ```
- **Proof**: steps 1–4 of §3. Exact mirror of `limitGuardBelow_of_priorS`
  (`ChronicleLimitGuardWitness.lean:105-207`) with `snce → untl`, `prior_S_gap → prior_U_gap`,
  `kMinus → kPlus`, `.2 → .1`, and the direction of every inequality reversed. Same plumbing
  (`htop`, `conj_mcs`, `theorem_in_mcs (DerivationTree.axiom … hfc)`, `implication_property`,
  `neg_excludes`, `negation_complete`, `exists_rat_btwn`). Unselectedness is used **exactly once**
  (to exclude `(e : ℝ) = r`).
- **Plus** the chronicle discharge, verbatim clone of `cantor_bfmcs_dense_limit_guard_below` with
  `.2 → .1` and `root := Formula.untl α β`. **No chronicle declaration is edited.**
- **Amendment required**: **none.**
- **Estimated output**: ~180-220 lines. **Timing**: 3 hours.

### Phase 7.4 — the bounded witness (R3b) + the conditional forward transport (R3c)

- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (extends);
  `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (**predicate definition only**, appended
  beside `LimitFutureWitness` and `LimitGuardBelow` — change nothing else in that file).
- **Statements**: `boundedWitness_of_limitGuardBelow` **exactly as proved in §3** (it is 12 lines
  and already verified; do not re-derive it, transcribe it); `BFMCS.LimitGuardEventual` as in the
  H3 table; then `toRealBundle_forward_until_unselected`, `toRealBundle_forward_since_unselected`,
  and their composition `BFMCS.toRealBundle_restricted_forward_until_since` conditional on
  `B.LimitGuardEventual`.
- **State `LimitGuardEventual` closure-free and with no `root` argument**, for the identical reason
  Phase 6.3 recorded for `LimitGuardBelow`: the guard `ψ` of an `untl φ ψ ∈ subformulaClosure root`
  need not lie in `deferralClosure root`.
- **Amendment required**: **one** — the v4 bounded-witness prohibition (text in §8).
- **Estimated output**: ~200-240 lines. **Timing**: 4 hours. **Depends on**: 7.3.

### Phase 7.5 — the chronicle discharge (R3d) — **NOT dispatchable as specified**

- **Target**: `cantor_bfmcs_dense_limit_guard_eventual`.
- **What it requires**: a new field on the finite-stage invariant, of the shape *"for every
  `ψ` in the (finite) closure, every ascending sequence of `¬ψ`-points in `dom` that is bounded
  above in `dom` has a least upper bound in `dom`"*, established at stage 0, preserved by every
  branch of `eliminatePotentialCounterexample` (`c5_forward_walk`, `c5_backward_walk`,
  `c4_forward`, `c4_backward`), and transported to `LimitDom`.
- **Why it is not one agent run**: the invariant is not local to the insertion — it constrains the
  *limit* of infinitely many insertions, so it needs a scheduling argument over the ω-chain, not a
  per-stage lemma. `CounterexampleElimination.lean` is >3000 lines and the placement is Burgess's
  verbatim, so the modification is not a patch but a redesign of the witness-placement discipline.
- **Amendment required**: **three** (texts in §8), plus explicit user authorization.
- **Honest risk assessment**: this is the step with **no source** (§1.5). Every prior escalation on
  this task that lacked a source (`limitMCS_no_oscillation`, the `fc`-generic backward transport,
  the bounded-witness detour as a *route*, R2) was subsequently refuted or killed. That base rate
  is a fact about this task and belongs in the decision.

---

## 7. Question 5 — Phase 8's remaining obligations against the current inventory

`fully_restricted_parametric_completeness_from_neg_membership`
(`RestrictedParametricTruthLemma.lean:417-422`) consumes **three** coherence hypotheses:
`h_rtc`, `h_buc`, `h_fuc`. Inventory of the ℝ-side instances:

| Obligation | Status | Anchor |
|---|---|---|
| `cantor_bfmcs_dense_real_restricted_tc` | **LANDED** | `ChronicleRealExtension.lean:800` |
| `cantor_bfmcs_dense_real_restricted_buc` | **LANDED** | `ChronicleRealExtension.lean:825` |
| `cantor_bfmcs_dense_real_restricted_fuc` | **NOT LANDED** | — |
| ↳ forward `untl`, selected target | LANDED | `:334` `toRealBundle_forward_until_selected` |
| ↳ forward `untl`, unselected, case A | LANDED | `:690`, `:723` |
| ↳ forward `untl`, unselected, case B | **BLOCKED** — needs `LimitGuardEventual` | `:876` reaches the eventuality half only |
| ↳ forward `snce`, selected target | LANDED | `:361` `toRealBundle_forward_since_selected` |
| ↳ **forward `snce`, unselected target** | **NOT LANDED AND NEVER CHARTERED** | no declaration exists; no task in any phase of plan v4 names it |
| ↳ `BFMCS.toRealBundle_restricted_forward_until_since` | NOT LANDED | composition of the four above |

Then Phase 8's own eight tasks (root placement, `countermodel_dedekind_dense` with `hfc`,
`completeness_dedekind_engine`, instantiating the pinned
`consequence_completeness_dedekind_of_engine`, the `Γ = []` corollary, two `#print axioms`, the
`FormalSystem/Metalogic.lean` tracking table, full `lake build`).

### Verdict on question 5

> **No.** With R3a–R3c landed, Phase 8 does **not** close: the terminus would be conditional on
> an undischarged `BFMCS.LimitGuardEventual`, which the Postmortem Constraints prohibit outright
> ("Do NOT make `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
> `consequence_completeness_dedekind`, or `completeness_dedekind` conditional on an undischarged
> bundle-shaped predicate"). Phase 8 closes unconditionally **iff R3d lands**.
>
> **Second finding, independent of R3**: plan v4 has a **charter gap**. The forward `snce`
> obligation at an unselected target is required by `h_fuc` and is landed nowhere; Phase 7.2's
> charter names only the `untl` half ("obtain the real Until witness from a membership at an
> unselected `t`"), and Phase 7.1′ chartered only the three *backward* cases. Even under the most
> optimistic reading of the current plan, Phase 8 was never reachable, because a required case was
> never assigned to any phase. §3 shows the same invariant discharges it, more cheaply than the
> `untl` half.

---

## 8. Plan-fidelity determination and exact amendment text

### 8.1 Is a plan revision required?

**Yes — plan v4 must be revised to v5 before any further implement dispatch**, for three
independent reasons, only one of which is about R3:

1. **The charter gap** (§7): a required obligation, forward `snce` at an unselected target, is
   assigned to no phase. This is a defect in v4 regardless of the R3 decision.
2. **Phase 8's heading marker** is `[IN PROGRESS]` at `plans/04_…-v4.md:2320`, but v4's own
   Revision Rationale item 7 states it was corrected to `[NOT STARTED]`. The orchestrator's phase
   scan reads that heading. This is a live inconsistency.
3. **The R3 decomposition** (§6) needs phases 7.3/7.4 (and, if authorized, 7.5) with the
   necessity theorem of §3 recorded as the reason the decomposition is forced rather than chosen.

### 8.2 Constraint amendments — exact text

**Amendment 1 (required for R3b, i.e. even for the R3a–R3c prefix).** The v4 constraint currently
reads, at `plans/04_strong-completeness-dedekind-v4.md:590-601`:

> "**(v4) Do NOT pursue the bounded-witness detour.** … (ii) it *is* provable, but only from
> `Axiom.prior_S_gap` via Phase 6.3's lemma instantiated at `ψ := φ.neg` — i.e. it is a
> **corollary of Phase 6.3, not a prerequisite of it**; (iii) **no case of the transport needs
> it** … Do not state it, do not prove it, do not budget a dispatch against it."

Replace clause (iii) and the final sentence with:

> "(iii) **no case of the *backward* transport needs it** — cases 3′ and 4 place the witness
> *below* the gap and case 2 needs no witness relocation at all. **(iv) Forward case B *does* need
> it**, as `boundedWitness_of_limitGuardBelow`, and the blocker research proved it sorry-free in
> twelve lines from the landed `limitGuardBelow_of_priorS`. The prohibition is hereby narrowed in
> place to its original target: do not pursue the bounded witness **as a route** (i.e. do not
> attempt to derive it from `BFMCS.LimitFutureWitness`, where finding (i) shows it is not
> derivable, and do not budget a dispatch against obtaining it). Stating and proving it as a
> Phase-6.3 corollary at the forward-case-B call site is permitted and required."

**Amendment 2 (required only for R3d).** The v4 constraint at `:558-562`:

> "**(v3) Do NOT modify any `cantorBfmcsDense` chronicle declaration**, in particular
> `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc` … or the underlying `limit_F_resolution` /
> `limit_satisfies_c4` / `limit_satisfies_c5_strong`."

Would require appending:

> "**(v5 exception, user-authorized on {DATE})** Phase 7.5 alone may extend the finite-stage
> invariant `ChronicleInvariant` (`ChronicleTypes.lean:745`) with a Dedekind-closedness field on
> the closure's guard-failure classes, and may alter the witness-placement discipline inside
> `eliminatePotentialCounterexample` (`CounterexampleElimination.lean`), **provided** the
> statements of `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc` and of `limit_F_resolution` /
> `limit_satisfies_c4` / `limit_satisfies_c5_strong` are **unchanged**, and provided every
> currently-sorry-free consumer remains sorry-free. This exception is granted on the explicit
> record that the modification has **no source in the corpus** (Burgess 1982 I places every
> witness as a fresh point, printed pp.372-373; Burgess 1984's completion has no guard, printed
> pp.109-110; Reynolds obtains every gap-facing formula by expressive completeness, printed
> pp.176-178) and is therefore an **original construction**, not a transcription."

**Amendment 3 (required only for R3d).** The v4 constraint at `:563-567`:

> "**(v3) Do NOT enlarge `deferralClosure`, `extendedDeferralClosure`, or the root**…"

Would require appending:

> "**(v5 clarification)** Phase 7.5's invariant is indexed by the guard formulas of
> `untl`/`snce` members of `subformulaClosure root`, which is a `Finset`
> (`SubformulaClosure/Closure.lean:36`). Indexing an invariant *by* the closure is not enlarging
> it; no closure may grow."

**Amendment 4 (required only for R3d).** The settled decision at `:661-672` ("Every gap-facing
obligation on this route is discharged `fc`-conditionally") would require the note:

> "**(v5)** `BFMCS.LimitGuardEventual` is the **first** gap-facing obligation on this route that is
> *not* discharged by a frame-class axiom. Its discharge is a property of the construction, not of
> the logic. This is a genuine departure from the settled shape and is the reason Phase 7.5 is
> quarantined from Phases 7.3-7.4."

### 8.3 What does **not** need amending

Checked line by line against the full Postmortem Constraints list (`:461-694`): the one-sided
limit, the no-two-sided-limit rule, the no-witness-aware-*selection* rule (R3 changes the
*construction*, not the choice of `Ultrafilter.of`, and every descent asset through
`limitMCSBelow_cofinal_below` survives untouched), the no-`φ`-level-Prior-U rule (R3a applies
Prior-U to the **guard** `ψ`, which is Reynolds' own discipline — the formula uninterruptedly true
on an interval abutting the gap), the no-`cantorIsoDense`-edit rule (§4.2 shows it is not a lever
and need not be touched), the no-conditional-terminus rule, and the pinned
`consequence_completeness_dedekind_of_engine` signature all stand and are all respected by
R3a–R3d as decomposed.

---

## 9. Adversarial Self-Verification

Applied per `.claude/extensions/lean/context/contracts/adversarial-verification.md`. Every
load-bearing claim below was challenged for a documented reason it might fail. Two claims were
**modified** after verification; both modifications are recorded in §9.2.

| Claim | Source/Counterexample |
|---|---|
| Burgess 1984's completion runs only in `F`/`G` and so has no guard obligation at a gap | Verbatim re-read of `sources/burgess_1984/sec05_basic-tense-logic-continuity.md`; the entire §2.7 argument mentions only `Ga`, `Fa`, `Pa`, `HF¬a` — no `U`/`S` occurs. Verification: direct file read. **Confidence: High** |
| Burgess 1984 obtains the "above the gap ⟹ below the gap" conversion from axiom A7a, not from selection | Verbatim: *"Hence, by A7a, `F(Ga ∧ HF¬a) ∈ T(y₀)`"*, printed p.109; and the gap MCS is *"some MCS extending `C(Y,Z)`"*, i.e. arbitrary. **Confidence: High** |
| Burgess 1982 I's variants table has no Continuity/Dedekind row | Verbatim table re-read from `chunk_0009.md`: six rows, Density…No Last Element. **Confidence: High** |
| Burgess 1982 I places every Until-witness as a fresh point, `y = x+1` or `z = (x+x')/2` | Verbatim from `chunk_0022.md`: *"it is possible to add a single point `y` lying after `x`"*, *"Set `y = x + 1`"*, *"Set `z = (x + x')/2`"*. **Confidence: High** |
| The tree transcribes that discipline exactly, and contains no accumulation bookkeeping | `CounterexampleElimination.lean:671,677` (`witness_not_old`, "the witness is the midpoint between start and successor"), `:680-687` (the three-case walk docstring, Burgess's numbering), `ChronicleTypes.lean:745-755` (`ChronicleInvariant` fields: `hc0`, `hc1`, `hc2'`, `hc3` only). Verification: `lean_local_search`-class grep + bounded reads. **Confidence: High** |
| `LimitGuardBelow` is exactly "guard above ⟹ guard eventually below", closure-free, at unselected `r` | `lean_hover_info`-equivalent read of `Bundle/RealExtensionBundle.lean:324-327`; matches the Phase 6.3 spec byte-for-byte. **Confidence: High** |
| `limitSetBelow` is "eventually true below", not "cofinally true below" | `Bundle/LimitMCS.lean:136-137`: `{A | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < q → q < r → A ∈ m q}`. **Confidence: High** |
| **R3's invariant is *necessary* for forward case B** | `r3_invariant_necessary`, **proved sorry-free** via `lean_run_code` against the real tree (`success: true`, zero errors). Counterexample sought: could a witness `s` exist with the guard holding only at *unselected* reals of `(t,s)`? No — the rationals of `(t+δ, s+δ)` are dense and all selected, so `realLimitMCS_of_rat` reads the guard off `m q` directly. **Confidence: High** |
| `boundedWitness_of_limitGuardBelow` is provable from landed assets | **Proved sorry-free** via `lean_run_code` (`success: true`). Its `hcof` hypothesis is literally the right disjunct of the landed `toRealBundle_forward_until_unselected_dichotomy` (`ChronicleRealExtension.lean:732`). **Confidence: High** |
| `limitGuardAbove_of_priorU`'s statement elaborates against the tree | `lean_run_code`: statement accepted, only the expected `declaration uses sorry` warning. Its *proof* is **not** verified — steps 1–4 of §3 are a hand-verified sketch against the landed Prior-S mirror. **Confidence: Medium** (statement High, proof Medium) |
| `Axiom.prior_U_gap` / `prior_S_gap` / `sep` are the only `.Dedekind` axioms, so no other axiom can supply an interval | `ProofSystem/Axioms.lean` `minFrameClass` block at `:521-524`: exactly `prior_U_gap`, `prior_S_gap`, `sep` map to `.Dedekind`. `sep`'s shape (`Axioms.lean:398`) is entirely `K⁺`/`K⁻`, the negation of "holds on an interval". **Confidence: High** |
| "Accumulates at an irrational from below" is order-theoretic, hence invariant under `cantorIsoDense` | Two-line equivalence proof in §4.2, both directions written out. Counterexample sought: an unbounded ascending sequence — handled, it has no accumulation point *and* no lub, so the characterization must and does say "bounded above". **Confidence: High** |
| `CantorFDense` pulls the chronicle back through an order isomorphism, so the transport preserves the above | `ChronicleToCountermodelBasic.lean:250`: `fun q => LimitF fc A h_mcs ((cantorIsoDense …).symm q).val`, and `:293` uses `.symm.strictMono`. **Confidence: High** |
| `Chronicle.dom` is finite at every stage; `LimitDom` is the union | `ChronicleTypes.lean:557` (`dom : Finset Rat`), `ChronicleConstruction.lean:579`. **Confidence: High** |
| `subformulaClosure` is a `Finset`, so only finitely many guard formulas matter | `Syntax/SubformulaClosure/Closure.lean:36`. **Confidence: High** |
| Forward `snce` at an unselected target is unlanded and uncharted | Exhaustive `^theorem ` listing of `ChronicleRealExtension.lean` (17 declarations; no `forward_since_unselected`); Phase 7.2's Goal names only "the real **Until** witness"; Phase 7.1′'s charter names "the three unlanded **backward** cases". **Confidence: High** |
| Phase 8 requires `h_fuc` and therefore cannot proceed without the forward case | `RestrictedParametricTruthLemma.lean:417-422`, three coherence binders. **Confidence: High** |
| Family `Q` yields `untl P ¬P ∈ limitSetBelow m T` with **no** ultrafilter choice | `limitFilterBelow_le` (`LimitMCS.lean:347`) plus `limitSetBelow_subset_limitMCSBelow` (`:369`). The `P`-set is locally finite away from `T`, so a next `P`-point with a clean gap always exists. **Confidence: Medium-High** (the ℚ-semantics computation is hand-done, not formalized) |
| **`Q` is realizable at `fc = FrameClass.Dedekind`** | **[UNVERIFIED]** — rests on an EF/modal-depth argument that deep-`t` and deep-`u` blocks are `≡_d`-equivalent to points of `(ℚ, <, ℤ)`. That machinery is **forbidden** by the Postmortem Constraints and is what killed R2. **Confidence: Low.** Stated as a *candidate*, never as a refutation |
| R3d has no source in the corpus | Conjunction of the four Burgess/Reynolds rows above. Counter-search performed: greps for "arbitrarily soon", "for a while", "cofinal", "eventually true", "densely" across `reynolds_1992` returned only *hypothesis*-side uses ("`B` holds for a while up until a gap") and expressive-completeness constructions, never a construction-level invariant. **Confidence: High** |
| GHR 1994 §10.3 / Venema 2001 would not change the verdict | **Not consulted, by scope** — both present a form of the Reynolds separability route, which Phase 7.2 killed and which this dispatch's scope forbids re-litigating. **Confidence: Medium** (scoped-out, not verified) |

### 9.1 Contradiction log

**Resolved.** Mid-analysis this dispatch reached the conclusion that *"`cantorIsoDense` scrambles
accumulation structure, so R3 is aimed at the wrong object and the real lever is the Cantor
transport."* That contradicts R3's own framing ("an invariant on Until-witnesses in
`cantorBfmcsDense`'s deferral closure"). Resolution by the precedence ranking (a proof outranks an
intuition): the order-theoretic characterization in §4.2 was written out in both directions, and
it shows the property **is** isomorphism-invariant. R3's framing is correct; the intuition was
wrong. The wrong intuition is recorded here rather than silently deleted, because it is the
natural first thought and a future dispatch will have it too.

**No unresolved contradictions.**

### 9.2 Recommendations modified after verification

1. **The bounded-witness prohibition was initially read as fatal to R3.** Verification showed the
   prohibition's *reasons* (i)–(iii) are all about the bounded witness **as a route** and as a
   derivative of `LimitFutureWitness`; clause (iii)'s "no case needs it" is simply false for
   forward case B. The recommendation changed from "R3 conflicts with a settled prohibition" to
   "R3 requires a **narrowing in place** of one clause, of exactly the kind v3 and v4 already
   performed twice on this plan". Amendment 1 is drafted accordingly.
2. **The recommendation changed from a flat R3 accept/reject to a split.** The initial framing
   (inherited from the handoff) treated R3 as a single amendment-gated decision. Proving the
   necessity theorem showed that three quarters of R3 is unblocked, source-faithful, and needs one
   narrow amendment, while only the discharge is unsourced and (c). Recommending the whole thing
   as one gated decision would have thrown away the landable part.

### 9.3 Forbidden-output check

None of the contract's forbidden verification outputs occur: no "mathlib likely has this" without
a search (this is a project-internal obligation and no mathlib claim is made anywhere); no
type-mismatch claim without a goal state (the two proposed statements were elaborated, and the
proved ones were run); no "different approach needed" without alternatives (R3a–R3d are enumerated
with signatures, territory and estimates). No `sorry` is recommended anywhere, no new axiom is
proposed, and no vacuous definition is proposed. The scratch verification wrote **no tree files**.

---

## 10. Summary of what this dispatch adds to the tree's knowledge

1. **`r3_invariant_necessary`** — proved: R3's invariant is necessary, so forward case B has
   exactly one possible content. No third route exists.
2. **`boundedWitness_of_limitGuardBelow`** — proved sorry-free from landed assets; currently
   prohibited by a constraint that must be narrowed.
3. **`limitGuardAbove_of_priorU`** — statement verified to elaborate; the exact Prior-U mirror of a
   landed file, with a step-by-step proof plan.
4. **The order-theoretic characterization of gap-accumulation** — settles that `cantorIsoDense` is
   not a lever and that R3's stated seam is the correct one.
5. **The charter gap**: forward `snce` at an unselected target is required by `h_fuc`, landed
   nowhere, and chartered in no phase of plan v4.
6. **The literature verdict**: R3 has no source. Burgess 1984 has no guard; Burgess 1982 I has no
   Dedekind variant and never reaches a gap; Reynolds reaches every gap-facing formula through
   expressive completeness.
