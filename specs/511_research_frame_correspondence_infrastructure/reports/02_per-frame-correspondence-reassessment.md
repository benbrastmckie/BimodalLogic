# Research Report (Second Pass): Per-Frame Correspondence, Reassessed

**Task**: 511 — Determine what frame-correspondence infrastructure this bimodal setting can
support, and specify it
**Task Type**: formal
**Domains**: logic (modal/temporal correspondence, general frames), math (order theory, ordered
abelian groups, Boolean algebras)
**Relationship to report 01**: supersedes §3 (O1–O3), the Tier-0 row of §5.3, and non-goal #1.
Everything else in report 01 stands, and two of its findings are strengthened.
**Lean evidence**: `specs/511_research_frame_correspondence_infrastructure/reports/02_probes.lean`
— 295 lines, compiles clean under `lake env lean`, no `sorry`, every result checked with
`#print axioms` to depend only on `propext` / `Classical.choice` / `Quot.sound`.

---

## Executive Summary

**Verdict: the challenge is upheld. Report 01's Tier-0 row is wrong, and per-frame correspondence
for `density` exists, is exact, and is proved.**

1. **The variation claim is TRUE, and verified in Lean.** At the single fixed carrier `D = ℤ`,
   `staticFrame` validates `GGφ → Gφ` for *every* formula `φ`, and `natFrame` refutes it. So
   per-frame validity is a genuinely non-constant function of `F` at fixed `D`. Report 01's O1
   therefore refutes only the *constant-in-`F`* candidate `DenselyOrdered D`; it does not, and
   cannot, refute per-frame correspondence as such (§1).

2. **The correct frame-valued Tier 0 exists and is an exact biconditional.** For every duration
   type `D` and every task frame `F`:

   > `F ⊨ GGp → Gp` (all atoms `p`, all models, all total histories, all times)
   > **⟺** `FwdRec F`: for every total history `τ` of `F` and every *covering* pair `t ⋖ s` in
   > `D`, the state `τ(s)` recurs at some time strictly after `s`.

   Proved in Lean, both directions, over an arbitrary `D` (`Corr.density_iff_fwdRec`). This has
   exactly the textbook shape `F ⊨ φ ↔ C(F)`, with `C` a condition on *that frame's own
   structure* — its total histories, which `TaskRel` determines through `respects_task` (§3).

3. **The correspondent is uniform, and Tier 1 falls out as a corollary.** Over a densely ordered
   `D` there are no covering pairs, so `FwdRec F` is vacuously true and *every* frame validates
   density — this is soundness, recovered for free (`Corr.fwdRec_of_denselyOrdered`, proved).
   Over a non-dense `D`, `FwdRec` reduces to forward state-recurrence at every point. Report 01's
   Tier 1 (`∀ D, ValidOn D density ↔ DenselyOrdered D`) survives intact as the corollary obtained
   by instantiating at one maximally free frame (§7).

4. **The differentiation route FAILS, and the reason is sharp rather than a matter of degree.**
   Not because differentiation collapses to full realisability by degrees, but because of a
   structural rigidity peculiar to this semantics: for a fixed history `τ` with state map
   `σ = τ.states`, the realisable **atom** truth-sets are exactly
   `{σ⁻¹(A) : A ⊆ F.WorldState}` — the `ker σ`-saturated sets, i.e. the *complete atomic* Boolean
   algebra `𝒫(D / ker σ)`. For an algebra of that shape, "separates points" and "is all of
   `𝒫(D)`" are **literally the same condition**. So atom-witnessed differentiation is not near
   the trivial end of a spectrum; it *is* the trivial end. Independently, differentiation stated
   over the frame-global `Adm(F)` is too weak: the frame `⊔_{n≥1} ℤ/nℤ` over `ℤ` is differentiated
   and validates density (§5).

5. **O2 is overstated and O3's conclusion is wrong.** `staticFrame` and `natFrame` over `ℤ`
   differ *only* in `WorldState`/`TaskRel` and differ in validity — proved. So `TaskRel` is not
   invisible to the language; it is visible exactly as a general frame's admissible algebra is,
   namely through the histories it admits. O3's diagnosis (this is the general-frame setting) is
   correct and is the report's most valuable observation; its conclusion (therefore correspondence
   dies) does not follow (§4).

6. **The challenge's candidate splitting condition is not merely non-separating — it is a frame
   axiom.** `TaskRel w d u ∧ d = d₁+d₂ → ∃v, …` is verbatim `TaskFrame.Interpolates`, the `→`
   half of the `comp` field, and is therefore a *theorem about every task frame*
   (`TaskFrame.interpolates`, `TaskFrame.lean:661`). It separates no two frames whatever. The
   challenge's observation is confirmed, in a stronger form (§2, `splitting_is_universal`).

