# Research Report: Frame-Correspondence Infrastructure for Task Frames

**Task**: 511 — Determine what frame-correspondence infrastructure this bimodal setting can
support, and specify it
**Task Type**: formal
**Domains**: logic (modal/temporal correspondence theory), math (ordered abelian groups, order
theory)
**Grounding**: `specs/reviews/review-2026-08-31-metalogic-systematicity.md` issue M2
**Started / Completed**: 2026-08-31

---

## Executive Summary

**Verdict: split, and sharply so.**

1. **Textbook per-frame correspondence is PROVABLY UNAVAILABLE** for 37 of the 45 axiom
   constructors, and the refutation is two lines: `TaskFrame.staticFrame`
   (`Semantics/TaskFrame.lean:1276`) admits only constant histories, so *every* schematic axiom is
   frame-valid on it over *every* duration type, including duration types violating the axiom's
   own `minFrameClass` condition. A statement of the form "`F ⊨ density` iff `D` is densely
   ordered" is therefore false, not merely unproven. Three independent structural obstructions
   (§3) reinforce this; the tree already records one of them itself
   (`Independence/CoNotPriorU.lean` module docstring: "no frame-level countermodel can exist,
   for any frame whatever").

2. **Sahlqvist machinery does NOT transfer**, for reasons *independent* of the `Until`/`Since`
   operator shape. The binding obstruction is not polyadicity — a Sahlqvist theorem for LTL with
   `U` exists in the literature (Li & Belardinelli 2022) — it is that this semantics has **no free
   relational parameter and no free valuations**. The temporal relation is `<` on `D`, fixed by
   `D`; the modal relation is the *universal* relation over total histories, fixed outright
   (`Semantics/Truth.lean:168`); and valuations live on world states
   (`Semantics/TaskModel.lean:56`), so the induced time-valuation is filtered through a
   `TaskRel`-aligned history. Sahlqvist's minimal-valuation step is unavailable in general. This
   is the *general-frame* setting, where Sahlqvist correspondence provably fails.

3. **The right general statement is one level up: duration-type correspondence.** Not
   "frame `F` validates `ax` iff …" but

   > `∀ D, (∀ F M τ t, TruthAt M τ t (ax φ)) ↔ Cond(D)`

   quantifying over *all* task frames on a fixed `D`. This is well-posed, non-degenerate, and
   **reducible to classical Until/Since correspondence over the linear order `(D, <)`** — via a
   single missing frame (§7.1, `transFrame`) whose total histories realise **arbitrary**
   time-valuations. All 8 non-`Base` axioms are `□`-free, so the reduction covers exactly the
   axioms in question.

4. **AFFIRMATIVE, with a concrete construction spec.** Five of the eight non-`Base` axioms admit
   full duration-type correspondence (`density`, `dense_indicator`, `prior_UZ`, `prior_SZ`, `z1`);
   two are plausible-but-unproven (`prior_U_gap`, `prior_S_gap`); one is **provably
   non-corresponding** (`sep` — Reynolds' own note, already transcribed in the tree, that the long
   line satisfies it). The whole programme rests on **two frames**, one of which
   (`natFrame`) already exists and the other of which (`transFrame`) is ~15 lines given the
   existing helper `TaskFrame.limit_of_shift` (`Semantics/TaskFrame.lean:758`).

5. **The stated motivating goal does not actually need correspondence.** "TM⁺_d is the logic of
   dense task frames" is `Derivable .Dense Γ φ ↔ ValidDense φ` — soundness plus completeness,
   which is already the tree's programme. What correspondence adds is the *exactness* of
   `Axiom.minFrameClass`, which is a strictly smaller, finite obligation (§6, Tier 2) and is the
   recommended deliverable.

---

## 1. What Was Checked

Read in full or in the relevant part:

| File | What it settled |
|---|---|
| `FormalSystem/Semantics/Truth.lean:163–172` | The truth definition — the decisive evidence |
| `FormalSystem/Semantics/TaskModel.lean:49–56` | Valuations are on **world states**, not times |
| `FormalSystem/Semantics/TaskFrame.lean:493–…`, `:758`, `:1213`, `:1276`, `:1346` | Frame structure; `limit_of_shift`; `trivialFrame`/`staticFrame`/`natFrame` |
| `FormalSystem/Semantics/PartialHistory.lean:91–119` | `respects_task` — the alignment constraint on histories |
| `FormalSystem/Semantics/Validity.lean:94,206,248,301,336` | The 5 validity predicates and their binder sets |
| `FormalSystem/Semantics/DurationClassification.lean:117,149,165,229,252` | Hölder dichotomy: `complete_duration_discrete_or_dense`, `complete_not_dense_iso_int`, `intIso` |
| `FormalSystem/Semantics/IntTransfer.lean:336,356` | `validDiscrete_iff_validInt` — an existing exactness result |
| `FormalSystem/ProofSystem/Axioms.lean` (whole `Axiom` inductive + `minFrameClass`) | All 45 constructors; the 8 non-`Base` ones verbatim |
| `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean`, `Separability.lean` | Which frame property each soundness proof consumes |
| `FormalSystem/Metalogic/Soundness.lean:1519,1568,1638` | `prior_U_gap_valid` consumes **only** LUB + linear order |
| `FormalSystem/Metalogic/Independence/{ClockFrame,LoopingDuration,CoNotPriorU}.lean` | The three existing countermodels, in full |
| `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean:272,360` | `semanticPriorUZ_fails_of_interval_witness` — an existing necessity engine, in the wrong world |
| `FormalSystem/FrameConditions/{FrameClass,Validity}.lean` | The unconsumed `ValidOver` layer (review issue M1) |

Literature check: [Li & Belardinelli, *A Sahlqvist-style Correspondence Theorem for Linear-time
Temporal Logic*, arXiv:2206.05973](https://arxiv.org/abs/2206.05973).

---

## 2. The Semantics, Stated Precisely (the load-bearing facts)

```lean
-- Semantics/TaskModel.lean:56
valuation : F.WorldState → Atom → Prop

-- Semantics/Truth.lean:163–172
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p    => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot       => False
  | Formula.imp φ ψ   => TruthAt M τ t φ → TruthAt M τ t ψ
  | Formula.box φ     => ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ
  | Formula.untl ψ φ  => ∃ s : D, t < s ∧ TruthAt M τ s φ ∧ ∀ r, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce ψ φ  => ∃ s : D, s < t ∧ TruthAt M τ s φ ∧ ∀ r, s < r → r < t → TruthAt M τ r ψ

-- Semantics/PartialHistory.lean:118
respects_task : ∀ s t hs ht, F.TaskRel (states s hs) (t - s) (states t ht)
```

Four consequences that drive everything below:

**(S1) `TaskRel` never appears in `TruthAt`.** The task relation enters only by constraining which
histories exist (`respects_task`). It is not a modal accessibility relation and nothing in the
language talks about it directly.

**(S2) `□` is the universal modality over total histories.** There is *no* accessibility relation.
No modal frame condition can therefore be expressed, and the five S5 axioms
(`modal_t/4/b/5_collapse/k_dist`) are valid by construction rather than by a frame property. Their
correspondents (reflexivity, transitivity, symmetry, euclideanness) are *definitionally* satisfied.

**(S3) The temporal relation is `<` on `D`, and `D` is a nontrivial linearly ordered abelian
group.** It is not a free parameter of a frame; it is determined by the type. The four `FrameClass`
values are constraints on `D` alone — carrier-type constraints, exactly as the task statement says.

**(S4) The induced time-valuation is not free.** Along a history `τ`, atom `p`'s truth set is
`V_τ(p) = { t | M.valuation (τ.states t) p }`. Both the valuation (on states) and the history
(`TaskRel`-aligned, and subject to the frame's `limit` axiom) constrain which subsets of `D` are
realisable. This is the general-frame / admissible-sets situation.

---

## 3. Why Per-Frame Correspondence Fails — Three Obstructions

### O1. The degenerate-frame refutation (decisive, two lines)

`staticFrame W` (`TaskFrame.lean:1276`) has `TaskRel w d u ↔ w = u`. By `respects_task`, every
total history over it is **constant**. Hence for a total `τ` and any atom `p`, `V_τ(p)` is `∅` or
all of `D`; by induction every formula's truth value along `τ` is time-invariant. So
`F(φ) ↔ φ ↔ G(φ)` and the density axiom `GGφ → Gφ` holds at every point — **over ℤ, over ℚ, over
any `D` whatever**. `trivialFrame` (`:1213`, `WorldState := Unit`) does the same.

Therefore the statement

```
∀ D F, (∀ M τ t, TruthAt M τ t (density φ)) ↔ DenselyOrdered D
```

is **false**, and likewise for every schematic (atom-carrying) axiom. This is not a gap to be
closed; it is a theorem in the wrong direction. Any future task must not attempt it.

### O2. No relational parameter to correspond to

Correspondence theory answers "which first-order condition on `R` does `φ` impose?". Here (S1)+(S2)
mean there is no `R`: the modal relation is universal, and the temporal relation is `<` on `D`.
`TaskRel` is the only free relation in a `TaskFrame`, and it is invisible to the language.

### O3. Valuations are not free — this is a general-frame setting

Sahlqvist correspondence turns on the **minimal-valuation** step: given a frame refuting the
first-order correspondent, one *chooses* a valuation exhibiting the failure. Here the choice must
be realised by a pair `(M, τ)` subject to (S4), and the frame's `limit` axiom actively obstructs
this. Worked example: the maximally permissive relation `TaskRel ≡ True` on a carrier with `|W| > 1`
**violates** `limit` — `limit` forces `u = w` whenever `u` sits in every positive-duration cone of
`w`. That is why `natFrame` (`:1346`), whose relation is `d ≠ 0 ∨ w = u` and which realises
arbitrary time-valuations, carries `[SuccOrder D] [NoMaxOrder D]`: on a **dense** `D` its `limit`
obligation fails outright.

The tree records this obstruction in its own words (`Independence/CoNotPriorU.lean` module
docstring):

> `def:frame-validity` quantifies over **all** valuations. On a densely ordered flow rich enough to
> realize an arbitrary set of times, frame-validity of `CO` already forces gap-freeness, and hence
> forces Prior-U valid too — so no frame-level countermodel can exist, for any frame whatever.

and in `co_not_derives_prior_U_gap`'s docstring: "**Not** claimed, and in fact false: any
*frame*-level statement."

---

## 4. Scope Question (b): Does Sahlqvist Transfer? — No, and the usual reason is the wrong one

The instinct is to blame `Until`. `U(ψ,φ)` is `∃`-then-`∀` — monotone in both arguments but
additive only in its second, hence not a normal polyadic diamond, hence outside classical
Sahlqvist/BAO machinery. **That instinct is defensible but not the binding constraint**, because
the machinery has since been extended: Li & Belardinelli (arXiv:2206.05973) prove a Sahlqvist-style
correspondence theorem for LTL with `X` and primitive `U`, identifying an LTL-Sahlqvist class with
effectively-computable first-order correspondents. So "`Until` is binary" is not a proof of
non-transfer.

What *does* block transfer is that their theorem — like every Sahlqvist theorem — is stated over
**arbitrary Kripke frames with all valuations admissible**. Both hypotheses fail here (O2, O3).
Two further failures, for completeness:

- **Goldblatt–Thomason is also unavailable.** Modal definability of a frame class requires closure
  under disjoint unions, generated subframes, bounded morphic images, and reflection of ultrafilter
  extensions. The class of nontrivial linearly ordered abelian groups is closed under **none** of
  these: a disjoint union of two ordered groups is not a group; a generated subframe of `(D,<)` is
  an upper set, not a subgroup; `ℝ`'s ultrafilter extension is not an ordered group.
- **Dedekind completeness is not first-order** (it is `Π¹₁`, and the class of Dedekind-complete
  linear orders is not closed under ultrapowers), so no first-order correspondent can exist for the
  Dedekind row *even in principle*. Reynolds says so directly, and the tree already transcribes it
  (`Semantics/Validity.lean`, `ValidDedekind` docstring): the Prior axioms enforce only a
  *definably* Dedekind-complete model — "there may be gaps in the order but … you wouldn't know
  that just looking at the behaviour of temporal formulas" (Reynolds 1992, printed p.169).

**Conclusion on (b): a bespoke argument is needed, but not per axiom layer — one shared reduction
(§7) covers all eight non-`Base` axioms at once, after which the per-axiom work is classical order
theory, not modal correspondence theory.**

---

## 5. Scope Question (c): The Right General Statement

### 5.1 Duration-type correspondence

Since (S3) makes frame classes carrier-type constraints, the correspondence question must be posed
at the level of `D`, quantifying over all frames on it:

```lean
def ValidOn (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal → ∀ t : D,
    TruthAt M τ t φ
```

This already exists, unconsumed, as `FrameConditions.ValidOver` (`FrameConditions/Validity.lean:59`)
— which is review issue **M1**'s "built and never wired" layer. **M2 and M1 share a fix.** The
correspondence statement is then

> **`ValidOn D (ax φ)` for all `φ`  ⟺  `Cond(D)`**

with `Cond` a condition on the ordered group `D`. The `⟸` half is exactly the existing soundness
lemmas; the `⟹` half is the missing necessity half.

Crucially, this is **not** degenerate the way per-frame correspondence is: `staticFrame` no longer
refutes it, because the `∀ F` quantifier is free to pick a better frame.

### 5.2 The reduction that makes it tractable

**Key structural fact (new, and the pivot of this report).** Define

```lean
def transFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    TaskFrame D where
  WorldState := D
  nonempty   := ⟨0⟩
  TaskRel    := fun w x u => u = w + x
  ...
```

Its total histories are exactly `τ_c(t) = c + t` for `c : D`, and its valuations are arbitrary
functions `D → Atom → Prop`. Hence **`transFrame D` realises every time-valuation**: for any
family `(S_p)` of subsets of `D` there is an `(M, τ)` with `V_τ(p) = S_p`.

Consequently, **on `transFrame D` the `□`-free fragment of TM has exactly the standard
Until/Since-over-`(D,<)`-with-arbitrary-valuations semantics.** All eight non-`Base` axioms are
`□`-free. So:

> **Reduction Theorem (target).** For `□`-free `φ`, `ValidOn D φ → (φ is US-valid on the linear
> order `(D,<)` under all valuations)`, with the converse for any frame by soundness. Hence
> duration-type correspondence for the eight axioms *is* classical Until/Since correspondence over
> linear orders, transported.

This is what makes the affirmative half of the verdict cheap: after the reduction, each
correspondent is an order-theoretic exercise with no modal machinery at all.

`transFrame` is legal: `limit` is discharged by the **existing** helper
`TaskFrame.limit_of_shift` (`TaskFrame.lean:758`) at `pos := id`; `spherical` by the
singleton-fibre route `ClockFrame.lean` already uses; `comp`/`converse`/`serial`/`nullity_identity`
are group-translation identities. Note the tree's own note at `TaskFrame.lean:134`: "*Limit* is
automatic for deterministic-shift frames over any nontrivial duration type, **dense included**" —
the helper was built for precisely this and the frame was never written.

### 5.3 A three-tier taxonomy (use these names; they are not interchangeable)

| Tier | Statement | Status |
|---|---|---|
| **Tier 0** — per-frame correspondence | `∀ D F, F ⊨ ax ↔ Cond(D)` | **PROVABLY FALSE** (§3, O1). Do not attempt. |
| **Tier 1** — duration-type correspondence | `∀ D, ValidOn D ax ↔ Cond(D)` | **The right statement.** Available for 5–7 of 8 (§6). |
| **Tier 2** — `minFrameClass` exactness | finitely many `¬Valid_C(ax)` for `C ⋠ minFrameClass ax` | **Fully finite; recommended deliverable.** Follows from Tier 1 but is far cheaper. |
| **Tier 3** — "logic of a class" | `Derivable fc Γ φ ↔ Valid_fc Γ φ` | Soundness + completeness. **Not correspondence.** Already the tree's programme. |

**Clarification the review should absorb:** M2's stated impact — "without correspondence, 'TM⁺_d is
the logic of dense task frames' is not a theorem the tree can state" — conflates Tier 3 with Tier 1.
Tier 3 needs no correspondence at all. What correspondence buys is that `Axiom.minFrameClass` is
*minimal*, i.e. that the classes cannot be weakened — Tier 2.

---

## 6. Scope Question (a): Per-Axiom Verdict

### 6.1 The atom-free / schematic split

The 45 constructors partition into **8 atom-free** (constructors taking no `Formula` argument) and
**37 schematic**:

| Atom-free (8) | `minFrameClass` |
|---|---|
| `serial_future`, `serial_past` | Base |
| `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`, `discrete_box_necessity` | Base |
| `dense_indicator` | **Dense** |

For an atom-free `φ`, `TruthAt M τ t φ` is independent of `M` and of `τ` (immediate induction:
no `atom` case arises; `box` collapses since the body is `M`,`τ`-independent). So **atom-free
axioms have their frame condition already, at Tier 0 as well as Tier 1** — they are pure statements
about `(D,<)`. These 8 are the *only* constructors for which Tier 0 correspondence survives O1.

`dense_indicator = ¬ U(⊥, ⊤)` (`Axioms.lean`, `untl bot ⊤`) unfolds to: no `s > t` has `(t,s)`
empty. So:

> **`ValidOn D dense_indicator ↔ D has no immediate successors ↔ DenselyOrdered D`**
> (in a nontrivial ordered abelian group, "no immediate successor anywhere" and "densely ordered"
> coincide, by translation invariance).

This is an exact biconditional at Tier 0 and Tier 1, and it is the cheapest correspondence result
in the tree. The `dense_indicator` docstring already contains the informal necessity argument
("`U(⊤,⊥)` is true on ℤ").

The 5 `discrete_*` constructors are also atom-free and are the tree's only *conditional* frame
statements ("if a gap exists here then it exists everywhere / at every history"). They are
`Base`-valid by translation invariance, and they correspond at Tier 0 to translation-invariance
facts that hold in every ordered group — i.e. their correspondents are theorems, so they carry no
frame-class information. Correct as classified; nothing to prove.

### 6.2 The eight non-`Base` axioms

| Axiom | Formula (guard-first) | `minFrameClass` | Tier 1 correspondent | Verdict |
|---|---|---|---|---|
| `dense_indicator` | `¬U(⊥,⊤)` | Dense | `DenselyOrdered D` | ✅ **Exact.** Atom-free; Tier 0 *and* Tier 1. Trivial. |
| `density` | `GGφ → Gφ` | Dense | `DenselyOrdered D` | ✅ **Available.** Necessity: `natFrame` over any non-dense `D`. |
| `prior_UZ` | `Fφ → U(¬φ, φ)` | Discrete | every nonempty `S ⊆ (t,∞)` has a least element ⟺ `D ≅+o ℤ` | ✅ **Available**, and *exactly* matches the binder set. |
| `prior_SZ` | `Pφ → S(¬φ, φ)` | Discrete | dual | ✅ Available (mirror of `prior_UZ`). |
| `z1` | `G(Gφ→φ) → (FGφ → Gφ)` | Discrete | successor-archimedean descent ⟺ `D ≅+o ℤ` | ✅ **Available**, but needs `transFrame` specifically (see §6.3). |
| `prior_U_gap` | `U(φ,⊤) ∧ F¬φ → U(φ, ¬φ ∨ K⁺¬φ)` | Dedekind | LUB property of `D` | ⚠️ **Plausible, unproven.** See §6.4. |
| `prior_S_gap` | dual | Dedekind | GLB property | ⚠️ Same. |
| `sep` | `K⁺φ ∧ ¬K⁺(φ ∧ U(¬φ,φ)) → K⁺(K⁺φ ∧ K⁻φ)` | Dedekind | **none** | ❌ **Provably non-corresponding.** See §6.5. |

### 6.3 Why `z1` needs `transFrame` and not the clock frame

`ClockFrame`'s realisable time-valuations are exactly the **1-periodic** subsets of ℚ (that is what
`LoopingDuration` proves, and why `CO` is valid there). For any nonempty proper periodic set,
`Gφ ≡ ⊥` everywhere, so `FGφ ≡ ⊥` and `z1` is **vacuously true**. Any periodic engine — including
the natural generalisation of `ClockFrame` to `D ⧸ ⟨p⟩` — is *structurally incapable* of refuting
`z1`, or of refuting anything whose failure needs an eventually-constant valuation.

`transFrame` refutes `z1` on ℝ in one line: take `V(φ) = [a, ∞)` with `a > t`. Then
`{s : Gφ at s} = [a,∞) ⊆ V(φ)`, so `G(Gφ→φ)` and `FGφ` both hold at `t`, but `Gφ` fails at `t`
because `t < a`. This is the concrete demonstration that `transFrame`, not a clock-frame
generalisation, is the necessity engine to build.

### 6.4 The `prior_U_gap` / `prior_S_gap` caveat, stated carefully

There is an apparent conflict to resolve, and it resolves in favour of the construction:

- Reynolds' "definably Dedekind-complete" caveat, and `CoNotPriorU.lean`'s "no frame-level
  countermodel can exist", are statements about **restricted** valuation classes — general frames.
- `transFrame D` supplies **unrestricted** valuations, so "definable" collapses to "arbitrary", and
  the caveat does not bite at Tier 1.
- `prior_U_gap_valid` (`Soundness.lean:1519`) consumes **only** the LUB hypothesis and the linear
  order (its own docstring says so). So the `⟸` half is already proved in the strongest form.

What remains genuinely open is the `⟹` half over `transFrame`: given `D` dense with a cut lacking a
supremum, exhibit a valuation refuting `prior_U_gap`. The `CoNotPriorU` arc construction is
evidence it works for `D = ℚ` (there, the irrational `√2/4` is the cut). Whether it generalises to
*every* non-complete dense ordered abelian group is not settled by this research and should be
scoped as its own phase, gated behind the ℚ case.

**Note the Hölder collapse, which limits the value of this row.** Within nontrivial ordered abelian
groups, `DenselyOrdered + LUB ⟹ ≅+o ℝ` (via `arch_of_lub`, `complete_duration_discrete_or_dense`,
`complete_not_dense_iso_int`, `DurationClassification.lean:117,149,165`). So `ValidDedekindDense`'s
model class is a **singleton up to isomorphism** — as is `ValidDiscrete`'s, which
`validDiscrete_iff_validInt` (`IntTransfer.lean:356`) already proves outright. Correspondence over a
singleton class is informationally empty: *any* true statement about ℝ serves as a correspondent.
This is an independent reason to keep the Dedekind row's ambition modest.

### 6.5 `sep`: a documented negative

Two independent grounds, both already in the tree:

1. **Reynolds' own note**, transcribed in `Axioms.lean`'s `sep` docstring: "Sep does not
   *characterize* separability — Reynolds notes the long line satisfies it too." There is no
   condition `Cond(D)` with `ValidOn D sep ↔ Cond(D)` in the intended reading, because `sep`'s
   validity does not track separability.
2. **`Separability.lean`'s module docstring**: "Sep is **false** on an arbitrary densely ordered,
   Dedekind-complete linear order. The lexicographic square `[0,1] ×ₗₑₓ [0,1]` … refutes Sep at
   `t = (0,1)`." What rescues `sep` in this tree is the *additive group structure*, via
   `exists_countable_order_dense`. So `sep`'s frame condition is not `Dedekind` at all — it is
   "separable", which within the tree's binder set is implied by (and not equivalent to) the rest.

**Recommendation: `sep` is out of scope for correspondence permanently. Record this and close the
question.**

---

## 7. Scope Question (d): Do the `Independence/` Countermodels Generalize?

**Partly — but the wrong part, and this is the most important negative finding for planning.**

| File | Lines | What it is | Generalizes to necessity? |
|---|---|---|---|
| `ClockFrame.lean` | 240 | `D = ℚ`, `W = ℚ ⧸ ℤ`, `clockRel w x u := u = w + cmk x`. Frame only, no model. | **Infrastructure, not necessity.** |
| `LoopingDuration.lean` | 273 | Abstracts "`π` is a looping duration"; proves `truthAt_add_period`, and that `CO` is **true** on any such frame. | **No** — it is a *positive* validity result. |
| `CoNotPriorU.lean` | 584 | Arc valuation (`√2/4`) on `clockFrame`; refutes `prior_U_gap` at a **model**; concludes `¬ Derivable .Dense Γ (priorUGapFormula …)`. | **Closest to necessity**, but at model level, with an explicit disclaimer that the frame-level statement is *false*. |

**What generalizes.** The *chain* generalizes perfectly: build frame → build model → refute axiom
semantically → conclude underivability via the matching soundness theorem. `CoNotPriorU` is a
complete, working template for exactly the Tier-2 obligation.

**What does not generalize.** The *engine* does not. `clockFrame` is a quotient by a discrete
subgroup, so its realisable valuations are periodic, so `CO` holds (`LoopingDuration.co_true`) and
`Gφ` collapses. That is a feature there — the whole point was to validate `CO` while refuting
Prior-U — and a fatal defect for the necessity programme, which needs *maximal* valuation freedom.
Building `quotFrame D p := D ⧸ ⟨p⟩` as a generalisation of `clockFrame` is a tempting but **wrong
turn**: it inherits the periodicity ceiling and cannot touch `z1` (§6.3).

**Coverage today.** Of the eight non-`Base` axioms, `Independence/` refutes exactly **one**
(`prior_U_gap`), at model level, over ℚ. `density`, `dense_indicator`, `prior_UZ`, `prior_SZ`,
`z1`, `prior_S_gap`, `sep` are untouched. There is no non-dense frame and no non-discrete frame
construction anywhere in the directory.

**An adjacent asset in the wrong world.** `semanticPriorUZ_fails_of_interval_witness`
(`WeakCanonical/PriorDefsDense.lean:272`) is a *general* necessity lemma — on **any** densely
ordered flow, `SemanticPriorUZ` fails as soon as a formula holds throughout a nonempty open
interval — with an instance at `semanticPriorUZ_fails_on_dense` (`:360`). It is stated over
`OrderedMonadicStructure`/`TemporalTruth`, not `TaskFrame`/`TruthAt`. Bridging it is a *transport*
problem, not a mathematical one, and `transFrame` is exactly the bridge (an open interval is a
realisable time-valuation there).

---

## 8. Construction Specification

Recommended target: **Tier 2 (`minFrameClass` exactness)**, obtained through Tier 1 where cheap.
Phases are ordered so each is independently valuable and each ends green.

### Phase 1 — `transFrame` (the necessity engine) — ~40 lines

`FormalSystem/Semantics/TaskFrame.lean` (beside `natFrame`):

```lean
def transFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] : TaskFrame D where
  WorldState        := D
  nonempty          := ⟨0⟩
  TaskRel           := fun w x u => u = w + x
  nullity_identity  := fun w u => by simp [eq_comm]
  comp              := -- both halves are `add_assoc`; interpolation witness `u := w + x`
  converse          := fun w d u => by constructor <;> (intro h; subst h; abel_nf; ...)
  serial            := serial_of_total ...
  limit             := TaskFrame.limit_of_shift id (fun w y u h => by simp [h]) (by simp)
  spherical         := -- fibres are singletons; reuse ClockFrame's
                       -- `sInter_nonempty_of_directed_of_univ_or_singleton` route
```

Then the realisation lemmas — the actual deliverable of this phase:

```lean
def transHistory (c : D) : WorldHistory (transFrame D)   -- domain ≡ True, states t _ := c + t
theorem transHistory_isTotal (c : D) : (transHistory c).IsTotal

/-- Every family of time-sets is realised. -/
theorem exists_model_realizing (S : Atom → Set D) :
    ∃ (M : TaskModel (transFrame D)),
      ∀ (p : Atom) (t : D), TruthAt M (transHistory 0) t (Formula.atom p) ↔ t ∈ S p
```

*Risk*: low. `limit_of_shift` and the spherical route already exist and are designed for this.

### Phase 2 — the reduction lemma — ~80 lines

```lean
/-- Along a total history of `transFrame`, `□`-free truth is a function of the time-valuation
    alone. -/
theorem truthAt_transFrame_boxFree (φ : Formula) (hφ : φ.BoxFree) …
```

Requires a `Formula.BoxFree` predicate (check whether one exists; if not, ~10 lines) and a lemma
`boxFree_of_minFrameClass_ne_base` verifying all eight non-`Base` axioms are `□`-free (by `decide`
or an 8-case match).

*Risk*: low-medium. The induction is routine; the `untl`/`snce` cases are the only work.

### Phase 3 — the Dense row (necessity for `density`, `dense_indicator`) — ~100 lines

```lean
theorem exists_least_pos_of_not_dense (h : ¬ DenselyOrdered D) : ∃ p : D, IsLeast {x | 0 < x} p
noncomputable instance succOrder_of_not_dense (h : ¬ DenselyOrdered D) : SuccOrder D  -- succ x = x + p

theorem not_validOn_density_of_not_dense (h : ¬ DenselyOrdered D) :
    ¬ ValidOn D (Axiom-formula of `density` at some φ)
theorem not_validOn_dense_indicator_of_not_dense (h : ¬ DenselyOrdered D) :
    ¬ ValidOn D (Axiom-formula of `dense_indicator`)

-- Tier 1, both directions:
theorem validOn_dense_indicator_iff : ValidOn D denseIndicatorFormula ↔ DenselyOrdered D
```

`dense_indicator` needs no model at all (atom-free). `density` uses either `natFrame` (available
once `SuccOrder` is derived) or `transFrame` with `V(φ) = {t | t ≥ 2p}` at `t = 0`.

*Note*: `exists_least_pos_of_not_dense` is a two-line argument — if `(a,b)` is empty then `b - a` is
the least positive element by translation — but check Mathlib first
(`lean_leansearch`/`lean_loogle`).

*Risk*: low. Highest value per line in the whole plan.

### Phase 4 — the Discrete row (`prior_UZ`, `prior_SZ`, `z1`) — ~200 lines

All three refuted over `ℝ` (or any dense `D`) via `transFrame`:

- `prior_UZ` at `t = 0` with `V(φ) = (0, q)`: `Fφ` holds, but no first `φ`-point exists. This is
  `semanticPriorUZ_fails_of_interval_witness` transported.
- `prior_SZ`: mirror.
- `z1` at `t = 0` with `V(φ) = [a, ∞)`, `a > 0` (§6.3).

Since `ℝ ∈ DedekindDense ⊆ Dense ⊆ Base`, **one countermodel per axiom kills all three
incomparable-or-lower classes at once**. Then:

```lean
theorem not_validDense_priorUZ    : ¬ ValidDense    (priorUZFormula φ)
theorem not_valid_priorUZ         : ¬ valid         (priorUZFormula φ)
theorem not_validDedekindDense_z1 : ¬ ValidDedekindDense (z1Formula φ)
```

*Risk*: medium. The `z1` countermodel is the one to prototype first — it is the axiom no existing
machinery touches.

### Phase 5 — `minFrameClass` exactness theorem — ~60 lines

```lean
/-- `Axiom.minFrameClass` is exact: an axiom is valid on class `fc` iff `ax.minFrameClass ≤ fc`. -/
theorem Axiom.valid_iff_minFrameClass_le {φ : Formula} (ax : Axiom φ) (fc : FrameClass) :
    ValidFc fc φ ↔ ax.minFrameClass ≤ fc
```

`←` is the existing soundness lemmas; `→` is Phases 3–4 plus the `sep`/`prior_*_gap` row. **Note:**
this theorem is only statable once M1's `ValidFc : FrameClass → Formula → Prop` exists. **Sequence
this task behind M1** (or fold M1's Phase 1 into this task's Phase 0).

### Phase 6 (optional, gated) — the Dedekind row

Attempt `prior_U_gap` necessity over ℚ first, reusing `CoNotPriorU`'s arc idea on `transFrame`
instead of `clockFrame`. **Gate:** if the ℚ case does not close within one dispatch, stop and record
`prior_U_gap`/`prior_S_gap` as Tier-2-unproven with the Hölder-collapse note from §6.4 as the
justification. Do **not** attempt `sep`.

### Explicit non-goals — record these so the question is not reopened

1. **No Tier 0 (per-frame) correspondence for any schematic axiom.** Refuted by `staticFrame`
   (§3, O1).
2. **No Sahlqvist algorithm, no Goldblatt–Thomason, no canonicity-via-correspondence.** §4.
3. **No correspondent for `sep`.** §6.5, on Reynolds' own authority.
4. **No `quotFrame D p` generalisation of `ClockFrame` for necessity purposes.** §7 — it inherits
   the periodicity ceiling.
5. **Correspondence is not needed for "TM⁺_d is the logic of dense task frames".** §5.3, Tier 3.

---

## 9. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| **M1 dependency.** Tier-2's headline theorem needs an `fc`-indexed validity predicate that does not exist. | Sequence behind review issue M1, or absorb `FrameConditions.ValidOver` (`FrameConditions/Validity.lean:59`) as Phase 0. The two issues share a fix. |
| **`transFrame`'s `spherical` obligation.** `ClockFrame`'s route was 30 lines and non-obvious. | Fibres are singletons, identically to `clockRel_fib_subsingleton`; reuse `sInter_nonempty_of_directed_of_univ_or_singleton`. Prototype this field first — it is the only real unknown in Phase 1. |
| **Universe/binder friction.** `valid` uses `Type`, not `Type*`, to dodge universe issues; `ValidDedekind*` carries LUB as an anonymous *explicit* binder, not a typeclass. | Match the existing binder discipline exactly; every proof opens `intro D _ _ _ _ _ h_lub F M τ hτ t`. Do not "simplify" to `ConditionallyCompleteLinearOrder`. |
| **Naming collision.** Two live things are called `FrameClass` (`ProofSystem/Axioms.lean:531` inductive vs `FrameConditions/FrameClass.lean` typeclasses). | `FrameConditions/README.md` documents the distinction; keep new names unambiguous (`ValidOn`, not a third `Valid*` family). |
| **Duplication pressure.** The tree already has 15 validity predicates and 8 semantic-consequence variants (review H1). | Add **no** new validity predicate. Consume `ValidOver`/`ValidFc` from M1. |
| **Over-claiming the Dedekind row.** | The Hölder collapse (§6.4) makes it near-vacuous. Gate Phase 6; a negative there is a complete outcome. |
| **`stale README`.** `Independence/README.md` names `co_not_derives_prior_U`; the real identifiers are `co_not_derives_prior_U_gap` and `co_not_derives_prior_U_gap_schema`. | Fix in passing. |

---

## 10. Answers to the Four Scope Questions, in One Line Each

**(a)** Of 45 constructors: **8 are atom-free** and correspond at every tier (only
`dense_indicator` carries frame-class information); of the remaining 37, **exactly the 7 schematic
non-`Base` ones** are candidates, of which **5 admit full duration-type correspondence**
(`density`, `prior_UZ`, `prior_SZ`, `z1`, plus atom-free `dense_indicator`), **2 are plausible but
unproven** (`prior_U_gap`, `prior_S_gap`), and **1 is provably non-corresponding** (`sep`). The 30
schematic `Base` axioms have no frame condition to correspond to.

**(b)** **No.** Not because `Until` is binary — an LTL Sahlqvist theorem with primitive `U` exists
(arXiv:2206.05973) — but because Sahlqvist's two standing hypotheses both fail: there is no free
relational parameter (`□` is the universal modality; `<` is fixed by `D`) and valuations are not
free (they live on world states and are filtered through `TaskRel`-aligned histories, with the
`limit` axiom actively obstructing the permissive frame). This is a general-frame setting.
Goldblatt–Thomason fails too, on closure grounds. One bespoke reduction, not per-layer arguments.

**(c)** **Duration-type correspondence**: `∀ D, ValidOn D ax ↔ Cond(D)`, quantifying over all task
frames on a fixed carrier `D`. Per-frame correspondence is *false*, not merely unavailable
(`staticFrame` refutes it). The duration-type form is tractable because a single missing frame,
`transFrame D` (`W := D`, `TaskRel w x u := u = w + x`), realises **arbitrary** time-valuations, so
the `□`-free fragment reduces to classical Until/Since-over-linear-orders — and every non-`Base`
axiom is `□`-free.

**(d)** **The chain generalizes; the engine does not.** `CoNotPriorU.lean` is a complete working
template (frame → model → semantic refutation → underivability via soundness) and should be copied.
But `ClockFrame` is a quotient by a discrete subgroup, so its valuations are periodic, `CO` holds,
`Gφ` collapses, and it *cannot in principle* refute `z1`. Generalising `ClockFrame` to `D ⧸ ⟨p⟩` is
a wrong turn. Build `transFrame` instead. Present coverage: 1 of 8 axioms, at model level, over ℚ.

---

## Sources

- [Li & Belardinelli, *A Sahlqvist-style Correspondence Theorem for Linear-time Temporal Logic*, arXiv:2206.05973](https://arxiv.org/abs/2206.05973)
- Reynolds 1992, printed pp. 168–169 — as transcribed in `FormalSystem/ProofSystem/Axioms.lean`
  (`prior_U_gap`, `prior_S_gap`, `sep` docstrings) and `FormalSystem/Semantics/Validity.lean`
  (`ValidDedekind` docstring)
- [Sahlqvist formula — Wikipedia](https://en.wikipedia.org/wiki/Sahlqvist_formula)
- [Conradie, Palmigiano & Sourabh, *Algebraic modal correspondence: Sahlqvist and beyond*](https://staff.fnwi.uva.nl/s.sourabh/ConPalSurfinal.pdf)
