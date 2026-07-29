# Phase 22 blocker research: Reynolds §6 Lemma 6's first clause (F1) and the anti-vacuity module direction (F2)

**Task**: 408 | **Type**: lean4 | **Mode**: `--hard` (H2/H3/H4)
**Session**: `sess_1785278656_384f35`
**Focus**: blocker research — Reynolds §6 Lemma 6 first clause, and the anti-vacuity module-direction blocker
**Reference grounding tier**: **Tier 1** (literature-backed — Reynolds 1992 §6, local corpus + page images)

---

## Headline

**F1 is not blocked. It is solved.** A complete, sorry-free, axiom-clean proof of
`HasBadIntervalSurgery` — and therefore of Theorem 4 unconditional in that hypothesis — was
written and compiled green during this dispatch. The full 294-line candidate is at

```
/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/6bb7ddc7-92d0-468e-8ec6-81f46805b1e7/scratchpad/F1-precompiled-candidate.lean
```

and is reproduced in full in §3 below. `#print axioms` on both
`hasBadIntervalSurgery` and a derived `no_gaps_dense_prior_unconditional` returns
`[propext, Classical.choice, Quot.sound]` — no `sorryAx`.

**The implementer's diagnosis was accurate about the symptom and wrong about the location.** The
missing content is not in Lemma 6 at all. It is a boundary case in **Lemma 4**, and it traces to a
genuine off-by-one in **Reynolds' own displayed formula on printed p.179** — which the tree
transcribed faithfully, and which therefore does not deliver what Reynolds' Lemma 6 prose goes on
to assume it delivers.

**F2's cycle claim is refuted as stated** (there is no import cycle, checked against the actual
transitive closure), but the implementer's *conclusion* — a new module downstream of both — is
still the right call, for a different and better reason.

---

## 1. F1, literature first

### 1.1 What the page actually says

Printed p.180 = PDF page 16 (`+164` offset re-confirmed). Rendered at 200 dpi and read as an
image, not via `pdftotext`.

> **LEMMA 6** *Bad points only occur in non-singleton bad intervals.*
>
> *In any bad interval both R and L hold throughout. Any bad interval, if bounded, has excluded
> end points in M (neither R nor L holds at these end points).*
>
> **PROOF.** We first show that L holds wherever R does. Suppose for contradiction that we have a
> maximal interval of R in which L fails to hold somewhere. So ¬L holds throughout at least one
> ∼–class. By the definition of L, there are two cases. Either this particular ∼–class is one
> which includes its left hand end point or it is one which begins just after some point of M. The
> class can not be unbounded below for then it would be first in this bad interval.
>
> In fact we can not have a class beginning just after a point r of M. Since the class can not be
> first in the bad interval r itself must be in a ∼–class in the bad interval. But r's class can
> not end in a gap on the right when r must be its right hand end point.
>
> Thus we have a class in the bad interval which includes its left hand end point. Its not hard to
> use the previous result to show that throughout the bad interval all classes include their left
> hand end points.
>
> Let B be a temporal formula true at times which are not left hand end points of their ∼–classes.
> B is then true continuously in any class from just after the left hand end point up until the
> gap at the right hand end point. B must be false arbitrarily soon after the gap contradicting
> Prior–U.
>
> Using mirror images of the above and previous results we get our proof. ∎

The corpus file `sec03_6-no-gaps-between-equivalence-classes.md:80-92` matches the image verbatim
except for one silent normalisation: the print reads **"Its not hard"** (no apostrophe), the
corpus reads **"It's not hard"**. Consistent with the already-recorded corpus habit of silently
correcting the print's typos.

**Note on the corpus's §6 file naming.** The delegation refers to "sec06"; the §6 material is in
`sec03_6-no-gaps-between-equivalence-classes.md`. `sec06_5-expressive-dedekind-completeness.md` is
§5. The corpus numbers files by PDF order, not by section number.

### 1.2 Does Reynolds prove the clause? — **Yes, and the implementer's characterisation is refuted**

The Phase 22 implementer wrote, in `NoGaps.lean:730-731` and in the delegation:

> "This is a gap in the formalization, NOT in Reynolds. His Lemma 6 states the clause and he takes
> it as established by the time Lemma 9 runs."

Read as "Reynolds asserts the clause without argument", **this is wrong**. Reynolds gives a
five-paragraph proof, with an explicit case analysis and an explicit Prior-U contradiction. The
implementer appears never to have read past the statement.

But the *conclusion* the implementer drew — that the tree's gap is not Reynolds' — needs
splitting, because Reynolds' proof has two halves with very different status:

| Half | Reynolds' treatment | Status |
|---|---|---|
| **L holds wherever R does** | Fully argued: three cases (unbounded below / begins just after `r ∈ M` / includes its left end point), then the `B`-formula against Prior-U | Landed in the tree as `endsInGapOnLeft_of_endsInGapOnRight` (`BadIntervals.lean:615`) |
| **R holds wherever L does** | One sentence: *"Using mirror images of the above and previous results we get our proof"* | Landed in the tree as `endsInGapOnRight_of_endsInGapOnLeft` (`BadIntervals.lean:1346`), by instantiation through `Dual.lean` |

**Both halves are landed.** So the clause is not missing in the sense the blocker report claims.
What is missing is the *hypothesis discharge*: both landed halves take an interval witness
(`ClassInteriorToRInterval` / `ClassInteriorToLInterval`) as an assumption, and **nothing in the
tree produces one**. Repo-wide, `ClassInteriorToRInterval` occurs at
`BadIntervals.lean:{422, 626, 868, 954, 1026, 1353, 1392}` — a definition, a field, a dual
instantiation, and four hypothesis positions. **There is no producer, on either side.**

### 1.3 Where the real gap is — and it *is* Reynolds'

The interval witness is supposed to come from Lemma 4. Reynolds' Lemma 4, printed p.179, verified
against the 200 dpi page image (the corpus display of this formula is corrupt; the image is
authoritative):

> By expressive completeness, the formula
>
> ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))
>
> has a temporal equivalent which is true only in the first classes of maximal intervals of R. If
> there is a first class then no immediately subsequent classes satisfy this and so we have this
> formula holding up to a gap and false arbitrarily soon afterwards. This contradicts Prior–U. ∎

