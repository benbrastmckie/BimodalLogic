# Teammate D: Truth Lemma End-to-End Findings

## Key Findings

1. **The truth lemma itself (TruthLemma.lean) is NOT the bottleneck.** All formula cases (atom, bot, imp, box, G, H, U forward, S forward) are proved. The 2 sorry sites (`until_backward_refl_mcs`, `since_backward_refl_mcs`) are dead code with no downstream consumers.

2. **The actual bottleneck is the BFMCS coherence properties** required by `dd_countermodel` in RootScopedChain.lean. Specifically, three restricted coherence obligations that `dd_countermodel` passes to the fully restricted parametric representation theorem.

3. **The completeness chain is clean and well-structured.** The architecture from `bx_completeness` down to the sorry sites is sound. The problem is entirely in proving that the Int-indexed chain (`dd_chain`) satisfies three coherence properties.

4. **The irreflexive semantics creates a genuine structural advantage**: `phi -> F(phi)` is NOT derivable, meaning resolved defects do not regenerate. This is the correct insight for closing the F-resolution sorry.

5. **The Until/Since coherence obligations (forward and backward) require a fundamentally different approach** than what the current chain provides. The chain is Lindenbaum-based and opaque -- it cannot provide the inter-step structural guarantees needed.

6. **The ROADMAP documents 36 dead ends**, showing exhaustive exploration. Any new approach must avoid all of these.

---

## Truth Lemma Analysis

### What the truth lemma proves

The **restricted parametric shifted truth lemma** (`RestrictedParametricTruthLemma.lean:104-260`) proves:

```
phi in fam.mcs t  <->  truth_at ParametricCanonicalTaskModel ShiftClosedParametricCanonicalOmega (parametric_to_history fam) t phi
```

This establishes the fundamental bridge: MCS membership = semantic truth in the canonical model.

### What the truth lemma assumes

The truth lemma requires THREE coherence properties on the BFMCS:

1. **`restricted_temporally_coherent root`** (TemporalCoherence.lean:295-300):
   - Forward: `F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s` (for phi in deferralClosure root)
   - Backward: `P(phi) in fam.mcs t -> exists s < t, phi in fam.mcs s` (for phi in deferralClosure root)

2. **`backward_until_since_coherent`** (full, not restricted in the current code at line 107, but `fully_restricted_parametric_shifted_truth_lemma` at line 299+ uses restricted versions):
   - If `exists s > t, psi in fam.mcs s AND forall r in [t,s), phi in fam.mcs r` then `(phi U psi) in fam.mcs t`
   - Mirror for Since

3. **`forward_until_since_coherent`** (full, same caveat):
   - If `(phi U psi) in fam.mcs t` then `exists s > t, psi in fam.mcs s AND forall r in [t,s), phi in fam.mcs r`
   - Mirror for Since

**Important**: The `dd_countermodel` at RootScopedChain.lean:1187-1213 actually calls `fully_restricted_parametric_representation_from_neg_membership` which uses the RESTRICTED versions of all three. The sorry sites are:
- `dd_bfmcs_restricted_tc` (restricted temporal coherence)
- `dd_bfmcs_restricted_buc` (restricted backward Until/Since)
- `dd_bfmcs_restricted_fuc` (restricted forward Until/Since)

### How the truth lemma handles F and P

The G/H backward cases (lines 198-228) are the critical consumers of `restricted_temporally_coherent`:

- **G backward**: Given `forall s > t, psi in fam.mcs s`, derive `G(psi) in fam.mcs t`. Uses `restricted_temporal_backward_G_strict` which calls `forward_F` on `neg(psi)` (i.e., resolves `F(neg psi)` to get a contradiction).
- **H backward**: Mirror using `backward_P`.

The Until/Since cases (lines 229-260) consume forward/backward Until coherence:
- **U forward**: `(phi U psi) in fam.mcs t` -> produces semantic witness `exists s > t` with guard
- **U backward**: Semantic witness `exists s > t` -> derives `(phi U psi) in fam.mcs t`

---

## Completeness Chain Map

### Full dependency trace

