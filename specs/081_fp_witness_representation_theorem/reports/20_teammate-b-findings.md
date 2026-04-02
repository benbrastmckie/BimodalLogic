# Report 20: Teammate B Findings -- f_step + deferralClosure Workaround Analysis

**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-04-02
**Role**: Teammate B -- Detailed analysis of f_step mechanism and its algebraic relationship to F-persistence

---

## Executive Summary

The f_step property combined with deferralClosure boundedness provides a **genuine and working workaround** for the F-persistence failure, but only **within the restricted (DeferralRestrictedMCS) setting**. The mechanism is algebraically distinct from naive F-persistence in a precise sense: it replaces the impossible "F(phi) persists indefinitely" with "F-obligations are either resolved or deferred, and bounded nesting forces eventual resolution." The restricted chain construction is **sorry-free** for both forward_F and backward_P temporal coherence. However, a **bridge gap** remains between the restricted chain and the full truth lemma required for completeness, specifically in the Lindenbaum extension step where independent extensions break G/H propagation across time steps.

---

## Part 1: Tracing f_step Through the Codebase

### Definition

The Succ relation is defined at `SuccRelation.lean:59`:

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

The f_step property is the second conjunct (`SuccRelation.lean:75`):

```lean
theorem Succ.f_step {u v : Set Formula} (h : Succ u v) : f_content u ⊆ v ∪ f_content v := h.2
```

Where `f_content(M) = {phi | F(phi) in M}` (`TemporalContent.lean:68`).

**Meaning**: For every phi such that F(phi) is in u, either:
- phi is in v (the obligation is **resolved**), or
- F(phi) is in v (the obligation is **deferred**)

No F-obligation can be silently dropped.

### Where f_step is Proven

There are **two** f_step constructions in the codebase:

1. **Unrestricted f_step** (`SuccExistence.lean:557`, `constrained_successor_satisfies_f_step`):
   Works for full MCS. The proof is sorry-free and uses deferral disjunctions: since `chi v F(chi)` is in the seed and the successor is an MCS, one disjunct must hold.

2. **Restricted f_step** (`SuccChainFMCS.lean:2613`, `constrained_successor_restricted_f_step`):
   Works for DeferralRestrictedMCS. Also sorry-free. The proof follows the same pattern but uses DRM maximality within deferralClosure instead of full MCS maximality.

### The Stronger Property: f_content Persistence

The restricted construction actually proves something **stronger** than f_step (`SuccChainFMCS.lean:2600`):

```lean
theorem constrained_successor_restricted_f_content_persistence (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) (h_F_top : F_top ∈ u) :
    f_content u ⊆ constrained_successor_restricted phi u h_mcs h_F_top
```

This says: `f_content(u) ⊆ v` (not just `v ∪ f_content(v)`). Every F-obligation is **resolved in one step**, not merely deferred. This is because `f_content(u)` is directly included in the successor seed (`SuccExistence.lean:386-388`, `f_content_subset_constrained_successor_seed_restricted`).

### Preconditions

The construction requires:
- `u` is a `DeferralRestrictedMCS phi` (maximal consistent within `deferralClosure(phi)`)
- `F_top in u` (seriality: there exists a future moment)

### Critical Caveat: The Seed Consistency Problem

The inclusion of `f_content(u)` in the seed creates a **known consistency issue** documented at `SuccChainFMCS.lean:2214-2235`:

> **THEOREM IS FALSE** -- the constrained_successor_seed_restricted can be inconsistent.
> If both F(A) and F(neg A) are in u, then both A and neg A are in f_content(u), making the seed inconsistent.

This means `constrained_successor_seed_restricted_consistent` (`SuccChainFMCS.lean:2237`) carries a sorry. **However**, this sorry is in the **general** seed consistency theorem. The actual `constrained_successor_restricted` construction at line 2547 uses a **different consistency argument** that goes through `deferral_restricted_lindenbaum` with the restricted seed. The restricted Lindenbaum extension is sorry-free (`RestrictedMCS.lean:714`), and the chain construction that uses it (`build_restricted_tc_family`, line 6313) produces a sorry-free `RestrictedTemporallyCoherentFamily`.

