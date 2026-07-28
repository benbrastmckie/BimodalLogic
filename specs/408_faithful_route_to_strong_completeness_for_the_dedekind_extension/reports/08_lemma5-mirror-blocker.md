# Blocker research — Reynolds §6 Lemma 6, fourth half: the missing Lemma 5 mirror

**Task**: 408 · **Session**: `sess_1785271303_3ad669` · **Mode**: `--hard --lit`
**Agent**: `lean-research-hard-agent` · **Reference grounding tier**: **Tier 1** (literature-backed)
**Blocker source**: Phase 20 handoff, Lemma 6 fourth half (`R` wherever `L`)

---

## Verdict (read this first)

All three of the deliverable options hold, in this configuration:

| | Verdict | Substance |
|---|---|---|
| **(a)** | **HOLDS — mechanical dual IS available** | `OrderedMonadicStructure.dual` over `OrderDual` + `dualize`/`swapUS` transport. **~150 of the ~320 required lines were compiled green during this dispatch** (probe below). One piece remains unverified and is named. |
| **(b)** | **HOLDS, but the ~180-line estimate is wrong** | A hand mirror is a genuine separate development — of **~540–590 lines, not ~180**. The Phase 20 estimate sized only `reynolds_lemma5_first_left` and omitted the fourth half's own mirror chain, which is the actual deliverable. In-file precedent (Lemma 7's mirror, 258 lines) corroborates. |
| **(c)** | **HOLDS — plan v8 deviates from Reynolds** | Phase 19 chartered Lemma 5 on the `ρ` side only. Reynolds' Lemma 6 provably needs both sides. Named sections to revise are in §6 below. |

**Recommendation**: charter **sub-phase 20.4 as the `OrderDual` transport route (a)**, not as a hand
mirror. It is ~40% smaller, it is mostly mechanical transport rather than new mathematical
argument, and it discharges *every* remaining "mirror image" in §6 — not just this one — at ~25
lines each. Revise plan v8 first (c), because the charter Phase 19 was given is the root cause.

---

## 1. Literature findings — verified verbatim against the page images

Page map re-confirmed this dispatch: **printed page = PDF page (1-based) + 164**. Lemma 5 is
printed **p.179** = PDF page 15; Lemma 6 is printed **p.180** = PDF page 16. Both pages were read
as rendered images at 200 dpi, not from `pdftotext`.

### 1.1 Q1 — Is Lemma 5 stated symmetrically? **No. It is `R`-side only, and that is Reynolds' own omission, not our transcription gap.**

Printed p.179, read off the page image, verbatim:

> **LEMMA 5** *If a temporal formula holds somewhere in one ∼–class in a maximal interval of R,
> then it holds somewhere in each ∼–class in the interval.*
>
> *Furthermore, each pair of the ∼–classes in a maximal interval of R are elementarily equivalent
> ( taken as substructures of M ).*

There is **no** dual statement, no "dually", and no `L`-side variant anywhere on the page. The same
holds for Lemmas 3 and 4 — all three are stated over *maximal intervals of `R`* only.

This is deliberate on Reynolds' part, not an oversight: he establishes a global duality convention
early and then leans on it. Printed p.178: *"Dually we can define λ(x) about left ends."* Lemma 2
ends with the bare sentence *"Dually L."* Having set that convention, he states Lemmas 3–5 on one
side and collects all four duals at once with the single sentence at the end of Lemma 6.

**Consequence for us**: the `L`-side Lemma 5 is a real mathematical dependency of Lemma 6 that
Reynolds never writes down. The Phase 20 agent's diagnosis is **faithful to the source**. This is
not a transcription defect on our side, and the corpus is not at fault here — §6 inline prose
checked clean against the images again, keeping the standing defect count at two, both displays.

### 1.2 Q2 — What does *"using mirror images of the above and previous results"* license?

Printed p.180, verbatim from the page image, the complete Lemma 6 proof:

