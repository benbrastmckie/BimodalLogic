# Research: frame-property representation and validity names

**Task**: 522 — WAVE 2 (core utilities)
**Findings covered**: A-04, A-07, A-15, A-16, C-08, C-09, C-10, D-20, G-05
**Method**: measurement by comment- and string-aware census over `FormalSystem/**` + `Tests/**`
(`Boneyard/` excluded), plus **eleven machine-checked Lean experiments** elaborated against the
warm build with `lake env lean` on a throwaway root file (created, run, deleted — the tree is
unmodified; `git status` shows only `specs/`).

---

## 0. Executive summary

The mechanism A-04 diagnoses is **real and reproduced**, but its prescription is wrong in two
places and its acceptance arithmetic is not achievable as stated. Four load-bearing corrections:

1. **`abbrev TaskFrame.IsDense` alone does nothing.** `FrameClass.Sat` is a non-reducible `def`
   sitting *above* `IsDense`, and it blocks instance-cache registration exactly as a `def IsDense`
   does. Both must become reducible together. Machine-checked in §2.1 (E1d fails, E2a passes).
2. **The recommended `structure TaskFrame.IsSuccArchDiscrete (F) : Prop where [succ : SuccOrder …]`
   does not compile.** Lean rejects it: *"failed to generate projection … for the 'Prop'-valued
   type, field must be a proof."* `SuccOrder` is `Type`-valued. §2.2 gives the two forms that do
   work, and shows the **existing existential already suffices** once `Sat` is reducible — the
   `IsSuccArchDiscrete` definition need not change at all.
3. **`47 → 2 (+2 BL)` is not reachable.** The 47 span *three* families (validity, finite-context
   consequence, set consequence) with three different carriers; the bare-predicate layer
   (`ValidOnFrames`, which `ValidComplete` lives at and no tag denotes) needs its own generic
   triple. The defensible, measured target is **47 → 12, all generic**, laid out in §3.4, plus a
   bonus `SatisfiableSet` 4 → 1 that the 47 never counted.
4. **The task's measured state is partly stale** (it predates tasks 519/521). Line anchors in
   `Validity.lean` are off by ~+15; `DenseValidity.lean` is already deleted; D-20's "231
   intro-chains in ~44 spellings" is now **148 in 31 spellings**; A-15's "~200 occurrences of
   `valid`" is **106 code-only, of which ~18 are an unrelated `FormulaLabel.valid`**; the "nine
   warnings across six files" is **15 sites across 11 files**. Fresh numbers throughout below.

Everything else in the work list is confirmed feasible and most of it is already proved in Lean
here: the `sat_intro` macro (both a reducible-`Sat` version and a fallback that needs no
reducibility change), the C-10 bridge and eliminator, `ValidComplete.of_not`, the four generic
consequence adapters, the two BL transfer theorems, and both prose implications of work item (6).

**Zero-debt note**: no step below requires `sorry`, and none introduces an axiom. Every proposed
declaration in this report was elaborated to completion.

---

## 1. Corrected measured state

### 1.1 Stale anchors in the task description

`Validity.lean` has shifted by roughly +15 lines since the review snapshot (`257cad9b8`). Current
anchors:

| Task says | Actual | Declaration |
|---|---|---|
| `Validity.lean:536-543` | `:553-559` | the `ValidDense.of_forall` rationale docstring |
| `Validity.lean:612-616` | `:627-631` | the "`@`, never `haveI`" paragraph |
| `Validity.lean:711` | **`:726`** | `def ValidDedekind := ValidOnFrames TaskFrame.IsComplete` |
| `Validity.lean:765` | **`:780`** | `def ValidDedekindDense := ValidIn .Dedekind` |
| `Validity.lean:820-824` | `:835-839` | (the `haveI` warning; also at `:627-631`) |
| `Validity.lean:638-648` | **`:658`** | the sole "Read this first" paragraph |
| `FrameProperty.lean:71 / :118` | **confirmed exact** | `IsDense` / `IsSuccArchDiscrete` |
| `TaskFrame.lean:836-842` | **`:815-821`** | the prose implications of work item (6) |

`FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` **no longer exists** (deleted by task
519); the directory now holds `CoValidity.lean`, `FrameClassVariants.lean`, `Separability.lean`,
`README.md`. Every A-15/D-20 count anchored on it is stale.

### 1.2 The 47 adapters, by family and by carrier

A-04's list of 47 is accurate as a *count* but conflates three layers:

| File | Count | Carrier | Generic form available? |
|---|---|---|---|
| `Semantics/Validity.lean` | 21 | `ValidOnFrames` / `ValidIn` / `SemanticConsequence` | partly (`ValidOnFrames.*_total`, `ValidIn.*_total`, `ValidIn.of_not` exist) |
| `Semantics/BLValidity.lean` | 12 | `BLValidOnFrames` / `BLValidIn` | partly (`BLValidOnFrames.*_total`, `BLValidIn.*_total` exist) |
| `Metalogic/StrongCompleteness.lean` | 6 | `SemanticConsequenceIn` (finite context) | **no generic pair exists** |
| `Metalogic/SetConsequence.lean` | 8 | `SetSemanticConsequenceOn` (set premises) | **no generic pair exists** |

Not counted in the 47, but the same boilerplate and the *dual* (introduction-into-`Sat`)
direction: `SatisfiableSet.{base,dense,discrete,dedekind}_of_forall`
(`SetConsequence.lean:301,307,317,327`) — 4 more.

The 21 in `Validity.lean` break down as: `SemanticConsequence` ×2 (`:140,:147`), `valid` ×3
(`:403,:411,:420`), `ValidOnFrames` ×2 (`:496,:503`), `ValidIn` ×3 (`:509,:516,:529`),
`ValidDense` ×3 (`:560,:567,:576`), `ValidDiscrete` ×3 (`:633,:643,:651`), `ValidDedekind` ×2
(`:731,:740`, no `.of_not` — C-09), `ValidDedekindDense` ×3 (`:785,:794,:802`).

### 1.3 Call-site load (what the deletion actually costs)

Per-file uses of the **class-specific** adapters, excluding the defining files:

```
11  Metalogic/Soundness.lean                        3  Metalogic/BaseLanguageSoundness.lean
 4  Metalogic/SoundnessLemmas/FrameClassVariants    2  Metalogic/SoundnessLemmas/CoValidity.lean
 3  Metalogic/StrongCompleteness.lean               2  Metalogic/DedekindNonCompactness.lean
 2  Metalogic/Decidability/Verified/Decidable.lean  2  Metalogic/BXCanonical/Completeness.lean
 1 each: Semantics/IntTransfer, Metalogic/SetConsequence, Metalogic/DiscreteNonCompactness,
         Metalogic/BXCanonical/CompletenessDedekind
```
≈ **34 external call sites**. The **generic** adapters are used 50× in `Soundness.lean`, 37× in
`FrameClassVariants.lean`, 3× in `StrongCompleteness.lean`, and once each in
`TMCompletenessReduction.lean` / `Decidability/Correctness.lean` — those sites do not change.
Consequence-adapter call sites: 12 in `StrongCompleteness.lean`, 9 in `SetConsequence.lean`, 2 in
`DedekindNonCompactness.lean`, 2 in `DiscreteNonCompactness.lean`, 1 in `Compactness.lean`.

This is a ~60-site mechanical migration, not a ~250-site one. It is one commit with the build as
oracle, as A-04 says — but it must be a **detached, guarded** `lake build`
(`context/project/lean4/operations/long-builds.md`), because `FrameProperty.lean` and
`FrameClassValidity.lean` sit under ~27 downstream consumers.

---

## 2. The representation fix, machine-checked

All experiments below were elaborated with `timeout 550 lake env lean Scratch522A.lean` from the
repo root against the warm `.lake/build`. "PASS" means zero errors.

### 2.1 `IsDense`: `abbrev` is necessary but **not sufficient**

| # | Setup | Result |
|---|---|---|
| E1a | `def IsDenseDef F := DenselyOrdered F.Duration`; `(h : IsDenseDef F) ⊢ exists_between` | **FAIL** — `failed to synthesize DenselyOrdered F.Duration.carrier` |
| E1b | `abbrev IsDenseA`; term binder `(h : IsDenseA F)` | PASS |
| E1c | `abbrev IsDenseA`; tactic `intro F hF` | PASS |
| E1d | `def SatLike F := IsDenseA F` (abbrev **under** a plain `def`) | **FAIL** — same error |
| E2a | `@[reducible] def SatR : FrameClass → TaskFrame → Prop` matching to `IsDenseA` | PASS |

**Conclusion.** Instance-cache registration happens at `intro`, via `isClass?`, which whnfs at
*reducible* transparency. A single non-reducible `def` anywhere in the chain
`Sat .Dense F ⇝ IsDense F ⇝ DenselyOrdered ↑F.Duration` blocks it. So work item (1) must be:

```lean
abbrev TaskFrame.IsDense (F : TaskFrame) : Prop := DenselyOrdered F.Duration   -- FrameProperty.lean:71
@[reducible] def FrameClass.Sat : FrameClass → TaskFrame → Prop := …           -- FrameClassValidity.lean:110
```

`IsComplete` and `IsDedekind` **do not** need to change: verified (§2.4) that with `IsDedekind`
left a plain `def` over an `abbrev IsDense`, `obtain ⟨_, hF⟩ := hF` still lands the density
instance in the cache, because `rcases` whnfs at *default* transparency.

**Reducible-`Sat` risk check (PASS).** `FrameClass.Sat.anti`'s 16-case proof — including the
`exact absurd h (by decide)` branch and `TaskFrame.isDense_of_isDedekind` — recompiles verbatim
against a `@[reducible]` copy, and the set-comprehension shape used by the Independence witnesses
(`{F | FrameClass.Sat FrameClass.Dedekind F}`, `RationalWitness.lean:163`,
`LexIntWitness.lean:163`) still accepts a bare `IsDedekind` proof. `Sat` is referenced 77× tree-wide,
almost entirely as a term; no `simp [FrameClass.Sat]` or `unfold FrameClass.Sat` site exists.

### 2.2 `IsSuccArchDiscrete`: the recommended `structure` **does not compile**

Verbatim from A-04 / the task's work item (1):

```lean
structure TaskFrame.IsSuccArchDiscrete (F : TaskFrame) : Prop where
  [succ : SuccOrder F.Duration] [pred : PredOrder F.Duration]
  [succArch : IsSuccArchimedean F.Duration] [predArch : IsPredArchimedean F.Duration]
```

Lean 4 rejects this:

```
error: failed to generate projection `IsSuccArchDiscreteS.succ` for the 'Prop'-valued type
`IsSuccArchDiscreteS`, field must be a proof, but it has type
  SuccOrder F.Duration.carrier
```

`SuccOrder α : Type`, so a `Prop`-valued structure cannot project it — the same reason `Nonempty`
has no `.val` projection. A-04's parenthetical *"the projections are still `instance`s"* is
therefore false. Two forms do work:

**(a) No change at all — recommended.** With `Sat` reducible, `obtain ⟨_, _, _, _⟩ := hF` on the
**existing** existential puts all four witnesses in the local instance cache, and a four-instance
consumer lemma then elaborates with *no* positional `@`-application:

```lean
theorem consumer (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
    [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration]
    (x : F.Duration) : Order.pred (Order.succ x) ≤ Order.succ x := Order.pred_le _

example : ∀ (F : TaskFrame), SatR .Discrete F → ∀ x : F.Duration, True := by
  intro F hF x; obtain ⟨_, _, _, _⟩ := hF; have := consumer F x; trivial   -- PASS (E6′)
```

**(b) `inductive`, not `structure` — if a named, symmetric form is wanted.** This compiles and
gains anonymous-constructor *introduction* as well as destructuring:

```lean
inductive TaskFrame.IsSuccArchDiscrete (F : TaskFrame) : Prop where
  | mk [succ : SuccOrder F.Duration] [pred : PredOrder F.Duration]
       [succArch : IsSuccArchimedean F.Duration] [predArch : IsPredArchimedean F.Duration]
```
`obtain ⟨⟩ := hF` PASSes; `example (F) [SuccOrder …] [PredOrder …] [IsSuccArchimedean …]
[IsPredArchimedean …] : IsSuccArchDiscrete F := ⟨⟩` PASSes (E7′, E8′). It has **no projections**
either — that is a hard Lean constraint, not a choice — so the `FrameProperty.lean` docstring must
record *why* (`Prop` + `Type` fields ⇒ no projections) rather than promising named accessors.

**Recommendation**: take (a). It is strictly less risk, it satisfies every downstream need, and
it leaves the definition of record byte-identical to the paper transcription. Take (b) only if the
plan also wants `⟨⟩`-introduction; note it changes a `def:TMplus-f`-citing definition.

### 2.3 The "`@`, never `haveI`" trap is real — and I reproduced its exact mechanism

`Validity.lean:627-631` and `:835-839` warn that routing the discrete witnesses through the
instance cache "would break definitional equality". The precise mechanism, reproduced:

```lean
obtain ⟨so, po, hsa, hpa⟩ := hF
have _t1 : SuccOrder F.Duration := inferInstance      -- opaque fvar, shadows `so`
have _t3 : IsSuccArchimedean F.Duration := inferInstance
-- FAIL: failed to synthesize IsSuccArchimedean F.Duration.carrier
```

`IsSuccArchimedean α [Preorder α] [SuccOrder α]` is *indexed by* the `SuccOrder` instance. Once a
fresh opaque `_t1 : SuccOrder F.Duration` becomes the most recent local instance, the elaborated
type `@IsSuccArchimedean _ _ _t1` no longer matches the obtained `hsa : @IsSuccArchimedean _ _ so`.

**This is a hard constraint on the `sat_intro` macro**: it must destructure with `obtain` and must
**never** re-introduce an instance with `have`/`haveI`/`letI` *for the Discrete case*. (For Dense
it is safe, because `DenselyOrdered α [Preorder α]` carries no data-instance index — see Plan B.)

### 2.4 `sat_intro`, both versions, PASS at all four tags

**Plan A (with `@[reducible] Sat` + `abbrev IsDense`)** — the version the task asks for:

```lean
/-- Discharge an `fc.Sat F` hypothesis into the instance cache, uniformly in `fc`. -/
macro "sat_intro " h:ident : tactic =>
  `(tactic| first
      | obtain ⟨_, _, _, _⟩ := $h        -- .Discrete: four witnesses into the cache
      | obtain ⟨_, $h:ident⟩ := $h        -- .Dedekind: density cached, completeness kept as `$h`
      | skip)                             -- .Base (True) and .Dense (already an instance)
```

Verified at every tag against the real `TaskFrame`/`TruthAt`/`FrameClass` (a faithful
`ValidInR`/`SatR` mock, since the real defs could not be edited):

| Tag | Site shape | Result |
|---|---|---|
| `.Discrete` | full `seriality_future_valid` body, `NoMaxOrder`+`exists_gt`, unchanged | PASS |
| `.Dense` | `exists_between` reachable | PASS (with a note, below) |
| `.Dedekind` | `exists_between` **and** the LUB hypothesis under the caller's own name | PASS |
| `.Base` | no-op | PASS |

Two design points the A-04 sketch gets wrong, both fixed above:
- A-04's first alternative is `clear $h`. **`clear` succeeds on any unused hypothesis**, so it
  would fire at `.Discrete` and `.Dedekind` too, silently discarding the frame condition. Drop it.
- Passing the caller's own `$h` back as the `.Dedekind` binder name is what keeps the completeness
  hypothesis *accessible* — macro hygiene would hide a macro-invented name.

**Known cosmetic cost**: at `.Dense` (and `.Base`) the `skip` branch fires and Lean's
`linter.unusedTactic` reports *"'sat_intro hF' tactic does nothing"*. Either omit `sat_intro` at
those sites (loses uniformity) or add `set_option linter.unusedTactic false` locally. Flag this in
the plan; it will otherwise appear as ~15 new warnings.

**Plan B (fallback — `Sat` stays non-reducible)**, in case the full build shows a regression from
making `Sat` reducible. All four tags PASS with:

```lean
macro "sat_intro " h:ident : tactic =>
  `(tactic| first
      | obtain ⟨_, _, _, _⟩ := $h
      | obtain ⟨_, $h:ident⟩ := $h
      | (haveI : DenselyOrdered _ := $h)
      | skip)
```
Only `abbrev IsDense` is then required (for the `.Dedekind` branch). `haveI` is safe **here and
only here** — `DenselyOrdered` has no data-instance index, so §2.3's trap does not apply.

### 2.5 C-10: the bridge and its eliminator — both PASS at the existing definition

```lean
theorem TaskFrame.isSuccArchDiscrete_of_instances (F : TaskFrame) [SuccOrder F.Duration]
    [PredOrder F.Duration] [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] :
    F.IsSuccArchDiscrete := ⟨_, _, ‹_›, ‹_›⟩

theorem TaskFrame.IsSuccArchDiscrete.elim {F : TaskFrame} {p : Prop} (h : F.IsSuccArchDiscrete)
    (k : ∀ [SuccOrder F.Duration] [PredOrder F.Duration] [IsSuccArchimedean F.Duration]
          [IsPredArchimedean F.Duration], p) : p := by
  obtain ⟨_, _, _, _⟩ := h; exact k
```

Both elaborate with no change to `IsSuccArchDiscrete`. The bridge subsumes
`SatisfiableSet.discrete_of_forall`'s inner `⟨so, po, hsa, hpa⟩`.

### 2.6 Work item (6): both prose implications machine-check as one-liners

`TaskFrame.lean:815-821` asserts in prose that the `TemporalOrder` bundle implies `NoMaxOrder` by
instance search, and that the discrete bundle subsumes `[SuccOrder]`+`[NoMaxOrder]`. Both are true
and each is a one-line `example` (all PASS):

```lean
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    NoMaxOrder D := inferInstance
example (F : TaskFrame) : NoMaxOrder F.Duration := inferInstance
example (F : TaskFrame) : NoMinOrder F.Duration := inferInstance
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] :
    NoMaxOrder D := inferInstance
```

