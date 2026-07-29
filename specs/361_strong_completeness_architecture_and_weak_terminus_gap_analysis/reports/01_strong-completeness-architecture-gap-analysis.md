# Strong-Completeness Architecture and Weak-Terminus Gap Analysis

**Task**: 361 — `strong_completeness_architecture_and_weak_terminus_gap_analysis`
**Type**: lean4 (analysis / scoping — no proof obligations closed, no Lean written into the tree)
**Date**: 2026-07-28
**Session**: `sess_1785304764_efadf2_361`

## Concurrency compliance

No `lake build`, `lake clean`, or `lean_build` was run. No file under `FormalSystem/` or
`Tests/` was created, edited, or deleted. The only tooling used against the Lean tree was
read-only: `Read`, `grep`, and two `lean_verify` calls (which consume existing oleans and do not
write build artifacts). Every Lean fragment below is a **design proposal in this report**, not a
tree edit.

---

## 0. Executive summary

Four findings, in order of how much they change the plan:

1. **The weak-terminus description in the task brief is materially stale.** Machine-verified
   against current oleans: `completeness_dense` (BXCanonical/Completeness.lean:255) is
   **already sorry-free** — `#print axioms` reports exactly `[propext, Classical.choice,
   Quot.sound]`. Task 170's stated obligation (retire `succ_reaches_dom_N` /
   `chronicle_gap_contradiction` / `MCSMixedCase` sorries) refers to declarations that have all
   been archived to `Boneyard/`; none of them is reachable from `completeness_dense`. **Task 170
   is already satisfied and should be closed as such after an independent re-verification, not
   worked.**

2. **`completeness` (Base, :196) has exactly ONE reachable sorry**, not three. It is
   `WeakCanonical.countermodel_discrete`, `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`
   — a direct terminal `sorry`. The brief's other two named gaps are gone: the dense arm now
   routes through `countermodel_dense_enriched` (Completeness.lean:133, sorry-free), and
   `dd_countermodel_chronicle_mixed_sorry` was replaced by the sorry-free
   `Chronicle.mcs_mixed_case_absurd`.

3. **Of the two remediation routes that `Transfer.lean`'s own docstring proposes for that sorry,
   route (i) is refutable and should be struck.** A Base-MCS containing `□U(⊤,⊥)` need not be
   Discrete-consistent, and I give an explicit witness below (`ℚ ×ₗ ℤ` / `ℤ ×ₗ ℤ` lex refutes
   `Axiom.z1` while validating `□U(⊤,⊥)`). No Base→Discrete MCS transfer lemma can exist. The
   live route is a **non-Archimedean discrete carrier** — and the `succ_cofinal` "ℤ+ℤ
   counterexample" that killed the old BX pipeline stops being an obstruction the moment the
   target carrier is allowed to be non-Archimedean, which `FrameClass.Base` permits.