The tree's `firstClassFormula` (`Lemma34.lean:785`) is a **correct, faithful, symbol-for-symbol
transcription** of that display, and `IsFirstClassPoint` (`:797`) is its correct semantic reading.
The transcription is not the problem.

**The display is.** Consider the configuration Lemma 3 explicitly licenses — a maximal interval of
`R` bounded below, with its excluded left end point `r ∈ M`, so `¬ρ(r)`, and with the first class
of the interval equal to `(r, δ)` for a gap `δ`:

- Take any `x` in that first class. Is Reynolds' formula true at `x`?
- The universal clause must hold at `y := r`. It demands `∃z` with **`r < z < x`** and `¬ρ(z)`.
- But `(r, x) ⊆ x`'s own class, where `ρ` holds throughout. **No such `z` exists.**
- So Reynolds' formula is **false** at `x`, even though `x` is in the first class.

Reynolds' formula therefore fails to be *complete* for "first class of a maximal interval of `R`"
in exactly the configuration his own Lemma 3 creates. It is sound (true only in first classes) —
which is the direction his Lemma 4 proof needs — but Lemma 4's *conclusion* is then weaker than
the plain-English statement, and **Lemma 6's second paragraph consumes the plain-English
statement**: *"Since the class can not be first in the bad interval, r itself must be in a ∼-class
in the bad interval"* requires that "not first" produce a class strictly below, inside the same
`R`-interval — i.e. exactly the closed lower witness the strict display cannot give.

**This is a defect in the source, and it is recorded as the source's** (honesty-charter Rule 7).
Changing `y < z` to `y ≤ z` repairs it: at `y := r`, take `z := r` itself. And Reynolds' *proof*
of Lemma 4 — soundness at later classes, plus the Prior-U gap-crossing contradiction — goes
through unchanged for the repaired formula. That is verified below, not asserted: the repaired
lemma compiles using the tree's existing `false_of_holds_throughout_class`, which *is* Reynolds'
argument, factored out.

So the honest accounting is:

- Reynolds **does** prove Lemma 6's clause (refuting "states it and treats it as established").
- Reynolds' Lemma 4 display has a **one-symbol boundary defect** which his Lemma 6 prose silently
  steps over. The tree inherited it by transcribing faithfully — which was the right thing to do.
- The tree's gap is therefore **downstream of a source defect**, not an independent formalization
  gap and not a step Reynolds waved away.

---

## 2. Source-to-implementation mapping (H3, Tier 1)