```
bx_completeness (Completeness.lean:123)
  |-- by_contra + push_neg: assume valid phi, not derivable phi
  |-- neg_consistent_of_not_derivable (sorry-free)
  |-- set_lindenbaum (sorry-free)
  |-- dd_countermodel (RootScopedChain.lean:1187)
        |-- dd_bfmcs (RootScopedChain.lean:~980-1037)
        |     |-- dd_chain (fwd_chain_of_sigma + bwd_chain_of_sigma)
        |     |-- shifted_dd_fmcs (shifted versions for modal saturation)
        |     |-- Box stability (box_stable_in_shifted_fmcs, sorry-free)
        |     '-- modal coherence (sorry-free via S5 properties)
        |
        |-- dd_bfmcs_restricted_tc (RootScopedChain.lean:1137) [SORRY x2]
        |     |-- fwd_chain_forward_F (RootScopedChain.lean:1130) [SORRY]
        |     |-- backward chain F-case [SORRY]
        |     '-- P-resolution backward direction [SORRY]
        |
        |-- dd_bfmcs_restricted_buc (RootScopedChain.lean:1170) [SORRY]
        |
        |-- dd_bfmcs_restricted_fuc (RootScopedChain.lean:1178) [SORRY]
        |
        '-- fully_restricted_parametric_representation_from_neg_membership (sorry-free given 3 coherences)
```

### What each sorry actually needs

**Sorry 1: `fwd_chain_forward_F` (line 1130)**
- Given: `F(phi) in chain(n)` where `phi in sigma_list`
- Need: `exists m > n, phi in chain(m)`
- This is the CORE sorry. The chain uses `fwd_chain_of_sigma` (preserving forward step). Infrastructure exists showing defects are one-step preserved and F-obligation monotone. The GAP (documented at line 1127-1129): need to show the active defect set eventually reduces to {phi}, at which point singleton resolution forces phi into the chain.

**Sorry 2: `dd_bfmcs_restricted_tc` forward, backward chain case (line 1161)**
- `F(phi)` in the BACKWARD chain at position `t - s < 0`. Need to find a future witness.
- The backward chain doesn't have F-preservation infrastructure.

**Sorry 3: `dd_bfmcs_restricted_tc` backward direction (line 1168)**
- `P(phi) in fam.mcs t -> exists s < t, phi in fam.mcs s`
- Symmetric to forward direction but for the backward chain.

**Sorry 4: `dd_bfmcs_restricted_buc` (line 1170)**
- Backward Until/Since: derive `(phi U psi) in fam.mcs t` from semantic witnesses.
- Requires "step transfer": knowing `phi in chain(r)` and `(phi U psi) in chain(r+1)` implies `(phi U psi) in chain(r)`. This is BLOCKED -- no BX axiom provides `phi AND F(phi U psi) -> phi U psi`.

**Sorry 5: `dd_bfmcs_restricted_fuc` (line 1178)**
- Forward Until/Since: derive semantic witnesses from `(phi U psi) in fam.mcs t`.
- Depends on restricted_tc (sorry 1-3) plus Until propagation along the chain.

---

## Semantics Requirements

### What irreflexive frames demand

From `Truth.lean:119-131`, the semantics is:
- `G(phi)` at t: `forall s, t < s -> phi at s` (strict, excludes current)
- `H(phi)` at t: `forall s, s < t -> phi at s` (strict, excludes current)
- `phi U psi` at t: `exists s > t, psi at s AND forall r, t <= r < s -> phi at r` (strict witness, half-open guard [t,s))
- `phi S psi` at t: `exists s < t, psi at s AND forall r, s < r <= t -> phi at r` (strict witness, half-open guard (s,t])

**Critical observation on Until guard**: The guard for `phi U psi` at time t includes t itself (`t <= r`). This means `phi` must hold at t when Until has a strictly future witness. This is exactly what BX9 (`until_elim`: `(phi U psi) -> (phi or psi)`) provides.

**Critical observation on irreflexivity**: Under irreflexive semantics:
- `G(phi) -> phi` is NOT valid (BX1 removed)
- `phi -> F(phi)` is NOT derivable
- Seriality (`T -> F(T)`, `T -> P(T)`) replaces reflexivity
- This means `bx_le` is NOT reflexive: `g_content(w)` is NOT a subset of w