7. **One thing is genuinely open, and it is not the framing.** The biconditional above is proved
   for the *atomic* instances of density. The full schema (φ ranging over all formulas) is
   strictly more demanding, because compound formulas escape the `𝒫(D/ker σ)` algebra —
   concretely, `P p` ("p has happened") manufactures a final segment from any atom set with a
   least element. Whether `FwdRec` nevertheless suffices for the full schema reduces to one clean
   lemma (§6, E2). Both possible answers leave the frame-valued framing intact.

---

## 0. Method, and what is verified vs. argued

Everything labelled **[Lean]** was machine-checked in
`reports/02_probes.lean` against the tree's own `TruthAt`, `TaskFrame`, `WorldHistory`, and
`TaskModel`. Everything labelled **[paper]** is an argument I did not formalise. Two claims are
flagged **[open]**. Report 01's §2, §5.2, §6, and §7 were reused, not re-derived, per the brief.

---

## 1. The variation claim: VERIFIED

### 1.1 `natFrame` over `ℤ` realises every time-valuation, and refutes density — **[Lean]**

`natFrame`'s relation is `TaskRel w d u ↔ d ≠ 0 ∨ w = u` (`TaskFrame.lean:1346`). Its
`respects_task` obligation is `TaskRel (σ s) (t - s) (σ t)`, which for `s ≠ t` is discharged
outright by the `d ≠ 0` disjunct and for `s = t` by reflexivity. Hence:

> **Every function `ℤ → ℕ` is a total history of `natFrame`.**

The probe builds `natHist S` for an arbitrary `S : Set ℤ` (states `1` on `S`, `0` off it),
proves it total, and proves the realisation lemma

```
natHist_atom : TruthAt natModel (natHist S) t (Formula.atom p) ↔ t ∈ S
```

so `Adm(natFrame (D := ℤ)) = 𝒫(ℤ)` — *full* realisability, with no new frame required. Then, with
`V(p) = {r | 2 ≤ r}` and `t = 0`:

- `GG p` at `0`: any `s > 0` has `s ≥ 1`, any `u > s` has `u ≥ 2`, so `u ∈ V`. ✓
- `G p` at `0`: fails at the witness `s = 1`, since `1 ∉ V`. ✗

`natFrame_refutes_density` is the machine-checked statement that `natFrame` over `ℤ` does **not**
validate `GGp → Gp`. The challenge's proposed valuation was exactly right.

**Planning consequence, and it is a real saving.** Report 01 §5.2 introduced `transFrame` as *the*
necessity engine. Over `ℤ` it is not needed: `natFrame`, already in the tree, already realises
every time-valuation. `transFrame` is needed only for **dense** `D` (where `natFrame`'s
`[SuccOrder D] [NoMaxOrder D]` binders — and its `limit` obligation — fail, exactly as report 01
§3 O3 observed).

### 1.2 `staticFrame` over `ℤ` validates density, for every formula — **[Lean]**

`staticFrame W` has `TaskRel w d u ↔ w = u`, so `respects_task` forces every total history to be
**constant**. The probe proves the general invariance lemma

```
Static.truth_time_invariant :
  ∀ (τ : WorldHistory (staticFrame W (D := ℤ))), τ.IsTotal →
    ∀ t s : ℤ, TruthAt M τ t φ → TruthAt M τ s φ
```

by induction on `φ` over *all* of `atom / bot / imp / box / untl / snce` — the `box` case works
because the induction hypothesis is quantified over the history, and the `untl`/`snce` cases
because `ℤ` supplies an immediately-adjacent witness with an empty open interval. Density then
follows in five lines (`Static.staticFrame_validates_density`), **for every `φ`**, not just for
atoms.

### 1.3 Verdict

> **Validity varies across frames over a fixed `D`.** At `D = ℤ`, `staticFrame ⊨ density` and
> `natFrame ⊭ density`, both machine-checked. Per-frame validity is therefore a non-constant
> function of `F`, and no argument that fixes a single frame can settle per-frame correspondence.

Report 01's O1 refutes the mixed-level statement `∀ D F, F ⊨ ax ↔ Cond(D)` — correctly, and the
refutation is now proved rather than asserted. But what it refutes is **`DenselyOrdered D` as a
candidate correspondent**, i.e. every *carrier-only* condition. The frame-valued shape was never
formulated or tested in report 01, and it is not refuted.

---

## 2. The splitting condition: CONFIRMED non-separating, for a stronger reason

The challenge conjectured that

```
TaskRel w d u ∧ d = d₁ + d₂ → ∃ v, TaskRel w d₁ v ∧ TaskRel v d₂ u
```

is satisfied by both `staticFrame` (take `v = w`) and `natFrame`, hence separates nothing. This is
correct, but understates the situation. That formula is character-for-character

```lean
-- TaskFrame.lean:395
def Interpolates (R : W → D → W → Prop) : Prop :=
  ∀ w v x y, 0 ≤ x → 0 ≤ y → R w (x + y) v → ∃ u, R w x u ∧ R u y v
```