| Source (printed page) | Proposition / location | Lean identifier | Type signature (abridged) | Status |
|---|---|---|---|---|
| Reynolds 1992 p.179 | Lemma 4 display `ρ(x) ∧ ∀y<x(¬ε(x,y) → ∃z(y<z<x ∧ ¬ρ(z)))` | `firstClassFormula` | `MonadicFormula sig 2 → MonadicFormula sig 1` | **Landed, faithful, and boundary-defective (defect is Reynolds')** |
| Reynolds 1992 p.179 | Lemma 4, *"no first class"* | `reynolds_lemma4_no_first_class` | `… → ¬ IsFirstClassPoint M ε t` | Landed; **too weak to supply the lower interval witness** |
| Reynolds 1992 p.179 | Lemma 4 repaired at the `r ∈ M` boundary | `firstClassFormulaClosed`, `IsFirstClassPointClosed`, `reynolds_lemma4_no_first_class_closed` | `… → ¬ IsFirstClassPointClosed M ε t` | **NEW — pre-compiled green** |
| Reynolds 1992 p.179 | Lemma 4, *"no last class"* | `reynolds_lemma4_no_last_class` | `EndsInGapOnRight M ε t → ∃ u, t < u ∧ ¬ContempEquivDense M ε t u ∧ ∀ q ∈ [t,u], EndsInGapOnRight M ε q` | Landed; supplies the **upper** witness as-is |
| Reynolds 1992 p.179 (rendering) | *"a maximal interval of R"* | `ClassInteriorToRInterval` | `structure` with `left_lt/lt_right/left_out/right_out/rThroughout` | Landed as a **hypothesis with no producer** |
| — (new) | the producer the plan assumed | `exists_classInteriorToRInterval` | `EndsInGapOnRight M ε t → ∃ a b, ClassInteriorToRInterval M ε a t b` | **NEW — pre-compiled green** |
| Reynolds 1992 p.180 | Lemma 6, *"We first show that L holds wherever R does"* | `endsInGapOnLeft_of_endsInGapOnRight` | `ClassInteriorToRInterval M ε a t b → EndsInGapOnLeft M ε t` | Landed (Phase 20) |
| Reynolds 1992 p.180 | Lemma 6, *"Using mirror images …"* | `endsInGapOnRight_of_endsInGapOnLeft` | `ClassInteriorToLInterval M ε a t b → EndsInGapOnRight M ε t` | Landed (Phase 20.4, via `Dual.lean`) |
| Reynolds 1992 p.180 | Lemma 6 first clause, hypothesis-free form | `endsInGapOnLeft_of_endsInGapOnRight'` / `endsInGapOnRight_of_endsInGapOnLeft'` | `EndsInGapOnRight M ε t → EndsInGapOnLeft M ε t` and converse | **NEW — pre-compiled green** |
| Reynolds 1992 p.179 | *"a bad interval"* | `IsBadInterval`, `badComp` | `M.carrier → Prop` | Landed / **NEW component construction, green** |
| Reynolds 1992 p.181 | *"Let Q₀ be the bad interval itself"* | `HasBadIntervalSurgery` | `structure` (Phase 22's named hypothesis) | **NEW: `StepD.hasBadIntervalSurgery` discharges it, green** |
| Reynolds 1992 p.183 | Theorem 4 | `no_gaps_dense_prior` | `… → HasBadIntervalSurgery M ε → ¬ EndsInGapOnRight M ε t` | Landed conditional; **hypothesis now dischargeable** |

---

## 3. F1, the concrete route

Four steps. Every line below **compiled green, sorry-free**, against the tree at this commit
(`lake env lean`, Lean v4.33.0-rc1). The residual errors encountered and their fixes are recorded
in §3.6.

### Step A — the repaired Lemma 4 (additive; nothing landed is touched)

Placed in `Lemma34.lean` (needs the `private` cons lemmas `c2_one`/`c3_one`/`c3_two` at `:375-381`;
in the scratch they were re-declared as `c2_one'` etc., which the real edit will not need).
`firstClassFormula` and `IsFirstClassPoint` **stay exactly as they are** — the faithful
transcription is preserved and the repaired variant is added beside it, with a docstring recording
that the deviation from Reynolds' display is a repair of the source's boundary case.

```lean
/-- Lemma 4's displayed formula with the inner lower bound read as `y ≤ z` rather than `y < z`. -/
def firstClassFormulaClosed (ε : MonadicFormula sig 2) : MonadicFormula sig 1 :=
  .and (rhoAt ε 0)
    (.all (.imp (.lt 0 1)
      (.imp (.not (epsAt ε 1 0))
        (.ex (.and (.not (.lt 0 1)) (.and (.lt 0 2) (.not (rhoAt ε 0))))))))

def IsFirstClassPointClosed (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) : Prop :=
  EndsInGapOnRight M ε t ∧
  ∀ y : M.carrier, y < t → ¬ ContempEquivDense M ε t y →
    ∃ z : M.carrier, y ≤ z ∧ z < t ∧ ¬ EndsInGapOnRight M ε z

theorem firstClassFormulaClosed_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) :
    eval M (fun _ => t) (firstClassFormulaClosed ε) ↔ IsFirstClassPointClosed M ε t := by
  simp only [firstClassFormulaClosed, IsFirstClassPointClosed, eval, eval_imp, eval_epsAt,
    eval_rhoAt, Fin.cons_zero, c2_one, c3_one, c3_two, not_lt]

noncomputable def firstClassTemporalClosed (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (firstClassFormulaClosed ε)).val

theorem firstClassTemporalClosed_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (firstClassTemporalClosed atomMap h_surj ε) ↔
      IsFirstClassPointClosed M ε t :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj (firstClassFormulaClosed ε)).property
    M h_prior_U h_prior_S t).symm.trans (firstClassFormulaClosed_eval M ε t)

theorem isFirstClassPointClosed_congr {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t t' : M.carrier}
    (htt' : ContempEquivDense M ε t t') (h : IsFirstClassPointClosed M ε t) :
    IsFirstClassPointClosed M ε t' := by
  refine ⟨(endsInGapOnRight_congr hε M htt').mp h.1, fun y hyt' hny => ?_⟩
  have hnty : ¬ ContempEquivDense M ε t y := fun hc =>
    hny (contemp_trans hε M (contemp_symm hε M htt') hc)
  have hyt : y < t := by
    by_contra hle
    push_neg at hle
    exact hnty (contemp_of_between hε M hle hyt'.le htt')
  obtain ⟨z, hyz, hzt, hnz⟩ := h.2 y hyt hnty
  refine ⟨z, hyz, ?_, hnz⟩
  by_contra hle
  push_neg at hle
  exact hnz ((endsInGapOnRight_congr hε M
    (contemp_of_between hε M hle hzt.le (contemp_symm hε M htt'))).mp
      ((endsInGapOnRight_congr hε M htt').mp h.1))

theorem not_isFirstClassPointClosed {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t u : M.carrier} (htu : t < u)
    (hnu : ¬ ContempEquivDense M ε t u)
    (hIcc : ∀ q : M.carrier, t ≤ q → q ≤ u → EndsInGapOnRight M ε q) :
    ¬ IsFirstClassPointClosed M ε u := by
  rintro ⟨_, h2⟩
  obtain ⟨z, htz, hzu, hnz⟩ := h2 t htu (fun hc => hnu (contemp_symm hε M hc))
  exact hnz (hIcc z htz hzu.le)

theorem reynolds_lemma4_no_first_class_closed (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) : ¬ IsFirstClassPointClosed M ε t := by
  intro h
  exact false_of_holds_throughout_class atomMap h_surj hε M h_prior_U h_prior_S h.1
    (firstClassTemporalClosed atomMap h_surj ε)
    (fun r hr => (firstClassTemporalClosed_spec atomMap h_surj ε M h_prior_U h_prior_S r).mpr
      (isFirstClassPointClosed_congr hε M hr h))
    (fun u htu hnu hIcc hP => not_isFirstClassPointClosed hε M htu hnu hIcc
      ((firstClassTemporalClosed_spec atomMap h_surj ε M h_prior_U h_prior_S u).mp hP))
```

Note that `reynolds_lemma4_no_first_class_closed`'s proof is byte-for-byte the shape of the landed
`reynolds_lemma4_no_first_class` — this is Reynolds' Lemma 4 argument, unchanged, applied to the
repaired formula. That is the evidence that the repair is faithful to his *prose* even though it
deviates from his *display*.

### Step B — the producer the plan assumed existed (~22 lines)

```lean
/-- **The producer**: at any point where `R` holds, a class-interiority witness exists. -/
theorem exists_classInteriorToRInterval (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    ∃ a b : M.carrier, ClassInteriorToRInterval M ε a t b := by
  obtain ⟨b, htb, hnb, hIccb⟩ :=
    reynolds_lemma4_no_last_class atomMap h_surj hε M h_prior_U h_prior_S ht
  have hnf := reynolds_lemma4_no_first_class_closed atomMap h_surj hε M h_prior_U h_prior_S t
  have hlow : ∃ y : M.carrier, y < t ∧ ¬ ContempEquivDense M ε t y ∧
      ∀ z : M.carrier, y ≤ z → z < t → EndsInGapOnRight M ε z := by
    by_contra hcon
    push_neg at hcon
    refine hnf ⟨ht, fun y hy hny => ?_⟩
    obtain ⟨z, hyz, hzt, hnz⟩ := hcon y hy hny
    exact ⟨z, hyz, hzt, hnz⟩
  obtain ⟨a, hat, hna, hIcca⟩ := hlow
  have hR : ∀ q : M.carrier, a ≤ q → q ≤ b → EndsInGapOnRight M ε q := by
    intro q h₁ h₂
    rcases lt_or_ge q t with h | h
    · exact hIcca q h₁ h
    · exact hIccb q h h₂
  exact ⟨a, b, ⟨hat, htb, hna, hnb, hR⟩⟩
```

This is where the `≤` repair pays: with the landed strict form, `hlow` would only give `R`
throughout the **open** `(y, t)`, and `ClassInteriorToRInterval.rThroughout` demands the closed
`[a, b]`. Shrinking `a` into `(y, t)` is unavailable in exactly the residual case where `t`'s class
begins immediately after `y ∈ M` — the configuration §1.3 identifies.

### Step C — Lemma 6's first clause, hypothesis-free, both directions (~22 lines)

```lean
theorem endsInGapOnLeft_of_endsInGapOnRight' (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    EndsInGapOnLeft M ε t := by
  obtain ⟨a, b, hint⟩ :=
    exists_classInteriorToRInterval atomMap h_surj hε M h_prior_U h_prior_S ht
  exact endsInGapOnLeft_of_endsInGapOnRight atomMap h_surj hε M h_prior_U h_prior_S hint

theorem endsInGapOnRight_of_endsInGapOnLeft' (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnLeft M ε t) :
    EndsInGapOnRight M ε t :=
  (endsInGapOnLeft_dual (M := M) ε t).mp
    (endsInGapOnLeft_of_endsInGapOnRight' atomMap h_surj (isContempEquivDense_dualize hε) (dual M)
      (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U)
      ((endsInGapOnRight_dual (M := M) ε t).mpr ht))
```

### Does `Dual.lean` apply? — **Yes, at Step C, and no, at Steps A/B.**

Explicitly, since the delegation asks for a yes-or-no with a reason:

- **Step C: YES.** `endsInGapOnRight_of_endsInGapOnLeft'` is obtained by instantiating the `ρ`-side
  producer at `(dual M, dualize ε)` — 6 lines, no hand-mirror, exactly the Phase 20.4 pattern.
  It compiled first try. This is the third successful use of the transport layer.
- **Steps A and B: NO, and this is the trap.** The naive reading — *"an `L`-side interval witness
  is just the dual of an `R`-side one, so `Dual.lean` closes F1"* — fails because **there is no
  `R`-side producer to dualise.** Dualising a theorem that does not exist yields nothing. The
  transport layer can only be applied *after* Step B lands. Any dispatch that reaches for
  `Dual.lean` first will spend its budget discovering this.

### Step D — discharging `HasBadIntervalSurgery` (~110 lines)

`Q` is the bad-connected component of `t`. The `interior` field is the only real work: it needs a
single segment `[a,b]` that both straddles `p`'s class *and* contains a second arbitrary point `u`
of the component. Extending the Step B witness by `min`/`max` against `u`, and then pulling the
extension back into the component by convexity, is what does it.

```lean
namespace StepD

/-- `q` lies weakly between `t` and `x`, in whichever order they come. -/
def Btw {M : OrderedMonadicStructure sig} (t x q : M.carrier) : Prop :=
  (t ≤ q ∧ q ≤ x) ∨ (x ≤ q ∧ q ≤ t)

theorem btw_of_minmax {M : OrderedMonadicStructure sig} {t x q : M.carrier}
    (h₁ : min t x ≤ q) (h₂ : q ≤ max t x) : Btw t x q := by
  rcases le_total t x with h | h
  · rw [min_eq_left h] at h₁; rw [max_eq_right h] at h₂; exact Or.inl ⟨h₁, h₂⟩
  · rw [min_eq_right h] at h₁; rw [max_eq_left h] at h₂; exact Or.inr ⟨h₁, h₂⟩

theorem minmax_of_btw {M : OrderedMonadicStructure sig} {t x q : M.carrier}
    (h : Btw t x q) : min t x ≤ q ∧ q ≤ max t x := by
  rcases h with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩
  · exact ⟨le_trans (min_le_left _ _) h₁, le_trans h₂ (le_max_right _ _)⟩
  · exact ⟨le_trans (min_le_right _ _) h₁, le_trans h₂ (le_max_left _ _)⟩

theorem btw_self {M : OrderedMonadicStructure sig} (t x : M.carrier) : Btw t x x := by
  rcases le_total t x with h | h
  · exact Or.inl ⟨h, le_refl _⟩
  · exact Or.inr ⟨le_refl _, h⟩

/-- The bad-connected component of `t`. -/
def badComp (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2) (t x : M.carrier) : Prop :=
  ∀ q : M.carrier, Btw t x q → IsBadPoint M ε q

theorem badComp_isBadInterval (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    IsBadInterval M ε (badComp M ε t) := by
  refine ⟨⟨t, fun q hq => ?_⟩, fun x hx => hx x (btw_self t x),
    fun a b c hab hbc ha hc q hq => ?_, fun a x ha hsat q hq => ?_⟩
  · rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩ <;>
      exact (le_antisymm h₂ h₁ ▸ IsBadPoint.of_right ht)
  · rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩
    · exact hc q (Or.inl ⟨h₁, le_trans h₂ hbc⟩)
    · exact ha q (Or.inr ⟨le_trans hab h₁, h₂⟩)
  · rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩
    · rcases le_total q a with h | h
      · exact ha q (Or.inl ⟨h₁, h⟩)
      · exact hsat q (minmax_of_btw (Or.inl ⟨h, h₂⟩)).1 (minmax_of_btw (Or.inl ⟨h, h₂⟩)).2
    · rcases le_total a q with h | h
      · exact ha q (Or.inr ⟨h, h₂⟩)
      · exact hsat q (minmax_of_btw (Or.inr ⟨h₁, h⟩)).1 (minmax_of_btw (Or.inr ⟨h₁, h⟩)).2

/-- Every point of the component satisfies both `R` and `L`. -/
theorem badComp_right (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t x : M.carrier} (hx : badComp M ε t x) :
    EndsInGapOnRight M ε x := by
  rcases hx x (btw_self t x) with h | h
  · exact h
  · exact endsInGapOnRight_of_endsInGapOnLeft' atomMap h_surj hε M h_prior_U h_prior_S h

/-- **F1 discharged**: `HasBadIntervalSurgery` holds outright. -/
theorem hasBadIntervalSurgery (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) :
    HasBadIntervalSurgery M ε := by
  refine ⟨fun t ht => ⟨badComp M ε t, ⟨?_, ?_, ?_⟩, ?_⟩⟩
  · exact badComp_isBadInterval atomMap h_surj hε M h_prior_U h_prior_S ht
  · intro q hq
    rcases hq with ⟨h₁, h₂⟩ | ⟨h₁, h₂⟩ <;> exact (le_antisymm h₂ h₁ ▸ IsBadPoint.of_right ht)
  · -- `interior`
    intro p u hp hu
    have hbi := badComp_isBadInterval atomMap h_surj hε M h_prior_U h_prior_S ht
    have hRp : EndsInGapOnRight M ε p :=
      badComp_right atomMap h_surj hε M h_prior_U h_prior_S hp
    obtain ⟨a₀, b₀, hint⟩ :=
      exists_classInteriorToRInterval atomMap h_surj hε M h_prior_U h_prior_S hRp
    have ha₀ : badComp M ε t a₀ := by
      refine hbi.saturated p a₀ hp (fun q h₁ h₂ => ?_)
      rw [min_eq_right hint.left_lt.le] at h₁
      rw [max_eq_left hint.left_lt.le] at h₂
      exact IsBadPoint.of_right (hint.rThroughout q h₁ (le_trans h₂ hint.lt_right.le))
    have hb₀ : badComp M ε t b₀ := by
      refine hbi.saturated p b₀ hp (fun q h₁ h₂ => ?_)
      rw [min_eq_left hint.lt_right.le] at h₁
      rw [max_eq_right hint.lt_right.le] at h₂
      exact IsBadPoint.of_right (hint.rThroughout q (le_trans hint.left_lt.le h₁) h₂)
    refine ⟨min a₀ u, max b₀ u, min_le_right _ _, le_max_right _ _, ?_⟩
    have hamem : badComp M ε t (min a₀ u) := by
      rcases min_cases a₀ u with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h] <;> assumption
    have hbmem : badComp M ε t (max b₀ u) := by
      rcases max_cases b₀ u with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h] <;> assumption
    have hseg : ∀ q : M.carrier, min a₀ u ≤ q → q ≤ max b₀ u → badComp M ε t q :=
      fun q h₁ h₂ => hbi.convex _ _ _ h₁ h₂ hamem hbmem
    have hal : min a₀ u < p := lt_of_le_of_lt (min_le_left _ _) hint.left_lt
    have hbr : p < max b₀ u := lt_of_lt_of_le hint.lt_right (le_max_left _ _)
    refine ⟨⟨hal, hbr, ?_, ?_, fun q h₁ h₂ =>
        badComp_right atomMap h_surj hε M h_prior_U h_prior_S (hseg q h₁ h₂)⟩,
      fun q h₁ h₂ => endsInGapOnLeft_of_endsInGapOnRight' atomMap h_surj hε M h_prior_U h_prior_S
        (badComp_right atomMap h_surj hε M h_prior_U h_prior_S (hseg q h₁ h₂))⟩
    · intro hc
      exact hint.left_out (contemp_trans hε M hc
        (contemp_of_between hε M (min_le_left a₀ u) hint.left_lt.le (contemp_symm hε M hc)))
    · intro hc
      exact hint.right_out (contemp_of_between hε M hint.lt_right.le (le_max_left b₀ u) hc)
  · intro q _ hq
    rcases hq with h | h
    · exact h
    · exact endsInGapOnRight_of_endsInGapOnLeft' atomMap h_surj hε M h_prior_U h_prior_S h

end StepD
```

### Consumption — Theorem 4, unconditional in `HasBadIntervalSurgery`

```lean
theorem no_gaps_dense_prior_unconditional (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (t : M.carrier) :
    ¬ EndsInGapOnRight M ε t :=
  no_gaps_dense_prior atomMap h_surj hε h_prior_U h_prior_S
    (StepD.hasBadIntervalSurgery atomMap h_surj hε M h_prior_U h_prior_S) t
```

```
'…StepD.hasBadIntervalSurgery' depends on axioms: [propext, Classical.choice, Quot.sound]
'…no_gaps_dense_prior_unconditional' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### 3.6 Residual errors encountered and their fixes

Five, all mechanical, all recorded so the implementing dispatch does not rediscover them:

| # | Error | Fix |
|---|---|---|
| 1 | `Unknown identifier c2_one/c3_one/c3_two` | They are `private` in `Lemma34.lean:375-381`. **Not an issue for the real edit** — Step A belongs in `Lemma34.lean`, where they are in scope. In the scratch they were re-declared as `c2_one'` etc. |
| 2 | `firstClassFormulaClosed_eval` unsolved goal (`¬(z < y)` vs `y ≤ z`) | Add `not_lt` to the `simp only` set |
| 3 | `unexpected identifier; expected '}'` on a multi-line structure instance inside `exact ⟨a, b, {…}⟩` | Use the anonymous constructor: `exact ⟨a, b, ⟨hat, htb, hna, hnb, hR⟩⟩`; hoist `rThroughout` into a preceding `have` |
| 4 | `le_refl` mismatch on `Btw t x x` | Needs `le_total t x`; factored out as `btw_self` |
| 5 | `contemp_of_between` argument mismatch in the `right_out` branch | `hint.right_out (contemp_of_between hε M hint.lt_right.le (le_max_left b₀ u) hc)` — direct, no `contemp_trans`/`contemp_symm` wrapper (the `left_out` branch does need the wrapper; the two are not symmetric in this rendering) |

### 3.7 Sizing and file placement

| Step | Home file | Candidate lines | With docstrings |
|---|---|---|---|
| A | `DenseModelSurgery/Lemma34.lean` (additive, after `reynolds_lemma4`) | 85 | ~135 |
| B | `DenseModelSurgery/Lemma34.lean` or `BadIntervals.lean` | 22 | ~40 |
| C | `DenseModelSurgery/BadIntervals.lean` (after `endsInGapOnRight_of_endsInGapOnLeft`) | 22 | ~45 |
| D | `DenseModelSurgery/NoGaps.lean` (needs `HasBadIntervalSurgery` in scope) | 110 | ~165 |
| — | header/caveat updates in `NoGaps.lean` `## Conditionality after Theorem 4` | — | ~30 |
| **Total** | **3 files, all already owned by Block F** | **239** | **~415** |

No new module. No territory extension. Two of the three files are already `[COMPLETED]`, so the
edits are strictly additive insertions plus one docstring revision — the Preserved-Assets
constraint is respected: nothing landed is restated, reordered or weakened.

---

## 4. Adversarial Self-Verification (H4)

### 4.1 Claim verification table

| Claim | Source / Counterexample | Verification method | Confidence |
|---|---|---|---|
| Reynolds proves Lemma 6's clause; he does not merely assert it | Printed p.180, five paragraphs of argument | 200 dpi page image read directly | **High** |
| The implementer's *"his Lemma 6 states the clause and he takes it as established"* is wrong | Same page | Page image | **High** |
| The corpus §6 prose matches the print (one typo normalisation: *"Its"* → *"It's"*) | `sec03_6-…md:80-92` vs image | Line-by-line comparison | **High** |
| Reynolds' Lemma 4 display is `ρ(x) ∧ ∀y<x(¬ε(x,y) → ∃z(y<z<x ∧ ¬ρ(z)))`, strict | Printed p.179 | 200 dpi page image (corpus display at `:60` is corrupt — a **third** recorded §6 corpus defect, distinct from the two already on record) | **High** |
| `firstClassFormula` (`Lemma34.lean:785`) is a faithful transcription of that display | Side-by-side against the image | Read + `firstClassFormula_eval` is a checked transcription theorem | **High** |
| No producer of `ClassInteriorToRInterval` exists anywhere in the tree | 7 occurrences: def, field, dual, 4 hypothesis positions | Repo-wide grep excluding `Boneyard/` | **High** |
| The strict display fails to characterise "first class" when the `R`-interval has an excluded left end point `r ∈ M` | At `y := r`, `(r, x) ⊆ x`'s class, all `ρ` | Hand derivation, §1.3; **corroborated mechanically** — `reynolds_lemma4_no_first_class_closed` is a strictly stronger statement and required a real proof, so the two are genuinely inequivalent | **High** |
| The `≤` repair still admits Reynolds' Lemma 4 proof | `reynolds_lemma4_no_first_class_closed` compiles via the same `false_of_holds_throughout_class` route | `lake env lean`, green | **High** |
| Steps A–D compile green, sorry-free | 294-line scratch module | `lake env lean`, zero errors | **High** |
| `hasBadIntervalSurgery` is axiom-clean | `[propext, Classical.choice, Quot.sound]` | `#print axioms` | **High** |
| `Dual.lean` applies at Step C but not at Steps A/B | Step C compiled first try; Steps A/B have no `R`-side theorem to dualise | Compile + grep | **High** |
| The `≤` change is a deviation from Reynolds' printed display | Image shows `y < z < x` | Page image | **High** |
| F2 has no import cycle | `ChronicleMonadicBridge`'s 280-module transitive closure contains **zero** `DenseModelSurgery` modules; `NoGaps`' closure contains zero `BXCanonical` modules | Transitive-closure computation over all `import` lines outside `Boneyard/` | **High** |
| F1 does **not** retire the standing conditionality caveat | `IsContempEquivDense ε` and Prior-U/S remain hypotheses; `epsTop` is still the only exhibitable `ε` | Read of `Defs.lean` witnesses + `NoGaps.lean:707-740` | **High** |

### 4.2 Attacks on my own route

**Attack 1 — "the `≤` repair is unfaithful; it silently rewrites Reynolds."**
Partly lands, and the route is shaped to absorb it. Mitigation: `firstClassFormula` and
`IsFirstClassPoint` are **not modified**; the repaired variant is added beside them under a
different name, with a docstring that quotes the printed display, states the boundary
configuration it fails on, and attributes the defect to the source. Anyone auditing the tree
against p.179 still finds the faithful transcription where they expect it. **This is a
deviation and must be flagged as one in the implementing dispatch's deviation record** — it is
not absorbed silently.

**Attack 2 — "you have proved something vacuous."**
Does not land, but the *scope* of the win must be stated precisely. `hasBadIntervalSurgery` is
parametric in `M` and `ε` and assumes only `IsContempEquivDense ε` plus Prior-U/S — the same
hypotheses every §6 result carries. It is a real construction, not a vacuity artifact. **But**:
for the only `ε` the tree can currently exhibit (`epsTop`), `EndsInGapOnRight` is empty, so the
result has no live non-trivial instance. **The standing caveat's halves one and two survive
untouched.** What F1 retires is precisely the *third* condition the Phase 22 module header
introduced. Nothing below Lemma 2 becomes "discharged" in the unconditional sense.

**Attack 3 — "Step D's `interior` field is where this will fall over."**
It was the hardest part and it did nearly fall over, twice (residual errors 4 and 5). It now
compiles. The specific subtlety a re-derivation would hit: `interior` demands one segment that
straddles `p`'s class **and** contains an unrelated point `u` of the component. Extending by
`min`/`max` is fine, but the extension's `left_out`/`right_out` require pulling class-exclusion
back from `a₀`/`b₀` to `min a₀ u`/`max b₀ u`, and the two sides need *different* argument shapes
(§3.6 #5). If the implementing dispatch re-derives instead of transcribing, budget an extra hour.

**Attack 4 — "the implementer's diagnosis was right and you have just restated it."**
Does not land. The implementer said the crux is *"producing a `ClassInteriorToLInterval` witness at
a merely-`L` point"* and that `reynolds_lemma4_no_first_class` supplies the lower interiority
witness. Both are wrong in a way that would have cost a dispatch:
- The `L`-side witness is **not** the thing to build. Build the `R`-side one (Step B) and take the
  `L` side by duality. Building the `L` side directly means hand-mirroring Lemma 4 — the exact
  cost Phase 20.4's transport layer exists to avoid.
- `reynolds_lemma4_no_first_class` does **not** supply the lower witness. It gives `R` on the
  **open** `(y, t)`; `ClassInteriorToRInterval.rThroughout` needs the **closed** `[a, t]`. Shrinking
  `a` into `(y, t)` fails in exactly the boundary case. A dispatch that adopted the implementer's
  reading would grind on `push_neg` output for hours before finding the off-by-one.

**Attack 5 — "the whole thing is downstream of a claim about Reynolds you cannot fully settle."**
Partly lands, and is the residual risk. The claim "Reynolds' Lemma 4 display has a boundary
defect" is my reading, verified against the image but not against any secondary source. The route
does **not** depend on the reading being right: it depends only on the repaired lemma being
**provable**, which is machine-checked. If a reader disagrees about whether Reynolds intended `≤`,
the Lean is unaffected — only the docstring's attribution would change. **Fallback if the
attribution is disputed:** state the repair as this tree's rendering choice rather than as a source
defect, and cite Reynolds' Lemma 6 second paragraph as the evidence that the plain-English reading
is the one he uses. No code changes.

### 4.3 Contradiction log

**Resolved.** The Phase 22 implementer's blocker report (`NoGaps.lean:627-646`, plan `:3565-3577`)
locates the gap at Lemma 6 and names `endsInGapOnRight_of_endsInGapOnLeft` as the theorem that
"proves it, but only from a `ClassInteriorToLInterval` witness". This dispatch locates it at Lemma
4's boundary and produces the `R`-side witness instead. Precedence: **direct machine-checked
evidence over an agent's stuck-state diagnosis.** The compiled Step B settles it — the `L`-side
witness is never constructed anywhere in the working proof.

**No unresolved contradictions.**

---

## 5. F2 — module placement for the anti-vacuity instantiation

### 5.1 The cycle claim is refuted

Computed over every `import` line in `FormalSystem/` outside `Boneyard/`:

| Question | Answer |
|---|---|
| Does `ChronicleMonadicBridge` transitively import `DenseModelSurgery/NoGaps`? | **No** |
| Does it transitively import **any** `DenseModelSurgery` module? | **No — zero** |
| Does `NoGaps` transitively import `ChronicleMonadicBridge`? | No |
| Does `NoGaps` transitively import **any** `BXCanonical` module? | **No — zero** |

`ChronicleMonadicBridge.lean:7-14` imports `WeakCanonical.Transfer`, `.Table`,
`.IntegerModel.ReynoldsBridge`, `Bundle.TemporalCoherence`, `.PriorDefsDense`,
`.Kamp.KPlusFaithful`, `.PriorExpressivenessDense`, and
`BXCanonical.Chronicle.ChronicleToCountermodelBasic`. It imports **specific** `WeakCanonical.*`
modules, not the `WeakCanonical` umbrella, and none of them is under `DenseModelSurgery/`. The two
subtrees are import-disjoint; only `FormalSystem/Metalogic/WeakCanonical.lean` (a leaf aggregator)
sees both.

So `NoGaps.lean` *could* legally `import …ChronicleMonadicBridge` today. **It should not.** The
real objection is layering, not cyclicity: `ChronicleMonadicBridge`'s transitive closure is **280
modules**, and pulling that into the surgery layer would make a low-level, parametric §6 module
depend on the entire canonical-model construction. The implementer reached the right conclusion
through the wrong argument, and declining to extend territory silently was correct behaviour.

### 5.2 Recommended home

```
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/ChronicleInstance.lean   (new)
```

- **Imports**: `…DenseModelSurgery.NoGaps` and
  `FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleMonadicBridge`. Both closures are
  disjoint, so this is a clean join point with no cycle risk.
- **Alternative placement** if Block F would rather not put a `BXCanonical`-dependent file inside
  `DenseModelSurgery/`: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleNoGaps.lean`.
  Identical import set; only the directory differs. **Recommendation: the `DenseModelSurgery/`
  path**, because the file's content is §6 material and Block F's phases already own that
  directory, so no territory boundary is crossed.
- **Owner**: not Phase 22 (closed as `[PARTIAL]`) and not a new phase of its own. It is one
  instantiation of ~30 lines. **Fold it into the same sub-phase that lands F1** — the file is
  where `no_gaps_dense_prior`'s hypotheses finally get discharged at a live structure, and F1 is
  what makes that discharge worth performing.

### 5.3 Is mathematics left in F2?

**Almost none — but not literally none, and the residue matters.**

- **Prior-U / Prior-S**: pure instantiation. `chronicleIsDensePriorSepStructure`
  (`ChronicleMonadicBridge.lean:1053`) already provides `priorU` and `priorS` fields of
  `IsDensePriorSepStructure`. Plugging them into `no_gaps_dense_prior_unconditional` is a term.
- **`IsContempEquivDense ε`**: **not** supplied by the chronicle instance, and **not** F2's to
  supply. The only exhibitable `ε` remains `epsTop`. Reynolds' actual `ε` — the one that defines
  `∼_M` — is **Phase 25**'s deliverable (§8 Lemma 12, plan `:3680`ff).

So F2 is an **architecture decision plus a mechanical instantiation**. What it delivers is the
retirement of the caveat's *first* half (the structure), at one named structure. It does **not**
retire the second half (`ε`). Combined with F1 retiring the third condition, the position after
both land is: **one of three conditions fully gone (`HasBadIntervalSurgery`), one gone at a live
structure (Prior-U/S), one standing until Phase 25 (`ε`).** The standing caveat text must be
rewritten to say exactly that, and must not be deleted.

---

## 6. Plan fidelity check

Read: plan v9 `plans/09_strong-completeness-dedekind-v9.md`, Phase 20 (`:2971-3035`), Phase 20.4
(`:3139`), Phase 22 (`:3510-3615`), Phase 29 (`:3812-3845`), and the Phase 20 rendering notes
(`:3108-3125`).

### 6.1 What the plan got right

v9 is materially more faithful than v8 here. It split Reynolds' one Lemma 6 sentence into **four
halves** (a)-(d) at `:2994-3014`, correctly identified half (d) — *"Using mirror images…"* — as a
module-sized dependency rather than a step, chartered it as Phase 20.4, and correctly predicted
that `ClassInteriorToLInterval` did not exist and would have to be created. All of that held up.

### 6.2 Where the plan deviates from the source

**The deviation is at plan line 3117-3120**, in Phase 20's *"Rendering 1"* note:

> *Rendering 1 — "a maximal interval of R".* Rendered as `ClassInteriorToRInterval M ε a t b`: two
> points `a < t < b` outside `t`'s class with `R` throughout `[a,b]`. **That is what Lemma 4 ("no
> last class and no first class") plus convexity of a maximal interval supply.**

That sentence is an **unproved supply claim, asserted in a rendering note and never chartered as a
task.** It is false as stated for the landed Lemma 4: `reynolds_lemma4_no_last_class` supplies the
upper half, but `reynolds_lemma4_no_first_class` does **not** supply the lower half, for the
boundary reason in §1.3. No phase in v9 — not 19, not 20, not 20.4, not 22 — has a task whose
deliverable is a producer of `ClassInteriorToRInterval`.

**So, to answer the delegation's question directly:** the plan did **not** anticipate that Theorem
4 would need Lemma 6's clause as an input. It assumed the clause's *hypothesis* would already be
discharged, by Lemma 4 plus convexity, in Phase 20 — and recorded that assumption as a rendering
note rather than as a task with a checkbox. Phase 22 then discovered the shortfall at the point of
consumption and, correctly, named it rather than working around it.

A second, smaller deviation: the plan's Phase 22 `[PARTIAL]` note (`:3565-3577`) transcribes the
implementer's mislocated diagnosis verbatim into the plan, including *"`reynolds_lemma4_no_first_class`
[gives] the lower [interiority witness]"*. That sentence is now known to be false and would
mislead the next dispatch.

### 6.3 Recommendation

**Yes — revise the plan before the next implement dispatch.** Three sections, minimally:

1. **Phase 20, "Rendering 1" (`:3117-3120`)** — replace the supply claim with the measured fact:
   Lemma 4 supplies the upper witness only; the lower witness needs the repaired Lemma 4, and that
   repair is a task, not a rendering.
2. **Phase 22's `[PARTIAL]` blocker note (`:3565-3577`)** — correct the mislocation. The gap is
   Lemma 4's boundary case, not a missing `ClassInteriorToLInterval` witness. Keep the original
   text visible (as the plan's own convention does) so the correction is auditable.
3. **New sub-phase 22.1** — charter F1 + F2 with the sizing in §3.7 and §5.2.

Phase 29 needs no change of substance: its task list already says *"Land the statement so Phase 30
can consume it with `D1 := no_gaps_dense_prior`"*. Once 22.1 lands, `no_gaps_dense_prior` has one
fewer hypothesis and Phase 29 consumes it directly, as originally written. **One caveat for Phase
29**: its *"Anti-vacuity: instantiate at `chronicleIsDensePriorSepStructure`"* task still needs a
live `ε`, which is Phase 25's. Phase 29's checkbox should cite that dependency explicitly.

---

## 7. Verdict

**(a) Implementable now as sub-phase 22.1** — with **(b)** as a hard precondition: the plan
revision in §6.3 must land first, because the plan currently carries two statements that would
send the implementing dispatch to the wrong file.

This is not a hedge. The ordering is: revise (30 minutes, three edits, no research needed — the
replacement text is in §6.3), then dispatch 22.1.

### Charter — Phase 22.1: Reynolds §6 Lemma 4's boundary case, and the discharge of `HasBadIntervalSurgery`

- **Goal**: retire the `HasBadIntervalSurgery` hypothesis from `no_gaps_dense_prior` and
  `no_gaps_dense_prior_left`, and land the chronicle anti-vacuity instantiation.
- **Owns**: `DenseModelSurgery/Lemma34.lean`, `DenseModelSurgery/BadIntervals.lean`,
  `DenseModelSurgery/NoGaps.lean`, and `DenseModelSurgery/ChronicleInstance.lean` (new).
- **Tasks**:
  1. **Step A** — add `firstClassFormulaClosed`, `IsFirstClassPointClosed`,
     `firstClassFormulaClosed_eval`, `firstClassTemporalClosed(_spec)`,
     `isFirstClassPointClosed_congr`, `not_isFirstClassPointClosed`,
     `reynolds_lemma4_no_first_class_closed` to `Lemma34.lean`, **beside** the landed faithful
     transcription, which is not modified. Docstring must quote printed p.179's display verbatim,
     state the boundary configuration it fails on, and attribute the defect to the source.
     **Record this as a flagged deviation in the phase's deviation record.**
  2. **Step B** — `exists_classInteriorToRInterval`.
  3. **Step C** — `endsInGapOnLeft_of_endsInGapOnRight'` and its dual, in `BadIntervals.lean`,
     via `Dual.lean`.
  4. **Step D** — `Btw`/`badComp` family and `hasBadIntervalSurgery` in `NoGaps.lean`; then
     restate `no_gaps_dense_prior` / `no_gaps_dense_prior_left` without the hypothesis (keeping
     the hypothesised forms as `_of_hasBadIntervalSurgery` variants if any caller wants them).
  5. **F2** — `ChronicleInstance.lean`, importing `NoGaps` and `ChronicleMonadicBridge`;
     instantiate at `chronicleIsDensePriorSepStructure`.
  6. **Rewrite** `NoGaps.lean`'s `## Conditionality after Theorem 4` to the three-condition
     accounting in §5.3. **Do not delete the caveat.** Halves one and two of the standing §6
     caveat stay in every module header that carries them; only the third condition is retired.
  7. `#print axioms`; scoped build; full `lake build`.
- **Preserved Assets**: `firstClassFormula`, `IsFirstClassPoint`, `reynolds_lemma4_no_first_class`,
  `reynolds_lemma4_no_last_class`, `reynolds_lemma4`, `endsInGapOnLeft_of_endsInGapOnRight`,
  `endsInGapOnRight_of_endsInGapOnLeft`, `reynolds_lemma6`, `reynolds_lemma9`. All additive; none
  may be restated, renamed, reordered or weakened.
- **Estimated output**: ~415 lines across 4 files. **239 of them are pre-compiled green in §3 of
  this report** — transcribe, do not re-derive.
- **Depends on**: 22 (closed `[PARTIAL]`), and on the §6.3 plan revision.
- **Timing**: 3 hours.
- **Hard gate** (borrowed from Phase 20.4's R15 pattern): if **Step A** does not reproduce green
  in-file on the first dispatch, stop and report — do not iterate on alternatives, and do not
  attempt the `L`-side hand mirror, which §4.2 Attack 4 shows is the wrong direction.

### What this does *not* claim

The standing §6 conditionality caveat is **not** retired by this work. Every §6 result below Lemma
2 remains conditional on `IsContempEquivDense ε`, `epsTop` is still the only `ε` this tree can
exhibit, `EndsInGapOnRight` is still empty for it, and there is still **no live non-trivial
instance**. What 22.1 removes is one named hypothesis — the third condition, introduced by Phase
22 — and, at one named structure, the Prior-U/S half. The `ε` half stands until Phase 25.