### Consequence for chain construction

The chain `fwd_chain_of_sigma` at step n+1 contains `g_content(chain(n))` but NOT chain(n) itself. When phi is resolved at step n+1 (phi in chain(n+1)), we do NOT automatically get F(phi) in chain(n+1) because `phi -> F(phi)` is not derivable. This is the KEY structural advantage of irreflexive semantics.

---

## Minimal Chain Requirements

### What the BFMCS must provide (stripped to essentials)

For a BFMCS to make `dd_countermodel` go through, each family needs:

1. **FMCS basic structure** (already proved):
   - `mcs : Int -> Set Formula` (Int-indexed MCS chain)
   - `is_mcs : forall t, SetMaximalConsistent (mcs t)`
   - `forward_G : forall t t' phi, t < t' -> G(phi) in mcs t -> phi in mcs t'`
   - `backward_H : forall t t' phi, t' < t -> H(phi) in mcs t -> phi in mcs t'`

2. **Restricted temporal coherence** (sorry sites 1-3):
   - For each phi in deferralClosure(root):
     - `F(phi) in mcs t -> exists s > t, phi in mcs s`
     - `P(phi) in mcs t -> exists s < t, phi in mcs s`

3. **Forward Until/Since coherence** (sorry site 5):
   - For Until: `(phi U psi) in mcs t -> exists s > t, psi in mcs s AND forall r in [t,s), phi in mcs r`
   - For Since: mirror

4. **Backward Until/Since coherence** (sorry site 4):
   - For Until: `(exists s > t, psi in mcs s AND forall r in [t,s), phi in mcs r) -> (phi U psi) in mcs t`
   - For Since: mirror

### What the current chain provides vs. what's missing

**Provided** (sorry-free):
- FMCS basic structure (items 1 above)
- Box stability along the chain
- Modal coherence across families
- Defect step infrastructure (one-step preservation, F-obligation monotonicity)

**Missing** (sorry sites):
- F-resolution along the forward chain (item 2, forward F)
- P-resolution along the backward chain (item 2, backward P)
- Until step transfer (item 4)
- Forward Until coherence beyond what restricted_tc provides (item 3)

---

## Proposed Design Direction

### Analysis: Why the current approach is stuck

The ROADMAP documents 36 dead ends that collectively establish:

1. **Lindenbaum opacity**: `set_lindenbaum` uses `Classical.choose`, making chain(n+1) opaque. No structural guarantees can be extracted about what formulas are in chain(n+1) beyond what the seed guarantees.

