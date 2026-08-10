> **SUPERSEDED** (2026-08-10): written against the maximal-history (Mathlib `IsMax`) validity target, superseded by the paper's totality-based `H_F` (`\label{def:world-history}`: a world history is *total* iff `X = D`) and its four-axiom `\label{def:frame}`. The `Preorder`/Zorn/`chainSup` engine material survives; the target predicate does not. See specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md (Deliverable 4) for what survives, and specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/02_logical-consequence-discrepancy-audit.md (Findings 1b/4) for what report 01 itself got superseded on.

# Research Report: Omega-Free Maximal-History Validity Refactor

- **Task**: 414 `refactor_semantics_to_maximal_history_validity`
- **Session**: sess_1785280411_23b0e6_414
- **Date**: 2026-07-28
- **Agent**: lean-research-hard-agent (H2+H3+H4 active; H5 not triggered)
- **Reference grounding**: **Tier 1 (literature-backed)** — authority:
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md` sections B1 and C1
  (decision text at fix.md:77, 81, 120, 132), paper source
  `/home/benjamin/Philosophy/Papers/possible_worlds.tex` (def:world-history at line 1833).

## Summary

The refactor is **fully feasible and the mathematically hard part is already de-risked**: a
complete, sorry-free Lean prototype of task part (1) — the extension `Preorder` on
`WorldHistory`, time-shift monotonicity, **maximality preserved by time-shift**
(`isMax_timeShift`), the hand-built chain-union upper bound, and **every history extends to a
maximal one** via `zorn_le_nonempty_Ici₀` — was type-checked against the pinned repo + Mathlib
during this research (§ Verified Prototype, ~85 lines, zero sorries, zero errors). Part (2)
(Omega removal from `TruthAt`/`valid`/`satisfiable`/consequence) is a mechanical signature
change. Part (3) (Soundness propagation) survives **mathematically verbatim**: the only two
substantive `ShiftClosed` consumption patterns in the entire soundness chain map one-for-one
onto `isMax_timeShift`; textually every soundness proof needs a mechanical binder rewrite
(drop `Omega`/`h_sc`/`h_mem`, thread maximality instead). The single open planning decision is
what to do **in this task** with the completeness/decidability bridge files (415/417
territory): they rest on singleton-Omega box-transparency, which is **mathematically false**
under maximal-history semantics and cannot be mechanically ported — recommendation: move them
to `Boneyard/` in 414 so the build stays green (§ Finding 9).

## Findings

### Finding 1 — Lemma mapping table (H3 Tier 1, 5-column)

| Paper claim (fix.md / tex location) | Informal statement | Target Lean name | Lean signature | Status |
|---|---|---|---|---|
| fix.md:77 "restrict H_F to maximal histories" (B1 Decision, Option 1) | Box/validity quantify over maximal histories only | box clause of `TruthAt` | `\| Formula.box φ => ∀ σ : WorldHistory F, IsMax σ → TruthAt M σ t φ` | to-prove (mechanical edit of `FormalSystem/Semantics/Truth.lean:133`) |
| tex:1833-1835 def:world-history | history = convex-domain partial function respecting task relation | `WorldHistory` | existing structure, `FormalSystem/Semantics/WorldHistory.lean:75` | exists (unchanged by this task) |
| Task desc. (1) / fix.md:69 "sigma extends tau iff tau.domain ⊆ sigma.domain and states agree on tau.domain" | Extension order on histories | `instance : Preorder (WorldHistory F)` | `le τ σ := (∀ t, τ.domain t → σ.domain t) ∧ ∀ t (ht : τ.domain t) (ht' : σ.domain t), σ.states t ht' = τ.states t ht` | **verified sorry-free in prototype** |
| Task desc. (1) "the Maximal predicate" | maximality w.r.t. extension order | Mathlib `IsMax` (used directly; see Finding 4 naming note) | `IsMax : {α : Type*} → [LE α] → α → Prop` (i.e. `∀ ⦃b⦄, a ≤ b → b ≤ a`) | Mathlib-backed (verified by `#check` and `Iff.rfl` unfolding) |
| fix.md:69, 77 "Every history extends to a maximal one (Zorn) … re-verified" | Zorn extension | `WorldHistory.exists_maximal_extension` | `(τ : WorldHistory F) : ∃ σ, τ ≤ σ ∧ IsMax σ` | **verified sorry-free in prototype** (via `zorn_le_nonempty_Ici₀`) |
| fix.md:69, 77 "maximality is preserved by time-shift … re-verified" | shift preservation | `WorldHistory.isMax_timeShift` | `{σ : WorldHistory F} (h : IsMax σ) (Δ : D) : IsMax (timeShift σ Δ)` | **verified sorry-free in prototype** |
| fix.md:132 (C1 Decision) "the Omega parameter is removed; the false docstrings at Semantics/Validity.lean:33, 70-71 disappear" | Omega-free `valid` | `valid` | `∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F), IsMax τ → ∀ t : D, TruthAt M τ t φ` | to-prove (edit of `FormalSystem/Semantics/Validity.lean:79`) |
| fix.md:69 / task desc. (3) "soundness proofs … survive verbatim" | Soundness propagates | `soundness` and 70+ axiom-validity lemmas | unchanged statements modulo binder deletion | to-prove; **survives mathematically verbatim** (Finding 7; adversarially qualified in § Adversarial Self-Verification) |
| fix.md:77 "in any serial frame every maximal history is total" (context only, not this task's obligation) | totality ⇒ maximality (converse direction useful now) | `WorldHistory.isMax_of_total` | `{τ : WorldHistory F} (h : ∀ t, τ.domain t) : IsMax τ` | **verified sorry-free in prototype** (rescues total-history countermodels in 415) |

### Finding 2 — Exact Mathlib Zorn API in the pinned Mathlib (v4.33.0-rc1)

Verified by `lean_local_search` + direct read of
`.lake/packages/mathlib/Mathlib/Order/Zorn.lean:96-141` + `#check` via `lean_run_code`:

- **`zorn_le_nonempty_Ici₀`** — the exact "every element extends to a maximal one" form:
  ```
  theorem zorn_le_nonempty_Ici₀ [Preorder α] (a : α)
      (ih : ∀ c ⊆ Set.Ici a, IsChain (· ≤ ·) c → ∀ y ∈ c, ∃ ub, ∀ z ∈ c, z ≤ ub)
      (x : α) (hax : a ≤ x) : ∃ m, x ≤ m ∧ IsMax m
  ```
  Instantiate `a := τ`, `x := τ`, `hax := le_rfl`. Chain obligation is for **nonempty** chains
  only (`∀ y ∈ c`), and the upper bound need not lie in `Ici a` — both facts simplify the
  chain-union obligation. Requires only `[Preorder α]`, so **no `PartialOrder` instance (no
  antisymmetry / no `WorldHistory` extensionality lemma) is needed** for the Zorn argument.
- Also available: `zorn_le`, `zorn_le_nonempty` (whole-type maximum existence, `IsMax`),
  `zorn_le₀`, `zorn_le_nonempty₀` (set-relative, `Maximal (· ∈ s)`).
- **`zorn_partialOrder` does NOT exist** in this Mathlib (older name; `lean_local_search`
  returns empty). Do not cite it in the plan.
- `IsChain.total` (used by the chain-union construction) works for `(· ≤ ·)` on a `Preorder`
  via the ambient `IsRefl` instance — confirmed implicitly by the prototype compiling.
- Mathlib's root-namespace **`Maximal : (α → Prop) → α → Prop`** exists and takes a predicate
  first; it is NOT the right predicate here (`IsMax` is). See naming note in Finding 4.

### Finding 3 — Verified Prototype (type-checked sorry-free against the repo, first attempt)

The following compiled via `lean_run_code` with **zero errors and zero sorries** (only two
unused-binder lint warnings), importing `FormalSystem.Semantics.WorldHistory` and
`Mathlib.Order.Zorn`. This is directly liftable into `WorldHistory.lean`:

```lean
import FormalSystem.Semantics.WorldHistory
import Mathlib.Order.Zorn

namespace FormalSystem.Semantics
namespace WorldHistory

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}

/-- Extension order: `τ ≤ σ` iff `σ` extends `τ` (domain inclusion + state agreement). -/
instance : Preorder (WorldHistory F) where
  le τ σ := (∀ t, τ.domain t → σ.domain t) ∧
    ∀ t (ht : τ.domain t) (ht' : σ.domain t), σ.states t ht' = τ.states t ht
  le_refl τ := ⟨fun _ h => h, fun _ _ _ => rfl⟩
  le_trans τ σ υ h1 h2 :=
    ⟨fun t ht => h2.1 t (h1.1 t ht),
     fun t ht ht'' => (h2.2 t (h1.1 t ht) ht'').trans (h1.2 t ht (h1.1 t ht))⟩

theorem timeShift_mono {σ τ : WorldHistory F} (Δ : D) (h : σ ≤ τ) :
    timeShift σ Δ ≤ timeShift τ Δ :=
  ⟨fun z hz => h.1 (z + Δ) hz, fun z hz hz' => h.2 (z + Δ) hz hz'⟩

theorem le_timeShift_timeShift_neg (σ : WorldHistory F) (Δ : D) :
    σ ≤ timeShift (timeShift σ Δ) (-Δ) :=
  ⟨fun t ht => (time_shift_time_shift_neg_domain_iff σ Δ t).mpr ht,
   fun t ht ht' => time_shift_time_shift_neg_states σ Δ t ht ht'⟩

theorem timeShift_timeShift_neg_le (σ : WorldHistory F) (Δ : D) :
    timeShift (timeShift σ Δ) (-Δ) ≤ σ :=
  ⟨fun t ht => (time_shift_time_shift_neg_domain_iff σ Δ t).mp ht,
   fun t ht ht' => (time_shift_time_shift_neg_states σ Δ t ht' ht).symm⟩

theorem le_timeShift_timeShift_of_neg (σ : WorldHistory F) (Δ : D) :
    σ ≤ timeShift (timeShift σ (-Δ)) Δ := by
  have h := le_timeShift_timeShift_neg σ (-Δ)
  rwa [time_shift_congr (timeShift σ (-Δ)) (-(-Δ)) Δ (neg_neg Δ)] at h

/-- Maximality is preserved by time-shift. -/
theorem isMax_timeShift {σ : WorldHistory F} (h : IsMax σ) (Δ : D) :
    IsMax (timeShift σ Δ) := by
  intro τ hle
  have h1 : σ ≤ timeShift τ (-Δ) :=
    le_trans (le_timeShift_timeShift_neg σ Δ) (timeShift_mono (-Δ) hle)
  have h2 : timeShift τ (-Δ) ≤ σ := h h1
  calc τ ≤ timeShift (timeShift τ (-Δ)) Δ := le_timeShift_timeShift_of_neg τ Δ
    _ ≤ timeShift σ Δ := timeShift_mono Δ h2

/-- Any two members of a chain agree on their common domain. -/
theorem chain_states_agree {c : Set (WorldHistory F)} (hc : IsChain (· ≤ ·) c)
    {σ₁ σ₂ : WorldHistory F} (h1 : σ₁ ∈ c) (h2 : σ₂ ∈ c) (t : D)
    (ht1 : σ₁.domain t) (ht2 : σ₂.domain t) :
    σ₁.states t ht1 = σ₂.states t ht2 := by
  rcases hc.total h1 h2 with h | h
  · exact (h.2 t ht1 ht2).symm
  · exact h.2 t ht2 ht1

/-- Union of a chain of world histories. -/
noncomputable def chainSup (c : Set (WorldHistory F)) (hc : IsChain (· ≤ ·) c) :
    WorldHistory F where
  domain t := ∃ σ ∈ c, σ.domain t
  convex := by
    rintro x z ⟨σx, hσx, hx⟩ ⟨σz, hσz, hz⟩ y hxy hyz
    rcases hc.total hσx hσz with h | h
    · exact ⟨σz, hσz, σz.convex x z (h.1 x hx) hz y hxy hyz⟩
    · exact ⟨σx, hσx, σx.convex x z hx (h.1 z hz) y hxy hyz⟩
  states t ht := (Classical.choose ht).states t (Classical.choose_spec ht).2
  respects_task := by
    intro s t hs ht hst
    obtain ⟨hs_mem, hs_dom⟩ := Classical.choose_spec hs
    obtain ⟨ht_mem, ht_dom⟩ := Classical.choose_spec ht
    rcases hc.total hs_mem ht_mem with h | h
    · have hs_dom' : (Classical.choose ht).domain s := h.1 s hs_dom
      have := (Classical.choose ht).respects_task s t hs_dom' ht_dom hst
      rwa [h.2 s hs_dom hs_dom'] at this
    · have ht_dom' : (Classical.choose hs).domain t := h.1 t ht_dom
      have := (Classical.choose hs).respects_task s t hs_dom ht_dom' hst
      rwa [h.2 t ht_dom ht_dom'] at this

theorem le_chainSup {c : Set (WorldHistory F)} (hc : IsChain (· ≤ ·) c)
    {σ : WorldHistory F} (hσ : σ ∈ c) : σ ≤ chainSup c hc :=
  ⟨fun t ht => ⟨σ, hσ, ht⟩,
   fun t ht ht' =>
     chain_states_agree hc (Classical.choose_spec ht').1 hσ t (Classical.choose_spec ht').2 ht⟩

/-- Every world history extends to a maximal one (Zorn). -/
theorem exists_maximal_extension (τ : WorldHistory F) : ∃ σ, τ ≤ σ ∧ IsMax σ :=
  zorn_le_nonempty_Ici₀ τ
    (fun c _hsub hchain _y _hy => ⟨chainSup c hchain, fun z hz => le_chainSup hchain hz⟩)
    τ le_rfl

end WorldHistory
end FormalSystem.Semantics
```

Two further pieces verified sorry-free in a second run:

```lean
/-- A history with full domain is maximal. -/
theorem isMax_of_total {τ : WorldHistory F} (h : ∀ t, τ.domain t) : IsMax τ :=
  fun _σ hle => ⟨fun t _ => h t, fun t ht ht' => (hle.2 t ht' ht).symm⟩

/-- The empty history: exists for every frame, so maximal histories always exist. -/
def emptyHistory (F : TaskFrame D) : WorldHistory F where
  domain _ := False
  convex := fun _ _ hx => absurd hx not_false
  states := fun _ h => absurd h not_false
  respects_task := fun _ _ hs => absurd hs not_false
```

`emptyHistory` + `exists_maximal_extension` yields **nonemptiness of the maximal-history set
for every frame** (needed so the new `valid`/box quantifiers are never vacuous).

Proof-engineering notes baked into the prototype:
- The state-agreement clause quantifies over an *arbitrary* proof `ht'` of the larger domain
  (no dependent `∃` over the inclusion witness); Lean's definitional proof irrelevance then
  makes `le_refl` literally `rfl`-shaped.
- `chainSup.states` uses `Classical.choose` on the membership proof; well-definedness across
  different chain members is exactly `chain_states_agree` (from `IsChain.total` + the
  agreement clause) — this is the "union of a chain of partial functions" step that Mathlib
  does **not** provide off the shelf (see Finding 4).
- The reverse composition order (`-Δ` then `Δ`) is derived from the existing repo lemmas
  `time_shift_time_shift_neg_domain_iff` / `_states` (`WorldHistory.lean:341,353`) via
  `time_shift_congr` + `neg_neg` — no new dependent-transport lemmas were needed.

### Finding 4 — Extension order design: bespoke Preorder, not Mathlib PFun

`WorldHistory.domain` is a predicate `D → Prop` (not `Set`, not an interval type) with
dependent `states : (t : D) → domain t → F.WorldState` plus `convex` and `respects_task`
proof fields (`WorldHistory.lean:75-104`). Mathlib does have a `PartialOrder (PFun α β)`
instance (verified: `#check (inferInstance : PartialOrder (PFun ℕ Bool))` succeeds after
`import Mathlib.Data.PFun`), but reusing it would require an embedding
`WorldHistory F → (D →. F.WorldState)` and pulling the order back — pure indirection, since
the constraints and the dependent `states` field live on the structure, and Mathlib's
chain-sup machinery for `Part`-valued functions is ω-chain (ℕ-indexed) based, which does not
discharge Zorn's arbitrary-chain obligation. The bespoke 8-line `Preorder` instance (verified
above) is the right call. **`PartialOrder` (antisymmetry) is NOT required** by any consumer
found (`zorn_le_nonempty_Ici₀` and `IsMax` need only `Preorder`); antisymmetry would need a
`WorldHistory` extensionality lemma (funext + propext + dependent-states transport) and can be
added later if 415 wants it, but should not be in 414's critical path.

**Naming note**: Mathlib's root `Maximal` is `(α → Prop) → α → Prop` — a repo
`WorldHistory.Maximal : WorldHistory F → Prop` would shadow it confusingly inside the
namespace. Recommendation: use **`IsMax` directly** in the box clause and validity definitions
(zero aliases, per the task's no-shims directive). If the planner wants a named predicate for
paper-facing readability, `WorldHistory.IsMaximal` as a `def … := IsMax τ` with an
`@[simp]` unfolding lemma is acceptable, but plain `IsMax` is cleaner.

### Finding 5 — New core signatures (part 2 of the task)

`TruthAt` (`Truth.lean:128-137`): delete the `Omega` parameter; only the box clause changes
substantively:

```lean
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAt M τ t φ → TruthAt M τ t ψ
  | Formula.box φ => ∀ σ : WorldHistory F, IsMax σ → TruthAt M σ t φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M τ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M τ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M τ r ψ
```

`Validity.lean` replacements (Omega/ShiftClosed binders deleted, `τ ∈ Omega` becomes
`IsMax τ`; `[Nontrivial D]` binders stay exactly as they are):

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F), IsMax τ → ∀ t : D, TruthAt M τ t φ

def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F), IsMax τ → ∀ t : D,
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (Γ : Context) : Prop :=
  ∃ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F),
    IsMax τ ∧ ∃ t : D, ∀ φ ∈ Γ, TruthAt M τ t φ