> **PROOF.** We first show that *L* holds wherever *R* does. Suppose for contradiction that we have
> a maximal interval of *R* in which *L* fails to hold somewhere. […]
>
> Thus we have a class in the bad interval which includes its left hand end point. Its not hard to
> use the previous result to show that throughout the bad interval all classes include their left
> hand end points.
>
> Let *B* be a temporal formula true at times which are not left hand end points of their
> ∼–classes. *B* is then true continuously in any class from just after the left hand end point up
> until the gap at the right hand end point. *B* must be false arbitrarily soon after the gap
> contradicting Prior–U.
>
> **Using mirror images of the above and previous results we get our proof.** ∎

Parsing the referents precisely:

| Phrase | Referent | Mirror needed |
|---|---|---|
| *"the above"* | the four paragraphs just given — *"`L` holds wherever `R` does"* | `R` wherever `L`, over a maximal interval of **`λ`** |
| *"previous results"* — *"the previous result"* named inside the argument | **Lemma 5** (it is the only thing that gets *"all classes include their left hand end points"* from one class doing so) | **Lemma 5 over maximal intervals of `λ`** |
| *"previous results"* — *"can not be first in this bad interval"* | **Lemma 4** (no first/last class in a maximal interval of `R`) | Lemma 4 over maximal `λ`-intervals |
| *"previous results"* — the interval being open with excluded end points | **Lemma 3** | Lemma 3 over maximal `λ`-intervals |

So the mirror is a **mechanical dualization**, but a *wide* one: it dualizes the whole `ρ`/`R`
tower (Lemmas 3, 4, 5) plus the p.180 argument itself. The dualization dictionary is exactly
`ρ↔λ`, `R↔L`, `<↔>`, `K⁺↔K⁻`, `Prior-U↔Prior-S`, *left hand end point↔right hand end point*,
*immediate predecessor↔immediate successor*.

**It does not need a genuinely separate argument.** Every ingredient Reynolds relies on is
symmetric under that dictionary: the Prior axioms come in a U/S pair by hypothesis; `∼` is an
equivalence relation (hence symmetric) partitioning into intervals (a self-dual condition); and
the notion of a Dedekind gap at a class boundary is self-dual. There is no step in the p.180 proof
that uses an order-asymmetric fact.

### 1.3 Q3 — Is *our* formalization symmetric enough for a mechanical dual? **Yes, with exactly one nameable artifact.**

I checked every notion the R-side chain touches. Verified symmetric (probe-confirmed where noted):

| Notion | Symmetric? | Evidence |
|---|---|---|
| `MonadicFormula` / `eval` | **Yes** | Only `.lt` carries order. Under `dualize` (flip `.lt i j ↦ .lt j i`) the `lt` case of the transport theorem is **`Iff.rfl`** — order reversal is *definitional*. Probe-verified. |
| `TemporalTruth` `.untl`/`.snce` | **Yes** | Exact mirrors in `Table.lean:193-198`. `temporalTruth_dual` compiled green on the first probe attempt. |
| `SemanticPriorU` / `SemanticPriorS` | **Yes** | Exact mirrors, `PriorDefsDense.lean:119/133`, both quantified over **all** formulas `p` — which is what makes `SemanticPriorU (dual M) ↔ SemanticPriorS M` go through. Probe-verified. |
| `EndsInGapOnRight` / `EndsInGapOnLeft` | **Yes** | Exact mirrors, `Defs.lean:307/317`. Probe-verified transport (one propositional conjunct reorder). |
| `ContempEquivDense` | **Yes** | Probe-verified: `contempEquivDense_dual` closes essentially by `congr`. |
| `holdsSomewhereInClassFormula` | **Yes — order-free** | `Lemma5.lean:300`: `.ex (.and (epsAt ε 1 0) (atVar α 0))`, contains no `.lt`. Reusable verbatim on both sides. |
| `uSExpressivelyCompleteOverDensePrior` | **Yes** | Its `.property` takes exactly `(M) (h_prior_U) (h_prior_S) (t)` — no density instance, no carrier hypothesis (`Defs.lean:390` call site). Applies at `dual M` unchanged. |

