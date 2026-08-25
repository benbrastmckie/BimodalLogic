# Task 413 — Phase 5 handoff

**Phase 5 (DF at `FrameClass.Discrete`) COMPLETED via ROUTE A. Route B was never used.**

`#print axioms FormalSystem.Theorems.DiscreteUnfolding.dfSchema`
= `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no `completeness_*`.

## Landed in `FormalSystem/Theorems/DiscreteUnfolding.lean` (append only)
- `clashBot` (private) — `(A ∧ B) → ⊥` from `A → C`, `B → ¬C`.
- `nextAllFuture φ : ⊢[Discrete] X (Gφ ∧ φ) → Gφ`
- `swap_next_all_future_eq φ` — the `swapTemporal` image equation
- `prevAllPast φ : ⊢[Discrete] Y (Hφ ∧ φ) → Hφ` (free past dual via `temporal_duality`)
- `dfSchema φ : ⊢[Discrete] ((Hφ ∧ φ) ∧ F⊤) → F(Hφ)`

## Route A as executed (deviation from the report's 3-step sketch: step 3 was NOT the
literal past-dual of `unfoldForward`)
The report predicted step 3 = "past-dual of `unfoldForward`". What actually closes it is
`X (Gφ ∧ φ) → Gφ`, which *consumes* `unfoldForward` (at guard `⊤`) plus `nextConj` rather than
being its dual. The composition is then:
1. `succIndicator` gives `X ⊤`.
2. `Axiom.enrichment_until` (guard `⊥`, event `⊤`, payload `p := Hφ ∧ φ`) gives
   `X (⊤ ∧ Y (Hφ ∧ φ))` — this is the step the report did not name, and it is what makes the
   payload reach the successor.
3. `prevAllPast` + `eventMono` gives `X (Hφ)`; `Axiom.until_F` at guard `⊥` gives `F (Hφ)`.

The `F⊤` antecedent conjunct is unused (at Discrete, `X⊤` is stronger and already a theorem);
it is retained because the *schema*, not the derivation, must match `tr (BL DF)`.

## Association pinned for Phase 7
`((φ.allPast.and φ).and Formula.top.someFuture).imp (φ.allPast.someFuture)`

## Next action
Phase 2 (BL axiom set). BL-side DF must translate to exactly the association above.
