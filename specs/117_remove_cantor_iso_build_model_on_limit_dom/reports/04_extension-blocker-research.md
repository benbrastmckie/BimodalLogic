# Research Report: Resolving the forward_G Extension Blocker

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: Research complete
- **Type**: lean4
- **Artifacts**: reports/04_extension-blocker-research.md

## Executive Summary

After thorough analysis of the Burgess 1982 paper, the full codebase architecture (FMCS, BFMCS, truth_at, valid, TaskFrame, parametric truth lemma, TemporalCoherence, UntilSinceCoherence), and five proposed approaches, I have identified a fundamental architectural mismatch between Burgess's construction and the codebase's semantics. This mismatch is the root cause of the extension blocker.

**Root Cause**: Burgess builds his countermodel on X (= limit_dom), a suborder of Q, with truth conditions quantifying only over X. The codebase's `truth_at` quantifies over ALL of D (which must be an AddCommGroup), including non-domain rationals. These non-domain rationals need MCS assignments satisfying forward_G, but strict G prevents any constant-MCS assignment from working, and Lindenbaum extensions add uncontrollable G-formulas.

**Recommended Approach**: Restructure the parametric infrastructure to support a domain-restricted semantics where truth_at quantifies over the FMCS domain rather than all of D. This is a significant refactoring (~25-40 hours) but is the mathematically correct solution that aligns with Burgess's actual proof strategy.

**Alternative (if refactoring is rejected)**: Abandon the chronicle-based countermodel for the base logic and instead prove the three sorry'd coherence properties (`restricted_tc`, `restricted_buc`, `restricted_fuc`) for the existing Int chain construction directly.

---

## The Fundamental Problem (Detailed)

### What the FMCS Must Provide

The `dd_countermodel_chronicle` theorem must produce:

```lean
∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
  (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
  (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
  ¬truth_at TM Omega τ t φ
```

The `truth_at` definition quantifies over ALL of D:

```lean
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s φ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r ψ
```

The parametric truth lemma (ParametricTruthLemma.lean:309) directly uses `fam.forward_G`:

```lean
have h_psi_mcs : psi ∈ fam.mcs s := fam.forward_G t s psi hts h_G
```

This requires `forward_G : ∀ t t' φ, t < t' → G(φ) ∈ mcs t → φ ∈ mcs t'` to hold for ALL `t, t' : D`.

### What the Chronicle Provides

The chronicle gives:
- `limit_f : Rat → Set Formula` (total function, returns `∅` for non-domain points)
- `limit_forward_G` / `limit_backward_H` for domain points only
- `limit_satisfies_c5_strong`: Until witnesses at domain points, guard on domain points
- `limit_F_resolution` / `limit_P_resolution`: F/P witnesses in domain

### The Gap

If D = Rat:
- `limit_f(q) = ∅` for non-domain q (not an MCS)
- Any extension `extended_f(q)` for non-domain q must be an MCS
- `forward_G` must hold between ALL pairs of rationals
- Strict G means `G(φ) ∈ M` does NOT imply `φ ∈ M`, so constant-MCS assignment fails
- Lindenbaum adds uncontrollable G-formulas

If D = LimitDomSubtype:
- forward_G holds (from limit_forward_G)
- BUT: LimitDomSubtype lacks AddCommGroup (a + b may not be in limit_dom)
- AddCommGroup is required by TaskFrame, truth_at, WorldHistory, ShiftClosed

### Why No Simple Extension Works

The handoff (.handoff-phase4.md) documented 7 failed approaches. The root cause for all:

1. **Root MCS**: G(φ) ∈ A does not give φ ∈ A (strict G)
2. **Nearest domain bound**: Two non-domain rationals share same MCS, same failure
3. **g_content Lindenbaum**: g_content(A) may be Set.univ for adjacent pairs with no intermediate domain points, making the seed inconsistent
4. **Any constant assignment on an interval**: Strict G blocks self-propagation
5. **Future intersection seed**: Forward_G from non-domain to nearest domain fails because Lindenbaum adds G-formulas outside the seed
6. **Arbitrary Lindenbaum**: No control over which G-formulas are added

The Until guard adds a SECOND dimension to the problem: `forward_until_since_coherent` requires the guard formula `ψ ∈ fam.mcs r` for ALL `r : D` between source and witness, not just domain points.

---

## Approach A: Prove limit_dom is Always Dense

### Viability: NO

The chronicle construction only inserts points when forced by C4/C5 counterexamples. For an MCS A0 with only propositional, G/H, and Box formulas (no Until/Since), C5 only adds peripheral witnesses for F-obligations. C4 only triggers between points with specific neg(U(...)) formulas. Without density obligations, adjacent domain pairs can survive indefinitely.

Research round 3 correctly concluded: "X may be discrete, dense, or mixed."

A concrete example: if A0 contains G(p) for all atoms p, then at every domain point, all atoms are true. F-obligations add peripheral points but never insert between existing adjacent pairs. The domain becomes order-isomorphic to Z (integer-like), which is countable with no endpoints but NOT dense.