```

Same pattern for `FormulaSatisfiable`, `SatisfiableAbs`, `ValidDense`, `ValidDiscrete`,
`ValidDedekind`, `ValidDedekindDense` (`Validity.lean:154-262`), `ValidOver`
(`FrameConditions/Validity.lean:59`), `IsValid` (`SoundnessLemmas/Core.lean:39`), and
`SemanticConsequenceDedekindDense` (`StrongCompleteness.lean:128-136`). The false-docstring
text at `Validity.lean:33` and `70-72` is deleted along with the parameter, exactly as
fix.md C1/132 requires. `ShiftClosed` (`Truth.lean:333`) and `Set.univ_shift_closed`
(`Truth.lean:339`) are **deleted**, replaced by the theorem `isMax_timeShift` — no parallel
notion survives.

### Finding 6 — `time_shift_preserves_truth` under the new semantics

`Truth.lean:446-677`: the theorem **loses its `h_sc : ShiftClosed Omega` hypothesis
entirely**. In the box case (`Truth.lean:481-511`), the two membership obligations
`h_sc ρ h_rho_mem (y - x)` / `(x - y)` become `isMax_timeShift h_rho_max (y - x)` /
`(x - y)`; every other case is untouched (the `truth_double_shift_cancel` box case,
`Truth.lean:408-411`, is already Omega-independent commentary — "both sides quantify over the
same set"). All downstream callers simplify: `time_shift_preserves_truth M σ t s φ` with no
side conditions. This is a strict simplification of the API.

### Finding 7 — Soundness survival (research question 5, adversarially checked)

Exhaustive grep audit of `h_sc`/`h_mem` consumption across the whole soundness chain found
**exactly two substantive `ShiftClosed` consumption patterns**, both of which are precisely
`ShiftClosed {σ | IsMax σ}` — i.e., precisely `isMax_timeShift`:

1. **Box-shift membership**: `h_sc σ h_σ_mem (s - t)` at `Metalogic/Soundness.lean:264` (MF
   axiom) and `Metalogic/SoundnessLemmas/DenseValidity.lean:205, 857` (swap-MF variants).
   Replacement: `isMax_timeShift h_σ_max (s - t)`.
2. **Threading into `time_shift_preserves_truth`**: same three sites plus
   `Soundness.lean:819-833` (prior_UZ/SZ/z1 delegating to SoundnessLemmas). Replacement: the
   hypothesis disappears (Finding 6).

Every other occurrence is pure binder plumbing: `intro T _ _ _ _ F M Omega _h_sc τ _h_mem t`
(60+ lines in `Soundness.lean` alone) becomes `intro T _ _ _ _ F M τ h_max t` (or `_h_max`),
and `exact h D F M Omega h_sc τ h_mem t` becomes `exact h D F M τ h_max t`. Axioms that
consume `h_mem` substantively — `modal_t_valid` (`Soundness.lean:131`, `h_box τ h_mem`),
`modal_b_valid` (`Soundness.lean:146`) — consume the maximality of the evaluation history,
which the new `valid` supplies in the same binder position. Necessitation
(`Soundness.lean:1025-1029`) instantiates the induction hypothesis at the box-quantified
history `σ` with `h_σ_mem` → becomes `h_σ_max`; temporal necessitation is Omega-inert.
`FrameConditions/Soundness.lean` and `Automation/PrefilterSoundness.lean` are pure plumbing
(verified: all their `h_sc` uses are pass-through applications).

**Verdict on the description's "survives verbatim" claim**: TRUE mathematically — no proof
*strategy* changes anywhere in the soundness chain, and both re-verified paper lemmas (Zorn
extension, shift-preservation) exist with the claimed roles (shift-preservation is what
soundness consumes; Zorn extension is consumed by nonemptiness/countermodel work in 415/417,
**not** by soundness itself). FALSE textually — every one of the ~70 axiom-validity theorems
plus the three soundness theorems (`soundness`:1063, `soundness_dense`:1235,
`soundness_discrete`:1382, `soundness_dedekind`:1910) needs its binder lists mechanically
rewritten. Phase-sizing should treat `Soundness.lean` (1943 lines) + `SoundnessLemmas/`
(DenseValidity 169 Omega-hits) as several phases of mechanical rewriting, not one.

### Finding 8 — Blast radius (research question 4): full worklist

**Boneyard is NOT in the build** (no non-Boneyard file imports `FormalSystem.Boneyard.*`;
lakefile roots = `FormalSystem`), so Boneyard files are out of scope. Everything below IS in
the build via `FormalSystem/FormalSystem.lean`.

**Group A — semantics core (rewrite; task parts 1-2)**

| File | Affected declarations |
|---|---|
| `FormalSystem/Semantics/WorldHistory.lean` | additions only: Preorder instance, `timeShift_mono`, `le_timeShift_timeShift_neg`, `timeShift_timeShift_neg_le`, `le_timeShift_timeShift_of_neg`, `isMax_timeShift`, `chain_states_agree`, `chainSup`, `le_chainSup`, `exists_maximal_extension`, `isMax_of_total`, `emptyHistory` (all pre-verified, Finding 3) |
| `FormalSystem/Semantics/Truth.lean` | `TruthAt`:128, all 12 characterization lemmas (:147-324, drop Omega binder), **delete** `ShiftClosed`:333 + `Set.univ_shift_closed`:339, `truth_history_eq`:364, `truth_double_shift_cancel`:377, `time_shift_preserves_truth`:446 (drop `h_sc`; box case per Finding 6), `exists_shifted_history`:685 |
| `FormalSystem/Semantics/Validity.lean` | all 8 validity/satisfiability defs (:79-262) + all 14 lemmas (:269-417); false docstrings :33, 70-72 deleted with the parameter |
| `FormalSystem/FrameConditions/Validity.lean` | `ValidOver`:59 + 9 transfer lemmas (:114-208) — plumbing |

**Group B — soundness propagation (mechanical; task part 3)**

| File | Affected decls | Nature |
|---|---|---|
| `FormalSystem/Metalogic/Soundness.lean` | 68 | binder rewrite; 1 substantive site (:264-265) |
| `FormalSystem/Metalogic/SoundnessLemmas/Core.lean` | 3 (`IsValid`, `valid_at_triple`, `truth_at_swap_swap`) | binder rewrite |
| `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` | ~30 (169 Omega hits) | binder rewrite; substantive sites :205-206, :857-858 |
| `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` | ~15 (112 Omega hits) | binder rewrite |
| `FormalSystem/FrameConditions/Soundness.lean` | 8 | pass-through plumbing |
| `FormalSystem/Automation/PrefilterSoundness.lean` | 4 | pass-through plumbing |
| `Tests/BimodalTest/Semantics/TruthTest.lean` (11 hits), `SemanticBenchmark.lean` (2), `TemporalWitnessProbe.lean` (2) | small | test-call-site updates |

**Group C — completeness/decidability consumers (415/417 territory; CANNOT be mechanically
ported — see Finding 9)**

| File | Affected decls |
|---|---|
| `FormalSystem/Metalogic/StrongCompleteness.lean` | 4 |
| `FormalSystem/Metalogic/Bundle/LimitMCS.lean` | 1 |
| `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` | 6 (incl. singleton-Omega device `zIntervalOmega`:599, `zIntervalBox_transparent`:616) |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 14 (`ZOmegaV2`:468, `multiFamOmega`:694) |
| `FormalSystem/Metalogic/BXCanonical/Completeness.lean` | 4 (headline `completeness`:196, `completeness_dense`:255, `completeness_discrete`:296) |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/{ChronicleMonadicBridge (7, `multiFamOmegaGen`:170), ChronicleConstruction (4), ChronicleToCountermodelBasic (1), MCSMixedCase (1)}` | 13 |
| `FormalSystem/Metalogic/Algebraic/{ParametricCompleteness (4), ParametricHistory (6, `ParametricCanonicalOmega`:110), ParametricTruthLemma (3), RestrictedParametricTruthLemma (4)}` | 17 |
| `FormalSystem/Metalogic/Decidability/Verified/Bridge/{Omega (11, `regionOmega`:215), TruthLemma (4), Valuation (9), IntTruth (9), RegionLabel (2), BoxSaturation (1)}` + `Decidability/Correctness.lean` (1) | 37 |