2. **F-resolution vs. F-preservation tension**: Any seed that includes F-carry (to preserve F-obligations) risks inconsistency with g_content (dead end #13, #31). Any seed without F-carry loses F-obligations (dead end #24).

3. **Until step transfer impossibility**: No BX axiom provides `phi AND F(phi U psi) -> phi U psi`. The deterministic chain has bot-Until linking but cannot resolve F-eventualities.

### The irreflexive advantage (unused)

The ROADMAP (lines 497-518) identifies the key insight: under irreflexive semantics, resolved defects do NOT re-enter as F-obligations. The active defect count should strictly decrease. However, this advantage has not been fully exploited:

- `fwd_chain_defect_one_step` (line 1044-1051): proved, shows one-step preservation
- `fwd_chain_F_obligation_monotone` (line 1057-1091): proved, shows F-obligations never return
- `fwd_chain_F_set_nonincreasing` (line 1095-1100): proved

The GAP (documented at line 1127-1129): "Need to show the set eventually reaches {phi}." In the stabilized phase, resolved defects have both `chi in chain(k+1)` AND possibly `F(chi) in chain(k+1)`. But under irreflexive semantics, `chi in chain(k+1)` does NOT imply `F(chi) in chain(k+1)`. The question is whether the preserving chain construction ensures this.

### Recommended investigation: Does defect resolution prevent F-regeneration?

The `preserving_fwd_step` (or `fwd_chain_of_sigma`) resolves defects via `defect_step_choice_early`. When defect chi is resolved (chi in M'), the seed is `{chi} union g_content(M)`. The Lindenbaum extension M' contains chi and g_content(M).

**Key question**: Is it possible that `F(chi) in M'` when `chi in M'`? Under irreflexive semantics, `chi -> F(chi)` is not derivable. But Lindenbaum can freely add F(chi) if it's consistent with the seed. The seed is `{chi} union g_content(M)`. Is `{chi, F(chi)} union g_content(M)` consistent? Yes, potentially -- there's no reason it would be inconsistent in general.

So the Lindenbaum extension CAN add F(chi) even though chi is present. This means the defect count does NOT necessarily decrease. This is the core of why `fwd_chain_forward_F` is sorry'd.

### Three potential directions

**Direction A: Enriched seed that excludes F-regeneration**

Add `G(neg chi)` to the seed for non-target formulas. This forces `F(chi) not in M'` for those formulas. But this conflicts with `F(chi) in g_content(M)` if `G(F(chi)) in M`, which is possible. Need to check: is `{chi, G(neg chi)} union g_content(M)` consistent?

If `F(chi) in M` and `G(F(chi)) in M` (by temp_4 on F(chi) = neg G(neg chi)... actually temp_4 gives G(phi) -> G(G(phi)), and the contrapositive on the negation). This needs careful analysis.

**Direction B: Change the chain to deterministic (X/Y-based)**

Under irreflexive semantics on Int, `X(phi) = bot U phi` means `phi` at t+1 (the immediate successor). A deterministic chain where `chain(n+1)` is uniquely determined by `chain(n)` via X-content linking would give:
- `X(phi) in chain(n) <-> phi in chain(n+1)`
- `Y(phi) in chain(n) <-> phi in chain(n-1)`

This gives step transfer for free. But a deterministic chain requires the X-content seed `{phi | X(phi) in chain(n)}` to be consistent, which is not guaranteed for arbitrary MCS.

**Direction C: Semantic completeness (Goldblatt/GHR style)**

Abandon the syntactic chain and build the canonical model semantically. In the Goldblatt (1992) / GHR (1994) approach:
- The canonical model has worlds = MCS, accessibility = g_content inclusion
- The truth lemma is proved by well-founded induction on formula complexity
- F/P witness existence is guaranteed by the canonical model construction itself (not by a chain)

This avoids the Lindenbaum opacity problem entirely because witnesses are drawn from the FULL collection of all MCS, not from a single pre-constructed chain. The BFMCS families would be indexed by MCS (not by Int), with each family being a shifted chain through a different root MCS.

The challenge is re-engineering the parametric representation to work with MCS-indexed families rather than Int-indexed chains.

---

## Confidence Level: MEDIUM

**High confidence** in the diagnosis:
- The truth lemma architecture is correct and nearly complete
- The three coherence properties are the exact sorry sites
- The irreflexive advantage (no F-regeneration via axioms) is real
- The Lindenbaum opacity is the fundamental obstruction

**Medium confidence** in the proposed directions:
- Direction A (enriched seed) needs careful consistency analysis -- may hit dead end #13 again
- Direction B (deterministic chain) is promising but requires showing X-content seed consistency
- Direction C (semantic completeness) is the most theoretically sound but requires significant re-engineering

**Low confidence** that any quick fix will work:
- 36 documented dead ends show the problem is genuinely hard
- The core tension between Lindenbaum opacity and chain coherence requirements has resisted all previous approaches
- The irreflexive semantics advantage may be necessary but not sufficient

### Alignment with ROADMAP

The ROADMAP (lines 984-998) recommends three approaches, which align with my Directions B, C, and "axiom strengthening" (which I exclude as it changes the logic):

1. **Deterministic chain approach** (my Direction B) -- ROADMAP's first recommendation
2. **Semantic completeness proof** (my Direction C) -- ROADMAP's second recommendation
3. **Axiom strengthening** -- adds a "next" operator, changes the logic (NOT recommended)

The ROADMAP explicitly states: "Standard completeness proofs (Burgess 1984, Goldblatt 1992, GHR 1994) handle forward_F semantically, not syntactically." This suggests Direction C is the most principled path.
