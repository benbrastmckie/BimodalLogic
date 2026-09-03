# Research Report: Consequence / Compactness / Strong-Completeness Generic Theorems

- **Task**: 524 — WAVE 3 (theorem layer)
- **Type**: lean4
- **Date**: 2026-09-02
- **Baseline**: HEAD `b7da18269`; `.lake/build` current (oleans 2026-09-02 17:14–17:21); no build running
- **Review source**: `specs/reviews/2026-09-01-lean-engineering/{B-completeness,A-soundness,G-ecosystem}.md`
- **Verification method**: every proposed declaration below was elaborated against the built
  library with `lake env lean` on scratch files outside the repo tree. No source file was edited.

---

## Executive summary

**Every one of the eight work items is achievable, and the mathematically load-bearing parts of
items 1–6 have been written and compiled during this research** — not sketched. Seven scratch
files elaborated clean against the live library; the axiom profile of every new terminus is
exactly `[propext, Classical.choice, Quot.sound]`, matching the existing C2/C14 baselines.

Four corrections to the task's measured-state paragraph, all of which change the plan:

1. **B-08 has already landed.** All five BL-vs-TM files *are* in the build graph:
   `Metalogic.lean:17,18,20,21` imports `Conservativity`, `BaseLanguageSoundness`,
   `Z1Countermodel`, `SpWitness`, and `TMCompletenessReduction` is reached through
   `Z1Countermodel.lean:8`. `Semantics/LexCarrier.lean` is registered in `Semantics.lean`.
   The manifest carries none of them. Item 8's justification is now **only** B-19 (the
   convention), not "which is how they fell out of the build" — that sentence is stale.
2. **The dead-declaration inventory is 13, not 15, and the list has changed.** Task 523 already
   deleted the six per-class `.of_forall`/`.apply` adapters; `SetConsequence.lean` now carries a
   single generic `SetSemanticConsequenceOn.of_forall_total` / `.apply_total` /
   `SatisfiableSet.of_forall` trio. §6 gives the re-measured list.
3. **`semantic_deduction_base` is not the same script as its three siblings.** The other three
   are byte-identical; the Base one routes through `Valid.of_forall_total` /
   `SemanticConsequence.of_forall` / `.apply` (the frame-condition-free Base adapters). It still
   collapses to the same one-liner — verified — but a plan that says "four byte-identical
   scripts" will mis-predict the diff.
4. **The `PointedModel` migration is source-compatible.** `rcases`/`obtain` auto-flattens through
   `Nonempty` + a single-constructor structure, so `obtain ⟨F, hF, M, τ, hτ, t, hsat⟩` and
   `⟨F, hF, M, τ, hτ, t, h⟩` both keep working verbatim at all six existing call sites. Verified
   in §5.5. This is the single biggest de-risking result in the report: item 5 is a definition
   swap, not a call-site campaign.

Two blockers-turned-solved and one genuine constraint are recorded in §8.

---

## 1. What is actually there (re-measured at `b7da18269`)

| Declaration | File:line | Status |
|---|---|---|
| `semantic_deduction_dedekind` | `StrongCompleteness.lean:238` | 10-line script |
| `semantic_deduction_base` | `:615` | **different** 10-line script (Base adapters) |
| `semantic_deduction_dense` | `:728` | byte-identical to `_dedekind` |
| `semantic_deduction_discrete` | `:851` | byte-identical to `_dedekind` |
| `soundness_dedekind_consequence` | `:508` | 2-line body |
| `soundness_base_consequence` | `:658` | byte-identical |
| `soundness_dense_consequence` | `:772` | byte-identical |
| `soundness_discrete_consequence` | `:893` | byte-identical |
| `consequence_completeness_dedekind_of_engine` / `completeness_dedekind_of_engine` | `:487` / `:526` | the only `_of_engine` layer |
| `consequence_completeness_{dedekind,base,dense,discrete}` | `:551`, `:641`, `:754`, `:875` | 8 instances of 2 theorems |
| `completeness_{dedekind,base,dense,discrete}` | `:570`, `:671`, `:789`, `:911` | ” |
| engine shape written longhand | `:358` (`strongCompleteness_of_compact`), `:487`, `:526` | 3 sites, never named |
| `strongCompleteness_of_compact` / `compact_of_modelExistence` | `:358` / `:406` | generic ✓ |
| `modelExistenceBase` / `modelExistenceDense` | `Compactness.lean:84` / `:122` | 2 near-identical proofs |
| `discrete_consequence_not_compact` / `strongCompletenessDiscrete_refuted` | `DiscreteNonCompactness.lean:250` / `:279` | 5-step skeleton ×2 |
| `dedekind_consequence_not_compact` / `strongCompletenessDedekind_refuted` | `DedekindNonCompactness.lean:423` / `:451` | 5-step skeleton ×2 |
| `dedWitness_core` | `DedekindNonCompactness.lean:205–257` | 51 lines, four arguments |
| in-file `#print axioms` | 44 in territory (14 + 6 + 12 + 12), 55 tree-wide | B-23 |