which is the `→` half of the `comp` **field** of the `TaskFrame` structure, projected out as the
theorem `TaskFrame.interpolates` (`TaskFrame.lean:661`). The probe re-derives it generically
(`splitting_is_universal`) — **[Lean]**:

> Every task frame satisfies the splitting condition, by definition of being a task frame. It is
> not a weak separator; it is a tautology over the domain of discourse.

More generally, `comp` forces `R_{x+y} = R_x ∘ R_y` on the positive cone, so over `D = ℤ` a task
frame is determined by the single relation `R := R_1` on `WorldState` (with `R_n = R^n`, and `R_0
= id` from `nullity_identity`). **A task frame over `ℤ` is a serial digraph, and its total
histories are exactly the bi-infinite walks in it.** This reframing is used throughout below and
is, I believe, new to this task's analysis.

---

## 3. The corrected Tier 0, and what its correspondent is about

### 3.1 Where the density axiom actually bites

For `V ⊆ D` write `G V := {t | (t, ∞) ⊆ V}`. Unfolding `Truth.future_iff` twice, the instance
`GGφ → Gφ` fails at `t` for the truth-set `V` iff there is an `s > t` with `s ∉ V` while every
`r > t` that has *some* point strictly between `t` and `r` lies in `V`. The `s` witnessing failure
must therefore have **no point strictly between `t` and `s`** — i.e. `s` must be an immediate
successor of `t`. So:

> **The density axiom is a constraint that fires only at covering pairs `t ⋖ s`, and there it
> says: any `V` containing all of `(s, ∞)` must already contain `s`.**

This single observation is what makes the correspondent uniform across dense and non-dense `D`,
and it is what report 01 missed by reasoning only about `DenselyOrdered D` as a black box.

### 3.2 The correspondent — **[Lean]**

```lean
def Covers (t s : D) : Prop := t < s ∧ ∀ r : D, t < r → r < s → False

def FwdRec (F : TaskFrame D) : Prop :=
  ∀ (τ : WorldHistory F) (hτ : τ.IsTotal) (t s : D), Covers t s →
    ∀ A : F.WorldState → Prop,
      (∀ r : D, s < r → A (τ.states r (hτ r))) → A (τ.states s (hτ s))
```

Taking `A := σ[(s,∞)]` shows `FwdRec F` is equivalent to the readable form:

> for every total history `σ` of `F` and every covering pair `t ⋖ s`, **the state occupied at `s`
> recurs at some strictly later time**.

**Theorem (`Corr.density_iff_fwdRec`, proved, arbitrary `D`).**

```
(∀ p M τ, τ.IsTotal → ∀ t, TruthAt M τ t (GG(atom p) → G(atom p)))  ↔  FwdRec F
```

Both directions are constructive. `⟸` consumes the frame condition at exactly one place — the
covering-pair branch — and is otherwise pure order reasoning. `⟹` reads the recurrence witness off
the axiom by taking the valuation to be the characteristic function of `A`.

Corollaries, all proved:

| Result | Content |
|---|---|
| `Corr.fwdRec_of_denselyOrdered` | `[DenselyOrdered D] → FwdRec F` for **every** `F`. Soundness, recovered as a vacuity. |
| `Corr.staticFrame_fwdRec` | `staticFrame` satisfies it (constant histories recur trivially). |
| `natFrame_not_fwdRec` | `natFrame` over `ℤ` does not (via the biconditional and §1.1). |
| `staticFrame_density_via_corr` | density on `staticFrame`, re-derived through the biconditional. |

### 3.3 What the correspondent is *about*

The challenge asked for a correspondent stated over the admissible-set algebra
`Adm(F) := { V_τ(p) }`. The literal candidate — "*for every `S ∈ Adm(F)` and every `t`, if `S` is
GG-closed at `t` then `S` is G-closed at `t`*" — is **correct but circular**: it is a
transcription of validity into set notation, not a correspondent. A correspondent has to say
something about `F` that is not "the axiom holds".

The content of `FwdRec` is exactly the step that discharges the circularity:

> **`Adm(F)`'s atom part is not an arbitrary subalgebra. For a fixed model and total history `τ`
> with state map `σ`, varying the valuation `M.valuation : WorldState → Atom → Prop` sweeps out
> exactly `{σ⁻¹(A) : A ⊆ WorldState}` = `𝒫(D / ker σ)` — the complete atomic Boolean algebra of
> `ker σ`-saturated sets.** — **[paper; the two endpoint instances are Lean-verified]**

Because that algebra is generated by the fibres of `σ`, the second-order quantifier over `Adm`
collapses to a first-order statement about `σ` itself: "`(s,∞)` is a union of fibres that omits
`s`" is just "`σ(s)` does not recur after `s`". That collapse is why `FwdRec` is a *structural*
condition on `F` and not a restatement of the axiom. It is also — see §5 — the exact reason the
differentiation route dies.

So the honest answer to deliverable (2):

