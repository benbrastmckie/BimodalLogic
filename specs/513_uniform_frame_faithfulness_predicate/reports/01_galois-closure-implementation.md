# Galois-closure implementation for the frame-class layer — research report

**Status**: researched. Every deliverable below was probed against the live tree with
`lean_run_code`; the verdicts marked **[verified]** are compiled, sorry-free Lean, not estimates.

**Grounding**: `specs/archive/514_align_definitions_with_source_paper/reports/01_definitional-review-and-closure.md`
§2.4, §3.1–3.4; `specs/511_research_frame_correspondence_infrastructure/reports/01–03` and
`02_probes.lean` / `03_probes.lean`; `possible_worlds.tex` `def:frame-properties`,
`def:frame-validity`, `cor:tm-completeness`, `app:discrete`/`app:dense`/`app:complete`.

---

## 0. Headline

The task is feasible in full and cheaper than the spec assumed. Seven of the eight construction
risks were retired by compiling them. The one genuine cost that the spec does not name is
**`Mod` of a theorem set vs. `Mod` of an axiom set** (§5), and the one correction the spec needs
is **the `.Dedekind`/`.Complete` naming** (§1.1), because 507 deliberately did not perform the
rename the 514 report anticipated.

A second scoping finding matters for cost: **the ~400-line `Walk`/`MinCyc` periodicity apparatus
of `03_probes.lean` is needed only for deliverable (3)'s schema half at ℤ.** The non-closure
witnesses of deliverable (5) do *not* need it — the tree's own
`Independence.LoopingDuration.truthAt_add_period` discharges them at arbitrary `D` (§4).

---

## 1. Corrections to the dispatch's premises

### 1.1 `.Complete` does not exist; the class is `.Dedekind` — and that is deliberate

The dispatch says "staticFrame over ℚ ∈ Mod(Axioms .Complete) \ Sat .Complete". There is no
`FrameClass.Complete`. `FormalSystem/Semantics/FrameClassValidity.lean:110` gives:

```
def FrameClass.Sat : FrameClass → TaskFrame → Prop
  | .Base, _ => True
  | .Dense, F => F.IsDense
  | .Discrete, F => F.IsSuccArchDiscrete
  | .Dedekind, F => F.IsDedekind
```

The 514 report's amendment text for 507 asked for `FrameClass.Dedekind → FrameClass.Complete`.
507 did **not** apply it, and recorded a "naming deviation of record" instead, at two sites
(`FrameClassValidity.lean` module docstring and `FrameProperty.lean:172`'s `IsDedekind`
docstring): the word "complete" is reserved for *proof-theoretic* completeness
(`completeness_dense`, `completeness_discrete`, `Metalogic/StrongCompleteness.lean`), so a
`TaskFrame.IsComplete`-versus-`FrameClass.Complete` pair would collide at exactly the point where
the two senses meet.

**Verdict**: read the dispatch's `.Complete` as `.Dedekind` throughout. Do **not** rename as part
of this task — the deviation is documented in two docstrings that would both have to be rewritten,
and neither the closure results nor the witnesses depend on the name. The substance is unaffected:
`Sat .Dedekind = IsDedekind = IsDense ∧ IsComplete`, so `staticFrame` over ℚ (dense, not complete)
is exactly the intended witness.

Note also `FrameProperty.lean:142`'s bare `TaskFrame.IsComplete` **does** keep the paper's name;
only the dense-and-complete conjunction is renamed. And `Semantics.ValidDedekind` is
`ValidOnFrames TaskFrame.IsComplete` — the *bare* clause — while `ValidDedekindDense` is
`ValidIn .Dedekind`. Both docstrings warn about the mismatch. Do not use `ValidDedekind` anywhere
in this task.

### 1.2 The probe files are pre-512 and need a rename pass, not a copy

`02_probes.lean` / `03_probes.lean` were written against the unbundled shape. The port must
rewrite three things mechanically:

| Probe spelling | Tree spelling (post-512) |
|---|---|
| `TaskFrame D` (a frame over a carrier) | `FrameOver D` where `D : TemporalOrder`; `TaskFrame` is now the bundled total space |
| `TaskFrame.staticFrame` | `FrameOver.staticFrame` (`TaskFrame.lean:1379`, inside `namespace FrameOver`) |
| `nonempty := …` field | `worldNonempty := …` |