Every `Sat` clause depends only on `F.Duration` (`FrameProperty.lean:97,154,175,205`), and
`FrameClass.Sat` is `@[reducible]` (`FrameClassValidity.lean:124`). `TaskFrame.IsDense` is now an
`abbrev`, so the "type-ascribed `inferInstance`" docstring at `Compactness.lean:110-121` and the
`haveI : DenselyOrdered F.Duration := hd` notes at `DedekindNonCompactness.lean:415,447` are
already partly stale.

---

## 2. Item 1 — `semantic_deduction_in`, `soundness_consequence`, `WeakCompleteness` (VERIFIED)

All of the following elaborated with **zero errors** against `FormalSystem.Metalogic.Compactness`.

```lean
theorem semantic_deduction_in {fc : FrameClass} (Γ : Context) (φ : Formula) :
    SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h
    exact ValidIn.of_forall_total fun F hF M τ hτ t =>
      (truthAt_foldr_imp M τ t Γ φ).mpr (SemanticConsequenceIn.apply_total h F hF M τ hτ t)
  · intro h
    exact SemanticConsequenceIn.of_forall_total fun F hF M τ hτ t =>
      (truthAt_foldr_imp M τ t Γ φ).mp (ValidIn.apply_total h F hF M τ hτ t)

theorem soundness_consequence {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : Derivable fc Γ φ) : SemanticConsequenceIn fc Γ φ :=
  fun F hF M τ hτ t h_ctx => h.elim fun d => soundness_in Γ φ d F hF M τ hτ t h_ctx

def WeakCompleteness (fc : FrameClass) : Prop := ∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ
```