Place them in `Semantics/DurationClassification.lean` beside `noMaxOrder_of_duration`'s pointer, as
C-10 recommends. The two frame-level ones are a free bonus and are worth keeping: they pin that
`NoMaxOrder`/`NoMinOrder` never need to be *hypotheses* at a `TaskFrame`.

### 2.7 G-05 conflict, resolved

G-05 recommends `TaskFrame.IsDense`/`IsDiscrete`/`IsDedekind` as **classes** with
`instance [F.IsDedekind] : F.IsDense`. That is incompatible with the C-frames §2 design
constraint the task restates, and §2.2 above shows why the strong form is impossible:
`IsSuccArchDiscrete` carries `Type`-valued data and admits neither class-hood nor projections.

**Resolution to record in the plan**: G-05's *goal* — "instance resolution carries the
inclusion" — is achieved by the narrow fix. Once `IsDense` is an `abbrev` and `Sat` is reducible,
`Sat .Dense F` and `Sat .Dedekind F`'s left conjunct both feed instance search directly, which is
the whole of what G-05's `instance [F.IsDedekind] : F.IsDense` would buy at the Dense/Dedekind
seam. G-05's further claim that "the eight `by decide` regression examples then become redundant"
is **not** adopted: `FrameClass.Sat.anti`'s `decide` branch is verified above to still be required
and still cheap. Treat G-05 as *partially adopted, deliberately*, and say so once.

---

## 3. Adapter arithmetic: the acceptance criterion needs restating

### 3.1 The generic consequence adapters do not exist yet — but are trivial (PASS)

The 14 consequence adapters in `StrongCompleteness.lean` (6) and `SetConsequence.lean` (8) have no
generic counterpart to delegate to. Both generic definitions already exist
(`SemanticConsequenceIn`, `Validity.lean:92`; `SetSemanticConsequenceOn`,
`SetConsequence.lean:107`); only the adapters are missing. All four elaborate as `:= h` /
direct application:

```lean
theorem SemanticConsequenceIn.of_forall_total {fc : FrameClass} {Γ : Context} {φ : Formula}
    (h : ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SemanticConsequenceIn fc Γ φ := h
theorem SemanticConsequenceIn.apply_total  … := h F hF M τ hτ t hΓ
theorem SetSemanticConsequenceOn.of_forall_total … := h
theorem SetSemanticConsequenceOn.apply_total  … := h F hF M τ hτ t hΓ
```
That the bodies are `h` is the proof that all 14 class-specific ones are pure boilerplate.

The four `SatisfiableSet.*_of_forall` likewise collapse to one (PASS):
```lean
theorem SatisfiableSet.of_forall {fc : FrameClass} {Γ : Set Formula} (F : TaskFrame)
    (hF : fc.Sat F) (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : SatisfiableSet fc Γ := ⟨F, hF, M, τ, hτ, t, h⟩
```

### 3.2 C-09's missing `.of_not` — and a way to not need it

`ValidComplete.of_not` is three lines and PASSes:

```lean
theorem ValidComplete.of_not {φ : Formula} (h : ¬ ValidComplete φ) :
    ¬ ∀ (F : TaskFrame), TaskFrame.IsComplete F → ∀ (M : TaskModel F) (τ : WorldHistory F),
        τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidComplete.of_forall h')
```

**Better**: add a generic `ValidOnFrames.of_not {P : TaskFrame → Prop}` (identical body, `P` for
`IsComplete`). Then `ValidComplete`'s whole triple *is* the `ValidOnFrames` triple at `IsComplete`,
C-09 is satisfied with **zero** new class-specific declarations, and the "`ValidComplete` is
visibly outside the `ValidIn` family" claim of C-08 becomes a fact about which generic lemma you
reach for rather than a docstring.

### 3.3 Why `47 → 2 (+2 BL)` cannot hold

Three independent reasons:

1. **`ValidComplete` is not at a tag.** It is `ValidOnFrames TaskFrame.IsComplete`. `ValidIn`'s
   adapters cannot serve it. The `ValidOnFrames` layer needs its own generic triple — as does the
   BL side, confirmed independently: `BLValidOnFrames.mono` is indexed by a bare
   `P : TaskFrame → Prop` and is **not** derivable from a `FrameClass`-indexed transfer theorem
   (§4).
2. **Three carriers, not one.** Validity, finite-context consequence, and set consequence are
   three distinct `Prop` shapes; a generic adapter for one does not typecheck against another.
3. **`.of_not` is the countermodel interface** and is genuinely used (`ValidIn.of_not` ×2,
   `ValidDense.of_not` ×4, `ValidDedekindDense.of_not`, `ValidDiscrete.of_not`,
   `valid.of_not`). Dropping the generic `.of_not` from either layer forces countermodel sites to
   open definitions by hand — the very thing `Validity.lean:521-528` says the family exists to
   prevent.

### 3.4 The corrected target

| Layer | Now | After | Kept |
|---|---|---|---|
| `Validity.lean` validity | 21 | **6** | `ValidOnFrames.{of_forall_total, apply_total, of_not}` + `ValidIn.{of_forall_total, apply_total, of_not}` |
| `BLValidity.lean` | 12 | **4** | `BLValidOnFrames.{of_forall_total, apply_total}` + `BLValidIn.{of_forall_total, apply_total}` (add `.of_not` twins only if a BL countermodel site needs them — none does today) |
| `StrongCompleteness.lean` consequence | 6 | **0** | replaced by `SemanticConsequenceIn.{of_forall_total, apply_total}` in `Validity.lean` |
| `SetConsequence.lean` consequence | 8 | **2** | `SetSemanticConsequenceOn.{of_forall_total, apply_total}` |
| **Subtotal (the 47)** | **47** | **12** | all generic, all `fc`- or `P`-indexed |
| `SatisfiableSet.*_of_forall` (bonus) | 4 | **1** | `SatisfiableSet.of_forall` |