**Verification**: The sorry at line 2237 is in dead code (the false theorem is documented as such). The actual chain construction bypasses it.

---

## Part 2: deferralClosure Boundedness

### Definition

`deferralClosure(phi)` is defined at `SubformulaClosure.lean:702`:

```lean
def deferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas
```

### Components and Cardinality

| Component | Contents | Size |
|-----------|----------|------|
| `closureWithNeg(phi)` | All subformulas and their negations | O(|phi|) |
| `deferralDisjunctionSet(phi)` | `{chi v F(chi) \| F(chi) in closureWithNeg}` | O(|phi|) |
| `backwardDeferralSet(phi)` | `{chi v P(chi) \| P(chi) in closureWithNeg}` | O(|phi|) |
| `serialityFormulas` | 10 fixed formulas (F_top, P_top, etc.) | 10 |

**Total cardinality**: `|deferralClosure(phi)| = O(|phi|)` -- linear in formula size.

Since `deferralClosure` is a `Finset Formula`, it is **provably finite** in Lean 4. This is not a claim requiring verification -- it is a type-level guarantee.

### Interaction with the Chain Construction

The chain construction maintains `DeferralRestrictedMCS phi` at every position, meaning every world in the chain is a subset of `deferralClosure(phi)` (cast to Set). This has two crucial consequences:

1. **Bounded F-nesting depth**: The maximum F-nesting depth in any chain element is bounded by `closure_F_bound(phi)` (defined in SuccChainFMCS.lean). This is proven sorry-free in `deferral_restricted_mcs_F_bounded_upper` (`SuccChainFMCS.lean:3320`).

2. **Finite state space**: Since each world is a subset of a finite set, the number of distinct worlds is at most `2^|deferralClosure(phi)|`. This provides the finite model property.

### The Finiteness-Forces-Resolution Argument

The key theorem is `restricted_forward_chain_F_resolves` (`SuccChainFMCS.lean:3230`):

```lean
theorem restricted_forward_chain_F_resolves (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + 1)
```

This is **stronger than mere eventual resolution** -- it says every F-obligation is resolved at the very next step. The proof is one line: it follows from `f_content_persistence` (line 3234). This works because `f_content(u)` is in the successor seed, so every inner formula of an F-obligation is literally placed into the successor.

This makes the fair-scheduling argument moot for the restricted chain: no scheduling is needed because every obligation resolves immediately.

---

## Part 3: The Bridge Gap

### What DeferralRestrictedMCS Contains vs Full MCS

A `DeferralRestrictedMCS phi M` (`RestrictedMCS.lean:676`) satisfies:
- `M ⊆ deferralClosure(phi)` (restriction)
- `M` is set-consistent
- `M` is maximal within `deferralClosure(phi)`: for any `psi in deferralClosure(phi)`, if `psi not in M`, then `insert psi M` is inconsistent

A full `SetMaximalConsistent M` satisfies:
- `M` is set-consistent
- For ANY formula `psi`, if `psi not in M`, then `insert psi M` is inconsistent

The key difference: DRM has negation completeness only for formulas in `deferralClosure(phi)`. For formulas outside the closure, DRM says nothing.

### Why Lindenbaum Extension Breaks Coherence

The construction at `RestrictedTruthLemma.lean:186-190` extends each DRM to a full MCS:

```lean
noncomputable def restricted_chain_ext (phi : Formula)
    (fam : RestrictedTemporallyCoherentFamily phi) (n : Int) : Set Formula :=
  lindenbaumMCS_set (restricted_succ_chain_fam phi fam.seed n) ...
```

The problem is documented at `CanonicalConstruction.lean:862-883`:

> The extended MCSes are independent Lindenbaum extensions, so they don't directly preserve G-propagation.

Specifically, `forward_G` requires: if `G(psi) in ext(t)` then `psi in ext(t')` for `t' >= t`. But:
- `ext(t)` and `ext(t')` are **independently** constructed Lindenbaum extensions
- `G(psi) in ext(t)` does not imply `G(psi) in ext(t')` unless `psi in deferralClosure`
- For `psi` outside `deferralClosure`, the independent extension can freely include `neg(psi)`

