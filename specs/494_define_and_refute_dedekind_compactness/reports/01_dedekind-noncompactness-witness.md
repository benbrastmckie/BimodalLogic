# Dedekind Non-Compactness: Vocabulary Instantiation and a New Witness

**Task**: 494 — define_and_refute_dedekind_compactness
**Type**: lean4 · **Session**: sess_1788308014_451fe6 · **Dispatch**: 1

## Executive summary

1. **Part 1 is a single instantiation, confirmed.** The post-509 `FrameClass`-indexed family
   (`SatisfiableSet`, `ModelExistence`, `Compact`, `StrongCompleteness`) is live in
   `FormalSystem/Metalogic/SetConsequence.lean:153,163,174,184`, and the two `.Dedekind`
   adapters the follow-on needs (`SatisfiableSet.dedekind_of_forall` at `:325`,
   `SetSemanticConsequenceDedekindDense.of_forall`/`.apply` at `:271`/`:280`) already exist.
   Part 1 is four one-line `def`s.
2. **A new witness exists and works.** `archWitness` does not port (§4). The replacement is a
   *bounded strictly-increasing chain of `q`-points whose supremum is contradicted by a
   left-gap formula*. It is finitely satisfiable over ℝ and unsatisfiable over every
   Dedekind-complete frame.
3. **The whole deliverable has been machine-checked in this research pass.** The complete
   module — Part 1 definitions, the witness, both halves, and both refutations — compiles
   against the current tree, sorry-free, at exactly `[propext, Classical.choice, Quot.sound]`,
   the same axiom set as `DiscreteNonCompactness.lean`. Full source in §7; it was run with
   `lake env lean` against the project's own toolchain, not merely sketched.
4. **Unexpected strengthening, worth recording:** the unsatisfiability half uses *only*
   Dedekind **completeness** — density is never invoked. The witness is therefore
   unsatisfiable over `TaskFrame.IsComplete` frames generally (ℤ included), and a fortiori over
   `FrameClass.Dedekind`. The Dedekind-ness of the *model* is only needed on the
   finite-satisfiability side.

## 1. The post-509 parameterized family (verified against current source)

All from `FormalSystem/Metalogic/SetConsequence.lean`:

| Declaration | Line | Signature |
|---|---|---|
| `SetConsequenceOnFrames` | 99 | `(P : TaskFrame → Prop) (Γ : Set Formula) (φ : Formula) : Prop` |
| `SetSemanticConsequenceOn` | 106 | `(fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop := SetConsequenceOnFrames fc.Sat Γ φ` |
| `SetSemanticConsequenceDedekindDense` | 125 | `:= SetSemanticConsequenceOn FrameClass.Dedekind` (**already present**) |
| `SatisfiableSet` | 153 | `(fc : FrameClass) (Γ : Set Formula) : Prop := ∃ (F) (_ : fc.Sat F) (M) (τ) (_ : τ.IsTotal) (t), ∀ ψ ∈ Γ, TruthAt M τ t ψ` |
| `ModelExistence` | 163 | `(fc : FrameClass) : Prop` |
| `Compact` | 174 | `(fc : FrameClass) : Prop` |
| `StrongCompleteness` | 184 | `(fc : FrameClass) : Prop` |

Frame-condition resolution: `FrameClass.Sat .Dedekind F = F.IsDedekind`
(`Semantics/FrameClassValidity.lean:116`), and
`TaskFrame.IsDedekind F = F.IsDense ∧ F.IsComplete` (`Semantics/FrameProperty.lean:172`), with
`IsDense F = DenselyOrdered F.Duration` (`:71`) and `IsComplete F = ∀ s, s.Nonempty → BddAbove s
→ ∃ x, IsLUB s x` (`:142`).

Adapters already in place for `.Dedekind` (this is what makes Part 1 free):

* `SatisfiableSet.dedekind_of_forall` — `SetConsequence.lean:325`; takes
  `[DenselyOrdered F.Duration]` as an instance plus `hlub` as a plain hypothesis and packs the
  `fc.Sat F` slot. Its docstring at `:322-324` states it was supplied *in advance* for this task.
* `SetSemanticConsequenceDedekindDense.of_forall` / `.apply` — `:271` / `:280`.
* `ValidDedekindDense = ValidIn .Dedekind` (`Semantics/Validity.lean:765`), with
  `ValidDedekindDense.apply` at `:779` — needed to consume the `ValidIn fc (L.foldr …)` that
  `Compact` returns.
* `soundness_dedekind` — `Metalogic/Soundness.lean:1668`, binder list
  `(Γ) (φ) (d) (F) [DenselyOrdered F.Duration] (h_lub) (M) (τ) (h_mem) (t) (h_ctx)`.

### Part 1, verbatim

```lean
def StrongCompletenessDedekind : Prop := StrongCompleteness FrameClass.Dedekind
def CompactDedekind : Prop := Compact FrameClass.Dedekind
def SatisfiableDedekindSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Dedekind Γ
def ModelExistenceDedekind : Prop := ModelExistence FrameClass.Dedekind
```

