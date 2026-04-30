# Phase 8b Handoff: A7a Axiom Invalidity

**Status**: BLOCKED — plan describes an unsound axiom
**Date**: 2026-04-30
**Agent**: lean-implementation-agent

## Summary

Phase 8b cannot be implemented as specified. The plan's target "A7a" formula is **not semantically valid** on linear temporal orders. Implementing it would introduce an unsound axiom, breaking the proof system.

## The Invalidity Argument

### Setup

In the Lean codebase, `untl φ ψ` means: φ is the **guard** (holds between t and the witness), ψ is the **event** (holds at the witness). Formally:

```
untl φ ψ holds at t ↔ ∃ s > t, ψ@s ∧ ∀ r ∈ (t,s), φ@r
```

### BX7 (current, valid)

```
U(φ,ψ) ∧ U(χ,θ) → U(φ∧χ, ψ∧θ) ∨ U(φ∧χ, ψ∧χ) ∨ U(φ∧χ, φ∧θ)
```

With witnesses s1 for `U(φ,ψ)` and s2 for `U(χ,θ)`:
- s1=s2: D1 works. Event ψ∧θ at s1. Guard φ∧χ on (t,s1). ✓
- s1<s2: D2 works with witness s1. Event ψ∧χ at s1: ψ@s1 ✓, χ@s1 (since s1 ∈ (t,s2), χ holds there) ✓. Guard φ∧χ on (t,s1) ✓.
- s2<s1: D3 works with witness s2. Event φ∧θ at s2: θ@s2 ✓, φ@s2 (since s2 ∈ (t,s1), φ holds there) ✓. Guard φ∧χ on (t,s2) ✓.

BX7 is valid because D2 uses **χ (the guard of second Until)** at the first witness, and D3 uses **φ (the guard of first Until)** at the second witness. Guards hold in open intervals.

### A7a (plan's target, INVALID)

```
U(φ,ψ) ∧ U(χ,θ) → U(φ∧χ, ψ∧θ) ∨ U(φ∧θ, ψ∧θ) ∨ U(χ∧ψ, ψ∧θ)
```

All three disjuncts have **fixed event ψ∧θ**. For any disjunct to hold, we need ∃w > t with *both* ψ@w and θ@w.

**Counterexample**: Let T = ℕ, t = 0.
- φ holds only at {1} (guard of first Until)
- ψ holds only at {1} (event of first Until)  → U(φ,ψ) holds at 0 with witness 1 ✓
- χ holds at {1,2} (guard of second Until)
- θ holds only at {2} (event of second Until) → U(χ,θ) holds at 0 with witness 2 ✓

Now ψ∧θ holds nowhere (ψ only at 1, θ only at 2, and 1≠2). So D1, D2, D3 all fail.

**A7a is invalid on this model.** BX7 is valid on it (D2 uses witness 1 with event ψ∧χ = ψ∧χ, where χ@1 holds since 1 ∈ (0,2)).

## Why the Plan Has This Error

The plan (Report 48 synthesis) correctly identifies that Burgess needs all disjuncts to share the same event for Lemma 2.7. It appears to construct A7a by fixing the event to `ψ∧θ`. However, this construction fails because:

- BX7's power comes from using the **guard** of one Until as the **event** component of a disjunct
- The guard holds throughout the open interval, so it holds at the earlier witness
- The **event** of a Until holds only at its witness, not necessarily at the other witness

The plan confused "having the same event structure" with "having event ψ∧θ". What Burgess actually needs is a linearity formula where, in the special case where both input events are equal (ψ = θ), all disjuncts have that same event.

## What Actually Works

### Option 1: Keep BX7, Derive What's Needed for Lemma 2.7

When ψ = θ (both Until formulas have the same event), BX7 gives:
- D1 = U(φ∧χ, ψ∧ψ) → event ψ∧ψ, implies ψ via lce
- D2 = U(φ∧χ, ψ∧χ) → event ψ∧χ, implies ψ via lce
- D3 = U(φ∧χ, φ∧ψ) → event φ∧ψ, implies ψ via rce

All events imply ψ. So in the special case psi=theta, ALL disjuncts have event that implies ψ. This is what Burgess's proof actually needs:
- Burgess applies BX7 to two formulas with the SAME event (both have event `β₀∧η`)
- D1, D2, D3 then have events ψ∧ψ, ψ∧χ, φ∧ψ where all imply ψ
- To rule out D1 and D2 via `¬U(γ₀, β₀∧η)`, the plan needs to show D1 event = β₀∧η and D2 event = β₀∧η... but wait, D2 event = ψ∧χ ≠ ψ in general.

Hmm, this still needs more thought. The key insight from Report 48 may be different.

### Option 2: Re-examine What Burgess's Proof Actually Uses

The actual Burgess 1982 paper should be consulted to determine the exact form of the linearity axiom. The plan's description of "A7a" may be a mischaracterization of Burgess's actual axiom. In particular, Burgess may use a form that IS equivalent to BX7 but written differently, or he may use a derived lemma rather than a base axiom.

### Option 3: Use Xu's Alternative (Report 48, Finding 3)

Report 48 mentions Xu's Lemma 2.4 avoids the BX7/A7a issue entirely. This is a viable fallback.

## Recommendation

**Run `/revise 107` to create Plan v35** with the following corrections:

1. **Do NOT replace BX7 with A7a** — A7a as described is not sound. BX7 must remain.

2. **For Phase 8b**: Investigate the actual Burgess 1982 axiom system. Either:
   - Burgess's actual A7a is equivalent to BX7 (just written differently), or
   - Burgess uses BX7 directly in Lemma 2.7 with a different argument structure, or
   - Burgess's argument for Lemma 2.7 uses a derived lemma that follows from BX7

3. **For Phase 6 (Lemma 2.7)**: The plan's account of how D1 and D2 are ruled out needs re-examination. With BX7 applied to two formulas with event `β₀∧η`:
   - D1 event = `(β₀∧η)∧(β₀∧η)` which simplifies to `β₀∧η` ✓ (can be ruled out)
   - D2 event = `(β₀∧η)∧χ` where χ is the guard of the second Until. This does NOT simplify to `β₀∧η` unless χ=β₀∧η.
   - D3 event = `φ∧(β₀∧η)` where φ is the guard of the first Until. Similarly mixed.

   The plan's assertion that D1 and D2 are both ruled out by `¬U(γ₀, β₀∧η)` was based on the incorrect A7a where all events equal `ψ∧θ = β₀∧η`. With BX7, this doesn't hold.

4. **Consider Xu's approach** as primary strategy for Lemma 2.7, per Report 48 Finding 3.

## Files Not Modified

No source files were changed. The codebase is in its original state. The build passes with zero sorries added.