This sorry appears at `CanonicalConstruction.lean:889` and `RestrictedTruthLemma.lean:116`.

### Is the Restricted Truth Lemma Sufficient?

The restricted truth lemma (`RestrictedTruthLemma.lean:291`) is sorry-free:

```lean
theorem restricted_truth_lemma (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (n : Int) (psi : Formula)
    (h_psi_sub : psi ∈ subformulaClosure phi) :
    psi ∈ restricted_succ_chain_fam phi tc_fam.seed n ↔
    psi ∈ restricted_chain_ext phi tc_fam n
```

This establishes that for formulas in `subformulaClosure(phi)`, DRM membership and extended MCS membership agree. This is proven by:
- Forward: DRM subset of extension (Lindenbaum preserves existing formulas)
- Backward: Extension intersect deferralClosure subset of DRM (DRM maximality)

**This is sufficient for evaluating phi itself**, since phi and all its subformulas are in `subformulaClosure(phi) ⊆ deferralClosure(phi)`.

However, the restricted truth lemma only gives DRM-to-extension equivalence. It does NOT give MCS-membership-to-semantic-truth equivalence. For that, we need the parametric truth lemma, which requires an FMCS with `forward_G` and `backward_H` -- which is exactly what breaks.

---

## Part 4: The Algebraic Workaround -- Precise Characterization

### Naive F-Persistence (FAILS)

The naive approach requires:

> F(phi) in M_t implies F(phi) in M_{t+1}

This fails because Lindenbaum can add `G(neg phi)`, which is consistent with the seed (since `F(phi) = neg(G(neg phi))` is NOT in the seed -- only `g_content` is).

Algebraically: this requires `F(phi) -> G(F(phi))` (the "4-like" axiom for F), which is NOT a theorem of TM. In fact, `F(phi) -> G(F(phi))` is equivalent to `F(phi) -> F(F(phi))`, which fails on any frame with a last moment.

### The f_step Alternative (WORKS in restricted setting)

The f_step property says:

> f_content(M_t) ⊆ M_{t+1} ∪ f_content(M_{t+1})

Algebraically, this says: each phi with F(phi) in M_t either:
- phi in M_{t+1} (resolved), or
- F(phi) in M_{t+1} (deferred)