**All four per-class instantiations of each are literal one-liners** (verified, including the Base
row, which is the one the task's measured state predicts wrongly):

```lean
theorem semantic_deduction_base (Γ φ) : SemanticConsequence Γ φ ↔ Valid (Γ.foldr Formula.imp φ)
  := semantic_deduction_in Γ φ            -- likewise _dense, _discrete, _dedekind
theorem soundness_base_consequence (Γ φ) (h : Derivable FrameClass.Base Γ φ) :
    SemanticConsequence Γ φ := soundness_consequence Γ φ h
```

**And the four `BXCanonical` engines already inhabit `WeakCompleteness` on the nose** — no
transport, no `rfl` lemma:

```lean
theorem wc_base  : WeakCompleteness FrameClass.Base     := completeness_base
theorem wc_dense : WeakCompleteness FrameClass.Dense    := completeness_dense
theorem wc_disc  : WeakCompleteness FrameClass.Discrete := completeness_discrete
theorem wc_ded   : WeakCompleteness FrameClass.Dedekind := completeness_dedekind
```

This is B-03's payoff made concrete: once `WeakCompleteness` is named, the four `completeness_*`
corollaries *are* the four `WeakCompleteness .X` witnesses, by type rather than by convention.

**Home**: `WeakCompleteness` belongs in `SetConsequence.lean` beside `StrongCompleteness` —
verified that its two ingredients (`ValidIn`, `Derivable`) are already imported there
(`SetConsequence.lean:8,10`). `semantic_deduction_in` and `soundness_consequence` must stay in
`StrongCompleteness.lean` (they need `truthAt_foldr_imp` / `soundness_in`, which that module owns;
stating them in `SetConsequence.lean` is an import cycle, exactly as the existing docstrings at
`:322-325` and `:398-401` already record for the two generic reductions).

---

## 3. Item 2 — the two iffs (VERIFIED, with a proof simpler than the review's)

```lean
theorem compact_of_strongCompleteness {fc : FrameClass} (h : StrongCompleteness fc) :
    Compact fc := by
  intro Γ φ hcons
  obtain ⟨L, hL, hd⟩ := h Γ φ hcons
  exact ⟨L, hL, hd.elim fun d => soundness_validIn ((derivable_foldr_imp_iff L φ).mp ⟨d⟩).some⟩

theorem strongCompleteness_iff_compact {fc : FrameClass} (engine : WeakCompleteness fc) :
    StrongCompleteness fc ↔ Compact fc :=
  ⟨compact_of_strongCompleteness, fun hc => strongCompleteness_of_compact hc engine⟩

theorem modelExistence_of_compact {fc : FrameClass} (hc : Compact fc) : ModelExistence fc := by
  intro Γ hfin
  by_contra hns
  exact not_compact_of_witness hfin hns hc

theorem compact_iff_modelExistence {fc : FrameClass} : Compact fc ↔ ModelExistence fc :=
  ⟨modelExistence_of_compact, compact_of_modelExistence⟩
```

Two notes the plan should carry:

- The review's sketch for `compact_of_strongCompleteness` used `soundness_in [] _ d … (by simp)`.
  `Soundness.lean:1319` already has `soundness_validIn {fc} {φ} (d : DerivationTree fc [] φ) :
  ValidIn fc φ` — the empty-context form, uniform in `fc`. Using it removes the `ValidIn.of_forall_total`
  wrapper and the vacuous-context `simp` entirely. **Use `soundness_validIn`.**
- `modelExistence_of_compact` is *literally* the contrapositive of `not_compact_of_witness` (§4).
  So item 2's second half depends on item 3's first half — order the phases accordingly.

**The Dedekind corollary the docstring at `SetConsequence.lean:565-570` says is "simply not drawn
here" is then one line** (verified, axioms clean):

```lean
theorem modelExistenceDedekind_refuted : ¬ ModelExistenceDedekind :=
  fun h => dedekind_consequence_not_compact (compact_of_modelExistence h)
```

---

## 4. Item 3 — the shared refutation skeleton (VERIFIED; the four refutations become one-liners)

```lean
theorem setConsequence_of_not_satisfiable {fc : FrameClass} {Γ : Set Formula} {φ : Formula}
    (h : ¬ SatisfiableSet fc Γ) : SetSemanticConsequenceOn fc Γ φ :=
  fun F hF M τ hτ t hall => absurd (SatisfiableSet.of_forall F hF M τ hτ t hall) h

theorem not_compact_of_witness {fc : FrameClass} {W : Set Formula}
    (hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ W) → SatisfiableSet fc {ψ | ψ ∈ L})
    (hunsat : ¬ SatisfiableSet fc W) : ¬ Compact fc := by
  intro hc
  obtain ⟨L, hL, hvalid⟩ := hc W Formula.bot (setConsequence_of_not_satisfiable hunsat)
  obtain ⟨F, hF, M, τ, hτ, t, hsat⟩ := hfin L hL
  exact (truthAt_foldr_imp M τ t L Formula.bot).mp (ValidIn.apply_total hvalid F hF M τ hτ t) hsat

theorem not_strongCompleteness_of_witness {fc : FrameClass} {W : Set Formula}
    (hfin : …) (hunsat : …) : ¬ StrongCompleteness fc :=
  fun h => not_compact_of_witness hfin hunsat (compact_of_strongCompleteness h)
```

The four refutations, verified verbatim, each with axiom profile
`[propext, Classical.choice, Quot.sound]`:

```lean
theorem discrete_consequence_not_compact : ¬ CompactDiscrete :=
  not_compact_of_witness (archWitness_finitely_satisfiable ⟨"p", none⟩)
                         (archWitness_not_satisfiable ⟨"p", none⟩)
theorem strongCompletenessDiscrete_refuted : ¬ StrongCompletenessDiscrete :=
  not_strongCompleteness_of_witness (archWitness_finitely_satisfiable ⟨"p", none⟩)
                                    (archWitness_not_satisfiable ⟨"p", none⟩)
-- and the Dedekind pair, with dedWitness_{finitely_satisfiable,not_satisfiable} ⟨"q", none⟩
```

**Consequence worth naming in the plan**: the routing through
`compact_of_strongCompleteness` means the two `*_refuted` theorems **no longer mention
`soundness_discrete` / `soundness_dedekind` at all**. That retires both `haveI : DenselyOrdered
F.Duration := hd` lines in `DedekindNonCompactness.lean` (`:441`, `:462`) — they exist only to feed
`soundness_dedekind`'s instance binder — and the whole `rintro ⟨F, ⟨_,_,_,_⟩, M, τ, hτ, t, hsat⟩`
bare-instance-binder discipline at `DiscreteNonCompactness.lean:288`. B-21's case (c) disappears
outright rather than being helped.

### 4.1 B-20 — the `dedWitness_core` split (VERIFIED)

Both extracted lemmas compile, and `dedWitness_core` rebuilt on top of them is **15 lines**, down
from 51, with the same clean axiom profile:

```lean
theorem qAlpha_step (q : Atom) (M : TaskModel F) (τ : WorldHistory F) (a : F.Duration)
    (ha : ∀ n, TruthAt M τ a (qAlpha q n)) :
    ∃ s, a < s ∧ TruthAt M τ s (Formula.atom q) ∧ (∀ n, TruthAt M τ s (qAlpha q n))

theorem exists_strictMono_qPoints (q : Atom) (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (ht : ∀ n, TruthAt M τ t (qAlpha q n)) :
    ∃ ch : ℕ → F.Duration, StrictMono ch ∧ t < ch 0 ∧
      ∀ n, TruthAt M τ (ch n) (Formula.atom q)
```

**The `t < ch 0` conjunct is not optional.** `dedWitness_core`'s `htz : t < z` step
(`DedekindNonCompactness.lean:250`) is `lt_of_lt_of_le (hc 0).1 (hz.1 ⟨0, rfl⟩)`, i.e. it consumes
exactly this fact. A chain lemma stating only `StrictMono ch ∧ ∀ n, TruthAt … (Formula.atom q)`
does not suffice and the caller cannot recover it. The review's proposed signature omits it.

### 4.2 B-21 — the `@[simp]` membership lemmas (VERIFIED)

```lean
@[simp] theorem mem_archWitness_iff (p : Atom) (ψ : Formula) :
    ψ ∈ archWitness p ↔
      ψ = (Formula.atom p).someFuture ∨ ∃ n : ℕ, ψ = (Formula.next^[n] (Formula.atom p)).neg := by
  simp [archWitness]

@[simp] theorem mem_dedWitness_iff (q : Atom) (ψ : Formula) :
    ψ ∈ dedWitness q ↔ ψ = qGap q ∨ ψ = qBound q ∨ ∃ n : ℕ, ψ = qAlpha q n := by
  simp [dedWitness, or_assoc]
```

With these, the three witness-extraction sites inside `dedWitness_core` become `h _ (by simp)`
(verified) in place of `by simp [dedWitness]` / `by right; exact ⟨n, rfl⟩`, and the `simp only
[<witness>, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq]` incantation at
`DiscreteNonCompactness.lean:203` and `DedekindNonCompactness.lean:393-394` becomes plain `simp`.

---

## 5. Items 4 and 5 — the two structural changes

### 5.1 Item 4 — `modelExistence_of_satPreserved` (VERIFIED, but not at the review's signature)

**The review's proposed hypothesis shape does not typecheck, and cannot.** It assumes
`fc.Sat F → fc.Sat (ShiftSet.ofModel F M).frame` is definitional. It is not: `ofModel F M` has
`Carrier := F.HF`, so `(ofModel F M).frame` and `F` are genuinely different frames — only their
`Duration`s coincide — and `FrameClass.Sat` is a `match` on the tag, so nothing reduces while `fc`
is a variable. The scratch `example … := h` fails with a type mismatch.

**Fix, verified**: one three-token bridge lemma, then the review's shape works.

```lean
theorem sat_ofModel_frame {fc : FrameClass} {F : TaskFrame} (M : TaskModel F)
    (h : fc.Sat F) : fc.Sat (ShiftSet.ofModel F M).frame := by cases fc <;> exact h
```

(The converse, `sat_frame_of_sat_ofModel`, is the same proof and also compiles; state it if a
consumer appears, not otherwise.) `cases fc` is what makes it go through: at each tag `Sat`
reduces to a `Duration`-only condition, and `(ofModel F M).frame.Duration = F.Duration` by `rfl`
— `ShiftSet.frame`, `ShiftSet.fibre` and `FrameOver.toTaskFrame` are all `@[reducible]`.

Then, verified end to end, with `modelExistenceBase` / `modelExistenceDense` as one-liners whose
axiom profiles are unchanged:

```lean
theorem modelExistence_of_satPreserved {fc : FrameClass}
    (hpres : ∀ {I : Type} (u : Ultrafilter I) (T : I → TemporalOrder) (S : ∀ i, ShiftSet (T i)),
      (∀ i, fc.Sat (S i).frame) → fc.Sat (uShiftSet u S).frame) :
    ModelExistence fc := by
  classical
  intro Γ hfin
  choose F hF M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    hpres (idxUF Γ) _ _ (fun i => sat_ofModel_frame (M i) (hF i)),
    …⟩   -- remaining 10 lines are `modelExistenceBase`'s, verbatim

theorem modelExistenceBase : ModelExistenceBase :=
  modelExistence_of_satPreserved (fun _ _ _ _ => trivial)

theorem modelExistenceDense : ModelExistenceDense :=
  modelExistence_of_satPreserved (fun u T S hS => by
    haveI : ∀ i, DenselyOrdered (T i : Type) := hS
    exact (inferInstance : DenselyOrdered (uShiftSet u S).frame.Duration))
```

**Binder note**: `T` must be **explicit** in `hpres`. With `{T}` implicit, the `S i` projection in
the Dense discharge elaborates `S : I → TemporalOrder` and fails with `Invalid field 'frame' …
TemporalOrder`. `I` may stay implicit.

The docstring this unlocks is the real prize: `hpres` is *false* at `.Discrete` and `.Dedekind`
(ultraproducts of Archimedean orders need not be Archimedean; of Dedekind-complete orders need not
be complete), and `discrete_consequence_not_compact` / `dedekind_consequence_not_compact` are the
machine-checked proof that no route around it exists. That single docstring replaces the
four-module status prose.

### 5.2 Item 5 — `PointedModel` (VERIFIED, and source-compatible)

```lean
structure PointedModel (fc : FrameClass) (Γ : Set Formula) where
  Frame   : TaskFrame
  inClass : fc.Sat Frame
  Model   : TaskModel Frame
  hist    : WorldHistory Frame
  htotal  : hist.IsTotal
  time    : Frame.Duration
  models  : ∀ ψ ∈ Γ, TruthAt Model hist time ψ

def SatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop := Nonempty (PointedModel fc Γ)

def FinitelySatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  ∀ Γ₀ : Finset Formula, ↑Γ₀ ⊆ Γ → SatisfiableSet fc ↑Γ₀

def PointedModel.mono (p : PointedModel fc Δ) (hs : Γ ⊆ Δ) : PointedModel fc Γ :=
  { p with models := fun ψ hψ => p.models ψ (hs hψ) }

theorem SatisfiableSet.mono (h : SatisfiableSet fc Δ) (hs : Γ ⊆ Δ) : SatisfiableSet fc Γ :=
  h.elim fun p => ⟨p.mono hs⟩

theorem SatisfiableSet.finitelySatisfiable (h : SatisfiableSet fc Γ) :
    FinitelySatisfiableSet fc Γ := fun _ hs => h.mono hs
```

`PointedModel.mono` must be a `def`, not a `theorem` — it is data (`PointedModel` lives in `Type`,
not `Prop`). Stating it as `theorem` fails with "type of theorem … is not a proposition".

**The compatibility result.** Both existing idioms survive the definition change verbatim:

```lean
-- flat elimination still works against `Nonempty (PointedModel fc Γ)`
example (h : SatisfiableSet fc Γ) : True := by
  obtain ⟨F, hF, M, τ, hτ, t, hsat⟩ := h; trivial
-- flat introduction still works: `SatisfiableSet.of_forall`'s body is unchanged
example … : SatisfiableSet fc Γ := ⟨F, hF, M, τ, hτ, t, h⟩
```

`rcases` auto-flattens through `Nonempty` plus a single-constructor structure. So all six existing
destructuring sites (`compact_of_modelExistence`, `archWitness_not_satisfiable`,
`dedWitness_not_satisfiable`, the four refutations, `modelExistence{Base,Dense}`'s `refine`)
compile unchanged. The `SatisfiableDiscreteSet` docstring's ten-line warning about anonymous
binders (`SetConsequence.lean:544-553`) becomes obsolete and should be deleted with the change,
since the structure fields now carry the names.

`PointedModel.of` (the G-01 smart constructor) is exactly today's `SatisfiableSet.of_forall`
retyped to return `PointedModel fc Γ`; there is **one** such adapter now, not four — task 523
already collapsed them, so item 5's "the four `*_of_forall` constructors become `PointedModel.of`"
should read "the one `SatisfiableSet.of_forall`".

### 5.3 Item 5 — compactness as an iff with finite satisfiability (VERIFIED)

`ModelExistence` is List-indexed and `FinitelySatisfiableSet` is Finset-indexed; the bridge needs
`classical` and both `List.toFinset` and `Finset.toList`:

```lean
theorem modelExistence_iff_finitelySatisfiable {fc : FrameClass} :
    ModelExistence fc ↔ ∀ Γ : Set Formula, FinitelySatisfiableSet fc Γ → SatisfiableSet fc Γ := by
  classical
  constructor
  · intro h Γ hfs
    refine h Γ (fun L hL => ?_)
    have := hfs L.toFinset (by intro ψ hψ; exact hL ψ (by simpa using hψ))
    simpa using this
  · intro h Γ hfin
    refine h Γ (fun Γ₀ hΓ₀ => ?_)
    exact (hfin Γ₀.toList (fun ψ hψ => hΓ₀ (by simpa using hψ))).mono (by intro ψ hψ; simpa using hψ)

theorem satisfiableSet_iff_finitelySatisfiable {fc : FrameClass} (hme : ModelExistence fc)
    {Γ : Set Formula} : SatisfiableSet fc Γ ↔ FinitelySatisfiableSet fc Γ :=
  ⟨SatisfiableSet.finitelySatisfiable, modelExistence_iff_finitelySatisfiable.mp hme Γ⟩
```

The task states this "given `Compact fc`"; route it through `compact_iff_modelExistence` (§3) so
`Compact fc` and `ModelExistence fc` are interchangeable at the hypothesis slot. One coercion trap:
`(by simpa using hL)` alone fails at `{a | a ∈ L} ⊆ Γ` versus `∀ ψ ∈ L, ψ ∈ Γ`; the explicit
`intro ψ hψ; exact hL ψ (by simpa using hψ)` is what elaborates.

### 5.4 Item 5 — the consequence/satisfiability bridge (VERIFIED)

```lean
theorem setConsequence_iff_not_satisfiable {fc : FrameClass} {Γ : Set Formula} {φ : Formula} :
    SetSemanticConsequenceOn fc Γ φ ↔ ¬ SatisfiableSet fc (Γ ∪ {φ.neg})
```

Both directions compile; the `←` direction needs `by_contra` plus the definitional unfolding of
`TruthAt M τ t φ.neg` to `TruthAt M τ t φ → False` (no `truthAt_neg` lemma exists or is needed —
`compact_of_modelExistence`'s docstring at `StrongCompleteness.lean:389-392` already records why).
`setConsequence_of_not_satisfiable` (§4) is its `mpr` at `Γ ∪ {φ.neg} := Γ`; keep both, and prove
the shorter one from the longer.

---

## 6. Item 7 — the dead-declaration inventory, re-measured

Repo-wide grep excluding `Boneyard/` and the defining file, discounting docstring prose. **Thirteen**
declarations, not fifteen:

| Declaration | `SetConsequence.lean:` | Live consumers |
|---|---|---|
| `SetSemanticConsequenceBase` | 112 | 0 |
| `SetSemanticConsequenceDense` | 116 | 0 |
| `SetSemanticConsequenceOn.apply_total` | 237 | 0 (**but §4 makes it live** — keep) |
| `setDerivable_mono` | 269 | 0 |
| `setSemanticConsequenceOn_mono_fc` | 285 | 0 |
| `setSemanticConsequence{Base,Dense,Discrete,Dedekind}_mono` | 291, 296, 301, 307 | 0 each |
| `setDerivable_of_derivable` | 321 | 0 |
| `derivable_of_setDerivable_contextToSet` | 331 | 0 |
| `setDerivable_of_mem` | 339 | 0 |
| `not_setConsistent_of_setDerivable_bot` | 349 | 0 |

`SetSemanticConsequence{Discrete,Dedekind}` **are** consumed (by the two refutation modules) and
must stay. `setConsequenceOnFrames_mono` (`:277`) and `setDerivable_iff_exists_finite` (`:316`) are
consumed by `soundness_setConsequence` and must stay. `soundness_setConsequence`
(`StrongCompleteness.lean:949`) currently has no consumer other than its own `#print axioms`;
**B-02 makes it load-bearing** as the `Set Formula` half of the `soundness_consequence` pair —
keep it and state the two adjacently.

**The `Core.MaximalConsistent` import can be dropped.** Exactly two live uses remain, both in
declarations on the delete list: `Core.contextToSet` at `:322`/`:332` and `Core.SetConsistent` at
`:350`. Delete those three declarations and the import at `:11` goes with them. Reference at `:46`
is prose and needs rewording, not deletion.

### 6.1 Item 7 — naming (B-18)

Three schemes currently in play: `compactBase : CompactBase` (lowerCamel mirroring the `Prop`),
`discrete_consequence_not_compact : ¬ CompactDiscrete` (snake, class-first), and
`strongCompletenessDiscrete_refuted : ¬ StrongCompletenessDiscrete` (lowerCamel + snake suffix).
**Recommendation: `not<PropName>`** — `notCompactDiscrete`, `notCompactDedekind`,
`notStrongCompletenessDiscrete`, `notStrongCompletenessDedekind` — because it mirrors the positive
form the module already uses (`compactBase : CompactBase`) and keeps the `Prop` name first, so the
four-row table reads off the declaration names. The four current names are cited **only in
docstring prose** (verified by grep: no `.lean` call site outside their defining files), so a
straight rename with no deprecated aliases is safe.

**However**: `discrete_consequence_not_compact` and `dedekind_consequence_not_compact` are named in
`scripts/check-module-invariants.sh`'s C2 baseline candidates and in `Metalogic/README.md` /
`Metalogic.lean` prose. A rename must sweep those in the same commit or C5/C12/C14 will trip.

### 6.2 Item 7 — `#print axioms` (B-23)

44 in territory (`StrongCompleteness` 14, `Compactness` 6, `DiscreteNonCompactness` 12,
`DedekindNonCompactness` 12), 55 tree-wide. **The mechanism is not
`scripts/module-invariants-manifest.txt`** — that file is C6's known-unreachable list. The C2
manifest is a **pair of heredocs inside `scripts/check-module-invariants.sh`**:
`AXIOM_BASELINE` (lines 144-149) and the `AX_SRC` Lean scratch file (155-161), compared by exact
string equality, so *they must list the same declarations in the same order*. C14 has a second
identical pair (`C14_BASELINE` / `C14LEAN`, lines 773-786) whose own comment says "Edit them
together, appending to both."

Recommended split: keep in-file `#print axioms` on the five termini the task names
(`strongCompletenessBase`, `strongCompletenessDense`, `notCompactDiscrete`, `notCompactDedekind`,
`consequence_completeness_dedekind`); append the remaining ~39 to the C2 pair. Also **delete the
two hand-transcribed output blocks** (`DiscreteNonCompactness.lean:300-313`,
`DedekindNonCompactness.lean:472-487`) — the script's baseline is their proper home, and C14's
stale-literal scan already covers `FormalSystem/**/*.lean` docstrings.

---

## 7. Item 8 — the `Conservativity/` directory

C8 (`check-module-invariants.sh:418-448`) scans exactly two parents, `FormalSystem` and
`FormalSystem/Metalogic`, and requires each Lean-bearing subdirectory to have a sibling `X.lean`
and no self-named `X/X.lean`. So the target layout is:

```
Metalogic/Conservativity.lean            -- aggregator; carries today's 231 lines of narrative
Metalogic/Conservativity/Backward.lean   -- today's Conservativity.lean declarations
Metalogic/Conservativity/BaseLanguageSoundness.lean
Metalogic/Conservativity/TMCompletenessReduction.lean
Metalogic/Conservativity/SpWitness.lean
Metalogic/Conservativity/Z1Countermodel.lean
```

**Import discipline is load-bearing here.** Today's chain is
`Conservativity ← BaseLanguageSoundness ← TMCompletenessReduction ← Z1Countermodel`, and
`SpWitness ← BaseLanguageSoundness`. The children must import
`FormalSystem.Metalogic.Conservativity.Backward`, **never** the aggregator
`FormalSystem.Metalogic.Conservativity` — otherwise the aggregator is imported by a file its own
contents reach and the build cycles. The manifest's own header already warns about exactly this
failure mode. `Metalogic.lean` then imports only the aggregator, and its four current lines
(`:17,18,20,21`) collapse to one.

Namespaces need no change: today's body is already `namespace FormalSystem.Metalogic.Conservativity`,
so declarations keep their fully-qualified names when the file moves to `Backward.lean`.

**Cost, measured**: ~60 path citations must be swept in the same commit or C5/C12/C13 fail —
`Metalogic/Conservativity.lean` 20, `Metalogic/BaseLanguageSoundness.lean` 23,
`Metalogic/SpWitness.lean` 7, `Metalogic/Z1Countermodel.lean` 5,
`Metalogic/TMCompletenessReduction.lean` 5; plus the dotted module form
(`FormalSystem.Metalogic.Conservativity` 14, `…BaseLanguageSoundness` 6, three others 1 each).
This is the largest mechanical component of the task and should be its own phase.

### 7.1 B-17 — the wrong carrier and the denied result

Confirmed verbatim at `Conservativity.lean:345-349` ("It says nothing about `TM_f ⊢ Z1`, which is
the half that fails and which needs a BL-side soundness theorem to establish") and `:354-357`
("not a `TM_f` theorem, the latter by soundness over `ℤ ×_lex ℤ` — an argument this repository
cannot yet formalize"). Both are contradicted by the same file at `:70-79` (the carrier is
`ℚ ×_lex ℤ`, "**not** `ℤ ×_lex ℤ` as an earlier draft … suggested") and `:159-166` ("**Both are
now landed**"). The result denied at `:354` is `Z1Countermodel.not_bl_derivable_z1`
(`Z1Countermodel.lean:175`), with `tmCompleteDiscrete_refuted` at `:199`. Rewrite both passages to
point at those two names.

---

## 8. Item 6 — `TMComplete` / `Forward` generic (VERIFIED; needs **no** bridge hypothesis)

B-22 proposes `tmComplete_iff_forward` with a `bridge : ∀ φ, BLValidIn fc φ ↔ ValidIn fc (tr φ)`
hypothesis and asks whether `BLValidity.lean` indexes over `FrameClass`. **It does**, and the
bridge is already a theorem: `BLValidIn` at `BLValidity.lean:107`, and
`blValidIn_iff_validIn_tr (fc) (φ)` at `BaseLanguageSoundness.lean:177`. So the hypothesis is
`WeakCompleteness fc` alone. Verified:

```lean
def TMComplete (fc : FrameClass) : Prop :=
  ∀ φ : BLFormula, BLValidIn fc φ → BaseLanguage.Derivable fc [] φ
def Forward (fc : FrameClass) : Prop :=
  ∀ φ : BLFormula, ProofSystem.Derivable fc [] (tr φ) → BaseLanguage.Derivable fc [] φ

theorem tmComplete_iff_forward {fc : FrameClass} (engine : WeakCompleteness fc) :
    TMComplete fc ↔ Forward fc := by
  constructor
  · intro hcomplete φ h
    exact hcomplete φ ((blValidIn_iff_validIn_tr fc φ).mpr (h.elim fun d => soundness_validIn d))
  · intro hforward φ hvalid
    exact hforward φ (engine (tr φ) ((blValidIn_iff_validIn_tr fc φ).mp hvalid))
```

All four existing names are `Iff.rfl`-level instantiations (verified):
`TMCompleteBase ↔ TMComplete .Base`, `ForwardBase ↔ Forward .Base`, and the Discrete pair. The two
existing theorems become

```lean
theorem tmCompleteBase_iff_forwardBase : TMCompleteBase ↔ ForwardBase :=
  tmComplete_iff_forward (fc := FrameClass.Base) completeness_base
theorem tmCompleteDiscrete_iff_forwardDiscrete : TMCompleteDiscrete ↔ ForwardDiscrete :=
  tmComplete_iff_forward (fc := FrameClass.Discrete) completeness_discrete
```

and the Dense and Dedekind rows come for free (verified, clean axioms) —
`tmComplete_iff_forward completeness_dense` / `… completeness_dedekind`. **This does not
weaken the module's "unasserted `def`, never a theorem conclusion" prohibition discipline**
(`TMCompletenessReduction.lean:28-33`): `TMComplete` and `Forward` remain `def`s, and
`tmComplete_iff_forward` concludes an `Iff`, not either side.

Dispatch note: the elaboration requires `open FormalSystem.BaseLanguage` and
`open FormalSystem.Metalogic.Conservativity` in scope (for `BLFormula` and `tr`) — which
`TMCompletenessReduction.lean:71,73` already has.

---

## 9. Constraints and risks a plan must respect

1. **Phase order is forced by three real dependencies**, not preference.
   `WeakCompleteness` (item 1) → `strongCompleteness_iff_compact` (item 2) and
   `tmComplete_iff_forward` (item 6); `not_compact_of_witness` (item 3) →
   `modelExistence_of_compact` (item 2, second half); `compact_of_strongCompleteness` (item 2) →
   `not_strongCompleteness_of_witness` (item 3). Item 2 and item 3 therefore **interleave** and
   cannot be two sequential phases; put `compact_of_strongCompleteness` +
   `setConsequence_of_not_satisfiable` + `not_compact_of_witness` +
   `not_strongCompleteness_of_witness` in one phase and the two iffs in the next.
2. **Home the `sat_ofModel_frame` bridge in `Compactness.lean`, not `Semantics/`.** It is the only
   new declaration in item 4 that would naturally sit in `Semantics/ShiftSet.lean` or
   `Semantics/FrameClassValidity.lean` — both of which are adjacent to task 525's territory
   (`Semantics/Correspondence/`). Keeping it in `Compactness.lean`, where its only consumer lives,
   avoids the contact entirely at zero cost.
3. **Item 5 changes a `def`, so re-verify the axiom profiles.** `SatisfiableSet` becoming
   `Nonempty (PointedModel …)` is definitionally different from the bare `∃`; the call sites
   compile (§5.2) but every terminus downstream of it passes through `Nonempty.elim`. Every profile
   measured during this research stayed `[propext, Classical.choice, Quot.sound]`, but item 5 was
   probed against the *current* definition, so re-run C2/C14 after the swap, not before.
4. **The C2/C14 heredoc pairs are compared by exact string equality including order.** Appending
   ~39 declarations means editing four heredocs consistently. A mismatch produces a "HARD STOP,
   not a new baseline" failure that reads like a real axiom regression.
5. **Stale prose the task does not list, but which this work invalidates**:
   `StrongCompleteness.lean:48-58` still calls Base/Dense strong completeness "the intended
   eventual terminus" and "an open research question", though `strongCompletenessBase` /
   `strongCompletenessDense` are proved in `Compactness.lean:157,164`;
   `Compactness.lean:110-121` explains a type-ascription workaround in terms of `TaskFrame.IsDense`
   being "a plain `def`", which it is not any more (`FrameProperty.lean:97` — `abbrev`);
   `DedekindNonCompactness.lean:415-421,447-449` explain `haveI` lines that item 3 deletes.
   Fold these into item 7's documentation sweep or C14 will keep passing over untrue prose.
6. **Zero sorries throughout.** Nothing in this task requires a deferred obligation: every
   declaration proposed above has been elaborated to completion.

---

## 10. Expected accounting against the acceptance criteria

| Criterion | Status from this research |
|---|---|
| `strongCompleteness_iff_compact` exists | Verified constructible (§3) |
| `compact_iff_modelExistence` exists | Verified constructible (§3) |
| Zero per-class copies of the deduction theorem | 4 → 1 + 4 one-liners (§2) |
| Zero per-class copies of the soundness guard | 4 → 1 + 4 one-liners or deletion (§2) |
| Zero per-class copies of the model-existence proof | 2 → 1 + 2 one-liners (§5.1) |
| Zero per-class copies of the refutation skeleton | 4 → 3 generics + 4 one-liners (§4) |
| ~230 lines of per-class instantiation removed | ≈ 44 (deduction) + 12 (soundness) + ≈ 30 (completeness) + 16 (model existence) + ≈ 44 (refutations) + ≈ 36 (`dedWitness_core`) + ≈ 55 (dead decls) ≈ **235**, plus ≈ 100 lines of now-false docstring |
| C2 manifest extended | Mechanism identified (§6.2): four heredocs in `check-module-invariants.sh`, not the C6 manifest file |
| `lake build` green | Every new declaration elaborated clean against the built library |
| `check-module-invariants.sh` ALL PASS | C8 satisfied by the §7 layout; C5/C12/C13 require the ~60-citation sweep in the same commit |

---

## 11. Sources

All VERIFIED by direct read at `b7da18269` unless noted.

**Target repository**
`FormalSystem/Metalogic/{StrongCompleteness,SetConsequence,Compactness,DiscreteNonCompactness,DedekindNonCompactness,Conservativity,TMCompletenessReduction,BaseLanguageSoundness,SpWitness,Z1Countermodel,Soundness}.lean`;
`FormalSystem/Metalogic.lean`; `FormalSystem/Semantics/{Validity,BLValidity,FrameProperty,FrameClassValidity,ShiftSet,TaskFrame}.lean`;
`FormalSystem/Semantics/Ultraproduct/{Carrier,IndexFilter,Los,ShiftSetProduct}.lean`;
`FormalSystem/Metalogic/BXCanonical/{Completeness,CompletenessDedekind}.lean`;
`FormalSystem/Metalogic/Core/MaximalConsistent.lean`; `scripts/check-module-invariants.sh`;
`scripts/module-invariants-manifest.txt`.

**Review artifacts**
`specs/reviews/2026-09-01-lean-engineering/B-completeness.md` (§1, §2, B-01…B-10, B-17…B-23, §4);
`…/A-soundness.md` (A-05); `…/G-ecosystem.md` (§2.1, §2.2, G-01, G-02, G-03).

**Elaboration probes** (scratch files, outside the repo tree, `lake env lean`, all clean)
`probe1` items 1 + the four `WeakCompleteness` witnesses; `probe2` item 2 + item 3 + the four
one-line refutations + `¬ModelExistenceDedekind`; `probe3b`/`probe3c` `sat_ofModel_frame` +
`modelExistence_of_satPreserved` + both instantiations; `probe4b` `PointedModel` +
compatibility of both flat idioms + `setConsequence_iff_not_satisfiable`; `probe5` item 6 + the
four `Iff.rfl` instantiations + the two new rows; `probe6` `FinitelySatisfiableSet` and the
List/Finset bridge; `probe7` `mem_{arch,ded}Witness_iff` + `qAlpha_step` +
`exists_strictMono_qPoints` + `dedWitness_core` rebuilt at 15 lines.