### Finding 9 — Group C cannot survive 414 mechanically; recommended interim strategy

The completeness constructions rest on **Omega-instantiation devices** that are mathematically
false under maximal-history semantics. Concrete witness (`WeakCanonical/Transfer.lean:616`):
`zIntervalBox_transparent` proves `TruthAt (.box ψ) ↔ TruthAt ψ` *because* `Omega =
{zIntervalHistory}` is a singleton. Under the new semantics box quantifies over **all** `IsMax`
histories of the frame — a set the construction does not control — so box-transparency must
instead be reproved from frame determinism ("maximal histories form a single shift class"),
which is exactly 415's stated design. There is no mechanical port; the mathematical content
changes. The same holds for `ZOmegaV2`/`multiFamOmega`/`multiFamOmegaGen`/`regionOmega`/
`ParametricCanonicalOmega` and everything downstream of them (the truth-lemma bridges and the
headline `completeness*` theorems in `BXCanonical/Completeness.lean`).

Since 414 forbids compatibility shims and parallel validity notions, and the repo must build
green after 414, the plan must pick one of:
1. **(Recommended) Boneyard the Group C chain in 414** (move to
   `FormalSystem/Boneyard/OmegaSemanticsLegacy/` and cut the `Metalogic.lean` /
   `FormalSystem.lean` imports), accepting that the headline completeness/decidability-bridge
   theorems are temporarily absent until 415/417 restore them against the new semantics. This
   matches fix.md's Part C decision ("cost accepted") and the fix.md C2 submission gate, and
   mirrors the existing `Boneyard/StrictSemanticsLegacy/` precedent for exactly this kind of
   semantics migration.