> **Corrected Tier 0**: `∀ D F, F ⊨ ax ↔ C_ax(F)`, where `C_ax` is a condition on `F`'s total
> histories (equivalently, on the walks its `TaskRel` admits) together with the covering structure
> of `(D, <)`. For `density`, `C_ax = FwdRec`, and the biconditional is proved for the atomic
> fragment. It is **not** first-order in `TaskRel` — it quantifies over histories — which is
> normal: Kripke-frame correspondence is Π¹₁ over `𝒫(W)` too, and Sahlqvist's contribution is a
> *reduction* to first-order that is available only when all valuations are admissible.

---

## 4. O2 and O3, reassessed

### 4.1 O2 ("`TaskRel` is invisible to the language") — **overstated; amend**

`staticFrame ℕ` and `natFrame` over `ℤ` have the same carrier type `D = ℤ`, the same `TruthAt`,
the same `□` clause, the same temporal order. They differ **only** in `WorldState` and `TaskRel`.
They differ in validity — proved. Therefore `TaskRel` is visible to the language.

What is true, and is worth keeping from O2:

- `TaskRel` is not an accessibility relation for *any* operator, so there is no
  modal-definability-of-`TaskRel` result in the classical sense, and no Sahlqvist-style
  first-order correspondent in `TaskRel`.
- The language sees `TaskRel` **only through the induced quotients `D / ker σ`** for `σ` ranging
  over `F`'s total histories. Two frames inducing the same family of quotient-plus-saturated-set
  data are indistinguishable by `□`-free formulas. This is a genuine *resolution limit* on how
  much of `TaskRel` any correspondence result could ever pin down.

That is a limit, not an invisibility. **Amend O2 to the resolution-limit statement.**

### 4.2 O3 ("valuations are not free, so this is a general-frame setting") — **right diagnosis,
wrong conclusion; amend**

O3 is the most valuable observation in report 01 and its diagnosis is exactly right. But in the
modal literature general frames are the framework in which correspondence over non-Kripke
structures is *carried out* — the persistence hierarchy (persistent, d-persistent, di-persistent;
differentiated / refined / descriptive frames) exists precisely to state and prove correspondence
when `Adm ⊊ 𝒫(W)`. Sahlqvist formulas are d-persistent and canonical; correspondence over
descriptive frames is a standard theorem, not a failure mode.

**Does that literature transfer here? Partially, and the part that fails is instructive.**

- **Transfers**: the *framework*. Along each `(M, τ)`, the structure `(D, <, Adm_τ)` is an honest
  general flow for the Until/Since language: `Adm_τ` is Boolean-closed and closed under `U`, `S`
  (and the box-sets are `τ`-independent, so they are constants of the algebra). So
  "`F ⊨ φ` for `□`-free `φ`" **is** "`φ` is valid on every general flow `(D, <, Adm_τ)` arising
  from `F`". That reduction is exact and is the right way to state the problem.
- **Fails**: the *rescue*. In the standard theory `Adm` is an arbitrary subalgebra — typically
  non-atomic (clopen sets of a Stone space) — and "differentiated" is a genuine intermediate
  condition strictly between trivial and full. Here `Adm_τ`'s atom part is forced to be
  `𝒫(D / ker σ)`, complete and atomic, and for such algebras *differentiated = full*. The standard
  intermediate condition has no room to exist. §5.

**Amend O3 to**: "this is the general-frame setting; correspondence is therefore *relativised to
the admissible algebra*, and here that algebra is atomic-complete, which both makes the
correspondent computable (`FwdRec`) and kills the differentiation rescue."

---

## 5. The differentiation route: FAILS — and where on the spectrum it sits

The challenge asked whether adding *temporally differentiated* — for all `t ≠ s` in `D`, some
`S ∈ Adm(F)` separates them — makes `F ⊨ density ↔ DenselyOrdered D` true, and to say explicitly
where the needed hypothesis sits on the trivial↔useful spectrum. **The answer is that no reading
of "differentiated" works, and the three readings fail for three different reasons.**

### 5.1 Reading A — global `Adm(F)` (the challenge's literal statement): **too weak**

Counterexample — **[paper]**. Over `D = ℤ`, let

```
F* : WorldState := ⊔_{n ≥ 1} ℤ/nℤ ,   TaskRel w d u :⟺ (same component) ∧ u = w + d
```

- **Legal**: `comp`/`converse`/`serial`/`nullity_identity` are componentwise group translations;
  `limit` is automatic over `ℤ` via the existing `TaskFrame.limit_of_succOrder`; fibres are
  singletons so `spherical` goes by `ClockFrame.lean`'s existing singleton route
  (`sInter_nonempty_of_directed_of_univ_or_singleton`).
- **Differentiated**: `Adm(F*)` is the set of *all periodic* subsets of `ℤ` (a history is confined
  to one component `ℤ/n`, giving `n`-periodic sets). Given `t ≠ s`, pick `n > |t - s|` and the
  class `{r ≡ t mod n}` — it separates them. ✓