**Proposed acceptance replacement**: *"binder adapters 47 → 12, and every surviving adapter is
indexed by `fc : FrameClass` or `P : TaskFrame → Prop` — zero adapters mention a literal tag;
`SatisfiableSet` 4 → 1."* Add: *"`grep -E '\.(of_forall|apply|of_not)\b' | grep -E
'Valid(Dense|Discrete|Dedekind)|SemanticConsequence(Dense|Discrete|Dedekind)|SetSemanticConsequence(Base|Dense|Discrete|Dedekind)'`
returns nothing."* That is checkable and honest; `47 → 2` is not.

---

## 4. BL transfer theorem (A-07) — feasible; needs **two** theorems, not one

Verified by elaboration. `BaseLanguageSoundness.lean` already imports both
`Semantics.BLValidity` and (transitively) `Semantics.Validity`, so placement is free.

**The two theorems (both PASS):**

```lean
theorem blValidIn_iff_validIn_tr (fc : FrameClass) (φ : BLFormula) :
    BLValidIn fc φ ↔ ValidIn fc (tr φ) := by
  constructor
  · intro h F hF M τ x; exact (truthAt_tr M φ τ.val x).mpr (h F hF M τ x)
  · intro h F hF M τ x; exact (truthAt_tr M φ τ.val x).mp  (h F hF M τ x)

theorem blValidOnFrames_iff_validOnFrames_tr (P : TaskFrame → Prop) (φ : BLFormula) :
    BLValidOnFrames P φ ↔ ValidOnFrames P (tr φ)     -- same two-line proof
```

The second is **required**, not optional: `BLValidOnFrames.mono` quantifies over a bare
`P : TaskFrame → Prop`, which for arbitrary `P` is no tag's `Sat` — the same asymmetry that makes
`ValidComplete` sit outside the `ValidIn` family. This mirrors `Validity.lean`'s own
`ValidOnFrames.mono` / `ValidIn.mono` split; it is not an extra cost of the transfer approach.

**Corollary yield (verified):**

| Target | Derives? | How |
|---|---|---|
| `BLValidIn.mono` | yes | `rw [blValidIn_iff_validIn_tr] at hv ⊢; exact ValidIn.mono h hv` |
| `BLValidOnFrames.mono` | yes, **from the second theorem** | `rw [blValidOnFrames_iff_validOnFrames_tr] at hP ⊢; exact ValidOnFrames.mono h hP` |
| `blValid_implies_blValidDense` / `…Discrete` / `…DedekindDense` | yes | `rw [BLValidX, blValidIn_iff_validIn_tr] …; exact ValidIn.mono (FrameClass.base_le _) h` |
| `blValid_iff_valid_tr` (`:147`) | yes | the `.Base` instance |
| `blValidDiscrete_iff_validDiscrete_tr` (`:167`) | yes | the `.Discrete` instance |
| `blValid_iff_empty_consequence` | **no** | `BLSemanticConsequence` is an orthogonal `Prop` shape (unbundled `τ`, no `FrameClass`, no `tr`); its existing short proof off `BLValid.of_forall_total` stays |
| `BLValidity.blValid_implies_blValidDiscreteSucc` | **no** | `BLValidDiscreteSucc` is *not* any `BLValidIn` — no `Sat` variant bundles just `SuccOrder`+`PredOrder` (`BLValidity.lean:256`) |

**Net**: 5 of `BLValidity.lean`'s 20 theorems become one-line corollaries; the file is 352 lines,
9 `def`s + 20 theorems. The remaining 15 are the binder adapters (going away under §3.4 anyway),
the `BLValidDiscreteSucc` layer, and the consequence lemma.

**The A-07 sub-claim about `BLSchemaValidity` is half wrong — correct it in the plan:**

- `dn_valid_of_denselyOrdered` (`:99`) **is** `density_valid` transported: verified
  `tr (φ.allFuture.allFuture.imp φ.allFuture) = ((tr φ).allFuture.allFuture).imp (tr φ).allFuture`
  by `rfl`, since `tr_imp`/`tr_allFuture` are both `rfl`. Safe to derive.
- `df_valid_of_succOrder` / `df_valid_of_isLeast_pos` are **not** `discreteness_forward_valid`
  transported. `rfl` fails: `tr φ.someFuture = (Formula.allFuture (tr φ).neg).neg`, which is a
  *different constructor tree* from `Formula.someFuture (tr φ)`. Both DF shapes mention
  `someFuture`. This is the already-documented "`tr` is exact only on `□, G, H, →, ⊥`" boundary
  (`Translation.lean` module docstring; `tr_someFuture_ne`), now with a compiled counterexample.
  **Do not attempt to delete these two.**

**Preserved**: the BL-native `example`s at `BaseLanguageSoundness.lean:489-503` (TK, T4, MT proved
directly against `BLTruthAt`) exist precisely to guard against `BLTruthAt` being redefined as
`TruthAt ∘ tr`. The transfer theorems are corollaries of the *theorem* `truthAt_tr`, not of a
definitional identity, so those examples remain load-bearing and unweakened. Keep them, and keep
the BL-native definitions, exactly as the task says.

---

## 5. The rename (C-08 / A-16) — larger and more hazardous than described

### 5.1 Scope, measured

Code-only (comments and string literals stripped) occurrences:

| Identifier | code-only | total incl. docs |
|---|---|---|
| `ValidDedekindDense` | 34 | 134, in **25 files** |
| `ValidDedekind` (bare) | 8 | 55 |
| `BLValidDedekindDense` | — | 16, in 4 files |

Dependent identifiers that must move with them (declaration sites):
`ValidDedekind.of_forall`, `ValidDedekind.apply`, `validDedekind_iff_validOnFrames_isComplete`,
`valid_implies_validDedekind`, `validDedekindDense_of_validDedekind`;
`ValidDedekindDense.{of_forall, apply, of_not}`, `validDedekindDense_iff_validIn_dedekind`,
`valid_implies_validDedekindDense`, `isValid_validDedekindDense`,
`not_validDedekindDense_of_hasOpen`; `BLValidDedekindDense.{of_forall, apply}`,
`blValid_implies_blValidDedekindDense`.

### 5.2 Two hazards that will bite a naive `sed`