2. Rewrite Group C signatures in 414 with `sorry`-free but weakened statements — **not
   viable**: the box-transparency lemmas become false, so this necessarily produces sorries or
   vacuous restatements, both prohibited.

Option 1 is the only zero-debt path. The plan should include an explicit inventory commit of
what moves to Boneyard so 415/417 can mine it.

### Finding 10 — Where Zorn is (and is not) actually consumed in 414

Adversarial finding: **soundness itself never needs `exists_maximal_extension`** — its only
new dependency is `isMax_timeShift`. The Zorn theorem is still a hard deliverable of part (1)
(the paper re-verified it, 415/417 consume it, and `emptyHistory` + Zorn gives the
every-frame nonemptiness fact that keeps the new quantifiers non-vacuous), but the plan should
not sequence Soundness behind the Zorn machinery: after the `WorldHistory.lean` +
`Truth.lean` + `Validity.lean` phases, Soundness propagation can proceed in parallel with the
Zorn additions.

## Adversarial Self-Verification

| Claim | Source/Counterexample probe | Verification Method | Confidence |
|---|---|---|---|
| `zorn_le_nonempty_Ici₀` exists with the quoted signature in pinned Mathlib | direct read of `.lake/packages/mathlib/Mathlib/Order/Zorn.lean:133-141` | `#check` via `lean_run_code` + source read | High |
| `zorn_partialOrder` does not exist (must not be cited) | — | `lean_local_search` empty result | High |
| Extension `Preorder`, `timeShift_mono`, shift-cancel `≤`-pair, `isMax_timeShift`, `chainSup`, `le_chainSup`, `exists_maximal_extension` all type-check sorry-free against the repo | — | `lean_run_code` full-prototype compile (success, 0 errors) | High |
| `isMax_of_total`, `emptyHistory` type-check sorry-free | — | `lean_run_code` compile | High |
| `IsMax a ↔ ∀ b, a ≤ b → b ≤ a` definitionally | — | `example … := Iff.rfl` accepted by `lean_run_code` | High |
| Mathlib `PartialOrder (PFun α β)` exists but is not the right tool | — | `#check (inferInstance : PartialOrder (PFun ℕ Bool))` succeeded; applicability argument is analysis (dependent states + constraints + ω-chain-only sups) | Medium-High |
| Only two substantive `ShiftClosed` consumption patterns exist in the soundness chain | tried to refute by grepping ALL `h_sc` non-underscore uses across Metalogic/, FrameConditions/, Automation/ | exhaustive grep audit (sites listed in Finding 7) | High |
| Soundness survives "verbatim" | probe: does any soundness proof instantiate Omega existentially or need a history outside the maximal set? Found none; but binder lists change everywhere | grep audit + case reads of `modal_t/4/b/5`, MF, necessitation | High (with the textual qualification recorded in Finding 7) |
| Group C singleton-Omega devices are mathematically unportable | probe: could `zIntervalBox_transparent` survive with `IsMax`-box? Only if the frame's full maximal set is that singleton's shift class — not established there; 415's description confirms reproof-by-determinism is the intended route | source read of `Transfer.lean:590-640` + fix.md B1/C1 + 415 description | High |
| Blast-radius file/declaration inventory complete | — | repo-wide grep (Omega, ShiftClosed) incl. Tests/, minus Boneyard (verified unimported) | High |