"Transplant and restate" in the acceptance criteria means this pass; it is not re-proof.

### 1.3 `Mod` takes a set of *formulas*, so `Axioms fc` must be reified

`Axiom` is an inductive family indexed by `Formula`, not a set of formulas. The spec's
`Axioms fc := {ax | minFrameClass ax ≤ fc}` reifies as **[verified]**:

```lean
def AxiomSet (fc : FrameClass) : Set Formula := {φ | ∃ h : Axiom φ, h.minFrameClass ≤ fc}
```

Similarly the density schema is a set of instances, not a schema former:

```lean
def densitySchema : Set Formula := {φ | ∃ ψ : Formula, φ = ψ.allFuture.allFuture.imp ψ.allFuture}
```

Both elaborate, and `Mod densitySchema = {F : TaskFrame | F.FwdRec}` is a well-formed `Prop`.

---

## 2. Deliverable (1) — `Semantics/Correspondence/Galois.lean` **[verified]**

The whole module compiles, with no universe trouble (`TaskFrame : Type 1`, so
`Set TaskFrame : Type 1`; nothing needs a `Type`-valued frame class):

```lean
def Th (K : Set TaskFrame) : Set Formula := {φ | ∀ F ∈ K, F.ValidOn φ}
def Mod (S : Set Formula) : Set TaskFrame := {F | ∀ φ ∈ S, F.ValidOn φ}

theorem th_anti  {K₁ K₂ : Set TaskFrame} (h : K₁ ⊆ K₂) : Th K₂ ⊆ Th K₁
theorem mod_anti {S₁ S₂ : Set Formula}   (h : S₁ ⊆ S₂) : Mod S₂ ⊆ Mod S₁
theorem subset_mod_th (K : Set TaskFrame) : K ⊆ Mod (Th K)
theorem subset_th_mod (S : Set Formula)   : S ⊆ Th (Mod S)
theorem mod_th_mod (S : Set Formula)   : Mod (Th (Mod S)) = Mod S
theorem th_mod_th  (K : Set TaskFrame) : Th (Mod (Th K)) = Th K

def GaloisClosed (K : Set TaskFrame) : Prop := Mod (Th K) = K
theorem galoisClosed_mod (S : Set Formula) : GaloisClosed (Mod S)
```

**Add one lemma the spec does not name, and both closure corollaries become one-liners** — this
is the indicator mechanism factored once, which is what "no per-class copies" should mean:

```lean
theorem galoisClosed_of_indicator {K : Set TaskFrame} (φ : Formula)
    (hmem : φ ∈ Th K) (hback : ∀ F : TaskFrame, F.ValidOn φ → F ∈ K) : GaloisClosed K :=
  Set.Subset.antisymm (fun F hF => hback F (hF φ hmem)) (subset_mod_th K)
```

Each proof body above is one term. Whole module ≈ 40 lines of code plus docstrings; the spec's
~80-line estimate holds.

**Placement and imports**: `Semantics/Correspondence/Galois.lean` importing
`Semantics/Validity.lean` gets `TaskFrame.ValidOn`, and transitively `FrameClassValidity.lean`'s
`Sat` and `ProofSystem.Axioms`. This opens **no new import seam** — `FrameClassValidity.lean` is
already the single documented `Semantics → ProofSystem` edge and `Validity.lean` already imports
it.

---

## 3. Deliverable (2) — indicator exactness **[verified]**

### 3.1 The formula

`Axiom.dense_indicator` (`Axioms.lean:381`) is `(Formula.untl ⊥ (⊥ → ⊥)).neg`, i.e. `¬X⊤` with
`X⊤ = Formula.next Formula.top = untl ⊥ ⊤` under the guard-first convention
(`Formula.lean:511`; `specs/decisions/untl-snce-argument-order.md`). Its `minFrameClass` is
`.Dense` — checked by `rfl`.

`TruthAt M τ t (untl ⊥ ⊤)` unfolds to `∃ s, t < s ∧ True ∧ ∀ r, t < r → r < s → False`, which
mentions no atom: the valuation is never consulted. That is the whole mechanism.

