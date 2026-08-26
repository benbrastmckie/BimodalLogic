# Research: Model Existence -> Compactness Bridge (Base and Dense)

**Task**: 490 — prove_model_existence_implies_compactness_bridge
**Status**: researched
**Session**: sess_1787724130_558d21_490

## Executive Summary

The bridge is real, cheap, and **already machine-verified during research**. Complete
sorry-free Lean proofs of both deliverables were written and compiled against the live
toolchain, and both audit to exactly `[propext, Classical.choice, Quot.sound]`. The
implementation phase is a transcription-plus-docstrings job, not a proof-search job.

Two findings modify the task brief:

1. **Placement**: the theorems cannot live in `SetConsequence.lean`. They consume
   `truthAt_foldr_imp`, which is owned by `StrongCompleteness.lean`, and that module already
   imports `SetConsequence.lean`. Putting them in `SetConsequence.lean` is an import cycle.
   This is the *same* constraint that already forced `strongCompletenessBase_of_compact` and
   `strongCompletenessDense_of_compact` into `StrongCompleteness.lean`, and the reason is
   documented verbatim at `FormalSystem/Metalogic/SetConsequence.lean:49-55`. The task brief's
   "or a sibling" clause covers this. **Recommended home**:
   `FormalSystem/Metalogic/StrongCompleteness.lean`, immediately after
   `strongCompletenessDense_of_compact` (currently ends at line 336), inside the existing
   section "Strong completeness for `FrameClass.Base` and `FrameClass.Dense`, modulo
   compactness" (line 266). No new module, no lakefile change, no import change.

2. **`push_neg` is deprecated** in this toolchain (Lean v4.33.0-rc1 / Mathlib `79d0395a`) and
   emits a warning. The repo has already largely migrated: 535 occurrences of `push Not` vs 245
   legacy `push_neg`. The verified proofs below use `push Not`.

## Verified Deliverables

Both theorems below were compiled with `lake env lean` against the current build, first in
isolation and then **inserted into a full copy of `StrongCompleteness.lean` at the recommended
insertion point** — the 871-line composite elaborated clean with zero errors and zero warnings,
and all sixteen `#print axioms` lines (the existing fourteen plus the two new ones) reported the
permitted axiom set.

### `compactBase_of_modelExistence`

```lean
theorem compactBase_of_modelExistence (h : ModelExistenceBase) : CompactBase := by
  classical
  intro Γ φ hcons
  by_contra hno
  push Not at hno
  have hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ insert φ.neg Γ) →
      SatisfiableBaseSet {ψ | ψ ∈ L} := by
    intro L hL
    have hsub : ∀ ψ ∈ L.filter (fun ψ => decide (ψ ∈ Γ)), ψ ∈ Γ := by
      intro ψ hψ
      exact of_decide_eq_true (List.mem_filter.mp hψ).2
    have hnv := hno _ hsub
    unfold valid at hnv
    push Not at hnv
    obtain ⟨D, _, _, _, _, F, M, τ, hτ, t, hfalse⟩ := hnv
    rw [truthAt_foldr_imp] at hfalse
    push Not at hfalse
    obtain ⟨hall, hnφ⟩ := hfalse
    refine ⟨D, inferInstance, inferInstance, inferInstance, inferInstance, F, M, τ, hτ, t, ?_⟩
    intro ψ hψ
    by_cases hg : ψ ∈ Γ
    · exact hall ψ (List.mem_filter.mpr ⟨hψ, decide_eq_true hg⟩)
    · rcases hL ψ hψ with rfl | hmem
      · exact fun hp => hnφ hp
      · exact absurd hmem hg
  obtain ⟨D, _, _, _, _, F, M, τ, hτ, t, hsat⟩ := h _ hfin
  exact hsat φ.neg (Set.mem_insert _ _)
    (hcons D F M τ hτ t (fun ψ hψ => hsat ψ (Set.mem_insert_of_mem _ hψ)))
```

Compiler output:
`'FormalSystem.Metalogic.compactBase_of_modelExistence' depends on axioms: [propext, Classical.choice, Quot.sound]`