**Contradiction log**:
- Task description "Soundness … expected to survive verbatim via Zorn extension +
  shift-preservation" vs. audit: soundness consumes only shift-preservation; Zorn is consumed
  by nonemptiness/415/417. Resolution: primary source (repo code) outranks the task
  paraphrase; recorded in Finding 10. Downstream risk if ignored: plan sequences Soundness
  behind Zorn unnecessarily.
- Task description "removing Omega … everywhere. NO compatibility shims" vs. build-integrity
  for Group C: no unresolved contradiction — resolved by the Boneyard recommendation
  (Finding 9), consistent with fix.md Part C "cost accepted" and the existing
  `StrictSemanticsLegacy` precedent. This is the one decision the planner must ratify.

**Revised after verification**: (a) initial candidate `zorn_le_nonempty` (whole-type) was
replaced by `zorn_le_nonempty_Ici₀`, which delivers the extension form `∃ m, x ≤ m ∧ IsMax m`
directly; (b) planned naming `WorldHistory.Maximal` was dropped after finding the Mathlib
root-namespace `Maximal` clash (Finding 4); (c) the "survives verbatim" claim was downgraded
from unqualified to "mathematically verbatim, textually a full binder rewrite".

## Literature Proof Structure (Tier 1)

Per fix.md B1 (Decision, line 77) and C1 (Decision, line 132), the source's proof plan for
this task maps to Lean as:

| Step (source) | Source location | Lean realization |
|---|---|---|
| 1. Restrict H_F to maximal histories (standard Ockhamist/maximal-path practice) | fix.md:69, 77 | box clause of `TruthAt` quantifies over `IsMax` (Finding 5) |
| 2. Every history extends to a maximal one (Zorn) — "re-verified in research" | fix.md:66, 69 | `exists_maximal_extension` — **now machine-verified** (Finding 3) |
| 3. Maximality preserved by time-shift — "re-verified" | fix.md:66, 69 | `isMax_timeShift` — **now machine-verified** (Finding 3) |
| 4. Soundness proofs and SP1/SP2 shift argument survive | fix.md:69, 77 | Finding 7: shift-preservation slots into the exact two `ShiftClosed` consumption sites |
| 5. One validity notion, no Ω ladder, false docstrings disappear | fix.md:81, 124, 132 | Omega parameter deleted from `TruthAt`/`valid`/etc.; `ShiftClosed` deleted (Finding 5) |
| 6. Completeness re-examined against the new class (not this task) | fix.md:69, 82, 132 | Group C → Boneyard in 414; 415/417 reprove (Finding 9) |

## Recommendations for the Plan

1. **Phase 1** — `WorldHistory.lean`: land the verified prototype (Finding 3) essentially
   as-is (+ `isMax_of_total`, `emptyHistory`, a nonemptiness corollary
   `∃ σ : WorldHistory F, IsMax σ`). Low risk: already compiles.