- **Validates density**: every history is `n`-periodic for its own `n`, hence (`□`-free) truth
  along it is `n`-periodic, hence every proper truth-set has cofinal complement, hence none has
  the failure shape "contains `(a,∞)`, omits `a`". ✓

`ℤ` is not densely ordered, so `F* ⊨ density ↔ DenselyOrdered ℤ` is **false**. Global
differentiation does not rescue the biconditional.

### 5.2 Reading B — per-history, atom-witnessed: **exactly trivial, not merely near-trivial**

By §3.3 the realisable atom sets along `τ` are `{σ⁻¹(A)} = 𝒫(D / ker σ)`. Hence:

> atom-differentiated at `τ` ⟺ `ker σ` is trivial ⟺ `σ` injective ⟺ **every** subset of `D` is
> realisable at `τ`.

There is no spectrum. The hypothesis "F is atom-differentiated" is *identical* to "F realises
every time-valuation", i.e. literally "`F` behaves like `transFrame`". Adding it as a side
condition makes the biconditional true and completely empty: the correspondence would be proved by
assuming the only property that was ever doing any work.

This is the collapse the brief asked me to look for, and it is worth being precise that it is an
equality rather than a tendency. **The structural reason: `Adm_τ`'s atom part is a complete atomic
Boolean algebra, and for complete atomic algebras "separating" and "full" coincide.** In the modal
literature that coincidence does not hold, which is why differentiated/refined/descriptive frames
are useful there and useless here.

### 5.3 Reading C — per-history, formula-witnessed: **circular, not trivial**

The formula-level algebra along `τ` is strictly larger than `𝒫(D/ker σ)` (compound formulas
consult the order, so they can separate `σ`-identified times — e.g. a Thue–Morse colouring of `ℤ`
with two states is separated by Boolean combinations of `X^k p`). So Reading C is strictly weaker
than Reading B and does not collapse the same way.

But it fails for a different reason. Formula-level separation at `τ` is exactly *aperiodicity* of
`σ` (a period `d` of `σ` makes truth `d`-periodic — this is the tree's own
`Independence.truthAt_add_period`, generalised — so `t` and `t+d` are inseparable). And for task
frames, aperiodicity of some history appears to be equivalent to density failing (§6, E2). So
Reading C's side condition would be equivalent to the conclusion it is supposed to license.

### 5.4 Verdict, and why it does not matter

> **The differentiation route is a dead end at every reading.** Reading A is too weak (`F*`),
> Reading B is exactly the trivialising hypothesis, Reading C is circular.

But this costs nothing, because **the differentiation route is not needed**: §3.2 gives a clean
per-frame biconditional with **no side condition at all**, uniform across dense and non-dense `D`,
with `staticFrame` on the true side of it (rather than excluded by fiat *or* by hypothesis). That
is strictly better than what the differentiation route was aiming at.

---

## 6. Atoms vs. the full schema — the one genuinely open point

`Corr.density_iff_fwdRec` is proved for the **atomic** instances. `F ⊨ density` as a schema
quantifies `φ` over all formulas, and the two are not obviously equal, because the formula-level
algebra escapes `𝒫(D/ker σ)`.

**Concrete reason the upgrade is not automatic — [paper].** Let `σ : ℤ → {a,b}` with
`σ⁻¹(b) = {1, 3, 5, …}` and `σ⁻¹(a)` everything else. Every state recurs forward at every point,
so this history is forward-recurrent. But `σ⁻¹(b)` has a *least* element, and the compound formula
`P p` ("`p` has happened", `= S(⊤, p)`) has truth-set `(1, ∞)` — a final segment omitting `1`,
which is exactly the failure shape. So *forward recurrence of one history does not by itself stop
compound formulas from manufacturing bad sets.*

This is **not** a refutation, because a task frame admitting that `σ` also admits the walk
`…aaa b aaa…` in which `b` occurs once and never recurs — which violates `FwdRec`. The pairwise
(`R_n = R^n`) shape of `respects_task` means one cannot pick histories independently. Closing the
gap is one lemma:

> **[open, E2] Over a non-dense `D`: does `FwdRec F` imply that every total history of `F` is
> periodic?** Equivalently, in the digraph picture of §2: if every bi-infinite walk in `(W, R)` is
> forward-recurrent at every position, is every bi-infinite walk periodic?

Evidence for *yes*: every attempt to build a non-deterministic serial digraph all of whose walks
are forward-recurrent produced a walk with a one-off visit (`{(a,a),(a,b),(b,a)}`, the golden-mean
shift; `{(a,b),(b,a),(a,c),(c,a)}`; `W = ℕ` with resets). The frames that survive are precisely
those whose `R` is a permutation with all orbits finite — the `staticFrame` / clock-frame /
`F*` family. I could not turn this into a proof, and I could not refute it. **[open]**

**If E2 is true**, `FwdRec` is the exact correspondent for the whole schema, since periodicity of
every history gives the positive half (§6.1 below). **If E2 is false**, the full-schema
correspondent is a strictly stronger recurrence condition — something in the neighbourhood of
*uniform* recurrence (every state recurring with bounded gaps, in both directions) — which is still
a per-frame structural condition, so the framing of §3 survives either way. Nothing in this report
outside §6 depends on E2.

