# BL (TM) Soundness by Composition — Research Report

**Task**: 489 — Prove soundness for the BaseLanguage (BL) proof system at `FrameClass.Base` and
its three extensions.
**Verdict**: **All four deliverables are machine-verified as feasible in this repository, today,
by prototype.** Every definition, the bridge, all four soundness theorems, both empty-context
validity forms and both consistency corollaries were elaborated against the built library with
`lake env lean`, sorry-free, at `#print axioms` exactly `[propext, Classical.choice, Quot.sound]`.

This report is written so the plan can be a transcription exercise: the verified source text is
reproduced verbatim below, with placement, naming, and the documentation-amendment list settled.

---

## 1. What was verified, and how

Four scratch files were elaborated with `lake env lean` against the built `FormalSystem` library
(the same mechanism `check-module-invariants.sh`'s C2/C14 use):

| Prototype | Contents | Result |
|---|---|---|
| `bl_proto.lean` | `BLTruthAt` + `truthAt_tr` | clean, first attempt |
| `bl_proto2.lean` | the above + 4 validity predicates + 4 soundness theorems + 4 validity forms + 2 consistency corollaries + `#print axioms` | clean; all seven axiom lines `[propext, Classical.choice, Quot.sound]` |
| `bl_proto3.lean` | 12 `BLTruth.*` clause/derived-operator characterization lemmas | clean (3 `push_neg` deprecation warnings only) |
| `bl_proto4.lean` / `bl_proto6.lean` | `blValid_iff_valid_tr`, three native validity spot checks, and the `induction … generalizing` variant of the bridge | clean |

Measured `#print axioms` output, verbatim:

```
'FormalSystem.Metalogic.bl_soundness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_soundness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_soundness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_soundness_dedekind' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_not_derivable_nil_bot' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.bl_not_derivable_nil_bot_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.truthAt_tr' depends on axioms: [propext, Classical.choice, Quot.sound]
```

The acceptance criterion is therefore already demonstrated at prototype scale. The remaining work
is placement, docstrings, aggregator registration, and the documentation amendments in §7 — not
proof search.

---

## 2. Paper fidelity — the transcription checks out, with one recorded gap

`def:BL-semantics` (`possible_worlds.tex:3566`, pinned in `specs/paper-definitions-of-record.md`
at `:1309`, sha256 `5f53774a…`), verbatim clause bodies:

| Clause | Paper | Proposed `BLTruthAt` clause | Existing `TruthAt` counterpart |
|---|---|---|---|
| `p_i` | `τ(x) ∈ \|p_i\|` | `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p` | identical (`Truth.lean:164`) |
| `⊥` | `M,τ,x ⊭ ⊥` | `False` | identical |
| `→` | `M,τ,x ⊭ φ` or `M,τ,x ⊨ ψ` | `… φ → … ψ` | identical |
| `□` | `M,σ,x ⊨ φ` for all `σ ∈ H_F` | `∀ σ, σ.IsTotal → BLTruthAt M σ t φ` | identical |
| `H` (`\Past`) | `M,τ,y ⊨ φ` for all `y ∈ D` where `y < x` | `∀ s, s < t → BLTruthAt M τ s φ` | `Truth.past_iff` (`:305`), a theorem |
| `G` (`\Future`) | `M,τ,y ⊨ φ` for all `y ∈ D` where `x < y` | `∀ s, t < s → BLTruthAt M τ s φ` | `Truth.future_iff` (`:287`), a theorem |

Three findings worth recording:

1. **The paper's H/G clauses are STRICT (`y < x`, `x < y`), not reflexive.** The task description
   and `past_iff`/`future_iff` both assume this, and the live `.tex` confirms it. However,
   `Semantics/Truth.lean`'s module docstring (lines 35–36) still describes the paper's clauses as
   "(past, reflexive)" / "(future, reflexive)" and calls this tree's strict reading "a refinement
   of the paper's reflexive convention". That is **stale**: the anchor of record now has `y < x`
   and `x < y` on the nose, so the tree matches the paper exactly rather than refining it. Fix
   this docstring while in the neighbourhood (see §7, item 5). It is not blocking.

2. **The atom clause's domain conjunct is the one deliberate divergence, and it must be carried
   over.** `def:BL-semantics`'s atom clause has no domain check; `TruthAt` has
   `∃ (ht : τ.domain t), …`, documented as Decision A of
   `specs/decisions/total-history-validity-decisions.md` and vacuous under totality. `BLTruthAt`
   **must carry the identical conjunct** — that is exactly what makes the atom case of the bridge
   `Iff.rfl`. Dropping it to be "more faithful" would break the bridge's easiest case and gain
   nothing on `H_F`. The new module's docstring should say this and cite Decision A, so the
   divergence is inherited knowingly rather than copied blindly.

3. **`thm:TM-soundness` (`:4484`) and `def:BL-semantics` are both live manifest rows** in
   `specs/paper-definitions-of-record.md`, so citing them in the new docstrings costs nothing at
   C15 (currently `all 46 paper-anchor citation(s) resolve`).

The four over-claim sites confirmed present in the live `.tex`:

- `:1661` — "The soundness theorem **thm:TM-soundness** for **TM** and its extension **TM**⁺ …
  implemented in Lean 4".
- `:4311` — "The full soundness proof, for **TM** and the **TM**⁺ systems below, has been
  formalized in the Lean 4 repository".
- `:4484` — `\begin{Tthm}[Soundness] \label{thm:TM-soundness}`, the theorem itself.
- `:4494` — the footnote: "implements the soundness theorem for **TM** in Lean 4".

This task retires all four.

---

## 3. Deliverable 1 — `BLTruthAt` and the four validity predicates (VERIFIED)

### 3.1 `BLTruthAt`

```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
  {F : TaskFrame D}

def BLTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : D) : BLFormula → Prop
  | .atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => BLTruthAt M τ t φ → BLTruthAt M τ t ψ
  | .box φ => ∀ (σ : WorldHistory F), σ.IsTotal → BLTruthAt M σ t φ
  | .allPast φ => ∀ s : D, s < t → BLTruthAt M τ s φ
  | .allFuture φ => ∀ s : D, t < s → BLTruthAt M τ s φ
```

The variable bundle is copied character-for-character from `Semantics/Truth.lean:99`. The `box`
clause recurses at a different history and the temporal clauses at a different time; Lean's
equation compiler handles this exactly as it already does for `TruthAt` — **no `termination_by`,
no `decreasing_by`, no well-founded annotation is needed.** Verified.

**This is NOT `TruthAt (tr φ)`.** It is a six-clause recursion on `BLFormula`, and the H/G clauses
state the paper's universal quantification directly rather than routing through `untl`/`snce`.
The forbidden design is avoided by construction, and §4 is a proof rather than a definitional
unfolding.

### 3.2 Characterization lemmas (all VERIFIED)

Twelve lemmas in a `BLTruth` namespace, mirroring `Semantics/Truth.lean`'s `Truth` namespace.
Six are `Iff.rfl`/`id`; six have content.

`bot_false`, `imp_iff`, `box_iff`, `future_iff`, `past_iff`, `neg_iff`, `top_true` — all
`Iff.rfl` or `id`. `and_iff`, `or_iff` — `simp only [BLFormula.and/or, BLFormula.neg, BLTruthAt];
tauto`. `diamond_iff`, `someFuture_iff`, `somePast_iff` — each the classical `¬∀¬ ↔ ∃` step:

```lean
@[simp] theorem someFuture_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.someFuture ↔ ∃ s : D, t < s ∧ BLTruthAt M τ s φ := by
  simp only [BLFormula.someFuture, BLFormula.neg, BLTruthAt]
  constructor
  · intro h; by_contra hc; push_neg at hc; exact h (fun s hs hφ => hc s hs hφ)
  · rintro ⟨s, hs, hφ⟩ h; exact h s hs hφ
```

and `always_iff` follows from `and_iff` + `past_iff` + `future_iff` by `simp only`.

**Style note**: `push_neg` emits a deprecation warning under this toolchain ("Prefer using
`push Not`"). The tree already carries 69 `push_neg` occurrences against 535 `push Not`, so
prefer `push Not` in the new code to avoid adding to the warning surface.

**Why these are worth landing even though soundness does not consume them.** Task 495 (which
declares Task 489 as its sole dependency) is the CEB/CEF countermodel work, and its witnesses
`(Sp)` and `Z1` are stated with the *derived existentials* `F` and `P`. Without
`someFuture_iff`/`somePast_iff` every countermodel evaluation in that task re-derives the
classical step by hand. They are the interface 495 will actually call.

### 3.3 The four validity predicates (VERIFIED)

Binder-for-binder mirrors of `Semantics/Validity.lean:94` (`valid`), `:206` (`ValidDense`),
`:248` (`ValidDiscrete`), `:336` (`ValidDedekindDense`), with `Formula`/`TruthAt` replaced by
`BLFormula`/`BLTruthAt` and nothing else changed. `Type` (not `Type*`) throughout, per the
universe note on `valid`.

```lean
def BLValid (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D), BLTruthAt M τ t φ

def BLValidDense (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D] (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D), BLTruthAt M τ t φ

def BLValidDiscrete (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D]
    [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D), BLTruthAt M τ t φ

def BLValidDedekindDense (φ : BLFormula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D] (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D), BLTruthAt M τ t φ
```

Recommend adding `BLSemanticConsequence` (mirroring `SemanticConsequence`, `Validity.lean:125`)
for completeness of the mirror; the four soundness theorems in §5 already take `Γ` and a context
hypothesis, so it is a one-line definition plus a trivial unfolding lemma, not new content.

---

## 4. Deliverable 2 — the bridge (VERIFIED, two equivalent forms)

```lean
theorem truthAt_tr (M : TaskModel F) (φ : BLFormula) (τ : WorldHistory F) (t : D) :
    TruthAt M τ t (tr φ) ↔ BLTruthAt M τ t φ := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ih1 ih2 => simp only [tr_imp, BLTruthAt]; exact imp_congr (ih1 τ t) (ih2 τ t)
  | box φ ih =>
      simp only [tr_box, BLTruthAt, Truth.box_iff]
      exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
  | allPast φ ih =>
      simp only [tr_allPast, BLTruthAt, Truth.past_iff]
      exact forall_congr' fun s => imp_congr_right fun _ => ih τ s
  | allFuture φ ih =>
      simp only [tr_allFuture, BLTruthAt, Truth.future_iff]
      exact forall_congr' fun s => imp_congr_right fun _ => ih τ s
```

**`generalizing τ t` is mandatory** — the `box` case needs the IH at `σ`, the temporal cases at
`s`. With `generalizing`, the IH is `∀ τ t, …`, so each use site must apply it explicitly
(`ih σ t`, `ih τ s`); omitting the arguments is the one error the first attempt produced, and it
is a type mismatch caught immediately. An equivalent form that avoids `generalizing` by stating
the theorem as `∀ φ τ t, …` and doing `intro φ; induction φ` was also verified; either is fine.

**Case-by-case content, as predicted by the task description and confirmed:**

- `atom`, `bot` — `Iff.rfl`, because the two atom clauses are literally the same expression.
- `imp` — `Iff.rfl` up to congruence; `imp_congr` on the two IHs.
- `box` — `tr_box` is `rfl` and both box clauses read `∀ σ, σ.IsTotal → …`, so this is congruence
  under the binder. It is *not* content-free only because the IH must be taken at `σ`.
- `allPast`, `allFuture` — **the only two cases with real content**, and both are already
  discharged in-tree. `tr φ.allFuture` is `Formula.allFuture (tr φ)`, an *abbreviation* over
  `untl`; `Truth.future_iff` (`Semantics/Truth.lean:287`) is the theorem that unfolds it to
  `∀ s, t < s → TruthAt M τ s (tr φ)`, which is `BLTruthAt`'s `allFuture` clause on the nose.
  Dually `Truth.past_iff` (`:305`). Both are already `@[simp]` and sorry-free.

Two corollaries, both verified:

```lean
theorem truthAt_trCtx (M : TaskModel F) (τ : WorldHistory F) (t : D)
    {Γ : BaseLanguage.Context} (h : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) :
    ∀ ψ ∈ trCtx Γ, TruthAt M τ t ψ := by
  intro ψ hψ
  obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hψ
  exact (truthAt_tr M χ τ t).mpr (h χ hχ)

/-- The validity-level bridge. A COROLLARY of `truthAt_tr`, not the definition of `BLValid`. -/
theorem blValid_iff_valid_tr (φ : BLFormula) : BLValid φ ↔ valid (tr φ) := by
  constructor
  · intro h D _ _ _ _ F M τ hτ t; exact (truthAt_tr M φ τ t).mpr (h D F M τ hτ t)
  · intro h D _ _ _ _ F M τ hτ t; exact (truthAt_tr M φ τ t).mp (h D F M τ hτ t)
```

`truthAt_trCtx` is the side-condition discharger every soundness composition in §5 calls; landing
it once keeps all four theorems to a single expression each. `blValid_iff_valid_tr` is the
statement a reader will expect to see and should be present *as a theorem*, precisely so that the
distinction from the forbidden definitional shortcut is visible in the file.

---

## 5. Deliverable 3 — the four soundness theorems (VERIFIED)

Each is one expression: translate, apply the BL⁺ soundness theorem, cross the bridge.

```lean
theorem bl_soundness (Γ : BaseLanguage.Context) (φ : BLFormula)
    (d : BaseLanguage.DerivationTree FrameClass.Base Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) :
    BLTruthAt M τ t φ :=
  (truthAt_tr M φ τ t).mp
    (soundness (trCtx Γ) (tr φ) (Conservativity.translate d) D F M τ h_mem t
      (truthAt_trCtx M τ t h_ctx))
```

`bl_soundness_dense`, `bl_soundness_discrete` and `bl_soundness_dedekind` are the same expression
with `soundness_dense` (`Soundness.lean:1260`), `soundness_discrete` (`:1406`) and
`soundness_dedekind` (`:1933`) substituted, and the corresponding binder bundle copied from each.
`soundness_dedekind` additionally takes `h_lub` between `D` and `F`; the BL statement threads it
through in the same position.

Empty-context validity forms, one line each:

```lean
theorem bl_soundness_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Base [] φ) : BLValid φ :=
  fun D _ _ _ _ F M τ h_mem t => bl_soundness [] φ d D F M τ h_mem t (by simp)

theorem bl_soundness_dense_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Dense [] φ) : BLValidDense φ :=
  fun D _ _ _ _ _ F M τ h_mem t => bl_soundness_dense [] φ d D F M τ h_mem t (by simp)

theorem bl_soundness_discrete_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Discrete [] φ) : BLValidDiscrete φ :=
  fun D _ _ _ _ _ _ _ _ F M τ h_mem t =>
    bl_soundness_discrete [] φ d D F M τ h_mem t (by simp)

theorem bl_soundness_dedekind_valid {φ : BLFormula}
    (d : BaseLanguage.DerivationTree FrameClass.Dedekind [] φ) : BLValidDedekindDense φ :=
  fun D _ _ _ _ _ h_lub F M τ h_mem t =>
    bl_soundness_dedekind [] φ d D h_lub F M τ h_mem t (by simp)
```

Three notes:

- **`Conservativity.translate` is `noncomputable`.** Irrelevant here: it appears only inside proof
  terms of `Prop`-valued theorems. Verified — the axiom profile is unaffected.
- **The Base-then-extensions structure is genuinely inherited free**, exactly as the task
  description predicted. `BaseLanguage.Axiom.minFrameClass` sends only `df`/`dn`/`co` off `.Base`,
  `translate` is already `{fc : FrameClass}`-parameterized, and each of the four BL⁺ soundness
  theorems is already stated at its frame class. No BL-side axiom-validity lemma is written at
  all.
- **What composition does and does not certify.** These theorems inherit per-axiom validity from
  `Soundness.lean`'s BL⁺ lemmas plus `BaseLanguage/AxiomDischarge.lean`. That is mathematically
  complete, but it means no BL axiom is ever evaluated *directly* against `BLTruthAt`. Three
  native spot checks were verified and should be landed as `example`s so a reader can see
  `BLTruthAt` carrying real content independently of the composition:

```lean
example (φ ψ : BLFormula) : BLValid ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture)) := by
  intro D _ _ _ _ F M τ _ t hk hf s hs
  exact hk s hs (hf s hs)                                        -- TK

example (φ : BLFormula) : BLValid (φ.allFuture.imp φ.allFuture.allFuture) := by
  intro D _ _ _ _ F M τ _ t h s hs r hr
  exact h r (lt_trans hs hr)                                     -- T4

example (φ : BLFormula) : BLValid (φ.box.imp φ) := by
  intro D _ _ _ _ F M τ hτ t h
  exact h τ hτ                                                   -- MT
```

`MT` is the informative one: it goes through because `τ` is *itself* total, which is precisely the
`H_F` reading of the box clause the paper specifies.

### The Dedekind asymmetry — confirmed, with a sharper BL-side witness

`bl_soundness_dedekind` must target `BLValidDedekindDense` (with `[DenselyOrdered D]`), inheriting
`soundness_dedekind`'s target. Targeting a density-free `BLValidDedekind` would be **refutable**,
and on the BL side the witness is more direct than on the BL⁺ side:

- BL⁺'s argument needs `Axiom.density` **and** `Axiom.dense_indicator` (`¬(⊥ U ⊤)`), the latter
  having no BL counterpart at all — BL has no `untl`.
- **BL's own `Axiom.dn` (`GGφ → Gφ`) suffices by itself.** `(Axiom.dn φ).minFrameClass = .Dense`
  and `FrameClass.Dense ≤ FrameClass.Dedekind` (pinned by an `example` at
  `BaseLanguage/Axioms.lean`), so `dn` is admissible in any `.Dedekind` BL derivation. It is false
  on `ℤ` (take `φ` true exactly at times `≥ t + 2`: `GGφ` holds at `t`, `Gφ` fails), and `ℤ`
  satisfies every binder of a density-free `BLValidDedekind` (Mathlib's
  `ConditionallyCompleteLinearOrder ℤ`).

So do not define a `BLValidDedekind` and do not "simplify" the target. The docstring should carry
this BL-native witness rather than paraphrasing `Validity.lean`'s BL⁺ one.

---

## 6. Deliverable 4 — consistency corollaries (VERIFIED)

Both mirror `not_derivable_nil_bot` (`Soundness.lean:1993`) and
`not_derivable_nil_bot_discrete` (`:2020`) structurally, including the `trivialFrame`/`Int`
witness and the reason for stating them as `¬ Derivable …` rather than via `Metalogic.Core.Consistent`.

```lean
theorem bl_not_derivable_nil_bot :
    ¬ BaseLanguage.Derivable FrameClass.Base ([] : BaseLanguage.Context) BLFormula.bot := by
  rintro ⟨d⟩
  refine TaskFrame.not_validOn_bot (D := Int) TaskFrame.trivialFrame ?_
  intro M τ x
  exact bl_soundness [] BLFormula.bot d Int TaskFrame.trivialFrame M τ.val τ.property x (by simp)

theorem bl_not_derivable_nil_bot_discrete :
    ¬ BaseLanguage.Derivable FrameClass.Discrete ([] : BaseLanguage.Context) BLFormula.bot := by
  rintro ⟨d⟩
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (D := ℤ) TaskFrame.trivialFrame
  exact bl_soundness_discrete_valid d ℤ TaskFrame.trivialFrame TaskModel.allFalse
    τ.val τ.property 0
```

The first works because `tr BLFormula.bot = Formula.bot` definitionally, so
`TaskFrame.not_validOn_bot` applies unchanged after the bridge. Note that the base case relies on
`Semantics/Validity.lean:586`'s `not_validOn_bot`, and the discrete case on `:599`'s
`hF_nonempty_of_frameAxioms` plus `TaskModel.allFalse` (`TaskModel.lean:65`) — no new
infrastructure.

Dense and Dedekind consistency corollaries are **deliberately not proposed**, matching the BL⁺
side: `Soundness.lean`'s own docstring records that "there is no `{fc}`-uniform statement, because
`Dense` and `Dedekind` have no corresponding consistency lemma in the tree yet". Adding BL-side
ones would need a dense/complete witness frame that the tree does not carry, and would be scope
creep. Say so in the docstring rather than leaving the asymmetry unexplained.

---

## 7. Placement — recommend Semantics/ + Metalogic/, NOT `BaseLanguage/Semantics.lean`

The task offers two options. **Take the second: place the new modules outside `BaseLanguage/`.**
The invariant then stays literally true and needs no weakening — only a clarifying sentence.

### Recommended file layout

| New file | Imports | Contents |
|---|---|---|
| `FormalSystem/Semantics/BLTruth.lean` | `FormalSystem.Semantics.Truth`, `FormalSystem.BaseLanguage.Formula` | `BLTruthAt`, the twelve `BLTruth.*` characterization lemmas |
| `FormalSystem/Semantics/BLValidity.lean` | `FormalSystem.Semantics.BLTruth`, `FormalSystem.Semantics.Validity` | `BLValid`, `BLSemanticConsequence`, `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense`, and the inclusion lemmas mirroring `Validity.valid_implies_valid_dense` etc. |
| `FormalSystem/Metalogic/BaseLanguageSoundness.lean` | `FormalSystem.Metalogic.Soundness`, `FormalSystem.Metalogic.Conservativity`, `FormalSystem.Semantics.BLValidity` | `truthAt_tr`, `truthAt_trCtx`, `blValid_iff_valid_tr`, the four soundness theorems, the four validity forms, the two consistency corollaries, the three native spot checks |

Register `Semantics.BLTruth` and `Semantics.BLValidity` in `FormalSystem/Semantics.lean`, and
`Metalogic.BaseLanguageSoundness` in `FormalSystem/Metalogic.lean`.

**Why the bridge goes in `Metalogic/` rather than `Semantics/`.** Putting `truthAt_tr` in
`Semantics/` would force `Semantics/` to import `BaseLanguage.Translation` (which pulls in
`Syntax.Formula` and `Syntax.Context`). Putting it in `Metalogic/BaseLanguageSoundness.lean` keeps
the whole `Semantics → BaseLanguage` edge down to a single import of `BaseLanguage.Formula`, a
leaf that itself imports only `Syntax.Atom`. `Metalogic/` already imports `Conservativity`, hence
`Translation`, so the bridge costs nothing there. Either placement compiles; this one is tidier.
If the implementer prefers the bridge beside the definition, note that `blValid_iff_valid_tr` and
`truthAt_trCtx` must travel with it.

**No cycle.** Verified end to end: the prototypes imported all of `FormalSystem` and elaborated.
`BaseLanguage/Formula.lean` imports only `Syntax.Atom`; nothing under `BaseLanguage/` imports
`Semantics`. The new edge runs `Semantics → BaseLanguage.Formula`, i.e. the permitted direction.

**Layering.** `docs/development/MODULE_ORGANIZATION.md:107–129` states a five-layer architecture
that does not mention `BaseLanguage` at all (it is described separately at `:239`). The new edge
is Layer 2 → a Layer-0-shaped leaf and is consistent with the stated rules, but the layer list
should be amended to place `BaseLanguage` explicitly so the next reader does not have to re-derive
this.

### Docstring and documentation amendments (all required; the module-invariant one is mandatory)

1. **`FormalSystem/BaseLanguage.lean`** ("## Module Invariant") and
   **`FormalSystem/BaseLanguage/Formula.lean:48`** (the same block). The invariant statement
   stays true under the recommended placement, but must be made **directional** in words, so a
   reader meeting `Semantics/BLTruth.lean` does not think it has been silently violated. Suggested
   addition: the invariant forbids `BaseLanguage/ → Semantics/`; the converse edge
   (`Semantics/BLTruth.lean` importing `BaseLanguage.Formula`) is permitted and is how the BL
   semantics is sited. Keep the `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/`
   check, which still returns nothing.

2. **`FormalSystem/Metalogic/Conservativity.lean` — four stale claims, all now false.** This is
   the largest amendment and it is not optional; leaving it produces exactly the "silently false
   docstring" the task forbids.
   - The "## No semantics" section's diagram annotates the left arrow
     `⟸[BL soundness, not built]`. It is now built.
   - "## What a machine-checked refutation would need" says "A BL-side semantics, a BL-side
     soundness theorem, and the two countermodels — **None of the three exists in this
     repository**". Two of the three now exist; only the countermodels remain (that is Task 495's
     scope, which cites this very paragraph).
   - The CEF section: "That half needs a BL-side semantics and soundness theorem, which this
     repository does not have and which is deliberately out of scope here."
   - The CEB section: "the failing half … needs a BL-side semantics this repository does not
     have."
   The **forward direction stays refuted and must still not be stated or `sorry`-ed** — nothing in
   this task changes that, and the amendments must not read as softening it. What changes is only
   which prerequisites are missing.

3. **`docs/project-info/known-limitations.md`, Limitation 8** (`:260`ff) — the "Impact" and
   "Resolution" text carries the same "no BL semantics" framing indirectly; re-read it against the
   amended `Conservativity.lean` and update if it asserts anything now false.

4. **Inventory/README rows**: `FormalSystem/Semantics/README.md` (Contents table),
   `FormalSystem/Metalogic/README.md` (`:141`-area file table),
   `FormalSystem/README.md` (`:226`-area table), `docs/development/MODULE_ORGANIZATION.md`
   (`:255`-area Semantics list, `:245`-area BaseLanguage list, plus the layer list per above),
   `docs/reference/API_REFERENCE.md` (`:746`-area BaseLanguage section).

5. **`FormalSystem/Semantics/Truth.lean:35–36`** — the "(past, reflexive)" / "(future, reflexive)"
   description of the paper's clauses, and the "a refinement of the paper's reflexive convention"
   sentence at `:30`. Both are stale against the pinned anchor (see §2, finding 1).

6. **`FormalSystem/Metalogic/Soundness.lean`** module docstring, and `FormalSystem/Metalogic.lean`
   (`:33-48`, the Conservativity + Soundness status block) — add the BL row so the new theorems
   are discoverable from the aggregator.

---

## 8. Gate impact — `scripts/check-module-invariants.sh`

Baseline measured on the current working tree at `--no-build`: **ALL CHECKS PASSED**, confirmed on
three consecutive runs. C15 reports `all 46 paper-anchor citation(s) resolve`; C3 reports zero
structural sorries; C7 reports 467 live `.lean` files, 445 reachable / 22 unreachable.

| Check | Impact of this task |
|---|---|
| C1 `lake build` | must stay green — the whole deliverable is new compiled code |
| C2 / C14(ii) `#print axioms` baselines | **unaffected**: the six pinned theorems are untouched; the new theorems are additions, and C2 asserts a fixed list |
| C3 zero sorries | unaffected — nothing proposed carries a `sorry` |
| C4 imports resolve | new imports are to real modules |
| C5 markdown module paths | new `FormalSystem.Semantics.BLTruth` / `.BLValidity` / `FormalSystem.Metalogic.BaseLanguageSoundness` mentions in README/docs must name the files as actually created |
| C6 rot guard | **the new modules must be reachable**, i.e. registered in the two aggregators. If a module is left unregistered it becomes an unreachable live module and C6 fails unless it is added to `scripts/module-invariants-manifest.txt`. Registering is the right answer; do not manifest them. |
| C8 aggregator convention | unaffected — new files go into existing directories that already have sibling aggregators |
| C9 task-number citations | **new `.lean` and `.md` text must not cite "task 489" or "task 495"** — C9 is enforced (`ENFORCE_C9=1`) and covers `FormalSystem/`. Cite `Conservativity.lean`'s section names and `Soundness.lean`'s theorem names instead. |
| C13 markdown links | any new README rows linking to the new files must resolve |
| C14(i) stale-count scan | the `\b(14\|21\|42\|44)\s+(axiom\|constructor)` regex now also scans `FormalSystem/**/*.lean` docstrings; do not write "the 21 BL axiom constructors" (BL's `Axiom` has 16 constructors, verified by count — write the number only if it is checked, or avoid a count) |
| C15 paper anchors | `def:BL-semantics`, `thm:TM-soundness`, `def:BL-language`, `def:logical-consequence` are all already manifest rows; citing them is free. Any *new* anchor cited must first get a row. |

**One operational caveat.** During this research a single transient `FAIL C6` ("5 manifest
entr(y/ies) name a REACHABLE module", with C7 reporting 450/17 instead of 445/22) was observed on
one invocation, and did not reproduce on four subsequent runs of an unchanged tree. If a C6 failure
appears at gate time with no corresponding module change, re-run before treating it as real.

---

## 9. Risks, and where the plan should put its attention

There is **no proof-search risk**: every obligation is verified. The residual risks are all
editorial.

| Risk | Severity | Mitigation |
|---|---|---|
| Conservativity.lean's four stale claims left unamended | **high** — leaves a docstring asserting the opposite of what the tree now proves, on the exact file Task 495 will read next | §7 item 2 is a required plan phase, not a cleanup afterthought |
| The invariant docstrings left unamended | **high** — the task names this explicitly | §7 item 1 |
| A `BLValidDedekind` (density-free) sneaking in "for symmetry" | high — refutable statement | §5; state the `Axiom.dn`-on-`ℤ` witness in the docstring |
| `BLTruthAt` defined as `TruthAt (tr φ)` under time pressure | high — the forbidden design | §3.1; the three native spot checks in §5 are the standing guard against it |
| Atom clause "corrected" to drop the domain conjunct | medium — breaks the bridge's `Iff.rfl` | §2 finding 2; document Decision A inheritance in the new docstring |
| New modules not registered in the aggregators | medium — C6 fails | §8 |
| Task-number citations in the new Lean files | medium — C9 is enforced | §8 |
| `push_neg` deprecation warnings added | low | use `push Not` |

### Suggested phase decomposition

1. `Semantics/BLTruth.lean` — `BLTruthAt` + the twelve characterization lemmas; register in
   `Semantics.lean`. (~130 lines with docstring.)
2. `Semantics/BLValidity.lean` — five predicates + inclusion lemmas; register. (~120 lines.)
3. `Metalogic/BaseLanguageSoundness.lean` — bridge, four soundness theorems, four validity forms,
   two consistency corollaries, three spot checks; register in `Metalogic.lean`. (~230 lines.)
4. Docstring amendments: `BaseLanguage.lean`, `BaseLanguage/Formula.lean`, and — the substantial
   one — `Metalogic/Conservativity.lean`'s four stale claims. (~60 lines changed.)
5. Inventory/doc sync: the six README/docs sites in §7 item 4, plus `Truth.lean`'s stale
   reflexive-convention note (§7 item 5). (~40 lines changed.)
6. Gate: `lake build`, `#print axioms` on all seven new headline results, full
   `bash scripts/check-module-invariants.sh`.

Each phase is comfortably inside one agent run.

---

## 10. Reference index

| Anchor | Location |
|---|---|
| `BLFormula`, `swapBL`, derived operators | `FormalSystem/BaseLanguage/Formula.lean` |
| `BaseLanguage.Axiom`, `minFrameClass`, `Dense ≤ Dedekind` examples | `FormalSystem/BaseLanguage/Axioms.lean` |
| `BaseLanguage.DerivationTree`, `Derivable`, `lift` | `FormalSystem/BaseLanguage/Derivation.lean` |
| `tr`, `trCtx`, `mem_trCtx`, push-through equations | `FormalSystem/BaseLanguage/Translation.lean` |
| `TruthAt` (6 clauses), `Truth.box_iff`, `Truth.past_iff` (`:305`), `Truth.future_iff` (`:287`) | `FormalSystem/Semantics/Truth.lean` |
| `valid` (`:94`), `SemanticConsequence` (`:125`), `ValidDense` (`:206`), `ValidDiscrete` (`:248`), `ValidDedekind` (`:301`), `ValidDedekindDense` (`:336`), `not_validOn_bot` (`:586`), `hF_nonempty_of_frameAxioms` (`:599`) | `FormalSystem/Semantics/Validity.lean` |
| `soundness` (`:1086`), `soundness_dense` (`:1260`), `soundness_discrete` (`:1406`), `soundness_dedekind` (`:1933`), `not_derivable_nil_bot` (`:1993`), `not_derivable_nil_bot_discrete` (`:2020`) | `FormalSystem/Metalogic/Soundness.lean` |
| `translate`, `derivable_translate`, the four `*_backward` rows, `Z1`, `z1_translate`, and the four stale claims of §7 item 2 | `FormalSystem/Metalogic/Conservativity.lean` |
| `TaskFrame.trivialFrame` | `FormalSystem/Semantics/TaskFrame.lean:1213` |
| `TaskModel.allFalse` | `FormalSystem/Semantics/TaskModel.lean:65` |
| `WorldHistory.IsTotal`, `isTotal_iff` | `FormalSystem/Semantics/WorldHistory.lean:470` |
| `def:BL-semantics`, `thm:TM-soundness`, `def:logical-consequence` pinned rows | `specs/paper-definitions-of-record.md` |
| Atom-clause domain conjunct (Decision A) | `specs/decisions/total-history-validity-decisions.md` |