### `compactDense_of_modelExistenceDense`

Structurally identical. The only three differences are (a) `ValidDense` for `valid`,
(b) `SatisfiableDenseSet` for `SatisfiableBaseSet`, and (c) one extra `_` in each `obtain`
pattern and one extra `inferInstance` in the `refine`, for the `[DenselyOrdered D]` binder.

```lean
theorem compactDense_of_modelExistenceDense (h : ModelExistenceDense) : CompactDense := by
  classical
  intro Γ φ hcons
  by_contra hno
  push Not at hno
  have hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ insert φ.neg Γ) →
      SatisfiableDenseSet {ψ | ψ ∈ L} := by
    intro L hL
    have hsub : ∀ ψ ∈ L.filter (fun ψ => decide (ψ ∈ Γ)), ψ ∈ Γ := by
      intro ψ hψ
      exact of_decide_eq_true (List.mem_filter.mp hψ).2
    have hnv := hno _ hsub
    unfold ValidDense at hnv
    push Not at hnv
    obtain ⟨D, _, _, _, _, _, F, M, τ, hτ, t, hfalse⟩ := hnv
    rw [truthAt_foldr_imp] at hfalse
    push Not at hfalse
    obtain ⟨hall, hnφ⟩ := hfalse
    refine ⟨D, inferInstance, inferInstance, inferInstance, inferInstance, inferInstance,
      F, M, τ, hτ, t, ?_⟩
    intro ψ hψ
    by_cases hg : ψ ∈ Γ
    · exact hall ψ (List.mem_filter.mpr ⟨hψ, decide_eq_true hg⟩)
    · rcases hL ψ hψ with rfl | hmem
      · exact fun hp => hnφ hp
      · exact absurd hmem hg
  obtain ⟨D, _, _, _, _, _, F, M, τ, hτ, t, hsat⟩ := h _ hfin
  exact hsat φ.neg (Set.mem_insert _ _)
    (hcons D F M τ hτ t (fun ψ hψ => hsat ψ (Set.mem_insert_of_mem _ hψ)))
```

Compiler output:
`'FormalSystem.Metalogic.compactDense_of_modelExistenceDense' depends on axioms: [propext, Classical.choice, Quot.sound]`

## Mathematical Route

The brief's suggested route — "contrapose through the `Formula.neg` clause of `TruthAt` plus
`truthAt_foldr_imp`" — is exactly right. Spelled out:

Assume `hcons : SetSemanticConsequenceBase Γ φ` and, for contradiction, that **no** finite
`L ⊆ Γ` has `valid (L.foldr Formula.imp φ)`.

1. **Extend the premise set.** Work with `Γ' := insert φ.neg Γ`. Note `Formula.neg φ = φ.imp ⊥`
   (`Syntax/Formula.lean:137`) and `TruthAt M τ t ⊥ = False` (`Semantics/Truth.lean:162`), so
   `TruthAt M τ t φ.neg` is *definitionally* `TruthAt M τ t φ → False`. No `truthAt_neg` lemma
   exists in the tree and none is needed: `exact hneg hφ` typechecks directly. This is the same
   idiom already used at `DiscreteNonCompactness.lean:241`.

2. **Every finite `L ⊆ Γ'` is satisfiable.** Given such an `L`, let
   `L₀ := L.filter (fun ψ => decide (ψ ∈ Γ))`. `L₀ ⊆ Γ`, so the contradiction hypothesis gives
   `¬ valid (L₀.foldr Formula.imp φ)` — i.e. some `D, F, M, τ, t` with
   `¬ TruthAt M τ t (L₀.foldr Formula.imp φ)`. Rewriting by `truthAt_foldr_imp`
   (`StrongCompleteness.lean:183`) and pushing the negation yields exactly
   `(∀ ψ ∈ L₀, TruthAt M τ t ψ) ∧ ¬ TruthAt M τ t φ`. That single configuration satisfies every
   member of `L`: a `ψ ∈ Γ` is in `L₀`, and a `ψ ∉ Γ` must be `φ.neg`, which the second conjunct
   supplies.