### 6.1 The positive half of the full schema is already available — **[Lean]**

The probe proves, over an **arbitrary** `D` and for **every** formula `φ`:

```
density_of_loopingDuration :
  LoopingDuration F π → ∀ φ M τ, τ.IsTotal → ∀ t, TruthAt M τ t (GGφ → Gφ)
```

in eleven lines, consuming only the tree's existing
`Metalogic.Independence.truthAt_add_period` (`LoopingDuration.lean:98`). `staticFrame` has a
looping duration (`staticFrame_looping`, proved), and `clockFrame` has `1`
(`clockFrame_looping`, already in the tree). So both known density-validating frames are covered
by a single lemma, for all formulas, and **this half needs no new work at all**.

This also **strengthens report 01 §7 and its non-goal #4** from an observation into a theorem:
quotient/clock frames have looping durations, hence validate density, hence can *never* refute it.
`quotFrame D p` is not merely a tempting wrong turn — it is provably incapable of the job.

---

## 7. Relationship to `transFrame` and to report 01's Tier 1

**Nothing established in report 01 is lost under the revised framing.** Specifically:

- **§5.2 `transFrame` stands, and is best re-cast as the challenge suggests**: not as "the
  necessity engine for a weaker tier", but as the **maximally free frame** — the extreme point at
  which `ker σ` is trivial, `Adm = 𝒫(D)`, and general-frame semantics degenerates to full Kripke
  semantics over `(D, <)`. It is the witness that the class of `¬FwdRec` frames is non-empty over
  every non-dense `D`, and it is what makes report 01's reduction to classical Until/Since
  correspondence legitimate. Its construction (including the `limit_of_shift` and singleton-fibre
  `spherical` routes) is unchanged and remains correct.
- **Tier 1 survives as a corollary** — **[paper, modulo `transFrame`]**:
  `∀ D, ValidOn D density ↔ DenselyOrdered D`. `⟸` is `Corr.fwdRec_of_denselyOrdered` applied at
  every `F` (proved). `⟹` is: `D` non-dense ⟹ `D` has a least positive `p` ⟹ every `t` is covered
  by `t + p` ⟹ `transFrame D` (whose `σ` is injective) violates `FwdRec` ⟹ `¬ ValidOn D density`.
  Exactly the instantiate-at-one-frame argument the challenge predicted.
- **Cost correction**: over `D = ℤ` specifically, `transFrame` is unnecessary — `natFrame`
  already realises every time-valuation (§1.1, proved). `transFrame` is required for the dense
  rows (`prior_UZ`, `prior_SZ`, `z1` refuted over `ℝ`/`ℚ`) and for the general non-dense `D` in
  the Tier-1 proof.
- **§6 per-axiom verdict stands unchanged.** It is a Tier-1 table and Tier 1 is untouched. §6.1's
  observation that atom-free axioms correspond "at Tier 0 as well" is now *explained* rather than
  coincidental: for atom-free `φ` the state map drops out, so `C_φ(F)` degenerates to a condition
  on `D` alone. `dense_indicator` is the degenerate case of the frame-valued Tier 0, not an
  exception to it.
- **§7 stands and is strengthened** (see §6.1 above).
- **§4 (Sahlqvist) stands**, with one amendment of emphasis: what fails is Sahlqvist's *algorithm*
  (its minimal-valuation step needs all valuations admissible). It does not follow that
  correspondents fail to exist. Here one exists and was found by hand in an afternoon.

---

## 8. What must be amended in report 01