4. **On strong completeness: the chronicle machinery does NOT extend to model existence, but a
   different and cleaner route exists.** The chronicle route is architecturally blocked by a
   *documented* dependency on finite root closures (see §3.2 — the tree itself states that full
   temporal coherence "requires bounding F-nesting depth, which is unbounded in full MCS
   chains"). The alternative is to prove **semantic compactness** of `⊨_Base` / `⊨_Dense`
   directly, by an ultraproduct argument, and then get strong completeness as
   `compactness + weak completeness` via the *already-proved, frame-class-generic*
   `derivable_foldr_imp_iff`. This bypasses the chronicle entirely. My confidence that Base and
   Dense are compact is **moderately high but not certain** — the supporting argument (§4.2) is
   that every binder in the `valid`/`ValidDense` lists is first-order, whereas the two
   provably-non-compact classes are exactly the two whose binder lists contain a non-elementary
   condition (`IsSuccArchimedean`/`IsPredArchimedean`; the lub property). That is suggestive
   structural evidence, not a proof, and §4.4 names the specific step that could break.

---

## 1. Verified state of the tree

### 1.1 Machine-checked axiom sets

| Declaration | Location | `#print axioms` | Verdict |
|---|---|---|---|
| `completeness_dense` | `Metalogic/BXCanonical/Completeness.lean:255` | `[propext, Classical.choice, Quot.sound]` | **sorry-free** |
| `completeness_discrete` | `.../Completeness.lean:296` | `[propext, Classical.choice, Quot.sound]` (per in-file audit) | sorry-free |
| `completeness` | `.../Completeness.lean:196` | `[propext, sorryAx, Classical.choice, Quot.sound]` | **1 sorry** |

The first and third rows were obtained in this session via `lean_verify` against current
oleans, not read off the file's comments. Completeness.lean and its entire import cone are
unmodified in the working tree (`git status` shows only `Metalogic/Decidability/**` dirty, which
is not in this cone), so the olean answers are current.

### 1.2 Every live `sorry` outside `Boneyard/`

A tree-wide scan for actual `sorry` tokens (as opposed to the many docstrings *containing the
word*) finds exactly three outside `Boneyard/`:

| File:line | Declaration | Reachable from `completeness`? | Reachable from `completeness_dense`? |
|---|---|---|---|
| `Metalogic/WeakCanonical/Transfer.lean:1242` | `countermodel_discrete` | **YES — sole source** | no |
| `Metalogic/WeakCanonical/RealModel/ShuffleReal.lean:201` | `doets_lemma_1_5` | no | no |
| `Metalogic/WeakCanonical/Kamp/Boneyard/*` | (archived sub-tree) | no | no |

`ShuffleReal.doets_lemma_1_5` is on the Reynolds/Dedekind axis and is owned by task 408; it is
not on either weak terminus tracked here. `PriorExpressivenessDense` is now sorry-free (its
former strategic sorry was retired; the docstring at :273-276 records this).

### 1.3 Corrections to the task brief

| Brief claim | Actual state |
|---|---|
| "`completeness` … dense-arm `countermodel_dense`" | The dense arm of `completeness` uses `countermodel_dense_enriched` (Completeness.lean:133), which is sorry-free. `Chronicle.countermodel_dense` (ChronicleToCountermodelBasic.lean:829) is no longer consumed by `completeness`; Completeness.lean:413-415 flags it as retained-pending-archival. |
| "`dd_countermodel_chronicle_mixed_sorry`" | Archived. The mixed case is closed by `Chronicle.mcs_mixed_case_absurd` (MCSMixedCase.lean), sorry-free, used by both `completeness` and `completeness_discrete`. |
| "`completeness_dense` … inherits ChronicleToCountermodel.lean `succ_reaches_dom_N` / `chronicle_gap_contradiction`; MCSMixedCase.lean" | All three are gone from live code. `succ_reaches_dom_N` and `chronicle_gap_contradiction` live only in `Boneyard/DeadChronicleGapElimination/` and `Boneyard/SorriedDeclExcisions/`. `MCSMixedCase.lean` exists and is sorry-free. `completeness_dense` is verified clean. |
| "`countermodel_discrete` … deprecated Transfer.lean route" | Correct, and it is the *only* remaining gap. |

**Recommendation**: update task 170's description (and its status) before any implementation
dispatch is spent on it.

---

## 2. Deliverable 1 — the set-based layer

Everything below is a proposal. Nothing here exists in the tree; nothing here was written to
the tree.

### 2.1 Finitary set-derivability

```lean
namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/--
Finitary derivability from a possibly-infinite premise set. A derivation is a finite object
and can cite only finitely many premises, so this is the only derivability notion a finitary
proof system can support over `Set Formula`.
-/
def SetDerivable (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop :=
  ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ
```

This is exactly the relation named in `StrongCompleteness.lean`'s module docstring (:36-37) and
in the `consequence_completeness_dedekind_of_engine` docstring (:259). Its shape deliberately
matches `SetConsistent` (`Core/MaximalConsistent.lean:96`), which quantifies over
`L : List Formula` with `(∀ φ ∈ L, φ ∈ S)` — so the two compose without an adapter.

### 2.2 Per-class set-based semantic consequence

Each definition below is the corresponding validity predicate's binder list **verbatim** from
`FormalSystem/Semantics/Validity.lean`, with the premise hypothesis
`(∀ ψ ∈ Γ, TruthAt M Omega τ t ψ)` inserted before the conclusion — the same surgery that
`SemanticConsequenceDedekindDense` (StrongCompleteness.lean:128) performs on
`ValidDedekindDense`. `Γ : Set Formula` rather than `Γ : Context` is the only difference from
the finite-context forms; `∀ ψ ∈ Γ` elaborates identically for `Set` and `List`.

```lean
/-- Set-based semantic consequence over `FrameClass.Base`. Binder list: `valid` (Validity.lean:79). -/
def SetSemanticConsequenceBase (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ

/-- Set-based semantic consequence over `FrameClass.Dense`. Binder list: `ValidDense` (:169). -/
def SetSemanticConsequenceDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ

/-- Set-based semantic consequence over `FrameClass.Discrete`. Binder list: `ValidDiscrete` (:187).
    Stated for completeness of the layer; strong completeness at this class is REFUTED
    (non-compactness — see §5). -/
def SetSemanticConsequenceDiscrete (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ

/-- Set-based semantic consequence over dense Dedekind-complete carriers. Binder list:
    `ValidDedekindDense` (:276) — the `soundness_dedekind` target. Non-compact; see §5. -/
def SetSemanticConsequenceDedekindDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ
```

A `SetSemanticConsequenceDedekind` against `ValidDedekind` (:241, no `DenselyOrdered`) can be
added by the same recipe; it is not the soundness target and is not needed by the programme.

### 2.3 Basic lemmas

```lean
/-! ### Monotonicity -/

theorem setDerivable_mono {fc : FrameClass} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetDerivable fc Γ φ) : SetDerivable fc Δ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact ⟨L, fun ψ hψ => h_sub (hL ψ hψ), hd⟩

theorem setSemanticConsequenceBase_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceBase Γ φ) : SetSemanticConsequenceBase Δ φ := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t h_all
  exact h D F M Omega h_sc τ h_mem t (fun ψ hψ => h_all ψ (h_sub hψ))
-- and the three siblings, each a one-line binder permutation of this.

/-! ### Finite restriction / agreement with the finite-context layer -/

/-- Every set-derivation restricts to a finite context. Definitional, but worth naming: it is
    the statement the compactness argument consumes. -/
theorem setDerivable_iff_exists_finite {fc : FrameClass} (Γ : Set Formula) (φ : Formula) :
    SetDerivable fc Γ φ ↔ ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ :=
  Iff.rfl

/-- A finite context is set-derivable from its own carrier set. -/
theorem setDerivable_of_derivable {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : Derivable fc Γ φ) : SetDerivable fc (Core.contextToSet Γ) φ :=
  ⟨Γ, fun _ hψ => hψ, h⟩

/-- …and conversely, so the set layer is a conservative extension of the finite layer. -/
theorem derivable_of_setDerivable_contextToSet {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : SetDerivable fc (Core.contextToSet Γ) φ) : Derivable fc Γ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact hd.weaken hL

/-- Membership gives derivability. -/
theorem setDerivable_of_mem {fc : FrameClass} {Γ : Set Formula} {φ : Formula} (h : φ ∈ Γ) :
    SetDerivable fc Γ φ :=
  ⟨[φ], by simpa using h, ⟨DerivationTree.assumption _ _ (by simp)⟩⟩

/-! ### The bridge to `SetConsistent` (already in the tree, Core/MaximalConsistent.lean:96) -/

theorem not_setConsistent_of_setDerivable_bot {fc : FrameClass} {Γ : Set Formula}
    (h : SetDerivable fc Γ Formula.bot) : ¬ Core.SetConsistent (fc := fc) Γ := by
  obtain ⟨L, hL, hd⟩ := h
  exact fun hcons => hcons L hL hd
```

### 2.4 The statement of strong completeness, and how it is discharged

```lean
/-- **Strong completeness for `FrameClass.Dense`** — the reserved statement. -/
def StrongCompletenessDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceDense Γ φ → SetDerivable FrameClass.Dense Γ φ

/-- Semantic compactness of the Dense consequence relation, stated in the form the
    completeness derivation actually consumes. -/
def CompactDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDense Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDense (L.foldr Formula.imp φ)

/--
**Strong completeness = compactness + weak completeness.** No new proof-theoretic machinery,
no `Γ`-relative Lindenbaum, no widened subformula root: the countermodel engine is used
unchanged, as a single-formula engine, exactly as `StrongCompleteness.lean`'s engine contract
(:40-43) specifies.

`derivable_foldr_imp_iff` (StrongCompleteness.lean:222) is already proved and already generic
in `fc`, so it needs no per-class instance.
-/
theorem strongCompletenessDense_of_compact (hc : CompactDense)
    (engine : ∀ ψ : Formula, ValidDense ψ → Derivable FrameClass.Dense [] ψ) :
    StrongCompletenessDense := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩
```

For Dense the `engine` hypothesis is **already dischargeable today**: `completeness_dense` has
exactly that type and is sorry-free. So `CompactDense` is the *entire* remaining obligation for
Dense strong completeness. For Base the analogous statement additionally waits on the
Transfer.lean sorry (task 169).

A more natural equivalent form of compactness — "every finitely satisfiable set is satisfiable"
— is also worth landing, since it is what the ultraproduct construction proves directly:

```lean
def SatisfiableDenseSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : DenselyOrdered D) (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    ∀ ψ ∈ Γ, TruthAt M Omega τ t ψ

def ModelExistenceDense : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableDenseSet {ψ | ψ ∈ L}) →
    SatisfiableDenseSet Γ
```

`ModelExistenceDense → CompactDense` is a contraposition through the `Formula.neg` clause of
`TruthAt` and `truthAt_foldr_imp` (StrongCompleteness.lean:147, already proved and already
stated at the bare `TaskModel` binder set so it is reusable here unchanged).

---

## 3. Deliverable 2 — feasibility verdict for Base and Dense strong completeness

### 3.1 The question, precisely

Two separable questions were conflated in earlier framing, and the plan should keep them apart:

- **(Q1) Mathematical**: is `⊨_Base` / `⊨_Dense` compact?
- **(Q2) Architectural**: does the existing BXCanonical chronicle machinery deliver a
  model-existence theorem for arbitrary `SetConsistent` sets?

My verdict is **Q1: probably yes, with a named residual risk** and **Q2: no — and the blocker is
documented in the tree itself.** These have opposite signs, which is why the recommended route
below abandons the chronicle for this purpose rather than extending it.

### 3.2 Q2 — the chronicle route does not reach model existence

The obstruction is not a missing lemma; it is the architecture of the truth lemma.

Every countermodel in this tree is produced by
`fully_restricted_parametric_completeness_from_neg_membership`
(`Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:417`), whose three coherence
hypotheses are all **root-relative**:

- `BFMCS.RestrictedTemporallyCoherent root` (Bundle/TemporalCoherence.lean:308) quantifies only
  over `φ ∈ deferralClosure root`;
- `RestrictedForwardUntilSinceCoherent root` (:558) and
  `RestrictedBackwardUntilSinceCoherent root` (:589) quantify only over
  `subformulaClosure root`.

Both `subformulaClosure` (`Syntax/SubformulaClosure/Closure.lean:36`) and `deferralClosure`
(`Syntax/SubformulaClosure/TemporalFormulas.lean:276`) return `Finset Formula`. A strong
completeness argument for an infinite `Γ` needs the truth lemma at every `ψ ∈ Γ`, hence
coherence over `⋃_{ψ ∈ Γ} subformulaClosure ψ` — a countably infinite set, not a `Finset`.

The tree states explicitly *why* the unrestricted version is not available
(TemporalCoherence.lean:293-298, verbatim):

> The existing `TemporalCoherentFamily` quantifies forward_F/backward_P over ALL formulas.
> Proving this for a chain construction requires bounding F-nesting depth, which is unbounded
> in full MCS chains. The restricted variant only quantifies over `deferralClosure(root)`,
> where F-nesting IS bounded (by `maxFDepthInClosure`), making the coherence proof achievable
> via the BXCanonical chain construction's bounded subformula closure.

The bounded F-nesting depth of the root closure is *load-bearing for the construction*, and it
is exactly what an infinite premise set destroys. `BFMCS.temporally_coherent_implies_restricted`
(:319) exists but points the wrong way. So the substantive obligation on this route would be
"construct a BFMCS satisfying `TemporallyCoherent` / `ForwardUntilSinceCoherent` /
`BackwardUntilSinceCoherent` unrestricted" — i.e. re-do the chronicle construction with an
unbounded eventuality schedule. That is a research programme, not a phase.

**Verdict on the brief's stated question**: the chronicle machinery does *not* extend to a
model-existence theorem in any way I would call incremental. The single-formula countermodel
engines indeed do not suffice, and neither does a mild generalization of them.

### 3.3 Q1 — the compactness argument, and the route it opens

The semantics has a feature that makes an ultraproduct argument unusually clean: **`TruthAt`
never mentions `TaskRel`, `respects_task`, or `convex`.** Reading `Semantics/Truth.lean:128-137`:

```
| Formula.atom p  => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
| Formula.bot     => False
| Formula.imp φ ψ => TruthAt … φ → TruthAt … ψ
| Formula.box φ   => ∀ σ, σ ∈ Omega → TruthAt M Omega σ t φ
| Formula.untl φ ψ => ∃ s, t < s ∧ TruthAt … s φ ∧ ∀ r, t < r → r < s → TruthAt … r ψ
| Formula.snce φ ψ => ∃ s, s < t ∧ TruthAt … s φ ∧ ∀ r, s < r → r < t → TruthAt … r ψ
```

The frame's algebraic content reaches the truth definition only through the atom clause, which
is a plain binary relation `A_p(σ, t)`. That yields a **representation theorem**:

> Let `⟨Ω, D, sh, A⟩` be a *shift set*: `D` an ordered abelian group, `Ω` a nonempty type with a
> `D`-action `sh : Ω → D → Ω`, and `A : Atom → Ω → Prop`. Define
> `WorldState := Ω`, `TaskRel w d u := (u = sh w d)`, `domain := Set.univ`,
> `states σ t := sh σ t`, `valuation w p := A p w`, `Omega := Set.range (fun σ => h_σ)`.
> Then `nullity_identity`, `forward_comp`, `converse`, `convex`, and `respects_task` all hold by
> construction, `Omega` is `ShiftClosed` because `sh` is an action, and
> `TruthAt` in this model is determined by `A` alone.
>
> Conversely, from any `(F, M, Omega, ShiftClosed Omega)` take `Ω := Omega`,
> `sh σ Δ := WorldHistory.timeShift σ Δ` (lands in `Omega` by shift-closure) and
> `A p σ := TruthAt M Omega σ 0 (atom p)`; `TimeShift.time_shift_preserves_truth`
> (Truth.lean) supplies the compatibility `A_p (sh σ Δ) t ↔ A_p σ (t + Δ)`.

Two consequences:

1. **Every binder of `valid` and `ValidDense` is first-order** over the two-sorted signature
   `⟨Ω, D; <, +, 0, sh, (A_p)⟩`: `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`,
   `Nontrivial` (`∃x, x ≠ 0`), `DenselyOrdered` (`∀x y, x<y → ∃z, x<z<y`). And `TruthAt` is a
   literal standard translation into that signature. First-order compactness therefore *predicts*
   that `⊨_Base` and `⊨_Dense` are compact.

2. **The two classes that are provably non-compact are exactly the two with a non-elementary
   binder**: `ValidDiscrete` carries `IsSuccArchimedean`/`IsPredArchimedean`; `ValidDedekind(Dense)`
   carries the least-upper-bound `Prop`. Neither is preserved by ultraproducts. This is not a
   coincidence — it is the same phenomenon, seen from the model-theoretic side, that the brief
   already records as settled for those two classes.

That correspondence is the strongest single piece of evidence available without doing the work,
and it is why I would rate Base/Dense compactness as **likely** rather than open-ended.

**Recommended Lean route (Route B)**, which avoids formalizing the standard translation into
Mathlib's `FirstOrder.Language` (single-sorted, and the encoding cost would dominate):

- Prove the representation theorem above (§3.3) so that the model class becomes shift sets.
- Build a bespoke ultraproduct of shift sets over an ultrafilter on the index type
  `{L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}`.
- Prove a Łoś lemma for `TruthAt` by induction on `Formula` — six cases, each mechanical.
- Conclude `ModelExistenceDense` / `ModelExistenceBase`, hence `CompactDense` / `CompactBase`,
  hence strong completeness via §2.4.

### 3.4 Main technical risks (stated as risks, not as blockers)

1. **Dependent ultraproduct of carriers.** Each finite subset may be satisfied over a different
   `D_L`. Mathlib's ordered instances live on the *non-dependent* `Filter.Germ l β`
   (`Mathlib/Order/Filter/FilterProduct.lean:92` gives `LinearOrder β*` for an `Ultrafilter`);
   the dependent `Filter.Product ε` (`Order/Filter/Germ/Basic.lean:100`) has no ordered-group
   instances. Either a bespoke quotient of `∀ i, D i` with ~15 hand-supplied instances, or a
   prior normalization step forcing a common carrier, is needed. I estimate one phase-sized
   file, but this is the single largest unknown in the estimate.
2. **The `box` case of Łoś.** `box` quantifies over the whole history sort `Ω*`, so the
   induction needs `(∀ σ* ∈ Ω*, P σ*) ↔ ∀*i, (∀ σ ∈ Ω_i, P_i σ)`. The `←` direction is
   immediate; `→` needs a choice-function argument to assemble a pointwise counterexample.
   Standard, but it is the step where a careless statement of the ultraproduct would fail.
3. **`Type` vs `Type*`.** `valid` and friends deliberately use `Type` "to avoid universe level
   issues" (Validity.lean:77). The ultraproduct quotient must land in `Type`; with the index
   type in `Type` this is fine, but the phase should assert it early rather than discover it at
   assembly time.
4. **Honest uncertainty.** I have not constructed a compactness *proof*, only an argument from
   the elementarity of the binder lists plus the representation theorem. If `TruthAt` had any
   clause quantifying over subsets of `D`, or if `ShiftClosed`/`τ ∈ Omega` could not be captured
   by the shift action, the argument would collapse. I read all six `TruthAt` clauses,
   `ShiftClosed` (Truth.lean:333), `WorldHistory` (WorldHistory.lean:75-104) and `TaskFrame`
   (TaskFrame.lean:99-128) directly, and none of them does — but a formalization could still
   surface a clause I mis-read. **Verdict: promising, not certain. Gate the strong-completeness
   sub-tasks behind a small feasibility phase (S1 below) that lands the representation theorem
   first; if S1 fails, the whole of Route B is refuted cheaply.**

---

## 4. Deliverable 3 — the weak termini, and how to close Base

### 4.1 Dense (task 170)

**Nothing to close.** `completeness_dense` is verified sorry-free. Recommended action: an
independent re-verification (`#print axioms` after a clean build, run by whoever holds the build
lock next), then mark task 170 `[COMPLETED]` with a completion summary recording the verified
axiom set. Do not dispatch an implementation agent at it.

### 4.2 Base (task 169) — the single gap

The gap is `WeakCanonical.countermodel_discrete` (Transfer.lean:1225-1242). Its obligation:

```lean
theorem countermodel_discrete (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box nextTop ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬TruthAt TM Omega τ t φ
```

Note what the conclusion does **not** demand: it does not require `D` to be `ℤ`, discrete,
Archimedean, or anything beyond a nontrivial ordered abelian group. Any carrier will do. This
matters enormously for route selection.

#### Route (i) — Base-MCS → Discrete-MCS transfer: REFUTED

`Transfer.lean:1239-1241` proposes "(i) a Base-MCS → Discrete-MCS transfer lemma that lets
`countermodel_discrete_reynolds_v2` apply". **No such lemma can exist**, and the witness is
cheap.

`FrameClass.Discrete` adds exactly three axiom schemes over Base (`Axioms.lean:556-561`):
`prior_UZ φ : F φ → U(φ, ¬φ)`, `prior_SZ φ : P φ → S(φ, ¬φ)`, and
`z1 φ : G(Gφ → φ) → (FGφ → Gφ)` — the last being, per its own docstring (:327-331), "the
characteristic axiom of `IsSuccArchimedean` frames".

Take `D := ℤ ×ₗ ℤ` (lexicographic, first coordinate dominant) and let `p` hold exactly at points
`≥ (1,0)`.

- Every point `(a,b)` has immediate successor `(a,b+1)`, so `U(⊤,⊥)` holds everywhere, hence
  `□U(⊤,⊥)` holds. So the MCS of the model at `(0,0)` satisfies `h_box_discrete`.
- `Gp` holds exactly at points `≥ (1,0)`; therefore `Gp → p` holds everywhere, so `G(Gp → p)`
  holds at `(0,0)`.
- `FGp` holds at `(0,0)` (witness `(1,0)`), but `Gp` fails at `(0,0)` (witness `(0,1) ⊁ (1,0)`).
- So `z1 p` is **false** at `(0,0)`.

Hence `{□U(⊤,⊥), G(Gp→p), FGp, ¬Gp}` is satisfiable over an ordered abelian group, therefore
Base-consistent, therefore (Lindenbaum, `set_lindenbaum`, MaximalConsistent.lean:303) extends to
a Base-MCS `A` with `□U(⊤,⊥) ∈ A` that is Discrete-**in**consistent. Route (i) is dead; its two
sentences in `Transfer.lean`'s docstring should be corrected as part of the fix.

#### Route (iii) — reuse the ℚ dense chronicle: BLOCKED, and here is where

Tempting, because the restricted truth lemma only constrains `subformulaClosure φ`, and
`U(⊤,⊥)` need not be in it. But `h_box_dense` is not bookkeeping: it feeds
`box_dense_gives_density` (ChronicleToCountermodelBasic.lean:435), which is what licenses the
Cantor isomorphism of the chronicle order with `ℚ` used by `rootedCantorFmcsDense` (:500-506)
and threaded through all three `cantor_bfmcs_dense_restricted_*` proofs (:629, :682, :757). With
`□U(⊤,⊥) ∈ A` the chronicle order is discrete, and the `ℚ` isomorphism is simply unavailable.
Route (iii) requires a *different* carrier, which is route (ii).

#### Route (ii) — non-Archimedean discrete carrier: RECOMMENDED

The old BX pipeline died at `succ_cofinal`, refuted by the "ℤ+ℤ counterexample"
(`Boneyard/BXPipelineGapAnalysis/`). But `succ_cofinal` was only needed to force the chronicle
into `ℤ` — i.e. to make it **Archimedean**. `FrameClass.Base` imposes no Archimedean-ness
(`valid`, Validity.lean:79, has no `IsSuccArchimedean` binder), so the ℤ+ℤ shape is not a
counterexample to the construction; **it is the intended carrier**.

Concretely: a countable discrete linear order without endpoints decomposes into ℤ-blocks whose
block order is a countable linear order; if the block order is densified (the same Cantor step
already used in the dense branch) the carrier `ℚ ×ₗ ℤ` — lexicographic, `ℚ` dominant — is
- an ordered abelian group (lex product of ordered abelian groups),
- discretely ordered with successor `(q, n) ↦ (q, n+1)`, so it validates `U(⊤,⊥)` everywhere,
- non-Archimedean, so `z1` is not required of it,
- countable, so the existing Cantor/chronicle bookkeeping transfers.

**Risk to check first**: Mathlib's `Prod.Lex` has `LinearOrder`, but I did not find an
`IsOrderedAddMonoid (α ×ₗ β)` instance under `Mathlib/Algebra/Order/`. If absent it is a short
supply (translation-invariance of the lex order is a two-case argument), but the phase should
verify instance availability before committing.

### 4.3 Deliverable 4 — the Discrete non-compactness witness

Worth doing, cheap, and independent of everything else. It converts the prose in
`StrongCompleteness.lean:56-62` into a machine-checked theorem, and it is the negative half that
justifies the whole per-class split.

Statement sketch (report-only):

```lean
/-- The premise set `{F p} ∪ {¬ Xⁿ p : n ∈ ℕ}`, where `X φ = Formula.next φ = untl φ bot`. -/
def archWitness (p : Atom) : Set Formula :=
  {(Formula.atom p).someFuture} ∪ {ψ | ∃ n : Nat, ψ = (Formula.next^[n] (Formula.atom p)).neg}

/-- Every finite subset is satisfiable over `ℤ`: place `p` beyond the largest `n` used. -/
theorem archWitness_finitely_satisfiable (p : Atom) (L : List Formula)
    (hL : ∀ ψ ∈ L, ψ ∈ archWitness p) : SatisfiableDiscreteSet {ψ | ψ ∈ L} := …

/-- No Archimedean discrete carrier satisfies the whole set: the `F p` witness lies at some
    finite successor distance, contradicting the corresponding `¬ Xⁿ p`. -/
theorem archWitness_not_satisfiable (p : Atom) : ¬ SatisfiableDiscreteSet (archWitness p) := …

/-- Hence `⊨_Discrete` is not compact, hence strong completeness is REFUTED for this class
    (a derivation cites only finitely many premises). -/
theorem discrete_consequence_not_compact : ¬ CompactDiscrete := …
```

The load-bearing ingredient — that `Formula.next φ = Formula.untl φ Formula.bot`
(`Syntax/Formula.lean:490`) truly is a next-step operator — is immediate from the `untl` clause
of `TruthAt`: `∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ⊥` says exactly that `s` is the immediate successor.
The `¬ satisfiable` half is where `IsSuccArchimedean` is used, via
`Order.succ_iterate`-style reachability lemmas in Mathlib.

An analogous Dedekind witness is *not* recommended here: it belongs to task 408, and the brief
already records the class's non-compactness as established.

---

## 5. Sub-task decomposition and dependency graph

Each item below is sized for one agent run. Items marked **(new)** do not correspond to an
existing task number.

### 5.1 Items

| ID | Title | Scope | Est. |
|---|---|---|---|
| **T170-verify** | Verify and close Dense weak terminus | Clean-build `#print axioms completeness_dense`; record the axiom set; update task 170 description (it names archived declarations) and mark `[COMPLETED]`. **No Lean edits.** | small |
| **B0** (new) | Correct `Transfer.lean` route guidance | Replace the "candidate route (i)" paragraph (Transfer.lean:1239-1241) with the refutation in §4.2 and point at route (ii). Docstring-only. | small |
| **B1** (new) | Non-Archimedean discrete carrier: instance probe | Confirm/supply `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial` for `ℚ ×ₗ ℤ`; add a `CarrierProbe`-style `example` block mirroring `CompletenessDedekind.lean:61-100` showing the parametric canonical machinery elaborates at that carrier. | 1 phase |
| **B2** (new) | Discrete chronicle over the block carrier | The analogue of `box_dense_gives_density` + `cantorIsoDense` for the `□U(⊤,⊥)` case: block decomposition, densified block order, iso into `ℚ ×ₗ ℤ`. | 2-3 phases |
| **B3** (new) | `restricted_*` coherence for the discrete chronicle | The three `cantor_bfmcs_*_restricted_{tc,buc,fuc}` analogues at the new carrier. | 2 phases |
| **B4** = task **169** | Close `countermodel_discrete`, rewire `completeness` | Assemble B1-B3 into `countermodel_discrete`; delete the Transfer.lean sorry; re-verify `#print axioms completeness` reports no `sorryAx`. | 1 phase |
| **S0** (new) | Set-based layer | Land §2.1-§2.3 in a new module (suggested `Metalogic/SetConsequence.lean`, imported by `StrongCompleteness.lean`). Pure definitions + easy lemmas; zero sorries expected. | 1 phase |
| **S1** (new) | Shift-set representation theorem | §3.3 both directions. **Gate: if this fails, Route B is refuted and S2-S5 are cancelled.** | 2 phases |
| **S2** (new) | Ultraproduct carrier | Bespoke dependent ultraproduct of ordered abelian groups + instances + `DenselyOrdered`/`Nontrivial` preservation. Largest unknown (§3.4 risk 1). | 2-3 phases |
| **S3** (new) | Łoś lemma for `TruthAt` | Induction on `Formula`, six cases, over ultraproducts of shift sets. | 2 phases |
| **S4** (new) | Compactness of `⊨_Base` and `⊨_Dense` | Assemble S1-S3 into `ModelExistenceBase`/`ModelExistenceDense`, then `CompactBase`/`CompactDense`. | 1 phase |
| **S5-Dense** (new) | Strong completeness for `FrameClass.Dense` | §2.4 with `engine := completeness_dense`. Small once S4 lands. | 1 phase |
| **S5-Base** (new) | Strong completeness for `FrameClass.Base` | §2.4 with `engine := completeness`. Requires B4. | 1 phase |
| **D1** (new) | Discrete non-compactness, machine-checked | §4.3. Independent of everything except S0's vocabulary. | 2 phases |

### 5.2 Dependency graph

```
T170-verify ──(independent, do first, cheap)

B0 ──▶ B1 ──▶ B2 ──▶ B3 ──▶ B4 (=task 169) ──┐
                                              │
S0 ──┬──▶ D1                                  │
     │                                        ▼
     └──▶ S5-Dense ◀── S4 ◀── S3 ◀──┬── S1   S5-Base
                                     └── S2    ▲
                                               │
                              S4 ──────────────┘
```

Read as: `S5-Base` depends on both `S4` and `B4`. `S5-Dense` depends on `S4` and `S0` only —
**it does not wait on the Base weak terminus**, because `completeness_dense` is already green.
That makes Dense the natural first strong-completeness target.

`S1` is the gate for the whole S-branch. Schedule it before `S2`, and do not authorize `S2`
(the expensive one) until `S1` lands.

### 5.3 Suggested spawn set

Concretely, I would spawn: **B0+B1 as one task** (both are small and both touch the same
route-selection question), **B2+B3 as one task** (they share the block-carrier construction),
**S0 as one task** (it is self-contained and unblocks two branches), **S1 as one task** (the
gate), and **D1 as one task** (independent, and it retires a prose claim). `S2`/`S3`/`S4`/`S5-*`
should be spawned only after S1 returns positive; spawning them now would commit plan budget to
a branch that S1 can refute in one run.

---

## 6. Open questions I did not resolve

1. **Is `⊨_Base` actually compact?** §3.3 gives a structural argument, not a proof. S1 is the
   cheap gate.
2. **Does the block decomposition in B2 actually land in an ordered *group*?** A countable
   discrete order without endpoints is a ℤ-indexed fibration over its block order, but making
   the total structure a *group* requires the block order to carry a compatible group
   structure. Densifying the block order into `ℚ` is the natural move and is what the dense
   branch already does — but I did not verify that the chronicle's block order can always be
   densified without disturbing the MCS-chain coherence. This is the main risk in B2.
3. **`consequence_completeness_*` for Base/Dense/Discrete** (the finite-context layer reserved
   at StrongCompleteness.lean:314-340) is not scoped here — it is task 362's territory, and it
   is mechanical once each class's engine exists (`truthAt_foldr_imp` and
   `derivable_foldr_imp_iff` are already generic).