### 3.2 The two theorems, compiled

`Nonempty (TaskFrame.HF F)` — needed for the (⇒) readings — is
`TaskFrame.hF_nonempty_of_frameAxioms` (`Validity.lean:236`), wholly frame-intrinsic. The model
witness is `TaskModel.allFalse`.

```lean
theorem validOn_neg_nextTop_iff (F : TaskFrame) :
    F.ValidOn nextTop.neg ↔ DenselyOrdered F.Duration
theorem validOn_nextTop_iff (F : TaskFrame) :
    F.ValidOn nextTop ↔ ∀ x : F.Duration, ∃ y, IsLeast {z | x < z} y
theorem validOn_nextTop_iff_isDiscrete (F : TaskFrame) :
    F.ValidOn nextTop ↔ F.IsDiscrete
```

Ten lines each. Two notes:

- **No homogeneity argument is needed.** `DenselyOrdered` is literally
  `∀ a b, a < b → ∃ c, a < c ∧ c < b`, which is the negation of `¬X⊤`'s falsity condition on the
  nose. The 514 report's appeal to ordered-group homogeneity is not required for IND-D at all.
- **IND-F needs one step past the raw statement.** `TaskFrame.IsDiscrete`
  (`FrameProperty.lean:89`) carries the paper's guard `(∃ y, x < y) →`, which
  `validOn_nextTop_iff` does not. The guard is discharged by
  `TaskFrame.exists_pos_of_nontrivial` (`TaskFrame.lean:957`) — `Nontrivial` is a *field* of
  `TemporalOrder` (`TemporalOrder.lean:86`), so every `TaskFrame.Duration` has it. Without that
  step the two are inequivalent on a trivial carrier.

### 3.3 The corollaries

With `galoisClosed_of_indicator`:

- `Mod (Th (Sat .Dense)) = Sat .Dense`: instantiate at `φ := nextTop.neg`. `hmem` is
  `validOn_neg_nextTop_iff.mpr`, `hback` is `.mp`. **No proof theory is involved** — the
  dependence on `dense_indicator` being an axiom is only rhetorical.
- The paper-Discrete analogue `Mod (Th {F | F.IsDiscrete}) = {F | F.IsDiscrete}`: same, at
  `φ := nextTop`, via `validOn_nextTop_iff_isDiscrete`.