3. **Apply model existence.** `h Γ' hfin : SatisfiableBaseSet Γ'` gives one configuration
   satisfying all of `Γ` *and* `φ.neg`. But `hcons` applied there forces `TruthAt M τ t φ`.
   Contradiction.

### Why the `filter` step is needed

`ModelExistenceBase` quantifies over `L : List Formula` with `∀ ψ ∈ L, ψ ∈ Γ'`, and such an `L`
may interleave `φ.neg` with `Γ`-members arbitrarily and repeat them. The `Γ`-part has to be
extracted to feed the contradiction hypothesis, which demands `∀ ψ ∈ L₀, ψ ∈ Γ`. `Γ : Set
Formula` carries no decidability, so `classical` (already the file-local idiom — see
`DiscreteNonCompactness.lean:194, 249`) supplies `DecidablePred (· ∈ Γ)` and `List.filter`
applies. `Formula` does derive `DecidableEq` (`Syntax/Formula.lean:107`), but that is not what is
needed here; set membership is the undecidable part.

### What is *not* claimed

Only the stated direction. `CompactBase → ModelExistenceBase` is not proved and is not part of
this task. `ModelExistenceBase` itself remains an open obligation — this task closes the
*second*, cheap gap on the route, exactly as the brief frames it.

## Tactic Survey Results

| Goal | Tactic | Result | Notes |
|------|--------|--------|-------|
| `¬ valid (…)` -> existential unpacking | `unfold valid; push Not` | success | `unfold` needed; `valid` is a plain `def`, `rw` does not apply |
| same, deprecated form | `push_neg` | success + deprecation warning | repo has migrated: 535 `push Not` vs 245 `push_neg` |
| `¬ TruthAt … (foldr imp)` -> conjunction | `rw [truthAt_foldr_imp]; push Not` | success | `rw` works through the leading `¬` |
| `TruthAt M τ t φ.neg` applied to `TruthAt M τ t φ` | `exact hneg hφ` | success | `Formula.neg`/`TruthAt ⊥` unfold at default transparency |
| Rebuilding `SatisfiableBaseSet` after `obtain` with bare `_` instance binders | `refine ⟨D, inferInstance, …⟩` | success | matches the `DiscreteNonCompactness.lean:196` precedent |

No `aesop`/`simp`/`omega`/`decide` search was required — the proof is a direct construction.
`lean_multi_attempt` was not needed because full candidate proofs compiled on the first
submission.

## Recommended Placement and Companion Changes

### Code

Insert both theorems in `FormalSystem/Metalogic/StrongCompleteness.lean` after line 336 (the end
of `strongCompletenessDense_of_compact`), under a new `/-! ### Model existence implies
compactness -/` heading inside the existing section at line 266. Add both names to the
`#print axioms` block at lines 796-805.

Docstrings for the two theorems should record: (a) the import-cycle reason they live here rather
than in `SetConsequence.lean`, mirroring the paragraph already in
`strongCompletenessBase_of_compact`'s docstring at lines 276-279; and (b) that the hypothesis is
still open, so these are reductions, not termini — the same distinction the axiom-audit prose at
lines 790-795 already draws for `strongCompletenessBase_of_compact`.

### Prose that becomes false and must be updated

These are the load-bearing edits; the acceptance criteria are met by the code alone, but leaving
these stale would re-create the exact "silent gap" the task exists to close.

