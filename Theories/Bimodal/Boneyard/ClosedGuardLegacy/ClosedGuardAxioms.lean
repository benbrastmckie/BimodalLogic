/-!
# Archived Axiom Constructors (Closed/Half-Closed Guard)

Archived 2026-04-27 (task 113): These axiom constructors are unsound under
open guard semantics (t,s) for Until/Since. The half-closed guard [t,s) that
made them valid was replaced by open guard to match Kamp 1968, Burgess 1982,
Xu 1988, Reynolds 1992, and the paper (possible_worlds.tex lines 1182-1189).

## Removed Constructors

### BX9 / BX9': until_elim / since_elim

```
  /-- BX9: Until elimination: `(φ U ψ) → (φ ∨ ψ)`.
  Under irreflexive Until semantics with A2 guard, `φ U ψ` at t has witness s > t
  with ψ(s) and guard φ on [t,s). Since t ∈ [t,s), φ(t) holds. So φ ∨ ψ at t. -/
  | until_elim (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp (Formula.or φ ψ))

  /-- BX9': Since elimination: `(φ S ψ) → (φ ∨ ψ)`.
  Under irreflexive Since, `φ S ψ` at t has witness s < t with ψ(s) and guard φ
  on (s,t]. Since t ∈ (s,t], φ(t) holds. So φ ∨ ψ at t. -/
  | since_elim (φ ψ : Formula) :
      Axiom ((Formula.snce φ ψ).imp (Formula.or φ ψ))
```

**Why unsound**: Under open guard (t,s), the guard only covers the *interior*
of the interval. The current time t is NOT in (t,s), so φ(t) is not guaranteed.
Countermodel: any frame where φ U ψ holds at t with ¬φ(t) ∧ ¬ψ(t) and witness
s > t with ψ(s) and φ on (t,s).

### Layer 3c: until_guard / since_guard

```
  -- Layer 3c: Until/Since Guard Axioms (2)
  -- Under half-open guard semantics, (φ U ψ) at t has guard φ on [t,s).
  -- Since t ∈ [t,s), the guard gives φ(t) directly.

  /-- Until guard: `(φ U ψ) → φ`.
  Under half-open guard [t,s): φ U ψ at t has witness s > t with ψ(s) and φ on [t,s).
  Since t ≤ t and t < s, the guard gives φ(t). Strictly stronger than BX9 (until_elim). -/
  | until_guard (φ ψ : Formula) :
      Axiom ((Formula.untl φ ψ).imp φ)

  /-- Since guard: `(φ S ψ) → φ`.
  Under half-open guard (s,t]: φ S ψ at t has witness s < t with ψ(s) and φ on (s,t].
  Since s < t and t ≤ t, the guard gives φ(t). -/
  | since_guard (φ ψ : Formula) :
      Axiom ((Formula.snce φ ψ).imp φ)
```

**Why unsound**: Under open guard (t,s), the guard is ∀r, t < r → r < s → φ(r).
The current time t does not satisfy t < t, so φ(t) is not implied.
-/
