# Task 326 Phase 4.1 — List.permutations Head-Coverage Helper (Summary)

**Status:** COMPLETED (implemented, green, axiom-clean)
**Phase:** 4.1 of 8 (single-phase dispatch; stopped at the Phase 4.1 boundary — did NOT start 4.2)
**File:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` (purely additive)

## What was proved

Two additive, sorry-free theorems in namespace `Bimodal.Metalogic.WeakCanonical.Kamp`:

1. `exists_permutation_cons_head {α : Type*} {l : List α} {χ : α} (hχ : χ ∈ l) : ∃ rest, (χ :: rest) ∈ l.permutations` (:752) — the **make-or-break interface** Phase 4.2 consumes. The CONS head `χ` feeds Phase 3's `bracketFromLists3 (χ0 :: lXU')`; the membership is the `S_XU.permutations.flatMap` key.
2. `exists_permutation_head?_eq {α : Type*} {l : List α} {χ : α} (hχ : χ ∈ l) : ∃ p ∈ l.permutations, p.head? = some χ` (:761) — the plan's literal `head?` form, a one-line corollary of the CONS form.

## Mathlib search (Task 1)

No single packaged head-coverage lemma exists. Assembled from three primitives:
- `List.mem_permutations` (`s ∈ t.permutations ↔ s ~ t`, `Mathlib.Data.List.Permutation`)
- `List.append_of_mem` (`a ∈ l → ∃ s t, l = s ++ a :: t`, core `Init.Data.List.Lemmas`)
- `List.perm_middle` (`(l₁ ++ a :: l₂) ~ (a :: (l₁ ++ l₂))`, core `Init.Data.List.Perm`)

## Proof shape (Task 2)

`obtain ⟨s, t, rfl⟩ := List.append_of_mem hχ; exact ⟨s ++ t, List.mem_permutations.mpr List.perm_middle.symm⟩`.
No `simp`/`aesop`/`omega` closer. No `DecidableEq` (append-split route, not `List.erase`).

## Interface coordination (Task 3)

CONS form recorded as the primary Phase 4.2 interface in `.orchestrator-handoff.json`
`continuation_context.phase_4_1_helper_api_for_phase_4_2`. Instantiation: `α := TemporalPred`,
`l := S_XU`, `χ := ⟨charBase χ⟩`.

## Deviations

- **Added one import** `Mathlib.Data.List.Permutation` to EANegationClosure.lean: its narrower
  import closure (only `EANegation` + `VecEAClosure`) lacked `List.mem_permutations`. Additive,
  no cycle, no DO-NOT-EDIT asset changed. `NfMultiAnchorBridge.lean` already imports
  EANegationClosure (:4), so no new import edge is needed for Phase 4.2.

## Verification

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` → green (991 jobs).
- `#print axioms` on both theorems → `[propext, Quot.sound]` (no `sorryAx`, no `Classical.choice`).
- No `sorry`/`admit` in the file. Warnings present are all pre-existing DO-NOT-EDIT assets
  (lines 166/167/255/256), none on the new additions.
- Constraint compliance: purely additive; all landed EANegation/EANegationClosure assets
  byte-identical; no `sorry` on the committed live path; axiom-clean.

## G5 / citation

Rabinovich 2014 Lemma 5.3 (md:137-152) permutation-coverage support noted in the doc-comment;
the lemma itself is a domain-free `List` fact (citation optional, as flagged).