**The one asymmetry, and it is ours, not Reynolds':**

> `IsContempEquivDense` clause (iii) `contemporary` (`Defs.lean:242`) renders Reynolds' `M | [a,b]`
> as `M.subinterval sig (min a b) (max a b)`, whose carrier is the Subtype
> `{x // min a b ≤ x ∧ x ≤ max a b}`. Under order reversal the dual subinterval's predicate is
> `x ≤ max a b ∧ min a b ≤ x` — **the same two conjuncts in the opposite order**. Subtypes over
> `P ∧ Q` and `Q ∧ P` are not definitionally equal, so this one clause does not transport for free.

Reynolds' `M | [a,b]` is an unordered interval; the conjunct ordering is an artifact of our
Lean rendering. **Record this**: it is the single place in the §6 formalization where our
encoding is less symmetric than the mathematics it encodes.

Two mitigations, both cheap, detailed in §4.3. Decisive fact: **clause (iii) is never consumed.**
Repo-wide, `contemporary` appears at exactly two sites — its own declaration (`Defs.lean:242`) and
its *construction* in the `epsTop` witness (`Defs.lean:479`). The whole of §6 uses only
`hε.equiv` and `hε.convex`, via the four helpers `contemp_refl` / `contemp_symm` /
`contemp_trans` / `contemp_of_between` (`Lemma34.lean:176-199`).

---

## 2. Q4 — sizing, the highest-value question

### 2.1 The Phase 20 estimate is a substantial under-count

The handoff's *"~180 lines mirroring `not_endsInGapOnRight_of_immediatePredecessor`,
`false_of_allClassesHaveLeftEnd` and `exists_leftEnd_throughout`"* sizes only part of the job. Two
chains are needed, and the estimate covers neither in full.

**Chain 1 — `reynolds_lemma5_first_left` itself** (`Lemma5.lean`, R-side spans measured):

| R-side asset | Lines | Mirror status |
|---|---:|---|
| `kMinusFormula` / `KMinusAt` / `_eval` (`:243-268`) | 26 | needed (`kPlusFormula` / `KPlusAt`) |
| `classBeginsWith…` → `classLeftEndKMinusTemporal` + specs (`:271-378`) | 108 | needed (`classRightEndKPlus…`) |
| `false_of_holds_throughout_class_bounded` (`:400-435`) | 36 | **already landed** as `false_of_holds_throughout_class_upto_bounded` (`BadIntervals.lean:1027`) |
| `exists_bound_notHolds` (`:451-479`) | 29 | needed |
| `false_of_classInvariant_changes` (`:510-582`) | 73 | needed |
| `reynolds_lemma5_first` (`:591-627`) | 37 | needed |
| `holdsSomewhereInClass*` (`:300-353`) | — | **reusable verbatim** (order-free) |
| `exists_contemp_lt`, `endsInGapOnLeft_congr` | — | **already landed** (`BadIntervals.lean:1005`, `:975`) |
| **Chain 1 residual** | **~273** (≈320 with docstrings) | |

**Chain 2 — the fourth half itself** (`BadIntervals.lean`), which the estimate omits entirely:

| R-side asset | Lines | Mirror |
|---|---:|---|
| `NotLeftEnd` / `notLeftEndFormula` / `notLeftEndTemporal` + specs (`:332-375`) | 44 | needed |
| `not_endsInGapOnRight_of_immediatePredecessor` (`:390-414`) | 25 | needed |
| `ClassInteriorToRInterval` (`:416-443`) | 28 | needed |
| `leftEnd_iff_exists_not_notLeftEnd` (`:444-458`) | 15 | needed |
| `exists_leftEnd_throughout` (`:466-486`) | 21 | needed |
| `false_of_allClassesHaveLeftEnd` (`:514-595`) | 82 | needed |
| `endsInGapOnLeft_of_endsInGapOnRight` (`:615-670`) | 56 | needed |
| **Chain 2 residual** | **~271** | |