### Estimated effort: N/A

---

## Approach B: Canonical Extension (Lindenbaum on Rat)

### Viability: NO (for the reasons above)

Every proposed seed set for Lindenbaum at non-domain rationals fails because:
1. Lindenbaum adds G-formulas outside the seed with no structural relationship to domain points
2. Forward_G from non-domain to domain requires controlling the G-content of the Lindenbaum extension, which standard Lindenbaum does not support
3. Even the most carefully crafted seed (T_q = intersection of limit_f over all domain points above q) is G-closed but the extension is not

The Until guard poses an additional problem: even if forward_G could be solved, the guard condition at non-domain rationals between source and witness requires psi in the MCS at every intermediate rational.

### Estimated effort: N/A

---

## Approach C: Follow Burgess Exactly

### Viability: YES (mathematically), but requires architecture change

**Key finding**: Burgess builds his countermodel on X (= limit_dom) with truth conditions quantifying only over X. He NEVER extends to all of Q. His Claim 2.11 says `x ∈ V(α) iff α ∈ f(x)` for x ∈ X, and the Until induction explicitly quantifies "z ∈ X" (not z ∈ Q).

The chronicle already provides everything Burgess needs:
- limit_c0: MCS at every domain point
- limit_forward_G / limit_backward_H: G/H propagation on domain
- limit_satisfies_c5_strong: Until witnesses with guard on domain
- limit_satisfies_c4: C4 counterexample elimination
- limit_F_resolution / limit_P_resolution: F/P witnesses

**Architectural obstacle**: The codebase's `valid` quantifies over `D : Type` with `AddCommGroup D`, and `truth_at` quantifies over ALL of D. LimitDomSubtype is NOT an AddCommGroup.

### Estimated effort: 25-40 hours (architecture change, see Approach D)

---

## Approach D: Restructure Parametric Infrastructure

### Viability: YES (recommended if we want a clean solution)

### The Design

Modify the parametric infrastructure to support a domain-restricted FMCS where truth_at quantifies over the domain, not all of D. Two sub-approaches:

**D1: Domain-Restricted Truth**

Modify `truth_at` to take a domain predicate:

```lean
def truth_at_dom (M : TaskModel F) (Omega : Set (WorldHistory F))
    (dom : D → Prop) (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.all_future φ => ∀ (s : D), dom s → t < s → truth_at_dom M Omega dom τ s φ
  | Formula.untl φ ψ => ∃ s : D, dom s ∧ t < s ∧ truth_at_dom M Omega dom τ s φ ∧
      ∀ r : D, dom r → t < r → r < s → truth_at_dom M Omega dom τ r ψ
```

Then define `valid_dom` that quantifies over arbitrary domains within D. Prove completeness relative to this definition.

**Problem**: This changes the semantics. `valid_dom` is a different notion from `valid`. Soundness and completeness would be for `valid_dom`, not for the original `valid`. We'd need to prove `valid ↔ valid_dom` or use `valid_dom` throughout.

Actually, for linear orders, `valid` (over all D) and "valid on all linear sub-orders" ARE equivalent (since any sub-order IS a linear order). So validity on (X, <) IS validity in the sense of the completeness theorem. But formally connecting them requires work.

**D2: Embed X into a Group**

Find an ordered abelian group D and an order-embedding X ↪ D, then transport the FMCS along this embedding. Since limit_dom ⊆ Q and Q is an ordered abelian group, the embedding is just inclusion. But then we're back to D = Rat and the extension problem.

Unless we can transport truth from (X, <) to (Rat, <) differently. If phi is valid on all linear orders (X, <), it's valid on (Rat, <). The contrapositive: if phi is NOT valid on SOME linear order, phi is not valid on ALL linear orders, hence not valid. So the countermodel on (X, <) suffices for refuting validity.

**D3: Modify `valid` to accept any linear order**