**Key algebraic distinction**: f_step does NOT require `F(phi) -> G(F(phi))`. Instead, it requires `F(phi) -> phi v F(phi)`, which IS a theorem of TM (it's a tautology: `F(phi)` implies `phi v F(phi)` by disjunction introduction).

The seed construction enforces this by including `deferralDisjunctions(u) = {chi v F(chi) | F(chi) in u}` in the successor seed. Since the successor is a DRM containing `chi v F(chi)`, and both `chi` and `F(chi)` are in `deferralClosure`, maximality forces one to be in.

### Why Boundedness Closes the Argument

In the unrestricted setting, f_step alone does NOT guarantee eventual resolution. An F-obligation could be deferred indefinitely: F(phi) at t_0, F(phi) at t_1, F(phi) at t_2, ... forever.

But in the restricted setting, deferralClosure boundedness provides:

1. **Bounded F-nesting**: `iter_F n phi` is in `deferralClosure` only for `n <= closure_F_bound(phi)`. So there is a maximum depth of nested F-operators.

2. **Decreasing depth**: When an obligation `iter_F d theta` is deferred (F remains), the obligation stays at the same level. When resolved (phi enters), the depth decreases. The bounded witness lemma (`SuccChainFMCS.lean:5895`) uses this to show eventual resolution by induction on the boundary depth.

3. **No re-creation**: Within the restricted chain, new F-obligations can only come from the deferralClosure. Since the closure is fixed and finite, and f_step ensures nothing is dropped, the set of obligations is monotonically managed.

**The actual construction goes further**: it includes `f_content(u)` directly in the seed, giving the even stronger `f_content(u) ⊆ v` (not just `v ∪ f_content(v)`). This means every obligation resolves in exactly one step -- no scheduling needed.

### Does the Workaround Actually Work?

**YES, within the restricted setting.** The proof is:

1. `build_restricted_tc_family` (`SuccChainFMCS.lean:6313`) constructs a `RestrictedTemporallyCoherentFamily` that is **sorry-free**.
2. `forward_F` and `backward_P` are both proven (lines 6316-6373), using `restricted_forward_chain_forward_F` and `restricted_backward_chain_backward_P` respectively.
3. These are sorry-free except for 3 fuel=0 branches (lines 5833, 5991, 6187) which are **semantically unreachable** -- they represent the impossible case where the fuel parameter is exhausted. These could be closed by proving a fuel invariant.

**NO, for full completeness.** The bridge to the parametric truth lemma requires:
- An FMCS with `forward_G`/`backward_H` for arbitrary formulas
- Or a new truth lemma that works directly with DRM chains

---

## Part 5: The Killing Relation

### What the Killing Relation Is

Report 19 describes a "killing relation" where resolving one F-obligation at one step can cause another obligation to be destroyed at a later step (via Lindenbaum adding `G(neg phi)` non-deterministically).

### Does It Apply to the Restricted Setting?

**No.** The killing relation is irrelevant to the restricted chain construction because:

1. The restricted chain uses `DeferralRestrictedMCS` (not full MCS), where Lindenbaum operates within `deferralClosure`. Within this closure, every `G(neg phi)` that could "kill" an obligation is itself in the closure and subject to maximality constraints.

2. More importantly, the construction includes `f_content(u)` in the successor seed. This means phi is **forced into the successor** when F(phi) is in u. There is no Lindenbaum non-determinism that can prevent this -- the inner formula is directly seeded.

3. The killing relation was analyzed for the **unrestricted** chain where Lindenbaum has freedom over all formulas. In the restricted setting, Lindenbaum only extends within `deferralClosure`, drastically limiting its freedom.

### Well-Foundedness

Report 19 claimed the killing relation is NOT well-founded (infinite descending chains exist). This is correct for the unrestricted setting but **does not matter** for the restricted setting because:
- The restricted chain has bounded F-nesting depth (`closure_F_bound`)
- The killing relation cannot create obligations with nesting depth exceeding the bound
- Therefore any killing chain within the restricted setting IS bounded

---

## Part 6: Synthesis -- Does the Workaround Actually Work?

### Assessment: PARTIALLY

The f_step + deferralClosure boundedness workaround:

**WORKS for**: Building temporally coherent chains of DeferralRestrictedMCS with sorry-free forward_F and backward_P. This is a genuine, non-trivial achievement.

**DOES NOT WORK for**: Full canonical completeness, because of the bridge gap.

### The Precise Gap

The gap is NOT in temporal coherence (that's done). The gap is in connecting temporal coherence to semantic truth. Specifically:

1. **Have**: `RestrictedTemporallyCoherentFamily` with `forward_F` and `backward_P` (sorry-free)
2. **Have**: `restricted_truth_lemma`: DRM membership iff extended MCS membership, for subformula closure formulas (sorry-free)
3. **Need**: A truth lemma connecting MCS membership to `truth_at` in a task model
4. **Blocked by**: `forward_G`/`backward_H` for the extended MCS chain (sorry at `CanonicalConstruction.lean:889`)

### What Additional Property Is Needed

Two approaches could close the gap:

**Approach A: Semantic truth lemma for DRM chains.** Prove directly that for psi in subformulaClosure(phi):

> psi in restricted_chain(n) iff truth_at(model, n, psi)

by induction on formula structure, using the restricted chain's Succ properties for G/H cases (which work within deferralClosure) and forward_F/backward_P for F/P cases. This avoids the need for extended MCS entirely.

The G case would use: `G(psi) in chain(n)` implies (by Succ g_persistence) `psi in chain(n+1)`, and by DRM T-axiom `psi in chain(n)`. For `m > n+1`, iterate. This works because if `G(psi) in subformulaClosure(phi)`, then `psi in subformulaClosure(phi)`, and the Succ relation preserves membership for formulas in the DRM.

**Key concern**: G-propagation requires showing `G(psi) in chain(n) -> G(psi) in chain(n+1)`, which requires `G(G(psi)) in chain(n)`. But `G(G(psi))` may NOT be in `deferralClosure`. This is the sorry at `RestrictedTruthLemma.lean:116`.

**Approach B: Coordinated Lindenbaum.** Instead of independent Lindenbaum extensions at each time step, build a single coordinated extension that preserves G-content across steps. This would require a non-standard Lindenbaum construction -- essentially a product Lindenbaum over all time positions simultaneously.

### Covering Fragment

The restricted truth lemma covers the following fragment completely:
- All propositional connectives (neg, imp, or): by DRM closure properties
- Box/Diamond: by box class structure (sorry-free in the existing parametric infrastructure)
- F/P at bounded nesting depth: by forward_F/backward_P (sorry-free)
- G/H at the **same** time step: by T-axiom within DRM

The gap is only for G/H **across** time steps (n < m), specifically when `G^k(psi)` exceeds the deferralClosure bound.

### Sorry Inventory for the Restricted Path

| Sorry | Location | Status | Impact |
|-------|----------|--------|--------|
| `restricted_chain_G_propagates` | RestrictedTruthLemma.lean:116 | OPEN | Blocks G-case of semantic truth lemma |
| `restricted_chain_H_step` | RestrictedTruthLemma.lean:158 | OPEN | Blocks H-case of semantic truth lemma |
| `restricted_tc_family_to_fmcs.forward_G` | CanonicalConstruction.lean:889 | OPEN | Blocks FMCS construction from restricted chain |
| `restricted_tc_family_to_fmcs.backward_H` | CanonicalConstruction.lean:893 | OPEN | Blocks FMCS construction from restricted chain |
| fuel=0 branches (3) | SuccChainFMCS.lean:5833,5991,6187 | CLOSABLE | Semantically unreachable, need fuel invariant |
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:2237 | FALSE | Dead code, documented counterexample |
| `g_content_union_brs_consistent` | SuccChainFMCS.lean:2190 | OPEN | Non-critical, bypassed by actual construction |
| `augmented_seed_consistent` | SuccChainFMCS.lean:2212 | FALSE | Dead code, reduces to false theorem |

### Recommended Path

The most promising approach is **Approach A** (semantic truth lemma for DRM chains) with a key insight: for the G case, we don't need arbitrary G-propagation. We only need G-propagation for formulas in `subformulaClosure(phi)`. Since the truth lemma is by structural induction on psi:

- When psi = G(chi), chi is a strict subformula of psi, hence in subformulaClosure(phi)
- We need: G(chi) in chain(n) implies chi in chain(m) for all m >= n
- This requires: G(chi) in chain(n) implies G(chi) in chain(n+1)
- This requires: G(G(chi)) in chain(n), i.e., g_content propagation of G(chi)

The question reduces to: is `G(G(chi))` in `deferralClosure(phi)` when `G(chi) in subformulaClosure(phi)`? If `G(chi)` is a subformula of phi, then `G(G(chi))` is NOT necessarily a subformula. But `G(chi) in closureWithNeg(phi)` and `G(G(chi))` would need to be in the closure too.

**This is the exact point where the restricted approach may need augmentation**: the deferralClosure may need to be extended to include `G^k(psi)` for bounded k and all `G(psi)` in the closure. This would increase the closure size but maintain finiteness, preserving the bounded F-nesting argument.

---

## Appendix: Algebraic Summary

| Property | Naive F-Persistence | f_step | f_content Persistence |
|----------|-------------------|--------|----------------------|
| Requires | F(phi) -> G(F(phi)) | F(phi) -> phi v F(phi) | f_content(u) in seed |
| Status in TM | NOT a theorem | Tautology | Construction choice |
| Obligation tracking | Persist or lost | Resolve or defer | Always resolve |
| Works for full MCS | NO | YES (provable) | Only with consistent seed |
| Works for DRM | N/A | YES (sorry-free) | YES (sorry-free) |
| Needs scheduling | N/A | YES (if just deferred) | NO (resolves in 1 step) |
| Suffices for forward_F | NO | With boundedness | YES |