| Location | Current text | Required change |
|----------|--------------|-----------------|
| `FormalSystem/Metalogic/SetConsequence.lean:236-238` | "`ModelExistenceBase → CompactBase` is a contraposition … ; that implication is future work and is not proved here." | Now proved. Point at `compactBase_of_modelExistence` in `StrongCompleteness.lean` and keep the "not *here*" (import cycle) framing. `ModelExistenceBase` itself stays an open obligation. |
| `FormalSystem/Metalogic/SetConsequence.lean:280-282` | Same sentence for the Dense sibling. | Same, pointing at `compactDense_of_modelExistenceDense`. |
| `FormalSystem/Metalogic/SetConsequence.lean:49-55` ("## Downstream") | Names only the two `strongCompleteness*_of_compact` theorems as living downstream for the import-cycle reason. | Add the two bridge theorems to that list — the reason is identical. |
| `FormalSystem/Metalogic/StrongCompleteness.lean:129-136` ("## Contents") | Does not list the bridge theorems. | Add a bullet. |
| `FormalSystem/Metalogic/StrongCompleteness.lean:290-303` | "**Status of `CompactBase`.** Open … it needs an ultraproduct carrier, a Łoś lemma for `TruthAt`, `ModelExistenceBase` and hence `CompactBase`." | The final "and hence" step is now a proved theorem rather than remaining work. `CompactBase` is still open (it now reduces to `ModelExistenceBase`), so the "Open" verdict stands; only the enumeration of remaining pieces shrinks. |
| `FormalSystem/Metalogic/StrongCompleteness.lean:786-795` | "The **fourteen** declarations of the Base, Dense and Discrete sections above …" | Count and scope change if the two new names are folded into that audit paragraph; alternatively give the bridge theorems their own one-line audit note. |
| `FormalSystem/Metalogic.lean:135-147` | Module inventory lists the two compactness reductions. | Add the two bridge theorems to the `StrongCompleteness.lean` bullet. |

`SetConsequence.lean:24-25` ("**No compactness result is proved or refuted here**") stays
literally true under the recommended placement and needs no edit — a further argument for
`StrongCompleteness.lean` over `SetConsequence.lean` as the home.

## Zero-Debt Compliance

No `sorry`, no new axiom, no deferral. Both deliverables are complete, compiled proofs; the
acceptance criteria (sorry-free, `#print axioms` exactly
`[propext, Classical.choice, Quot.sound]`, build green) were verified during research rather
than deferred to implementation. The only implementation risk is prose drift in the seven
docstring sites above.

## Downstream Consumers

`specs/TODO.md` already carries a follow-on task whose description reads "then compose with the
ModelExistence -> Compact bridge to obtain CompactBase and CompactDense". That task's S4 step is
the named consumer of these two theorems, and it is the piece that would make the paper's
`cor:tm-completeness` rows 1 and 2 unconditional. This task supplies the composition target; it
does not touch the ultraproduct/Łoś work, per the brief's explicit exclusion.

An optional third theorem — `StrongCompletenessBase` from `ModelExistenceBase` plus an engine,
by chaining into `strongCompletenessBase_of_compact` — is **not** recommended here. The tree
deliberately keeps `engine` hypotheses live (documented at `StrongCompleteness.lean:281-288`) so
that compactness is isolated as the whole remaining obligation, and it is out of this task's
declared scope.

## Key File References

- `FormalSystem/Metalogic/SetConsequence.lean:219-221` — `CompactBase`
- `FormalSystem/Metalogic/SetConsequence.lean:227-232` — `SatisfiableBaseSet`
- `FormalSystem/Metalogic/SetConsequence.lean:239-242` — `ModelExistenceBase`
- `FormalSystem/Metalogic/SetConsequence.lean:263-265` — `CompactDense`
- `FormalSystem/Metalogic/SetConsequence.lean:271-276` — `SatisfiableDenseSet`
- `FormalSystem/Metalogic/SetConsequence.lean:283-286` — `ModelExistenceDense`
- `FormalSystem/Metalogic/StrongCompleteness.lean:178-190` — `truthAt_foldr_imp`
- `FormalSystem/Metalogic/StrongCompleteness.lean:305-310` — `strongCompletenessBase_of_compact`
- `FormalSystem/Metalogic/StrongCompleteness.lean:331-336` — `strongCompletenessDense_of_compact`
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean:193-217` — the anonymous-instance-binder
  construct/destruct idiom the proofs above follow
- `FormalSystem/Syntax/Formula.lean:137` — `Formula.neg φ = φ.imp bot`
- `FormalSystem/Semantics/Truth.lean:159-168` — `TruthAt`, incl. the `bot` and `imp` clauses
- `FormalSystem/Semantics/Validity.lean:94-98` — `valid`
- `FormalSystem/Semantics/Validity.lean:206-211` — `ValidDense`