**Hazard 1 — the `Dedekind` word is heavily overloaded.** 118 declared identifiers contain
`Dedekind`; the overwhelming majority are the **canonical-model order-completion family**, wholly
unrelated: `HasDedekindINF`/`HasDedekindSUP`, `HasFaithfulDedekind*`, `HasGuardedDedekind*`,
`HasDenseDedekind*` and ~50 `.to*` bridges, plus `carrierDedekind`, `layerReynoldsDedekind`,
`orderIsoRealOfDedekindDenseSeparable`, `prop42_*_dedekind`. **A substring replace on `Dedekind`
would corrupt the canonical layer.** The rename must be identifier-exact.

**Hazard 2 — ordering.** Do `ValidDedekind → ValidComplete` **first**, then
`ValidDedekindDense → ValidDedekind`. Word-boundary anchors make this safe:
`\bValidDedekind\b` does *not* match inside `ValidDedekindDense` (both sides are word chars) and
does *not* match inside `BLValidDedekindDense`. BL names need their own patterns. Also rename the
lowercase-initial forms (`validDedekind*`) in the same pass.

**Out of scope, correctly**: `soundness_dedekind`, `completeness_dedekind`, `CompactDedekind`,
`StrongCompletenessDedekind`, `SatisfiableDedekindSet`, `ModelExistenceDedekind`,
`axiom_dedekind_valid`, `SatisfiableSet.dedekind_of_forall` — these name the **tag**, which is not
renamed.

### 5.3 Decision the plan must take: the consequence family

`SemanticConsequenceDedekindDense` (+2 adapters, + `semantic_deduction_dedekind_dense`) and
`SetSemanticConsequenceDedekindDense` (+2 adapters, + `setSemanticConsequenceDedekindDense_mono`)
are the `.Dedekind`-tagged *consequence* predicates. If they keep `DedekindDense` while
`ValidDedekindDense` becomes `ValidDedekind`, the naming invariant is re-broken in a neighbouring
file. **Recommend renaming them too** (`→ SemanticConsequenceDedekind`,
`SetSemanticConsequenceDedekind`), ~30 further occurrences. Note that §3.4 deletes 4 of these 6
declarations anyway, which shrinks the rename.

### 5.4 The "nine warnings across six files" is **15 sites across 11 files**

Measured (current line numbers):

| File | Sites |
|---|---|
| `Semantics/Validity.lean` | `:326`, `:338`, `:658` (the sole literal "Read this first"), `:710`, `:753`, `:768-772`, `:819`, `:848`, `:886` |
| `Semantics/FrameProperty.lean` | `:129-140` ("Reciprocal pointer"), `:157-172` (naming deviation of record) |
| `Semantics/FrameClassValidity.lean` | `:42-52`, `:105-110` |
| `Semantics/BLValidity.lean` | `:26-45` (module docstring), `:278`, `:316` |
| `Metalogic/Soundness.lean` | `:811-818`, `:1517` |
| `Metalogic/BaseLanguageSoundness.lean` | `:46-54` |
| `Metalogic/StrongCompleteness.lean` | `:193` |
| `Metalogic/DedekindNonCompactness.lean` | `:416` |
| `Metalogic/Decidability/Verified/Bridge/Carrier.lean` | `:59-63` |
| `ProofSystem/Axioms.lean` | `:512` |
| `Metalogic.lean` `:65`, `Semantics.lean` `:109` | 2 |

Note `Semantics.lean:64` and `FrameProperty.lean:157-172` are the *naming-deviation-of-record*
blocks (paper says Complete / tree says Dedekind for the **dense-and-complete** class). Those are
**not** the warning being collapsed and must survive — the rename does not remove that deviation,
it removes only the `ValidDedekind` ≠ `ValidIn .Dedekind` trap. Do not conflate them.

Only **one** occurrence of the literal string "Read this first" exists in `FormalSystem/`
(`Validity.lean:658`); a second unrelated one sits in `Tests/BimodalTest/TemporalWitnessProbe.lean:59`.
The acceptance test *"grep finds one 'Read this first' paragraph"* is therefore already satisfied
today and is not a useful gate. **Replace it** with: *"`grep -rn 'not.*ValidIn .Dedekind\|NOT
`ValidDedekind`' FormalSystem/` returns at most one site, on `ValidComplete`."*

---

## 6. Naming convention (A-15) — much cleaner than the review says

`DenseValidity.lean`'s deletion removed most of A-15's mess. Measured current state (79 `*_valid`
declarations):

| Shape | Count | Verdict |
|---|---|---|
| `<axiom>_swap_valid` | **23** | the majority convention — **keep, it is the target** |
| `swap_axiom_<axiom>_valid` | 4 (`mt`, `m4`, `mb`, `mf`; `FrameClassVariants.lean:48,66,84,104`) | rename → `mt_swap_valid` etc. **No collisions** (verified) |
| `<axiom>_is_valid` | 4 (`prior_UZ`, `prior_SZ`, `z1`, `z1_past`; `:772,812,851,913`) | rename → `<axiom>_valid`; **collision, see below** |
| `axiom_<axiom>_valid` | 4 (`temp_linearity`, `temp_linearity_past`, `F_until_equiv`, `P_since_equiv`) | strip `axiom_`; **collision, see below** |
| `axiom_{dense,discrete,dedekind}_valid` | 3 | **not** per-axiom lemmas — these are "every axiom of class ≤ fc is valid". Keep. |
| `<X>_valid_of_<hypothesis>` | 4 (`BLSchemaValidity.lean:62,84,99,135`) | BL semantic lemmas at a hypothesis, not axiom-validity theorems. Keep; §4 shows they cannot be transported away. |
| `co_valid` | 1 (`CoValidity.lean:75`) | already `<X>_valid`. Keep. |

**Collision finding (this is the one that will surprise an implementer).** Seven of the eight
proposed target names **already exist**:

```
FormalSystem.Metalogic.temp_linearity_valid       Soundness.lean:324   (at `valid` / ⊨)
FormalSystem.Metalogic.temp_linearity_past_valid  Soundness.lean:343
FormalSystem.Metalogic.F_until_equiv_valid        Soundness.lean:381
FormalSystem.Metalogic.P_since_equiv_valid        Soundness.lean:391
FormalSystem.Metalogic.prior_UZ_valid             Soundness.lean:759   := SoundnessLemmas.prior_UZ_is_valid φ
FormalSystem.Metalogic.prior_SZ_valid             Soundness.lean:765   := SoundnessLemmas.prior_SZ_is_valid φ
FormalSystem.Metalogic.z1_valid                   Soundness.lean:770   := SoundnessLemmas.z1_is_valid φ
```

The stragglers live in `namespace FormalSystem.Metalogic.SoundnessLemmas`, so the renames are
**legal** — different namespaces, and `Soundness.lean` does not `open SoundnessLemmas` (it opens
only `Syntax`, `ProofSystem`, `Semantics`). But the result is two theorems spelled identically
modulo namespace. Two of them are genuinely the *same statement*:

- `SoundnessLemmas.prior_UZ_is_valid : ValidDiscrete …` and `Metalogic.prior_UZ_valid :
  ValidDiscrete …` — the latter is a **one-line re-export** of the former. Same for `prior_SZ`,
  `z1`.
- `SoundnessLemmas.axiom_temp_linearity_valid : ValidIn FrameClass.Base …` vs
  `Metalogic.temp_linearity_valid : ⊨ …` — the same formula at `ValidIn .Base` and at `valid`,
  which `valid_iff_validIn_base` proves equal. Near-duplicates.

**Recommendation**: for the three re-exports, *delete the wrapper* in `Soundness.lean` and export
the `SoundnessLemmas` name (or `export SoundnessLemmas (prior_UZ_valid …)`), rather than shipping
two same-named theorems. For the four `axiom_*`, rename to
`SoundnessLemmas.<axiom>_valid` and add a one-line docstring on each saying it is the
`ValidIn .Base` form of `Metalogic.<axiom>_valid`. Either way, this must be a **deliberate plan
decision**, because the naive rename silently creates the ambiguity.

### `valid` → `Valid`

- Notation `⊨` (`Validity.lean:398`) is used **410×** and is unaffected by the rename.
- Bare identifier `valid`, comment- **and string-**stripped: **106** occurrences, concentrated in
  `Soundness.lean` (44 — nearly all `refine valid.of_forall_total ?_`) and `Validity.lean` (24).
- **~18 of the 106 are a different `valid`**: `Automation/DatasetGenerator.lean`'s
  `FormulaLabel.valid` constructor and `DatasetValidator`/`ProofFirstBenchmark`/`DatasetExporter`
  fields. **These must not be renamed.** A naive `sed 's/\bvalid\b/Valid/g'` breaks the Automation
  layer.