2. **Phase 2** — `Truth.lean`: drop Omega from `TruthAt` + characterization lemmas; delete
   `ShiftClosed`/`Set.univ_shift_closed`; reprove `time_shift_preserves_truth` box case with
   `isMax_timeShift` (Finding 6).
3. **Phase 3** — `Validity.lean` + `FrameConditions/Validity.lean`: new
   valid/satisfiable/consequence family (Finding 5).
4. **Phase 4 (parallelizable with 5)** — Group C excision to
   `Boneyard/OmegaSemanticsLegacy/` with import-graph cut and inventory (Finding 9).
5. **Phases 5-7** — Group B mechanical propagation: `Soundness.lean` (split by axiom family),
   `SoundnessLemmas/{Core,DenseValidity,FrameClassVariants}`, then
   `FrameConditions/Soundness.lean` + `PrefilterSoundness.lean` + test files.
6. Final gate: `lake build` full project; grep-zero for `Omega`/`ShiftClosed` outside
   `Boneyard/`.

## References

- `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md` — B1 (lines 62-83), C1
  (lines 122-132), Part C decision (line 120)
- `/home/benjamin/Philosophy/Papers/possible_worlds.tex` — def:world-history (line 1833),
  box/S5 discussion (lines 940-946)
- `FormalSystem/Semantics/{WorldHistory,Truth,Validity,TaskFrame}.lean`;
  `FormalSystem/Metalogic/Soundness.lean`; `FormalSystem/Metalogic/SoundnessLemmas/*`;
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:590-640`
- `.lake/packages/mathlib/Mathlib/Order/Zorn.lean` (pinned tag v4.33.0-rc1)