These belong in `SetConsequence.lean` beside the Discrete block (`:539`, `:559`, `:566`),
replacing that file's module-docstring claim (`:27-30`) that the `.Dedekind` row is
"deliberately left unstated here".

**No new adapter, no new binder list, no fifth hand copy.** The description's REVISED note is
correct as written.

## 2. Why `archWitness` does not port

`archWitness p = {F p} ∪ {¬Xⁿ p : n ∈ ℕ}` (`DiscreteNonCompactness.lean:102`).

* `Formula.next φ = Formula.untl Formula.bot φ` (`Syntax/Formula.lean:511`). Its `TruthAt`
  clause (`Semantics/Truth.lean:169`) is `∃ s, t < s ∧ φ(s) ∧ ∀ r ∈ (t,s), ⊥`, i.e. `(t,s)` is
  empty. **On a densely ordered carrier `(t,s)` is never empty for `t < s`, so `next φ` is false
  at every point.** Every `¬Xⁿ p` (`n ≥ 1`) is therefore *vacuously true* on a Dedekind frame and
  the set carries no constraint at all. (The tree already knows this: `Axiom.dense_indicator` is
  `¬X⊤`, and `Semantics.validOn_neg_nextTop_iff` converts validity of `¬X⊤` into density —
  see `Independence/RationalWitness.lean:213-217`.)
* The unsatisfiability half (`DiscreteNonCompactness.lean:229-242`) runs entirely through
  `Order.succ_le_of_lt hts |>.exists_succ_iterate`, i.e. through `[SuccOrder D]` +
  `[IsSuccArchimedean D]`. Neither is available at `.Dedekind`, and neither *can* be: a densely
  ordered type with no maximum admits **no** `SuccOrder` instance (if `a < b` then `succ a ≤ b`
  for every such `b`, and `succ a = a` forces `IsMax a` via `max_of_succ_le`).
* Consequence for the implementer: `truthAt_next_iff` / `truthAt_next_iterate`
  (`:65`, `:79`) carry `[SuccOrder]` `[NoMaxOrder]` binders and are unusable here. The new file
  reuses **none** of `DiscreteNonCompactness.lean`'s lemmas — only its *file shape*.

The same `[SuccOrder D] [NoMaxOrder D]` obstruction rules out the ℤ file's model frame:
`FrameOver.natFrame` (`Semantics/TaskFrame.lean:1449`) carries both binders, so `natFrame (D := ℝ)`
does not elaborate. See §5 for the replacement.

## 3. The new witness

Fix an atom `q`. Write `Xq φ` for "the **next** `q`-point exists and `φ` holds there".

```lean
def qNext  (q : Atom) (φ : Formula) : Formula :=
  Formula.untl (Formula.atom q).neg (Formula.and (Formula.atom q) φ)   -- Xq φ
def qAlpha (q : Atom) (n : ℕ) : Formula := (qNext q)^[n] Formula.top   -- αₙ = Xqⁿ ⊤
def qGap   (q : Atom) : Formula := (Formula.snce (Formula.atom q).neg Formula.top).allFuture
def qBound (q : Atom) : Formula := ((Formula.atom q).neg.allFuture).someFuture

def dedWitness (q : Atom) : Set Formula :=
  {qGap q, qBound q} ∪ {ψ | ∃ n : ℕ, ψ = qAlpha q n}
```

Semantic readings (each proved as a named lemma in §7):

* `qNext q φ` at `t` ⟺ `∃ s > t`, `q(s)`, `φ(s)`, and no `q` strictly inside `(t,s)` — so `s` is
  *the* next `q`-point after `t`, and it is unique.
* `αₙ` at `t` ⟺ the next-`q`-point operation is defined `n` times from `t`. Each `αₙ` is a
  **finite** assertion; no single one of them says "every `q`-point has a successor `q`-point".
  This is exactly why the set must be infinite (see the finite-set caveat in §6).
* `qGap q = G(⊤ S ¬q)` at `t` ⟺ every `s > t` has a `q`-free open interval `(u,s)` immediately to
  its left. (`Formula.snce` is guard-first: `snce ψ φ` at `t` is `∃ s < t, φ(s) ∧ ∀ r ∈ (s,t), ψ(r)`,
  `Truth.lean:171`.)
* `qBound q = F(G ¬q)` at `t` ⟺ `∃ x > t` with no `q`-point strictly after `x`.

### 3(a) Finite satisfiability over Dedekind-complete dense time

Model: ℝ with `q` true exactly at the integers `1..N`, evaluated at `0`, where
`N = (L.map qDepth).sum` for the given finite `L` — the same "sum as upper bound" device as
`archWitness_finitely_satisfiable` (`DiscreteNonCompactness.lean:194-217`), with `qDepth` the
analogue of `nextDepth`/`witIdx`.