This is the cleanest approach. Change `valid` to:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [LinearOrder D] ...
```

without requiring `AddCommGroup D`. This would require removing the group structure from TaskFrame or making it optional.

**This is a significant redesign** touching soundness, validity, TaskFrame, WorldHistory, truth_at, and all interaction axioms. The modal-temporal interaction axioms (MF: □φ → □(Gφ), TF: □φ → G(□φ)) and the ShiftClosed condition require the group structure.

### Estimated effort

- D1 (domain-restricted truth): 15-20 hours
- D2 (embed X into group): Doesn't work (reduces to extension problem)
- D3 (modify valid): 40-60 hours (touches entire semantics layer)

### Files affected

At minimum: FMCSDef.lean, BFMCS.lean, ParametricTruthLemma.lean, RestrictedParametricTruthLemma.lean, ParametricHistory.lean, ParametricCanonical.lean, ParametricRepresentation.lean, TemporalCoherence.lean, UntilSinceCoherence.lean, CanonicalModel.lean, ChronicleToCountermodel.lean, Completeness.lean

---

## Approach E: Irrationality of Until

### Viability: NO

The axiom `Irr_U : U(φ,ψ) → U(φ, ψ ∧ ¬U(φ,ψ))` is not in the BX axiom system. The existing axioms BX5 (self_accum_until), BX6 (absorb_until), and BX14 (separation_until) do not collectively imply Irr_U. Even if added, Irr_U constrains witness CHOICE but does not force density of the domain.

### Estimated effort: N/A

---

## Recommended Path Forward

### Primary Recommendation: Prove Int chain coherence properties directly

The cleanest path that avoids architectural changes is to **abandon the chronicle-based countermodel for base completeness** and instead prove the three sorry'd properties of the Int chain:

1. `bx_bfmcs_restricted_tc` (restricted temporal coherence)
2. `bx_bfmcs_restricted_buc` (restricted backward Until/Since coherence)
3. `bx_bfmcs_restricted_fuc` (restricted forward Until/Since coherence)

The Int chain has D = Int with forward_G/backward_H already proved. The remaining sorries are about:
- **tc**: F(φ) in chain(n) implies witness at some m > n with φ in chain(m). This requires showing that F-obligations eventually resolve along the chain. The forward chain uses g_content seeds, and F(φ) = ¬G(¬φ). If F(φ) persists, it creates an infinite chain of F-obligations. The resolution comes from the chain's construction ensuring each MCS is "as different as possible" from its predecessor.
- **buc**: backward Until/Since. Given a witness pattern (φ at s, ψ on guard [t,s)), derive (φ U ψ) in chain(t). The `UntilSinceCoherence.lean` module provides `backward_until_from_step` parameterized by a step transfer hypothesis. Proving the step transfer for the Int chain requires `(φ U ψ) ∈ chain(n+1) ∧ ψ ∈ chain(n) → (φ U ψ) ∈ chain(n)`.
- **fuc**: forward Until/Since. Given (φ U ψ) in chain(n), produce a witness m > n with φ in chain(m) and ψ on guard [n,m). This is the hardest part -- the Int chain doesn't insert Until witnesses.

The Int chain approach requires resolving Until/Since obligations along a linear chain, which is fundamentally different from the chronicle's point-insertion approach. This is a hard problem but it's a self-contained mathematical challenge without architectural risk.

**Estimated effort**: 20-30 hours for all three properties.

### Secondary Recommendation: Domain-restricted truth lemma (Approach D1)

If the Int chain approach proves too difficult, the next best option is D1: create a parallel `truth_at_dom` and `valid_dom` infrastructure, prove they are equivalent to the original for base validity, then use the chronicle directly on limit_dom.

**Proof of equivalence**: For base TM logic (no density/discreteness axioms), a formula φ is valid on all linear orders iff it is valid on all AddCommGroup-ordered types. The forward direction is trivial (AddCommGroup types form a subset of linear orders). The backward direction requires showing that any linear order (X, <) can be order-embedded into some AddCommGroup D. This is true: any linear order embeds into the rationals (if countable) or the reals (in general), both of which are AddCommGroup.

However, formalizing this equivalence in Lean requires Cantor-type embedding theorems from Mathlib, adding complexity.

**Estimated effort**: 25-40 hours including the equivalence proof.

### What NOT to Do

- Do NOT attempt Approach B (Lindenbaum extension on Rat) -- it is provably stuck
- Do NOT attempt Approach A (prove density) -- limit_dom is not always dense
- Do NOT introduce sorry deferral -- the goal is zero sorries
- Do NOT add new axioms (Irr_U) -- changes the logic

---

## Summary Table

| Approach | Viable? | Effort | Risk | Notes |
|----------|---------|--------|------|-------|
| A: Prove density | NO | N/A | N/A | limit_dom can be discrete |
| B: Lindenbaum extension | NO | N/A | N/A | Lindenbaum adds uncontrollable G-formulas |
| C: Follow Burgess | YES (math) | 5-10h + arch change | Low (math) | Architecturally incompatible as-is |
| D: Restructure infra | YES | 25-60h | HIGH | Touches entire semantics layer |
| E: Irr_U axiom | NO | N/A | N/A | Axiom not in system |
| **Int chain fix** | **YES** | **20-30h** | **MEDIUM** | **Self-contained, no arch changes** |
| D1 + chronicle | YES | 25-40h | MEDIUM | Parallel infra + equivalence proof |

### Final Recommendation

**Mark task 117 as [BLOCKED] and create a new task** to investigate proving the Int chain's three sorry'd coherence properties directly. The chronicle construction remains valuable reference material but should not be the primary path to sorry-free completeness for base TM logic.

The chronicle pathway (D = Rat with Cantor iso) was sound when density was available. Without density, the architectural mismatch between Burgess's X-based semantics and the codebase's AddCommGroup-D semantics cannot be bridged by any extension argument. The Int chain pathway (D = Int) avoids this mismatch entirely because Int is an AddCommGroup and forward_G holds on ALL integers by construction.