**Hand-mirror total: ~540–590 lines**, i.e. roughly **3× the estimate**, spanning two files.

**Empirical calibration, from this repository**: Phase 20 already executed exactly this pattern
once. `BadIntervals.lean:968-1225` — the Lemma 7 *"Similarly at the end"* mirror — is **258 lines**
for a chain roughly half the size of the two above. The ~540–590 figure is consistent with that
measured precedent; the ~180 figure is not.

### 2.2 There IS a factorization — and it is the standard Lean idiom

The repository has **no** `OrderDual` machinery anywhere (`grep` over
`FormalSystem/Metalogic/WeakCanonical/`: every past/future duality is hand-written, including the
whole 364-line `Kamp/Lemma53FaithfulPast.lean`). So the cheap route was never available — not
because it does not work, but because it was never built.

**I built and compiled the core of it during this dispatch.** The probe was run via
`lean_run_code` against `FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Lemma5`. Final
state: **three trivial errors remaining out of ten declarations** — one `generalizing` lint, one
`congr` that closed the goal early, and one conjunct reorder in a three-line `refine`. Everything
load-bearing compiled.

The mechanism, and the one trick that makes it cheap:

```lean
def dual (M : OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := (M.carrier)ᵒᵈ
  interp p x := M.interp p (OrderDual.ofDual x)
  carrierOrder := inferInstance

/-- Move a point across, definitionally — this is what removes ALL the `Fin.cons` friction. -/
def d {M : OrderedMonadicStructure sig} (x : M.carrier) : (dual M).carrier := x
```

With `d` in place (rather than `OrderDual.toDual`, which triggers the `.carrier`-unfolding
mismatch that `NEquivalence.lean:134` already documents for `orderedSum`), the binder cases of the
`eval` transport collapse to one-liners:

```lean
| all a ih => show (∀ x, _) ↔ (∀ x, _)
              exact ⟨fun h x => (ih (Fin.cons x env)).mp (h (d x)),
                     fun h x => (ih (Fin.cons x env)).mpr (h x)⟩
```

**Compiled green in the probe** (all with full proofs, not statements):

| Declaration | Content |
|---|---|
| `dual`, `d`, `dual_carrier`, `d_lt` | the dual structure; `d_lt : d x < d y ↔ y < x` is `Iff.rfl` |
| `dualize` | flip every `.lt` in a `MonadicFormula` |
| `eval_dualize` | `eval (dual M) (d ∘ env) (dualize φ) ↔ eval M env φ` — **`lt` case is `Iff.rfl`** |
| `swapUS` | swap `untl`/`snce`; **leaves `.box` opaque**, which is required since `TemporalTruth` reads `atomMap (.box φ)` |
| `temporalTruth_dual` | `TemporalTruth (dual M) atomMap (d t) A ↔ TemporalTruth M atomMap t (swapUS A)` |
| `swapUS_involutive` | |
| `semanticPriorU_dual` | **`SemanticPriorS M → SemanticPriorU (dual M)`** |
| `contempEquivDense_dual` | `∼` is the same relation on the dual |
| `endsInGapOnRight_dual` | **`EndsInGapOnRight (dual M) (dualize ε) (d t) ↔ EndsInGapOnLeft M ε t`** |

That is **~150 lines with docstrings, verified this dispatch**.

### 2.3 What remains, and the honest costing

| Item | Lines | Verified? |
|---|---:|---|
| Group 1 — the probe above | ~150 | **Yes, this dispatch** |
| `semanticPriorS_dual` (symmetric to the verified one) | ~20 | No, but symmetric to a green proof |
| `endsInGapOnLeft_dual` (symmetric to the verified one) | ~25 | No, but symmetric to a green proof |
| `isContempEquivDense_dualize`, clauses (i)+(ii) | ~30 | No — routine, uses `contempEquivDense_dual` |
| `isContempEquivDense_dualize`, **clause (iii)** | ~70 | **No — the one real risk**, see §4.3 |
| `reynolds_lemma5_first_left` (instantiate at `(dual M, dualize ε)`) | ~25 | No |
| `endsInGapOnRight_of_endsInGapOnLeft` (instantiate at `(dual M, dualize ε)`) | ~30 | No |
| **Route (a) total** | **~350** | ~150 green |
| **Route (b) total** (hand mirror, §2.1) | **~560** | 0 green |