- Real `Semantics.valid` sites: **~85-90**.
- Note that 55 of them are `valid.of_forall_total`, which §3.4 **deletes** (it is `ValidIn
  .Base`'s adapter). Sequence the `valid` → `Valid` rename *after* the adapter collapse and the
  count drops to ~35.
- `@[deprecated]` is available and already used in the tree (`Theorems/Propositional/Core.lean:341`),
  so `@[deprecated Valid (since := "…")] alias valid := Valid` is viable — but it fires a warning
  at every remaining site, which is noisy. **Recommend**: rename outright (≈35 sites post-collapse),
  no alias, and delete A-15's "or document the exception" branch.

---

## 7. Intro-chain normalisation (D-20) — stale census, and one real hazard

Current measurement (all `intro F …` chains, 15 files):

| Spelling | Count |
|---|---|
| `intro F M τ _h_mem t` | 40 |
| `intro F _ M τ _hτ t` | 37 |
| `intro F M τ hτ t` | 9 |
| `intro F hF M tau h_mem t` | 6 |
| `intro F M τ h_mem t` | 5 |
| `intro F _ _ _ _ M τ _hτ t` | 4 |
| `intro F _ h_lub M τ h_mem t h_ant` | 4 |
| `intro F hF M τ hτ t h_ctx` | 4 |
| 23 further one- to three-occurrence spellings | 39 |
| **total** | **148 chains, 31 spellings** |

D-20's "231 in 40+ shapes" and its "`intro F M τ _hτ t` ×119" are **stale** — that spelling now
occurs twice. Distribution: `Soundness.lean` 61, `FrameClassVariants.lean` 41,
`StrongCompleteness.lean` 14, `Validity.lean` 8, `BaseLanguageSoundness.lean` 7, then singles.

**The rename hazard.** `_h_mem` occurs **46×** tree-wide and is always the validity-binder leftover
— safe to rename to `_hτ` mechanically, and since every one is underscore-prefixed the change is
line-local. But **`h_mem` (non-underscore) occurs 581×**, and the overwhelming majority are
ordinary set-membership hypotheses in unrelated proofs. **A global `h_mem → hτ` rename would be a
disaster.** Only ~17 chains bind a *live* `h_mem` as the totality hypothesis
(`intro F M τ h_mem t` ×5, `intro F hF M tau h_mem t` ×6, `intro F _ M τ h_mem t` ×2,
`intro F _ h_lub M τ h_mem t h_ant` ×4). Those 17 proofs must be edited individually, with the
body references updated. Scope the plan accordingly.

Also note `intro F hF M tau h_mem t` ×6 uses ASCII `tau` for `τ` — fold into the same pass.

**Confirmed**: D-20 recommends *against* a binder macro (hygiene makes `F`/`M`/`τ`/`t`
inaccessible). Nothing in this research contradicts that; `sat_intro` takes an *explicit ident
argument* from the call site, which is exactly why it escapes the hygiene problem that a
`valid_intro` binder macro would not.

**Interaction with §2.4**: the `.Discrete` sites currently read
`intro F _h_succ _h_pred _h_succ_arch _h_pred_arch M τ _h_mem t` (3 sites) and
`intro F so po hsa hpa M τ hτ t` (2 sites); the `_ _ _ _` forms (4 + 3 + 2 = 9 sites) likewise.
All of these collapse to `intro F hF M τ _hτ t; sat_intro hF` — do the intro normalisation and the
adapter collapse **in the same edit per proof**, not as two passes over the same 148 lines.

---

## 8. Risks, sequencing, and verification

### Risks

| Risk | Severity | Mitigation |
|---|---|---|
| `@[reducible] FrameClass.Sat` changes unification behaviour tree-wide | **High** — the one change that cannot be validated in isolation | `Sat.anti` + set-membership verified PASS (§2.1). Full detached, guarded `lake build` is the only real oracle. **Plan B (§2.4) needs no reducibility change** and is the fallback. |
| Substring rename corrupts the `HasDedekind*` canonical layer | **High** | identifier-exact, word-boundary patterns; §5.2 ordering |
| `h_mem` global rename (581 hits, ~17 relevant) | **High** | per-proof edits only; never `sed` |
| `valid` global rename hits `FormulaLabel.valid` (~18 hits) | Medium | exclude `Automation/**`; rename after the adapter collapse |
| New same-named theorems across `Metalogic` / `Metalogic.SoundnessLemmas` | Medium | §6 decision: delete the three re-export wrappers |
| `linter.unusedTactic` fires on `sat_intro` at `.Base`/`.Dense` (~15 sites) | Low | omit `sat_intro` there, or set the option locally |
| C2/C14 drift | Medium | C2 pins `BXCanonical.{completeness, completeness_dense, completeness_discrete}` + `Chronicle.countermodel_dense`; C14(ii) pins `Decidability.sound_of_isValid`, `completeness_dedekind`, `strongCompletenessBase`, `strongCompletenessDense`, all at `[propext, Classical.choice, Quot.sound]`. **None of these eight names is renamed by this task** — verified. C14(i) is a stale-literal scan over `docs/` + `*.lean`; the docstring edits in §5.4 must not introduce a `14/21/42/44 axiom` literal. |

### Recommended phase order

1. **Representation** — `abbrev IsDense`; `@[reducible] Sat`; `sat_intro` (new
   `Semantics/SatTactic.lean` or beside `Sat`); `isSuccArchDiscrete_of_instances` +
   `IsSuccArchDiscrete.elim`; the four `example`s of §2.6 into `DurationClassification.lean`.
   *Build green here before touching a single call site.* Decide Plan A vs Plan B on this build.
2. **Generic adapters up** — add `ValidOnFrames.of_not`, `SemanticConsequenceIn.{of_forall_total,
   apply_total}`, `SetSemanticConsequenceOn.{of_forall_total, apply_total}`,
   `SatisfiableSet.of_forall`. Purely additive; build green.
3. **Migrate call sites, delete adapters** — ~60 sites; fold the §7 intro normalisation into the
   same per-proof edits. This is the phase that must be sized to fit one agent run; split by file
   (`Soundness.lean` alone is 11 class-adapter + 61 intro-chain sites).
4. **BL transfer** — the two theorems into `BaseLanguageSoundness.lean`; rewrite the five
   corollaries; keep `blValid_iff_empty_consequence`, `BLValidDiscreteSucc`, the native
   `example`s, and both `df_valid_of_*`.
5. **Rename pass** — `ValidDedekind → ValidComplete`, then `ValidDedekindDense → ValidDedekind`,
   then the BL twins, then (decision) the consequence family; collapse the 15 warning sites to one
   cross-reference on `ValidComplete`, **preserving** the two naming-deviation-of-record blocks.
6. **Naming pass** — `swap_axiom_*` ×4, `*_is_valid` ×4, `axiom_<axiom>_valid` ×4 (with the §6
   collision decision), then `valid → Valid`.
7. **Verify** — detached guarded `lake build` + `lake build BimodalTest`, then
   `scripts/check-module-invariants.sh` for C1/C2/C14.

Steps 1, 2 and 4 are independent of 5 and 6 and could run in parallel with territory contracts
(1+2+3 own `Semantics/Validity.lean`, `Semantics/FrameProperty.lean`,
`Semantics/FrameClassValidity.lean`, `Metalogic/SetConsequence.lean`; 4 owns
`Metalogic/BaseLanguageSoundness.lean`, `Semantics/BLValidity.lean`). Steps 5-6 touch nearly every
file and must be serialized last.

### Acceptance criteria, restated to be checkable

| Task's criterion | Verdict | Replacement |
|---|---|---|
| binder adapters 47 → 2 (+2 BL) | **unachievable** (§3.3) | 47 → 12, all `fc`- or `P`-indexed; zero literal-tag adapters; `SatisfiableSet` 4 → 1 |
| every `ValidX` is definitionally `ValidIn .X` | achievable | keep — add "and `ValidComplete` is the sole `ValidOnFrames`-level name, documented once" |
| grep finds one "Read this first" paragraph | **already true today**, so vacuous (§5.4) | "at most one site in `FormalSystem/` warns that a `Valid*` name is not its apparent `ValidIn` tag, and it is on `ValidComplete`" |
| BLValidity's lemma layer is corollaries of the transfer theorem | **partly** (§4) | "the five monotonicity/inclusion lemmas are corollaries of the two transfer theorems; `blValid_iff_empty_consequence` and the `BLValidDiscreteSucc` layer are documented exceptions" |
| lake build green | keep | must be detached + guarded |
| C2/C14 baselines unchanged | keep — verified none of the eight pinned names is renamed | keep |

---

## 9. Open questions for the plan

1. **Plan A or Plan B for `Sat`?** Only a full build decides. Plan A is what the task asks for and
   is cleaner; Plan B needs no reducibility change and is proven to work. Budget a build for A,
   with B as the documented fallback.
2. **`IsSuccArchDiscrete`: leave as the existential (§2.2a) or move to `inductive` (§2.2b)?**
   (a) is zero-risk and sufficient. The task's literal instruction (`structure`) is impossible.
3. **Rename the consequence family too?** (§5.3) — recommended, ~30 more occurrences, but it is
   scope the task did not name.
4. **The three `Metalogic` re-export wrappers** (`prior_UZ_valid`, `prior_SZ_valid`, `z1_valid`) —
   delete-and-export, or keep two same-named theorems in sibling namespaces? (§6)
5. **`valid → Valid` alias or not?** Recommended: no alias, rename after the adapter collapse
   (~35 sites), excluding `Automation/**`'s unrelated `valid`.