* `qGap q`: every `q`-point is an integer, so `((⌈s⌉ : ℤ) : ℝ) - 1` is a left endpoint of a
  `q`-free interval below **any** `s` — no integer lies strictly between `⌈s⌉ - 1` and `s`.
* `qBound q`: take `x = (N : ℝ) + 1`; any `q`-point is an integer `k ≤ N < x`.
* `αₙ` for `n ≤ N`: induction on `n` over integer base points — from `(k : ℝ)` with `0 ≤ k` and
  `k + n ≤ N`, the next `q`-point is `k + 1` (no integer strictly between), so `Xq` steps once
  and the IH supplies the rest. At `k = 0` this gives `αₙ` at `0` for every `n ≤ N`.
* `n ≤ N` comes from `qDepth (qAlpha q n) = n` plus `List.single_le_sum`.

### 3(b) Unsatisfiability over every Dedekind-complete frame

Suppose `M, τ, t ⊨ dedWitness q` on a frame with `hlub : F.IsComplete`.

1. **Chain.** Let `Inv a :≡ ∀ n, TruthAt M τ a (αₙ)`. From `αₙ₊₁ = Xq αₙ`
   (`Function.iterate_succ_apply'`), `Inv a` yields, for each `n`, a next-`q`-point `sₙ` with
   `Inv`-relevant data. **Uniqueness of the next `q`-point** (trichotomy: a nearer `q`-point
   would sit inside the other's empty gap) collapses all the `sₙ` to one `s`, giving
   `Inv a → ∃ s, a < s ∧ q(s) ∧ Inv s`. Choice on the subtype `{a // Inv a}` and
   `Function.iterate` build `ch : ℕ → F.Duration`, strictly monotone
   (`strictMono_nat_of_lt_succ`), with `q(ch n)` for every `n`.
2. **Boundedness.** `qBound q` gives `x` with no `q`-point above `x`; every `ch n` is a
   `q`-point, so `x ∈ upperBounds (range ch)`.
3. **Supremum.** `hlub` gives `z` with `IsLUB (range ch) z`, and `t < ch 0 ≤ z`.
4. **Contradiction.** `qGap q` at `z` gives `u < z` with `(u,z)` `q`-free. `IsLUB.exists_between`
   gives `n` with `u < ch n ≤ z`. And `ch n ≠ z`, since `ch (n+1) > ch n` would then exceed the
   upper bound `z`. So `ch n ∈ (u,z)` is a `q`-point in a `q`-free interval. **False.**

Density is used nowhere in 1–4.

## 4. Mathlib lemmas required (all verified by `#check` in this pass)

| Name | Signature (as reported by the LSP) | Used for |
|---|---|---|
| `Real.exists_isLUB` | `{s : Set ℝ} → s.Nonempty → BddAbove s → ∃ x, IsLUB s x` | discharges `IsComplete` for the ℝ frame |
| `IsLUB.exists_between` | `IsLUB s a → b < a → ∃ c ∈ s, b < c ∧ c ≤ a` | step 4 above |
| `strictMono_nat_of_lt_succ` | `(∀ n, f n < f (n+1)) → StrictMono f` | chain monotonicity |
| `Int.ceil_lt_add_one` | `(a : R) → (↑⌈a⌉ : R) < a + 1` | the ℝ gap witness `⌈s⌉ - 1 < s` |
| `Int.lt_ceil` | `z < ⌈a⌉ ↔ (↑z : α) < a` | no integer in `(⌈s⌉-1, s)` |
| `List.single_le_sum` | (as used at `DiscreteNonCompactness.lean:211`) | index bound `n ≤ N` |
| `Function.iterate_succ_apply'` | `f^[n+1] x = f (f^[n] x)` | `αₙ₊₁ = Xq αₙ` |
| `abs_pos`, `sub_ne_zero`, `add_assoc` | — | the `sep` field of the shift set |

Instances confirmed present: `DenselyOrdered ℝ`, `Nontrivial ℝ`, `IsOrderedAddMonoid ℝ`,
`AddCommGroup ℝ`, `LinearOrder ℝ` (so `TemporalOrder.of ℝ` / `⟨ℝ⟩` elaborates).

In-tree lemmas required: `Truth.future_iff` (`Truth.lean:283`), `Truth.some_future_iff` (`:249`),
`truthAt_foldr_imp` (`StrongCompleteness.lean:219`), `soundness_dedekind`
(`Soundness.lean:1668`), `ValidDedekindDense.apply` (`Validity.lean:779`),
`SatisfiableSet.dedekind_of_forall` and `SetSemanticConsequenceDedekindDense.of_forall`
(`SetConsequence.lean:325`, `:271`), plus `ShiftSet.forward_repr` / `hist_isTotal`
(`ShiftSet.lean:278`, `:226`).

A local `truth_and_iff'` is needed because `Truth.lean` supplies no unfolding lemma for
`Formula.and`. An identical lemma already exists as `truth_and_iff` in
`Semantics/Correspondence/DurationFrames.lean:299`; importing that module from `Metalogic/` is
legal (`Independence/RationalWitness.lean` does), but a three-line local copy avoids the import.
**Implementer's choice; the verified module below uses the local copy.**

## 5. The ℝ frame: use `ShiftSet`, not `natFrame`

`natFrame` is unavailable over ℝ (§2). `FrameOver.staticFrame` is unusable for a different
reason — its task relation forces constant-state histories, so no atom can change truth value
along the timeline, which the witness requires.

The working route is `Semantics/ShiftSet.lean`, which discharges all seven `FrameOver` fields
for any `D`-action:

```lean
@[reducible] noncomputable def realOrder : TemporalOrder := ⟨ℝ⟩          -- cf. intOrder, TemporalOrder.lean:133

@[reducible] noncomputable def rShift (q : Atom) (N : ℕ) : ShiftSet realOrder where
  Carrier := ℝ ; sh := fun w d => w + d ; …
  A := fun p x => p = q ∧ ∃ k : ℤ, (k:ℝ) = x ∧ 1 ≤ k ∧ k ≤ (N:ℤ)
```

Notes that cost time if missed:

* **Both `realOrder` and `rShift` must be `@[reducible]`.** Without it, `DenselyOrdered
  (rShift q N).frame.Duration` fails to synthesize and `(0 : (rShift q N).Carrier)` fails to
  elaborate. This is the same reducibility discipline `TemporalOrder.lean:100-126` documents for
  `intOrder`, and `ShiftSet.frame`/`fibre` already carry it.
* `sep` (the paper's *Limit*) for the translation action: if `u ≠ w`, instantiate at
  `x = |u - w|`; the returned `y` must be `u - w`, giving `|u-w| < |u-w|`.
* Atom truth along the orbit through `0` is `ShiftSet.forward_repr` + `simp [ShiftSet.ShiftTruth]`:
  `TruthAt (rShift q N).model ((rShift q N).hist 0) t (atom q) ↔ ∃ k : ℤ, (k:ℝ) = t ∧ 1 ≤ k ∧ k ≤ N`.
* Cast friction: `F.Duration.carrier` is `ℝ` only up to reducible unfolding, and `norm_cast`
  does **not** see through it. Restate hypotheses as explicit ℝ statements
  (`have h' : ((k:ℤ):ℝ) < ((j:ℤ):ℝ) := h`) before `exact_mod_cast`. Three sites need this.
* `TaskFrame.IsDense F` is a `def` whose head is not `DenselyOrdered`, so a destructured
  `hd : F.IsDense` is invisible to instance search: `haveI : DenselyOrdered F.Duration := hd`
  is required in both refutations before calling `ValidDedekindDense.apply` /
  `soundness_dedekind`. (`SetConsequence.lean:185-189` documents this trap.) Unlike the Discrete
  case, `haveI` is safe here — no `DenselyOrdered` instance is baked into `F`'s or `M`'s type.

## 6. Risks evaluated, and why the natural alternatives fail

* **"Sup of a bounded set is attained but nothing holds at it" (the naive shape) — rejected.**
  The four-formula set `{F q, G(q → F q), F(G ¬q), G(⊤ S ¬q)}` *is* unsatisfiable over
  Dedekind-complete frames and satisfiable over ℚ, and it is very short. It is **useless for
  compactness**: a *finite* unsatisfiable set refutes nothing, since compactness may simply
  return the whole set. The infinite family `{αₙ}` exists precisely to replace the single
  formula `G(q → F q)` ("every `q`-point has a later one") with an ω-family of finite chain
  assertions, each satisfiable by a finite configuration over ℝ. This is the load-bearing design
  decision and the one most likely to be lost in re-derivation.
* **Weakening `Xq φ` to `untl (¬q) φ` (dropping the `q ∧` conjunct) — rejected.** `α₂` then
  collapses to `α₁`: the intermediate witness point need not be a `q`-point, so nested untils
  stop counting. The `Formula.and` in `qNext` is necessary, and it is what makes `qDepth`'s
  pattern the nested `imp (imp _ (imp φ bot)) bot` shape.
* **Making the boundedness clause the infinite family instead — rejected.** "All `q`-points lie
  below some point" is a single formula `F(G ¬q)`; there is no natural ω-family for it that keeps
  finite subsets Dedekind-satisfiable without reintroducing chain markers (and then extra atoms
  and a messier index extractor).
* **Distinct indexed atoms `c₀, c₁, …` with `G(cₙ → F cₙ₊₁)` — viable but worse.** It removes the
  next-point uniqueness argument (any later `cₙ₊₁`-point will do) at the cost of extracting the
  atom index out of `Atom`'s `String × Option _` payload in `qDepth`'s analogue. Structural depth
  counting on nested `untl` is cleaner and mirrors `nextDepth` (`DiscreteNonCompactness.lean:110`).
  Recorded as the fallback if the uniqueness step ever becomes a problem — it did not.
* **Does the ultraproduct-based `CompactDense` conflict?** No. `compactDense`
  (`Metalogic/Compactness.lean`) forces `dedWitness q` to be satisfiable over *some* dense frame;
  that frame is necessarily gappy (ℚ-like, e.g. `q` at a sequence of rationals increasing to an
  irrational). This is consistent — and is the reason the witness must exploit completeness
  rather than density, which it does.
* **Task-frame-specific hazards checked:** none of `box`, the task relation, `WorldHistory`
  totality, or the `spherical`/`limit` frame axioms interacts with the argument. The witness is
  purely temporal (`untl`/`snce` plus one atom) and is evaluated on a single total history.
* **Remaining risk: none identified.** The module below compiles.

## 7. Verified module (compiles against the current tree, sorry-free)

Suggested location: `FormalSystem/Metalogic/DedekindNonCompactness.lean`, with the Part 1
definitions moved into `SetConsequence.lean` and this file importing it. Add the import to
`FormalSystem/Metalogic.lean` beside `DiscreteNonCompactness` (`Metalogic.lean:10`).

Verification performed: `lake env lean` on the file below with the project's own toolchain →
no errors; `#print axioms` on all four headline results →
`[propext, Classical.choice, Quot.sound]`.

```lean
import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.Semantics.ShiftSet
import Mathlib.Data.Real.Basic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic

/-! ## Part 1 (belongs in SetConsequence.lean) -/

def StrongCompletenessDedekind : Prop := StrongCompleteness FrameClass.Dedekind
def CompactDedekind : Prop := Compact FrameClass.Dedekind
def SatisfiableDedekindSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Dedekind Γ
def ModelExistenceDedekind : Prop := ModelExistence FrameClass.Dedekind

/-! ## Part 2: the witness -/

def qNext (q : Atom) (φ : Formula) : Formula :=
  Formula.untl (Formula.atom q).neg (Formula.and (Formula.atom q) φ)
def qAlpha (q : Atom) (n : ℕ) : Formula := (qNext q)^[n] Formula.top
def qGap (q : Atom) : Formula := (Formula.snce (Formula.atom q).neg Formula.top).allFuture
def qBound (q : Atom) : Formula := ((Formula.atom q).neg.allFuture).someFuture

def dedWitness (q : Atom) : Set Formula :=
  {qGap q, qBound q} ∪ {ψ | ∃ n : ℕ, ψ = qAlpha q n}

def qDepth : Formula → ℕ
  | Formula.untl _ (Formula.imp (Formula.imp _ (Formula.imp φ Formula.bot)) Formula.bot) =>
      qDepth φ + 1
  | _ => 0

theorem qDepth_qAlpha (q : Atom) (n : ℕ) : qDepth (qAlpha q n) = n := by
  induction n with
  | zero => simp [qAlpha, qDepth, Formula.top]
  | succ k ih =>
      rw [qAlpha, Function.iterate_succ_apply']
      simp only [qNext, Formula.and, Formula.neg, qDepth]
      exact congrArg (· + 1) ih

variable {F : TaskFrame}

theorem truth_and_iff' (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (A B : Formula) :
    TruthAt M τ t (A.and B) ↔ (TruthAt M τ t A ∧ TruthAt M τ t B) := by
  constructor
  · intro h; by_contra hn; exact h fun ha hb => hn ⟨ha, hb⟩
  · rintro ⟨ha, hb⟩ h; exact h ha hb

theorem truthAt_qNext_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (q : Atom) (φ : Formula) :
    TruthAt M τ t (qNext q φ) ↔ ∃ s, t < s ∧ TruthAt M τ s (Formula.atom q) ∧
      TruthAt M τ s φ ∧ ∀ r, t < r → r < s → ¬ TruthAt M τ r (Formula.atom q) := by
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    obtain ⟨h1, h2⟩ := (truth_and_iff' M τ s _ _).mp hs
    exact ⟨s, hts, h1, h2, fun r h1' h2' hq => hgap r h1' h2' hq⟩
  · rintro ⟨s, hts, hq, hφ, hgap⟩
    exact ⟨s, hts, (truth_and_iff' M τ s _ _).mpr ⟨hq, hφ⟩, fun r h1 h2 hqr => hgap r h1 h2 hqr⟩

theorem truthAt_qGap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (q : Atom)
    (h : TruthAt M τ t (qGap q)) :
    ∀ s, t < s → ∃ u, u < s ∧ ∀ r, u < r → r < s → ¬ TruthAt M τ r (Formula.atom q) := by
  intro s hts
  obtain ⟨u, hus, _, hgap⟩ := (Truth.future_iff _).mp h s hts
  exact ⟨u, hus, fun r h1 h2 hq => hgap r h1 h2 hq⟩

theorem truthAt_qBound (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (q : Atom)
    (h : TruthAt M τ t (qBound q)) :
    ∃ x, t < x ∧ ∀ y, x < y → ¬ TruthAt M τ y (Formula.atom q) := by
  obtain ⟨x, htx, hx⟩ := (Truth.some_future_iff _).mp h
  exact ⟨x, htx, fun y hy hq => (Truth.future_iff _).mp hx y hy hq⟩

/-! ### Unsatisfiability: only Dedekind completeness is used -/

theorem dedWitness_core (q : Atom) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (h : ∀ ψ ∈ dedWitness q, TruthAt M τ t ψ) : False := by
  classical
  have hgap := truthAt_qGap M τ t q (h _ (by simp [dedWitness]))
  obtain ⟨x, htx, hx⟩ := truthAt_qBound M τ t q (h _ (by simp [dedWitness]))
  have halpha : ∀ n, TruthAt M τ t (qAlpha q n) := fun n => h _ (by right; exact ⟨n, rfl⟩)
  have step : ∀ a : F.Duration, (∀ n, TruthAt M τ a (qAlpha q n)) →
      ∃ s, a < s ∧ TruthAt M τ s (Formula.atom q) ∧ (∀ n, TruthAt M τ s (qAlpha q n)) := by
    intro a ha
    have h1 : TruthAt M τ a (qNext q (qAlpha q 0)) := by
      have := ha 1; rwa [qAlpha, Function.iterate_succ_apply'] at this
    obtain ⟨s, hs1, hs2, -, hs4⟩ := (truthAt_qNext_iff M τ a q _).mp h1
    refine ⟨s, hs1, hs2, ?_⟩
    intro n
    have hn : TruthAt M τ a (qNext q (qAlpha q n)) := by
      have := ha (n+1); rwa [qAlpha, Function.iterate_succ_apply'] at this
    obtain ⟨s', hs1', hs2', hs3', hs4'⟩ := (truthAt_qNext_iff M τ a q _).mp hn
    have hss : s' = s := by
      rcases lt_trichotomy s' s with hlt | heq | hgt
      · exact absurd hs2' (hs4 s' hs1' hlt)
      · exact heq
      · exact absurd hs2 (hs4' s hs1 hgt)
    exact hss ▸ hs3'
  set Inv : F.Duration → Prop := fun a => ∀ n, TruthAt M τ a (qAlpha q n) with hInv
  let f : {a : F.Duration // Inv a} → {a : F.Duration // Inv a} := fun a =>
    ⟨(step a.1 a.2).choose, (step a.1 a.2).choose_spec.2.2⟩
  let c : ℕ → {a : F.Duration // Inv a} := fun n => f^[n] ⟨t, halpha⟩
  have hc : ∀ n, (c n).1 < (c (n+1)).1 ∧ TruthAt M τ (c (n+1)).1 (Formula.atom q) := by
    intro n
    have hcc : c (n+1) = f (c n) := by simp only [c, Function.iterate_succ_apply']
    rw [hcc]
    exact ⟨(step (c n).1 (c n).2).choose_spec.1, (step (c n).1 (c n).2).choose_spec.2.1⟩
  set ch : ℕ → F.Duration := fun n => (c (n+1)).1 with hch
  have hmono : StrictMono ch := strictMono_nat_of_lt_succ (fun n => (hc (n+1)).1)
  have hQ : ∀ n, TruthAt M τ (ch n) (Formula.atom q) := fun n => (hc n).2
  have hbdd : BddAbove (Set.range ch) := by
    refine ⟨x, ?_⟩
    rintro y ⟨n, rfl⟩
    by_contra hlt
    exact hx (ch n) (lt_of_not_ge hlt) (hQ n)
  obtain ⟨z, hz⟩ := hlub (Set.range ch) ⟨ch 0, ⟨0, rfl⟩⟩ hbdd
  have htz : t < z := lt_of_lt_of_le (hc 0).1 (hz.1 ⟨0, rfl⟩)
  obtain ⟨u, huz, hu⟩ := hgap z htz
  obtain ⟨y, ⟨n, rfl⟩, huy, hyz⟩ := hz.exists_between huz
  have hne : ch n ≠ z := by
    intro heq
    have hub : ch (n+1) ≤ z := hz.1 ⟨n+1, rfl⟩
    exact absurd (heq ▸ hmono (Nat.lt_succ_self n)) (not_lt.mpr hub)
  exact hu (ch n) huy (lt_of_le_of_ne hyz hne) (hQ n)

theorem dedWitness_not_satisfiable (q : Atom) :
    ¬ SatisfiableDedekindSet (dedWitness q) := by
  rintro ⟨F, ⟨-, hlub⟩, M, τ, hτ, t, h⟩
  exact dedWitness_core q M τ t hlub h

/-! ### The ℝ model for finite satisfiability -/

@[reducible] noncomputable def realOrder : TemporalOrder := ⟨ℝ⟩

@[reducible] noncomputable def rShift (q : Atom) (N : ℕ) : ShiftSet realOrder where
  Carrier := ℝ
  carrier_nonempty := ⟨0⟩
  sh := fun w d => w + d
  sh_zero := by intro w; simp
  sh_add := by intro w a b; exact add_assoc w a b
  sep := by
    intro w u h
    by_contra hne
    have hpos : (0:ℝ) < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
    obtain ⟨y, hy, hu⟩ := h (|u - w|) hpos
    have hy' : y = u - w := by rw [hu]; ring
    rw [hy'] at hy
    exact lt_irrefl _ hy
  A := fun p x => p = q ∧ ∃ k : ℤ, (k:ℝ) = x ∧ 1 ≤ k ∧ k ≤ (N:ℤ)

noncomputable def rM (q : Atom) (N : ℕ) : TaskModel (rShift q N).frame := (rShift q N).model
noncomputable def rH (q : Atom) (N : ℕ) : WorldHistory (rShift q N).frame := (rShift q N).hist 0

theorem rTruth_atom (q : Atom) (N : ℕ) (t : ℝ) :
    TruthAt (rM q N) (rH q N) t (Formula.atom q) ↔ ∃ k : ℤ, (k:ℝ) = t ∧ 1 ≤ k ∧ k ≤ (N:ℤ) := by
  rw [rM, rH, ShiftSet.forward_repr]
  simp [ShiftSet.ShiftTruth]

theorem rTruth_gap (q : Atom) (N : ℕ) : TruthAt (rM q N) (rH q N) 0 (qGap q) := by
  rw [qGap, Truth.future_iff]
  intro s _
  refine ⟨((⌈s⌉ : ℤ) : ℝ) - 1, by linarith [Int.ceil_lt_add_one s], id, ?_⟩
  rintro r hr hrs hq
  obtain ⟨k, rfl, -, -⟩ := (rTruth_atom q N _).mp hq
  have hr' : ((⌈s⌉ : ℤ) : ℝ) - 1 < ((k : ℤ) : ℝ) := hr
  have h1 : k < ⌈s⌉ := Int.lt_ceil.mpr hrs
  have h2 : (⌈s⌉ : ℤ) - 1 < k := by exact_mod_cast hr'
  omega

theorem rTruth_bound (q : Atom) (N : ℕ) : TruthAt (rM q N) (rH q N) 0 (qBound q) := by
  rw [qBound, Truth.some_future_iff]
  refine ⟨(N : ℝ) + 1, by positivity, ?_⟩
  rw [Truth.future_iff]
  intro y hy hq
  obtain ⟨k, rfl, -, hk⟩ := (rTruth_atom q N _).mp hq
  have h1 : ((k : ℤ) : ℝ) ≤ ((N : ℤ) : ℝ) := by exact_mod_cast hk
  have h2 : ((N : ℤ) : ℝ) = (N : ℝ) := by push_cast; ring
  have hy' : (N : ℝ) + 1 < ((k : ℤ) : ℝ) := hy
  rw [h2] at h1
  linarith

theorem rTruth_alpha (q : Atom) (N : ℕ) :
    ∀ (n : ℕ) (k : ℤ), 0 ≤ k → k + (n : ℤ) ≤ (N : ℤ) →
      TruthAt (rM q N) (rH q N) ((k : ℝ)) (qAlpha q n) := by
  intro n
  induction n with
  | zero => intro k _ _; exact id
  | succ m ih =>
      intro k hk hkN
      rw [qAlpha, Function.iterate_succ_apply']
      refine (truthAt_qNext_iff _ _ _ q _).mpr ⟨((k : ℝ) + 1), by linarith, ?_, ?_, ?_⟩
      · exact (rTruth_atom q N _).mpr
          ⟨k + 1, by push_cast; ring, by omega, by push_cast at hkN; omega⟩
      · have hih := ih (k + 1) (by omega) (by push_cast at hkN ⊢; omega)
        rw [show ((k + 1 : ℤ) : ℝ) = (k : ℝ) + 1 by push_cast; ring] at hih
        exact hih
      · rintro r hr hrs hq
        obtain ⟨j, rfl, -, -⟩ := (rTruth_atom q N _).mp hq
        have hr' : ((k : ℤ) : ℝ) < ((j : ℤ) : ℝ) := hr
        have hrs' : ((j : ℤ) : ℝ) < ((k : ℤ) : ℝ) + 1 := hrs
        have h1 : k < j := by exact_mod_cast hr'
        have h3 : j < k + 1 := by
          have hc : ((j : ℤ) : ℝ) < ((k + 1 : ℤ) : ℝ) := by push_cast; linarith
          exact_mod_cast hc
        omega

theorem dedWitness_finitely_satisfiable (q : Atom) (L : List Formula)
    (hL : ∀ ψ ∈ L, ψ ∈ dedWitness q) : SatisfiableDedekindSet {ψ | ψ ∈ L} := by
  classical
  set N : ℕ := (L.map qDepth).sum with hNdef
  refine SatisfiableSet.dedekind_of_forall (rShift q N).frame
    (fun _ hne hbd => Real.exists_isLUB hne hbd) (rM q N) (rH q N)
    (ShiftSet.hist_isTotal _ _) 0 ?_
  intro ψ hψ
  have hmem := hL ψ hψ
  simp only [dedWitness, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff,
    Set.mem_setOf_eq] at hmem
  rcases hmem with (rfl | rfl) | ⟨n, rfl⟩
  · exact rTruth_gap q N
  · exact rTruth_bound q N
  · have hn_le : n ≤ N := by
      have hmm : qDepth (qAlpha q n) ∈ L.map qDepth := List.mem_map_of_mem hψ
      have hle := List.single_le_sum (fun _ _ => Nat.zero_le _) _ hmm
      rwa [qDepth_qAlpha] at hle
    have := rTruth_alpha q N n 0 le_rfl (by push_cast; omega)
    simpa using this

/-! ### The two refutations -/

theorem dedekind_consequence_not_compact : ¬ CompactDedekind := by
  intro hc
  classical
  set q : Atom := ⟨"q", none⟩ with hq
  have hcons : SetSemanticConsequenceDedekindDense (dedWitness q) Formula.bot := by
    refine SetSemanticConsequenceDedekindDense.of_forall ?_
    intro F _ hlub M τ hτ t hall
    exact absurd (SatisfiableSet.dedekind_of_forall F hlub M τ hτ t hall)
      (dedWitness_not_satisfiable q)
  obtain ⟨L, hL, hvalid⟩ := hc _ _ hcons
  obtain ⟨F, ⟨hd, hlub⟩, M, τ, hτ, t, hsat⟩ := dedWitness_finitely_satisfiable q L hL
  haveI : DenselyOrdered F.Duration := hd
  have hv := ValidDedekindDense.apply hvalid F hlub M τ hτ t
  exact (truthAt_foldr_imp M τ t L Formula.bot).mp hv (fun ψ hψ => hsat ψ hψ)

theorem strongCompletenessDedekind_refuted : ¬ StrongCompletenessDedekind := by
  intro hsc
  classical
  set q : Atom := ⟨"q", none⟩ with hq
  have hcons : SetSemanticConsequenceDedekindDense (dedWitness q) Formula.bot := by
    refine SetSemanticConsequenceDedekindDense.of_forall ?_
    intro F _ hlub M τ hτ t hall
    exact absurd (SatisfiableSet.dedekind_of_forall F hlub M τ hτ t hall)
      (dedWitness_not_satisfiable q)
  obtain ⟨L, hL, ⟨d⟩⟩ := hsc _ _ hcons
  obtain ⟨F, ⟨hd, hlub⟩, M, τ, hτ, t, hsat⟩ := dedWitness_finitely_satisfiable q L hL
  haveI : DenselyOrdered F.Duration := hd
  exact soundness_dedekind L Formula.bot d F hlub M τ hτ t (fun ψ hψ => hsat ψ hψ)

end FormalSystem.Metalogic
```

One cosmetic warning is emitted (`push_cast` does nothing, in `rTruth_alpha`'s
`by push_cast at hkN ⊢; omega`); drop the `⊢` to silence it.

## 8. Documentation debt this creates (must be discharged with the code)

The tree currently asserts, in several places, that no Dedekind refutation exists. Each of these
becomes false when the module lands:

* `Metalogic/StrongCompleteness.lean:73-83` — the Dedekind row of the status ledger
  ("What this tree does **not** contain is a refutation…"). Rewrite to the Discrete row's shape.
* `Metalogic/StrongCompleteness.lean:84-90` — "Three distinct statuses" paragraph; there are now
  **two** (Base/Dense proved; Discrete/Dedekind refuted).
* `Metalogic/StrongCompleteness.lean:823` — second copy of the same claim.
* `Metalogic/SetConsequence.lean:22-30` — "the `.Dedekind` row … is deliberately **left
  unstated here**".
* `Metalogic/SetConsequence.lean:436-438` — "Dedekind (unavailable on its primary source's own
  terms)".
* `Metalogic/SetConsequence.lean:322-324` — `dedekind_of_forall`'s "even though no `.Dedekind`
  name is stated in this layer yet".
* `Metalogic.lean:10` — add the new import; `Metalogic.lean:197` — extend the
  `DiscreteNonCompactness.lean` bullet with its Dedekind sibling.
* `FormalSystem/Metalogic/README.md` — check for a status table (not audited in this pass;
  marked **unverified**).

Note that Reynolds 1992 §9 Thm 7 remains correctly cited as the *weak* completeness result; the
refutation does not contradict it — it explains why only weak completeness is available.

## 9. Explicitly unverified

* Whether `FormalSystem/Metalogic/README.md` (or `Semantics/README.md`) carries a status table
  needing the same edit — not read in this pass.
* The paper-side citation `possible_worlds.tex:4657` (`cor:tm-completeness`) was not opened;
  the claim that it asserts failure "for the dense-and-complete class R where compactness fails"
  is taken from the task description, not independently checked.
* Build-time impact of adding `Mathlib.Data.Real.Basic` to the `Metalogic` import closure was not
  measured (the file compiled in one `lake env lean` pass with warm caches).