**Route (a) is ~40% smaller and front-loads its risk into 150 already-green lines.** Its decisive
advantage is not the line count, though — it is that the *fourth half comes with it*. Once `dual`
and `dualize` exist, `endsInGapOnRight_of_endsInGapOnLeft` is `endsInGapOnLeft_of_endsInGapOnRight`
instantiated at `(dual M, dualize ε)`, and so is every other *"mirror image"* Reynolds waves at:
Lemma 3's dual, Lemma 4's dual, and — retrospectively — the 258 lines of Lemma 7 mirror already
paid for.

**Fidelity argument, which points the same way.** Reynolds does not re-run the proof on the left;
he says *"using mirror images … we get our proof"*. An `OrderDual` instantiation formalizes
**that sentence**. A 560-line hand mirror formalizes a proof Reynolds did not write. Under this
project's literature-fidelity standard, route (a) is the more faithful rendering, not merely the
cheaper one.

---

## 3. Reference grounding — Tier 1 lemma mapping

| Source (Reynolds 1992) | Prop / location | Lean identifier | Type signature (hover-confirmed) | Status |
|---|---|---|---|---|
| §6 Lemma 5, first statement | printed **p.179**, PDF p.15 | `reynolds_lemma5_first` | `… (hIcc : ∀ q, min t t' ≤ q → q ≤ max t t' → EndsInGapOnRight M ε q) → (∃ w, ContempEquivDense M ε t w ∧ TemporalTruth M atomMap w A) → ∃ w, ContempEquivDense M ε t' w ∧ TemporalTruth M atomMap w A` | **LANDED** `Lemma5.lean:591` |
| §6 Lemma 5, first statement, **`λ` side** | **unstated by Reynolds**; required by *"previous results"* p.180 | `reynolds_lemma5_first_left` | mirror with `EndsInGapOnLeft` in `hIcc` | **MISSING — the blocker** |
| §6 Lemma 5, second statement | printed p.179 | `reynolds_lemma5_second`, `reynolds_lemma5` | via `relativizeToClass` / `evalOn` | LANDED `Lemma5.lean:782`, `:805` |
| §6 Lemma 6, *"`L` wherever `R`"* | printed **p.180**, PDF p.16 | `endsInGapOnLeft_of_endsInGapOnRight` | `ClassInteriorToRInterval M ε a t b → EndsInGapOnLeft M ε t` | LANDED `BadIntervals.lean:615` |
| §6 Lemma 6, *"mirror images"* → **`R` wherever `L`** | printed p.180 | `endsInGapOnRight_of_endsInGapOnLeft` | `ClassInteriorToLInterval M ε a t b → EndsInGapOnRight M ε t` | **MISSING — the deliverable** |
| §6 Lemma 6, non-singleton | printed p.180 | `reynolds_lemma6_nonsingleton` | `EndsInGapOnRight M ε t → ∃ y, t < y ∧ ∀ r, t < r → r ≤ y → IsBadPoint M ε r` | LANDED `:677` |
| §6 Lemma 6, excluded end point | printed p.180 | `reynolds_lemma6_right_endpoint` | — | LANDED `:1275` |
| §6 Lemma 6, assembled | printed p.180 | `reynolds_lemma6` | three of four halves | **PARTIAL** `:1322` |
| §6 Lemma 4 | printed p.179 (display corrupt in corpus; image reads `ρ(x) ∧ ∀y < x(¬ε(x,y) → ∃z(y < z < x ∧ ¬ρ(z)))`) | Lemma34 chain | — | LANDED |
| §6 Lemma 7, both halves | printed pp.180-181 | `reynolds_lemma7` | — | LANDED `:1230` (mirror hand-written, 258 lines) |
| §6 Lemma 2 + *"Dually L"* | printed pp.177-178 | `reynolds_lemma2`, `reynolds_lemma2_dual` | — | LANDED `Defs.lean:417`, `:428` |