| Report 01 location | Status | Required amendment |
|---|---|---|
| §2 (S1–S4) | **Stands** | Keep, but do not read S1 as O2's invisibility claim. S4 is the load-bearing fact and is right. |
| §3 O1 | **Stands as a refutation; conclusion amended** | The `staticFrame` computation is correct (now Lean-verified, and for *all* `φ`, which is stronger than report 01 argued). What it refutes is every *carrier-only* correspondent, not per-frame correspondence. Delete "This is not a gap to be closed; it is a theorem in the wrong direction. Any future task must not attempt it." |
| §3 O2 | **Overstated — rewrite** | Replace "invisible to the language" with the resolution-limit statement of §4.1. Refuted by `staticFrame`/`natFrame` at fixed `D = ℤ`. |
| §3 O3 | **Diagnosis right, conclusion wrong — rewrite** | Keep the general-frame identification (it is the report's best observation). Replace "this is why correspondence dies" with §4.2: correspondence is relativised to `Adm`, which here is atomic-complete — which makes `FwdRec` computable *and* kills the differentiation rescue. |
| §5.3 Tier-0 row | **Rewrite** | `∀ D F, F ⊨ ax ↔ Cond(D)` — **FALSE, and mis-shaped**: it quantifies over `F` on the left and only over `D` on the right. Replace with **Tier 0′**: `∀ D F, F ⊨ ax ↔ C_ax(F)`. Status: **TRUE and proved for `density`** (atomic fragment); full-schema exactness gated on E2. |
| §5.3 "Clarification" para | **Stands** | Tier 3 ≠ Tier 1 is still right. |
| §6 | **Stands** | No change. |
| §7 | **Stands, strengthened** | `clockFrame` cannot refute density — now a theorem via `density_of_loopingDuration`. |
| Non-goal #1 | **Rewrite — see below** | |
| Non-goals #2–#5 | **Stand** | #4 is strengthened to a proved impossibility. |

### Non-goal #1, rewritten

> **1. No *carrier-only* per-frame correspondence.** The statement
> `∀ D F, F ⊨ ax ↔ Cond(D)` is false for every schematic axiom, refuted by `staticFrame`
> (§3, O1 — Lean-verified). It is also mis-shaped: it quantifies over frames on the left and over
> the carrier type on the right. This rules out `DenselyOrdered D` — and any `D`-only property —
> as a candidate correspondent.
>
> It does **not** rule out per-frame correspondence in its textbook shape `F ⊨ ax ↔ C(F)`, with
> `C` a condition on that frame's own structure. For `density` such a `C` exists, is exact, and is
> proved: `FwdRec F` (report 02 §3). Validity genuinely varies across frames at fixed `D`
> (`staticFrame ⊨ density`, `natFrame ⊭ density`, both over `ℤ`), so no single-frame argument can
> close this question in either direction.
>
> Also out of scope, and for a sharper reason than "it might collapse": **the
> differentiated/refined/descriptive-frame side-condition route.** The admissible atom algebra
> along any history is `𝒫(D / ker σ)` — complete and atomic — and for such algebras "separates
> points" is *identical* to "every subset admissible". The side condition would be exactly the
> trivialising hypothesis. See report 02 §5.

---

## 9. Construction Specification — the density pilot

Target file: `FormalSystem/FrameConditions/Correspondence/Density.lean` (new; the
`FrameConditions/` tree is report 01's M1 layer and is where a per-frame condition belongs — this
does **not** add a validity predicate, per report 01's risk table).

All of Phases A–C are **already written and machine-checked** in `reports/02_probes.lean`; the
implementation work is transcription plus docstrings, not discovery.

### Phase A — the correspondent and the biconditional (~70 lines) — **proof in hand**

`Covers`, `FwdRec`, `density_iff_fwdRec`, `fwdRec_of_denselyOrdered`. Lift verbatim from
`02_probes.lean` §Probe C. *Risk: none — it compiles today.*

### Phase B — full-schema sufficiency (~35 lines) — **proof in hand**

`density_of_loopingDuration` + `staticFrame_looping`; instantiate at `clockFrame` via the
existing `clockFrame_looping`. Lift from `02_probes.lean` §Probe F. Note this imports
`Metalogic.Independence.LoopingDuration` into `FrameConditions/`; if that dependency direction is
unwanted, relocate to `Metalogic/Independence/`. *Risk: low (import-direction question only).*

### Phase C — the `ℤ` necessity engine (~90 lines) — **proof in hand**

`natHist` / `natModel` / `natHist_atom` (the realisation lemma: `natFrame` over `ℤ` realises every
time-valuation), `natHist_isTotal`, `natFrame_refutes_density`, `natFrame_not_fwdRec`. Lift from
`02_probes.lean` §Probe A + §Probe E. **This replaces report 01's Phase 1 for the discrete case
and requires no new frame.** *Risk: none.*

Also lift `Static.truth_time_invariant` (§Probe B) — it is a reusable statement about
`staticFrame` that the tree does not have and that any future degenerate-frame argument will want.

### Phase D — `transFrame` and Tier 1 (~160 lines) — **new work**

Build `transFrame` exactly per report 01 §5.2 (unchanged; `limit_of_shift` at `pos := id`,
singleton-fibre `spherical`). Then:

```lean
theorem transFrame_not_fwdRec (h : ¬ DenselyOrdered D) : ¬ FwdRec (transFrame D)
theorem validOn_density_iff : ValidOn D densityFormula ↔ DenselyOrdered D
```

Needs report 01 Phase 3's `exists_least_pos_of_not_dense` (check Mathlib first). *Risk: medium —
`spherical` is the only real unknown, exactly as report 01's risk table says. Prototype that field
first.*

### Phase E — full-schema exactness (gated; a negative is a complete outcome)

- **E1** (~60 lines, low risk): generalise `truthAt_add_period` to a **per-history** period for
  `□`-free formulas. This closes `F*` and every all-orbits-finite frame. Requires a
  `Formula.BoxFree` predicate (report 01 Phase 2 already scopes this).
- **E2** (**open**, unbounded): `FwdRec F → every total history of F is periodic`, over non-dense
  `D`. **Gate**: if E2 does not close within one dispatch, stop and record `density_iff_fwdRec` as
  exact for the atomic fragment and `FwdRec` as *necessary* (proved) for the schema, with the
  `P p` first-occurrence example (§6) as the documented reason the upgrade is not automatic. Do
  not let E2 block Phases A–D, none of which depend on it.

### Sequencing note

Phases A–C are independent of report 01's M1 dependency and can land immediately. Phase D and
report 01's Phases 3–5 are unchanged and still sequence behind M1 for the `ValidFc` statement.

---

## 10. Risks

| Risk | Assessment |
|---|---|
| **E2 is false** | The framing survives; the full-schema correspondent is a stronger recurrence condition. Phases A–D are unaffected. Explicitly gated. |
| **Over-reading the atomic biconditional** | It is proved for `φ := atom p` only. Every claim about the *schema* in this report is either the sufficiency direction (proved, §6.1) or flagged open (E2). Do not let a plan state "density corresponds to `FwdRec`" without the atomic qualifier until E2 closes. |
| **`F*` is paper-only** | The differentiation counterexample of §5.1 is argued, not formalised. If a plan wants to *rely* on it, formalise `⊔_n ℤ/nℤ` (~80 lines, `spherical` via the singleton route). Nothing in §§1–4, 6–9 depends on it. |
| **The `𝒫(D/ker σ)` characterisation is paper-only** | Argued in §3.3; its two endpoint instances (`staticFrame` → `{∅, D}`; `natFrame` over `ℤ` → `𝒫(ℤ)`) are Lean-verified. Formalising the general statement is ~30 lines and is worth doing if §5's collapse argument is to be cited as settled. |
| **Import direction** | Phase B pulls `Metalogic/Independence/` into `FrameConditions/`. May want relocating. |
| **Naming** | `FwdRec` is provisional. It is a property of frames, not a validity predicate — keep it out of the `Valid*` namespace (report 01's duplication-pressure risk). |

---

## 11. Answers to the Five Deliverables, in One Line Each

**(1) Variation claim** — **TRUE, Lean-verified.** `staticFrame ⊨ density` (all `φ`) and
`natFrame ⊭ density`, both over `D = ℤ`; `natFrame` realises every time-valuation over `ℤ`, so no
new frame is needed for the discrete necessity engine.

**(2) Corrected Tier-0 shape** — `∀ D F, F ⊨ ax ↔ C_ax(F)` with `C_ax` a condition on `F`'s total
histories. For density, `C_ax = FwdRec` ("the state at any immediate successor recurs later"), and
the biconditional is **proved** for the atomic fragment over arbitrary `D`. Its correspondent is
about the *admissible-set algebra*, but that algebra is `𝒫(D / ker σ)`, which is what lets the
second-order condition collapse to a first-order statement about the history's state map.

**(3) Differentiation route** — **FAILS at all three readings.** Global `Adm(F)`: too weak
(`⊔_n ℤ/nℤ` is differentiated and validates density over `ℤ`). Per-history atom-witnessed:
**exactly** the trivialising hypothesis, not near it — for complete atomic algebras "separating" =
"full", so the side condition is literally "`F` behaves like `transFrame`". Per-history
formula-witnessed: circular. **It does not matter**, because §3 gives a biconditional needing no
side condition at all.

**(4) Report 01** — §2, §5.2, §6, §7 stand (§7 strengthened to a theorem). §3 O1's computation
stands but its conclusion is over-broad; O2 is overstated (refuted); O3's conclusion is wrong
(diagnosis right). §5.3's Tier-0 row must be replaced by Tier 0′. **Non-goal #1 must be rewritten**
— full replacement text in §8.

**(5) Construction spec** — §9. Phases A–C (~195 lines) exist as compiling Lean today. Phase D is
report 01's `transFrame` unchanged. Phase E is gated and a negative there is a complete outcome.

---

## Sources

- `reports/02_probes.lean` (this task) — 295 lines, all results `#print axioms`-clean.
- `FormalSystem/Semantics/TaskFrame.lean:395` (`Interpolates`), `:661` (`interpolates`),
  `:758` (`limit_of_shift`), `:1213`/`:1276`/`:1346` (`trivialFrame`/`staticFrame`/`natFrame`)
- `FormalSystem/Semantics/Truth.lean:163–172` (`TruthAt`), `:289` (`Truth.future_iff`)
- `FormalSystem/Semantics/PartialHistory.lean:118` (`respects_task`)
- `FormalSystem/Metalogic/Independence/LoopingDuration.lean:52` (`LoopingDuration`),
  `:80` (`states_add_of_looping`), `:98` (`truthAt_add_period`), `:251` (`clockFrame_looping`)
- `specs/511_research_frame_correspondence_infrastructure/reports/01_frame-correspondence-infrastructure.md`
- Blackburn, de Rijke & Venema, *Modal Logic* (2001), ch. 5.5 (general frames; differentiated /
  refined / descriptive) and ch. 3.6 (persistence) — the framework §4.2 assesses for transfer.