---

## 7. Sources read

All file:line references above were obtained by reading the tree in this session, not from the
task description. Primary files consulted:

- `FormalSystem/Semantics/Validity.lean` (binder lists, verbatim)
- `FormalSystem/Semantics/Truth.lean` (`TruthAt`, `ShiftClosed`)
- `FormalSystem/Semantics/TaskFrame.lean`, `WorldHistory.lean` (frame conditions)
- `FormalSystem/Metalogic/StrongCompleteness.lean` (programme, engine contract, fold lemmas)
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` (three termini, axiom audit)
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (carrier probe pattern)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` (Cantor
  construction, `box_dense_gives_density`)
- `FormalSystem/Metalogic/Bundle/BFMCS.lean`, `Bundle/TemporalCoherence.lean` (coherence
  definitions and the bounded-F-nesting note)
- `FormalSystem/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (the truth lemma)
- `FormalSystem/Metalogic/Core/MaximalConsistent.lean` (`SetConsistent`, `set_lindenbaum`)
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` (the sorry and its route guidance)
- `FormalSystem/ProofSystem/Axioms.lean` (`FrameClass`, `minFrameClass`, Discrete axioms)
- `.lake/packages/mathlib/Mathlib/Order/Filter/FilterProduct.lean`,
  `Order/Filter/Germ/Basic.lean`, `ModelTheory/Satisfiability.lean` (ultraproduct support)