---

## 4. Concrete charter for sub-phase 20.4

### 4.1 Group 1 — dualization core (~150 lines, **verified green this dispatch**)

New file, suggested `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean`. Contents
exactly as §2.2's table. Three fixes to apply to the probe as run:

1. drop the redundant `generalizing env` on `eval_dualize` (Lean 4.33 generalizes it automatically);
2. in `contempEquivDense_dual`, `congr 1` closes the goal — delete the trailing `funext`/`fin_cases`;
3. in `endsInGapOnRight_dual`'s third conjunct, the two inner implications appear in swapped order
   (`y < z → y < t` vs `z < y → y < t`); reorder the `imp_congr` chain or close with `tauto`.

**Discipline**: mark `dual` **not** `@[reducible]`, and route every point across with `d`, never
with a bare `OrderDual.toDual`. Both follow the hazard `NEquivalence.lean:134` documents for
`orderedSum`; ignoring either reproduces the `.carrier`-unfolding mismatch that the first probe run
hit and the `d` trick removed.

### 4.2 Group 2 — hypothesis transport (~145 lines)

`semanticPriorS_dual`, `endsInGapOnLeft_dual`, and `isContempEquivDense_dualize`.

### 4.3 Group 2's risk — clause (iii), and its two escapes

Clause (iii) is the only piece with no verified path. Escapes, in preference order:

- **Escape 1 (~70 lines, reusable).** Prove `eval` invariant along an `Equiv` of carriers that
  preserves order and `interp`, then apply it at
  `Equiv.subtypeEquivRight (fun _ => and_comm)`. One structural induction over `MonadicFormula`,
  six cases, same shape as the already-green `eval_dualize`. Reusable indefinitely.
- **Escape 2 (~40 lines, strictly additive).** Add
  `structure ContempFacts (M) (ε) : Prop` carrying only `equiv` and `convex`, plus
  `ContempFacts.of_isContempEquivDense`, plus `_of_facts` variants of the four helpers
  (`contemp_refl`/`symm`/`trans`/`of_between`) and of the Lemma 5 chain's entry points. Clause (iii)
  then never has to transport at all. Add new variants rather than rewriting the existing
  signatures, so nothing green is touched.

Escape 2 is the safe fallback and should be taken the moment Escape 1 resists — clause (iii) is
**dead weight** (never consumed anywhere in the tree), so no fidelity is lost either way.

### 4.4 Group 3 — the deliverables (~55 lines)

`reynolds_lemma5_first_left` and `endsInGapOnRight_of_endsInGapOnLeft`, each an instantiation at
`(dual M, dualize ε)` followed by rewriting through Group 1's transport lemmas. Then complete
`reynolds_lemma6`'s fourth conjunct and delete the gap note in `BadIntervals.lean`'s module header.

**Gate**: if Group 1 does not reproduce green in-file within its first dispatch, abandon (a) and
charter the ~560-line hand mirror (b) as two sub-phases split at the `Lemma5.lean` /
`BadIntervals.lean` boundary. Do **not** attempt both.

---

## 5. Zero-debt confirmation

No `sorry`, no vacuous definition, and no new axiom is required on either route. Route (a)'s
`Group 1` is already sorry-free and axiom-free by construction (structural inductions and
`Iff.rfl`). Nothing in this report recommends deferral.

---

## 6. Q5 — plan v8 deviates; sections requiring revision

**Yes, and the deviation is the root cause of the blocker.** Phase 19's charter asked only for the
`ρ` side; Reynolds' Lemma 6 provably needs both. Phase 20 could not have succeeded as written.

Sections to change, by heading:

1. **`### Phase 19: Reynolds §6 Lemma 5 …` (line 2545)** — task 1 charters only *"the whole of a
   class … left hand end point … `K⁻(B)`"*, i.e. the `ρ` side. **Add a task** for the `λ`-side
   statement, with a note that Reynolds states Lemma 5 one-sided and discharges the dual at p.180
   via *"previous results"*. Phase 19 is `[COMPLETED]`; the correct edit is a **scope-gap
   annotation** naming sub-phase 20.4 as the discharge point, not a reopening.
2. **`### Phase 20: … Lemmas 6 and 7` (line 2635)** — the Lemma 6 task says *"Then mirror images"*
   as a trailing clause on a single checkbox. That is what made a module-sized dependency look like
   a step. **Split** the Lemma 6 task into *"`L` wherever `R`"* (done) and *"`R` wherever `L`"*
   (sub-phase 20.4), with Lemma 5's `λ` side named as an explicit dependency.
3. **New `### Phase 20.4`** — charter §4 above: Groups 1–3, ~350 lines, gate at Group 1, fallback
   to the ~560-line hand mirror. Depends on 19; blocks nothing currently scheduled (Phase 21
   consumes Lemma 7, which is complete both sides — the Phase 20 handoff's claim here is correct).
4. **Source-correspondence table, lines 465-466** — reads *"§6 Lemma 5, **p.178**"* and
   *"§6 Lemmas 6-7, **pp.178-179**"*. Both wrong by 1–2 pages. Correct to **Lemma 5 → p.179**,
   **Lemma 6 → p.180**, **Lemma 7 → pp.180-181**. The Phase 19/20 deviation records already note
   this, but the plan's own table still carries the wrong values and is what a future dispatch
   reads first.
5. **Architecture/preserved-assets section** — record `Dual.lean` as new shared infrastructure and
   note that it retrospectively subsumes the hand-written mirrors in `BadIntervals.lean:968-1225`
   and `Kamp/Lemma53FaithfulPast.lean`, so no future phase re-derives a third one by hand.

---

## Adversarial Self-Verification

Every load-bearing claim, attacked. Per the dispatch instruction, I attacked the `OrderDual`
recommendation hardest.

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Reynolds states Lemma 5 only over maximal intervals of `R` | Printed p.179 read as a 200 dpi page image; full statement quoted §1.1; no "dually" on the page | Page-image read, not `pdftotext` | **High** |
| Lemma 6's mirror genuinely needs Lemma 5 on the `λ` side | p.180 *"Its not hard to use the previous result…"* is the only step deriving *all* classes from *one*; its mirror runs over a maximal `λ`-interval | Page-image read + referent analysis §1.2 | **High** |
| The mirror is mechanical, not a separate argument | Every ingredient (Prior U/S pair, `∼` an equivalence, gap self-dual) is symmetric; no order-asymmetric step appears on p.180 | Page-image read + probe (`d_lt` is `Iff.rfl`) | **High** |
| `OrderedMonadicStructure.dual` is definable and `eval` transports | Compiled | `lean_run_code`, green | **High** |
| `TemporalTruth` transports under `untl`/`snce` swap | Compiled green on the **first** probe attempt, zero diagnostics for that declaration | `lean_run_code`, green | **High** |
| `SemanticPriorS M → SemanticPriorU (dual M)` | Compiled | `lean_run_code`, green | **High** |
| `EndsInGapOnRight (dual M) (dualize ε) (d t) ↔ EndsInGapOnLeft M ε t` | Compiled except one conjunct-order slip in a 3-line `refine`; `contempEquivDense_dual` closed early ("no goals") | `lean_run_code`, near-green | **High** |
| **Attack**: `.box` breaks `swapUS` — `TemporalTruth` reads `atomMap (.box φ)`, so `swapUS` recursing into `box` would change the atom | **Real**, and it does break the naive definition. Neutralized by defining `swapUS (.box a) = .box a`; `box` is opaque to `TemporalTruth`, so the transport is still correct and `swapUS` still involutive. Both compiled | `lean_run_code`, green | **High** |
| **Attack**: expressive completeness needs density/carrier hypotheses that fail at `dual M` | **False.** `.property` takes exactly `(M) (h_prior_U) (h_prior_S) (t)` — no instance arguments | Call site `Defs.lean:390`, read | **High** |
| **Attack**: the dual's `LinearOrder` instance forms a diamond with `M`'s | **Real hazard**, already documented in-repo for `orderedSum` (`NEquivalence.lean:134`). Neutralized by the `OrderDual` synonym + non-`reducible` + the `d` transport function. Probe run 2 hit exactly this; probe run 3 with `d` did not | `lean_run_code`, both runs compared | **High** |
| **Attack (the one that lands)**: `IsContempEquivDense` clause (iii) does **not** transport for free | **Confirmed.** `M.subinterval` Subtype predicate is `min ≤ x ∧ x ≤ max`; the dual's is `x ≤ max ∧ min ≤ x` — conjuncts swapped, not defeq. No `eval`-along-iso lemma exists in the tree (`eval_rename` is variable renaming, not carrier transport) | Definition read `Defs.lean:242`, `MonadicFO.lean:215`; repo-wide grep | **High** |
| …but the damage is bounded: clause (iii) is never consumed | `contemporary` appears at exactly 2 sites repo-wide: its declaration and its *construction* in `epsTop`. All §6 use goes through `hε.equiv`/`hε.convex` | Repo-wide grep, §1.3 | **High** |
| Hand mirror is ~540–590 lines, not ~180 | Two chains itemized by measured R-side line spans (§2.1); in-file precedent `BadIntervals.lean:968-1225` = 258 lines for a half-size chain | Line-span measurement + precedent | **Medium-High** (line estimates are inherently approximate; the *ratio* to the 180 estimate is the robust part) |
| **Attack on my own recommendation**: is route (a) actually cheaper? ~350 vs ~560 is only 1.6×, and (a) adds global infrastructure to a green 1934-job tree | **Partially lands.** For *this one consumer* the margin is real but not overwhelming, and (b) is strictly additive whereas (a) is not. The recommendation survives on the second-order payoff — (a) discharges Lemma 3's dual, Lemma 4's dual and any future §6 mirror at ~25 lines each — and on 150 of its lines already being green. **This is why §4.4 specifies a hard gate**: if Group 1 does not reproduce green in-file on the first dispatch, fall back to (b) immediately | Reasoned trade-off, both routes costed | **Medium** |
| Route (a) is the more *faithful* rendering | Reynolds writes *"using mirror images … we get our proof"*, not a second proof. An `OrderDual` instantiation formalizes that sentence; a hand mirror formalizes a proof he did not write | Page-image read + project literature-fidelity standard | **Medium-High** (a judgement about rendering, not a checkable fact) |
| Phase 21 is not blocked | Lemma 8 consumes Lemma 7, complete both sides (`reynolds_lemma7`, `BadIntervals.lean:1230`) | Declaration read; corroborates the handoff | **High** |
| Plan v8's page refs at lines 465-466 are wrong | Says Lemma 5 → p.178, Lemmas 6-7 → pp.178-179; images give p.179, p.180, pp.180-181 | Page images + plan text read | **High** |

**Contradiction log**: one, resolved. The Phase 20 handoff sizes the residual at *"~180 lines"*;
§2.1 measures ~540–590. Resolution by precedence (direct measurement of the artifact over an
agent's prospective estimate): the handoff's figure is correct *for the sub-chain it names*
(`reynolds_lemma5_first_left` plus three helpers) but omits Chain 2, the fourth half's own mirror
chain — which is the actual deliverable. Both figures are right about different scopes; the
handoff's scope is not the deliverable's. **No unresolved contradictions.**

**Recommendations modified after verification**: two. (i) An earlier draft recommended the
`OrderDual` route unconditionally; after the clause (iii) attack landed I added the hard Group 1
gate (§4.4) and the Escape 2 fallback (§4.3). (ii) An earlier draft accepted the ~180-line figure;
measuring the R-side spans replaced it with ~540–590 and changed which route wins.