Note that the paper-Discrete class is `{F | F.IsDiscrete}`, **not** `Sat .Discrete`. `Sat
.Discrete` is `IsSuccArchDiscrete` (`def:TMplus-f`'s Hölder narrowing to ℤ-time), which is
strictly stronger and is *not* Galois-closed — that is exactly what deliverable (5b) witnesses.
State the corollary over `IsDiscrete` and say so.

### 3.4 The `Derivable`-level `X⊤` lemma **[verified, 12 lines, axioms: `propext`]**

```lean
def nextTopThm {fc : FrameClass} (h : FrameClass.Discrete ≤ fc) :
    ⊢[fc] Formula.untl Formula.bot Formula.top
```

Route, all three steps against existing helpers:

1. `Axiom.serial_future : ⊤ → F⊤` + `Combinators.topThm`, one `modus_ponens` ⟹ `⊢[fc] F⊤`.
2. `Axiom.prior_UZ Formula.top : F⊤ → untl ⊤.neg ⊤`, at `h : .Discrete ≤ fc` ⟹
   `⊢[fc] untl ⊤.neg ⊤`.
3. `Combinators.guardMono` (the usable form of `Axiom.left_mono_until_G`) with
   `⊢[fc] ⊤.neg → ⊥`, which is `modus_ponens theoremApp1 topThm`.

Step 3 is the one the spec's "prior_UZ + serial_future" phrasing omits: `prior_UZ` at `⊤` yields
the guard `⊤.neg`, not `⊥`, and those are different formulas. `guardMono` closes the gap for free.

---

## 4. Deliverable (5) — non-closure witnesses **[verified]**

This turned out to be the cheapest deliverable, not the most expensive, because of an asset the
spec does not mention.

### 4.1 Time-invariance at arbitrary `D` is three lines, from a tree asset

`Metalogic/Independence/LoopingDuration.lean:98` already has, **in the tree**:

```lean
theorem truthAt_add_period {F : FrameOver D} (M : TaskModel F) {π : ↑D}
    (h : LoopingDuration F π) :
    ∀ (φ : Formula) (τ : WorldHistory F), τ.IsTotal → ∀ t : ↑D,
      (TruthAt M τ t φ ↔ TruthAt M τ (t + π) φ)
```

`LoopingDuration F π := π ≠ 0 ∧ ∀ w u, F.TaskRel w π u ↔ u = w`. For `FrameOver.staticFrame`,
`TaskRel w d u ↔ w = u` at *every* `d`, so **every nonzero `π` is a looping duration**. Since
`truthAt_add_period` carries no positivity hypothesis on `π`, instantiating at `π := s - t` gives
full time-invariance immediately **[verified]**:

```lean
theorem staticFrame_looping (W) [Nonempty W] {π : D} (hπ : π ≠ 0) :
    LoopingDuration (FrameOver.staticFrame W (D := D)) π := ⟨hπ, fun _ _ => ⟨Eq.symm, Eq.symm⟩⟩

theorem static_time_invariant (W) [Nonempty W] (M) (φ : Formula) (τ) (hτ : τ.IsTotal) (t s : D) :
    TruthAt M τ t φ ↔ TruthAt M τ s φ
```

**Consequence for scope**: 03_probes' `truthAt_add_hist_period` (per-history periods) and the
entire `Walk`/`MinCyc`/`periodic` apparatus behind it exist to handle frames whose histories have
*different* periods. `staticFrame` does not need any of it. The spec's "03_probes
`density_of_hist_periodic` is the pattern" is a pointer to a heavier tool than the job requires;
02_probes' Probe F (`density_of_loopingDuration`, three lines over `truthAt_add_period`) is the
right pattern.

### 4.2 The constant-truth calculus — prove this once, and every axiom check is a rewrite **[verified]**

This is the lemma the plan should be built around. Do **not** check `prior_UZ`, `z1`, `sep`,
`prior_U_gap`, `prior_S_gap` and the Base axioms one at a time by hand.

```lean
theorem static_untl_iff (W) [Nonempty W] (M) (τ) (hτ : τ.IsTotal) (ψ φ : Formula) (t : D) :
    TruthAt M τ t (Formula.untl ψ φ) ↔
      (TruthAt M τ t φ ∧ (TruthAt M τ t ψ ∨ ∃ y, IsLeast {z : D | t < z} y))

theorem static_untl_iff_dense [DenselyOrdered D] … :
    TruthAt M τ t (Formula.untl ψ φ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ)

theorem static_untl_iff_disc (hdisc : ∀ x : D, ∃ y, IsLeast {z : D | x < z} y) … :
    TruthAt M τ t (Formula.untl ψ φ) ↔ TruthAt M τ t φ
```

All three compile. The `snce` mirrors are the same proof with the order reversed. With them, on a
static frame every formula has a constant truth value `b(·)` and:

- **Dense `D`**: `b(U(ψ,φ)) = b(φ) ∧ b(ψ)`, hence `b(K⁺φ) = b(K⁻φ) = b(φ)` and `b(Gφ) = b(φ)`.
  - `density` (`GGφ→Gφ`) reduces to `b(φ) → b(φ)`. ✓
  - `dense_indicator` is immediate from IND-D (ℚ is dense). ✓
  - `prior_U_gap`'s antecedent `U(φ,⊤) ∧ F(¬φ)` reduces to `b(φ) ∧ ¬b(φ)` — **vacuous**. ✓
    `prior_S_gap` dually. ✓
  - `sep`: `b(U(¬φ,φ)) = b(φ) ∧ ¬b(φ) = ⊥`, so the second conjunct of the antecedent is `⊤`, and
    the whole axiom reduces to `b(φ) → b(φ)`. ✓
- **Discrete `D`**: `b(U(ψ,φ)) = b(φ)`, hence `b(Fφ) = b(Gφ) = b(φ)`.
  - `prior_UZ` (`Fφ → U(¬φ,φ)`) reduces to `b(φ) → b(φ)`. ✓ `prior_SZ` dually. ✓
  - `z1` reduces to a tautology — separately **[verified]** as
    `static_validates_z1`, which needs only `static_time_invariant`, not the calculus. ✓

Base axioms need no argument: they are sound on every task frame, so `validOn_of_valid`
(`Validity.lean:387`) applies.

### 4.3 The two carriers

**(a) ℚ, for `Mod (AxiomSet .Dedekind) \ Sat .Dedekind`.** `DenselyOrdered ℚ` is an instance.
`¬ TaskFrame.IsComplete` needs a nonempty bounded-above rational set with no rational LUB;
**[verified]** in 25 lines, axioms `[propext, Classical.choice, Quot.sound]`:

```lean
theorem rat_not_complete : ¬ (∀ s : Set ℚ, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
```
witness `{q : ℚ | (q:ℝ) < √2}`, using `Nat.Prime.irrational_sqrt` and `exists_rat_btwn`. Mathlib
has no off-the-shelf statement of this; it must be written.

**(b) ℤ ×ₗ ℤ, for `Mod (AxiomSet .Discrete) \ Sat .Discrete`.** All four `TemporalOrder` instances
resolve **[verified]**: `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial` on
`ℤ ×ₗ ℤ` are all `inferInstance`, so `TemporalOrder.of (ℤ ×ₗ ℤ)` needs no new instance work.

- Discrete: `IsLeast {x | 0 < x} (toLex (0,1))` **[verified]**.
- Not `Sat .Discrete`: go through `DurationClassification.intIso` — `[SuccOrder D]`
  `[IsSuccArchimedean D]` gives `D ≃+o ℤ` — so `IsSuccArchDiscrete D → Nonempty (D ≃+o ℤ)`, and
  it suffices to refute the latter via `¬ Archimedean (ℤ ×ₗ ℤ)` **[verified]**: `(1,0)` dominates
  every `n • (0,1) = (0,n)`. **Do not attempt to refute the `∃ (_ : SuccOrder D)` existential
  directly** even though `Subsingleton (SuccOrder (ℤ ×ₗ ℤ))` is an instance; the `intIso` route
  is shorter and uses tree assets.

---

## 5. Deliverable (5)'s sandwiches, and the one real design decision

The spec writes `Mod(TM⁺_f)` and `Mod(TM⁺_c)`. These are ambiguous between

- `Mod (AxiomSet fc)` — model class of the axiom *instances*, and
- `Mod {φ | Derivable fc [] φ}` — model class of the *theorems*.

They differ, and the difference cuts both ways:

| Claim | Needs |
|---|---|
| `Sat .Discrete ⊊ Mod (…)` (witness is *in* Mod) | easier over `AxiomSet` |
| `Mod (…) ⊆ {F \| F.IsDiscrete}` (upper bound) | easier over theorems, since `X⊤` is derived, not an axiom |

**Recommendation: state both sandwiches over `AxiomSet fc`, and get the upper bound semantically
rather than proof-theoretically.** `TaskFrame.ValidOn` is trivially closed under modus ponens and
under `temporal_necessitation`, so replaying §3.4's three steps at the `ValidOn` level gives

```lean
theorem validOn_nextTop_of_mem_mod_discrete {F : TaskFrame} (hF : F ∈ Mod (AxiomSet .Discrete)) :
    F.ValidOn nextTop
```

directly, and `Mod (AxiomSet .Discrete) ⊆ {F | F.IsDiscrete}` follows by
`validOn_nextTop_iff_isDiscrete`. Under this reading `AxiomSet fc ⊆ {φ | Derivable fc [] φ}`
gives `Mod (Thms fc) ⊆ Mod (AxiomSet fc)`, so both sandwich statements are the *stronger* ones.

**Why not build a general `Derivable → ValidOn` bridge**: `DerivationTree` has seven constructors
(`Derivation.lean:91`), of which `axiom`, `assumption`, `modus_ponens`, `necessitation`,
`temporal_necessitation`, `weakening` are all one-liners at the `ValidOn` level — but
`temporal_duality` (from `⊢ φ` infer `⊢ φ.swapTemporal`) is not. `Soundness.lean` handles
`swapTemporal` only per-axiom at the *class* level (see `Soundness.lean:1745`–`1900`, ~150 lines
for `sep` alone), and there is no single-frame `F.ValidOn φ → F.ValidOn φ.swapTemporal` lemma —
nor should there be one: it is false in general, since a frame need not be closed under time
reversal. **If the plan insists on `Mod` of a theorem set, this is a genuine blocker and must be
scoped as its own phase.** Flag it rather than discovering it mid-implementation.

---

## 6. Deliverables (3) and (4) — the two remaining costs

### 6.1 (3) FwdRec port

Bundled restatement (elaborates **[verified]**):

```lean
def TaskFrame.FwdRec (F : TaskFrame) : Prop :=
  ∀ (τ : F.HF) (t s : F.Duration), t < s → (∀ r, t < r → r < s → False) →
    ∀ A : F.WorldState → Prop,
      (∀ r, s < r → A (τ.val.states r (τ.property r))) → A (τ.val.states s (τ.property s))
```

The probes' validity shape `∀ M (τ : WorldHistory F) (hτ : τ.IsTotal) t, TruthAt …` bridges to
`ValidOn` by a one-term lemma **[verified]**, since `TaskFrame.HF` is a subtype
(`WorldHistory.lean:512`):

```lean
theorem validOn_iff_total (F : TaskFrame) (φ : Formula) :
    F.ValidOn φ ↔ ∀ M (τ : WorldHistory F), τ.IsTotal → ∀ t, TruthAt M τ t φ :=
  ⟨fun h M τ hτ t => h M ⟨τ, hτ⟩ t, fun h M τ t => h M τ.val τ.property t⟩
```

**Two results, two different strengths — state them separately, do not merge:**

- `Corr.density_iff_fwdRec` (02_probes:162) is **atomic instances only**, at arbitrary `D`.
- `Bridge.density_schema_iff_fwdRec` (03_probes:626) is the **full schema**, at `D = ℤ` only.

So `Mod densitySchema = {F | F.FwdRec}` is a **ℤ-only** statement, as the dispatch says. The
atomic version generalizes; the schema version does not, and the ℤ restriction is what the
`Walk`/`MinCyc` apparatus buys. Porting the schema half means porting ~400 lines of Probe H (walks
in a digraph, `MinCyc`, `succ_unique`, `periodic`) plus Probe J's bridge. That is the single
largest line-count item in the task and it is *not* needed by any other deliverable. Size the
phase accordingly, or scope the schema half as optional.

### 6.2 (4) The two (T1) witness frames

**Statement shape.** Quantify over the fibre, not over bundled frames with a `Duration` equation:

```lean
theorem transFrame_… (D : TemporalOrder) :
    (∀ F : FrameOver D, F.toTaskFrame.ValidOn ax) ↔ P D
```

`FrameOver.toTaskFrame` is `@[reducible]` with `(F.toTaskFrame).Duration = D` by `rfl`
(`TaskFrame.lean:1633`), so this needs no transport. A `F.Duration = D` formulation would.

**The translation frame** (`W = D`, `w ⇒_x u ↔ u = w + x`), for `app:discrete`/`app:complete`:
**[verified] — the complete `FrameOver` value compiles sorry-free in ~35 lines**, all seven
obligations discharged:

- `comp` via `TaskFrame.comp_of` with the interpolant `w + x`;
- `limit` via `TaskFrame.limit_of_shift id` (`TaskFrame.lean:846` — its docstring names exactly
  this "flow-style frame" shape as its intended use);
- `spherical` by copying `ClockFrame.clockRel_spherical`'s argument
  (`sInter_nonempty_of_directed_of_univ_or_singleton` + fibre-subsingleton) — the translation
  relation is deterministic, so its fibres are singletons, same as the clock frame's.

This was the largest construction risk in the task and it is retired.

**The two-state permissive frame** (`W = Bool`, `w ⇒_d u ↔ d ≠ 0 ∨ w = u`), for `app:dense`: this
is 03_probes' `freeFrame` at `W = Bool`, which is already generic in `D` — but it carries
`[SuccOrder D] [NoMaxOrder D]`, because `TaskFrame.limit_of_permissive` needs them. For the
(T1)-DN (⇒) direction the hypothesis is "`D` is not dense", which supplies both:

- `NoMaxOrder D` is free from `Nontrivial` + ordered group, via
  `TaskFrame.exists_pos_of_nontrivial` **[verified]**;
- `SuccOrder D` comes from `Semantics.duration_dense_or_least_pos`
  (`DurationClassification.lean:283`, **already in the tree**: `DenselyOrdered D ∨ ∃ d, IsLeast
  {x | 0 < x} d`) fed into `SuccOrder.ofSuccLeIff (fun x => x + p)` **[verified]**.

Neither is a research gap; both are ~8-line glue lemmas. `freeFrame` also needs the pre-512
rename pass of §1.2 and a `natFrame`-style docstring.

**Adjudication to carry into the docstrings** (514 report §2.4, and it must not be silently
dropped): the per-frame reading (T0) `F ⊨ ax ↔ P F.Duration` is **false** in its (⇒) direction —
`staticFrame` over ℤ validates the whole density schema while ℤ is not dense. Only (T1),
`(∀ F over D, F ⊨ ax) ↔ P D`, is true, and it is what the paper's proofs actually conclude. State
(T1); record the refutation of (T0) next to it.

---

## 7. Deliverable (6) — the non-goals

No Lean content. Record as a module-level docstring section in `Galois.lean`: closed-form
characterizations of `Mod (AxiomSet .Discrete)` and `Mod (AxiomSet .Dedekind)` are **open and not
promised**. Evidence to cite, both already in the tree or in 511: no variable-free BL⁺ sentence
separates ℤ from ℤ ×ₗ ℤ or ℚ from ℝ; and `sep` has no duration-level correspondent at all —
Reynolds, quoted verbatim in `Axioms.lean`'s own `sep` docstring (~:390), that the axioms "enforce
only a *definably* Dedekind-complete model".

---

## 8. Recommended phase decomposition

Each phase is one agent run and ends `lake build`-green; every phase below has its load-bearing
lemma already compiled in this research.

| Phase | Content | Est. lines | Risk |
|---|---|---|---|
| 1 | `Semantics/Correspondence/Galois.lean`: `Th`, `Mod`, antitonicity, closure, `GaloisClosed`, `galoisClosed_of_indicator`, `AxiomSet`, non-goals docstring | ~120 | none — compiled |
| 2 | Indicator exactness: IND-D, IND-F, `validOn_nextTop_iff_isDiscrete`, the two closure corollaries | ~90 | none — compiled |
| 3 | `Derivable` `X⊤` lemma + `validOn_nextTop_of_mem_mod_discrete` | ~60 | none — compiled |
| 4 | Static-frame kit at arbitrary `D`: `staticFrame_looping`, `static_time_invariant`, `static_untl_iff` (+ `snce` mirror, dense/discrete specializations) | ~140 | none — compiled |
| 5 | Witness (a): `rat_not_complete`, `staticFrame ℚ ∈ Mod (AxiomSet .Dedekind) \ Sat .Dedekind`, sandwich `Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind) ⊆ Sat .Dense` | ~180 | low — calculus does the work |
| 6 | Witness (b): `ℤ ×ₗ ℤ` discreteness + non-Archimedean, `staticFrame (ℤ ×ₗ ℤ) ∈ Mod (AxiomSet .Discrete) \ Sat .Discrete`, sandwich | ~160 | low |
| 7 | (T1): `transFrame` + `freeFrame` port + the three duration-level biconditionals | ~350 | medium — three separate (⇒) arguments |
| 8 | (3) FwdRec port, atomic half at arbitrary `D` | ~150 | low — transcription |
| 9 | (3) FwdRec port, schema half at ℤ (`Walk`/`MinCyc`/Bridge) | ~450 | medium — bulk transcription; optional |

Phases 1–6 are independent of 7–9 and of each other after 1. Phase 4 gates 5 and 6.

---

## 9. Zero-debt note

No step in this plan requires a `sorry` or a new axiom. Every construction that could have forced
one — the translation frame's `spherical` field, ℚ's incompleteness, ℤ ×ₗ ℤ's non-Archimedean
property, the `SuccOrder` from non-density — was compiled during this research. The one place
where the task as specified could become unsatisfiable is §5's `Mod`-of-theorems reading; the
recommendation there avoids it structurally rather than deferring it.
