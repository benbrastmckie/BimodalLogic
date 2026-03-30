# Research Findings: Teammate A — Segerberg Bulldozing Technique

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Role**: Teammate A — Bulldozing technique research
**Session**: sess_1774882100_ta37a

---

## Key Findings

### 1. What Is Segerberg's Bulldozing Technique?

Segerberg's bulldozing technique (1971, "An Essay in Classical Modal Logic") is a model
transformation procedure for proving completeness of temporal and tense logics. Its core
mechanism:

**Step 1 — Canonical model construction**: Build the standard Henkin/Lindenbaum canonical
model as an ordering of maximal consistent sets (worlds).

**Step 2 — Cluster decomposition**: The canonical model contains "clusters" — equivalence
classes of worlds connected by the reflexive-transitive accessibility relation. Clusters arise
because reflexive worlds allow formulas like G(phi) to be perpetually deferred.

**Step 3 — Bulldozing clusters into strict chains**: Each cluster (which may be reflexive,
symmetric, or transitive) is "bulldozed" by inserting a strict partial order into it. The
worlds in each cluster are arranged into a single strictly-ordered linear sequence (an
infinite omega-sequence). This kills reflexivity within the cluster and creates a true linear
temporal structure.

**Step 4 — Concatenation into linear time**: The bulldozed clusters are concatenated
together. The result is an infinite strictly linear order on worlds — a model over `Z` or `N`.

**Step 5 — F-obligation resolution via omega-repetition**: Within each bulldozed cluster,
every world from the original cluster appears infinitely often (because the cluster's worlds
are cycled round-robin through the infinite omega-sequence). For any F(phi) that holds at
some world w in the cluster, the canonical model theory of w includes phi in some world
w' in the same cluster. Since w' appears infinitely often in the bulldozed sequence, F(phi)
is eventually resolved at a later position in the omega-sequence.

**The key property**: Bulldozing a reflexive cluster (where every world satisfies G(phi)
implies phi via the T-axiom) into an infinite repetition guarantees that any F-obligation
F(psi) in the cluster is resolved at some later world in the sequence — not immediately,
but within finitely many steps bounded by the cluster's size.

### 2. Why Bulldozing Works: The F-Obligation Resolution Argument

The critical insight is that within a single cluster C:
- Every world w in C has a Succ-successor in C (by reflexivity or the accessibility relation)
- If F(psi) ∈ w, then by the canonical model truth lemma: there exists w' in C with psi ∈ w'
- By bulldozing (infinite repetition), w' appears at position j > i in the omega-sequence
- Therefore: the bulldozed sequence resolves F(psi) at position j

This argument does NOT require:
- Knowing which world w' to use in advance
- A priority or scheduling scheme for which F-obligation to resolve first
- A global fairness constraint

Instead, it relies on **exhaustive repetition**: because every world in C occurs
infinitely often, every obligation present anywhere in C is satisfied infinitely often.

### 3. How Plan 8 Attempted Bulldozing (Dovetailed OmegaFMCS)

Plan 8 (specs/067.../plans/08_dovetailed-omega-fmcs.md) implemented a dovetailed
construction in `UltrafilterChain.lean`:
- At step n, decode (t, k) = Nat.unpair(n)
- Let psi = enumFormula(k) (the k-th formula by Denumerable order)
- If F(psi) ∈ chain(n), resolve psi; otherwise use F_top

**Why it got blocked (Phase 3, obligation_eventually_resolved)**:

The dovetailed chain does NOT implement Segerberg's cluster repetition. It implements
*selection*: at each step, it picks one formula to resolve. The problem is:

1. F(psi) ∈ chain(n) does NOT persist to chain(m) for m > n in the current construction
2. The witness construction adds `{psi} ∪ G_theory(u) ∪ box_theory(u)` as seed
3. For F(chi) ∈ chain(n) with chi ≠ psi, the Lindenbaum extension may add G(neg chi)
4. G(neg chi) ∈ chain(n+1) forces F(chi) ∉ chain(n+1): the obligation is LOST

This is the F-persistence failure. Unlike Segerberg's approach where F-obligations survive
within the cluster through exhaustive repetition, the current construction actively destroys
F-obligations during each Lindenbaum extension step.

### 4. Why Plan 8's Blocker and the Current k >= B Blocker Are the Same Root Cause

Both blockers trace to the same missing construction property:

**Plan 8 blocker**: "F(phi) ∈ chain(t) does not imply ∃ s > t, phi ∈ chain(s)"
**Current blocker** (lines 3006, 3037): "k >= B should be impossible but cannot be proven"

These are equivalent. The bounded witness lemma (restricted_bounded_witness_wf) attempts
to prove that an F-obligation at depth d resolves within k + d additional steps. The k >= B
regime represents the case where an obligation has been DEFERRED more times than its
F-depth allows — which should be impossible if F-obligations must eventually resolve, but
IS possible in the current construction because obligations can be lost (not just deferred).

---

## Application to Our Setting

### What Segerberg's Technique Requires

For bulldozing to work in our bimodal TM setting (combining S5 modal + linear temporal),
the construction needs these properties:

**Property A (Cluster Formation)**: There must be a notion of "equivalence class" of worlds
where F-obligations persist. In bimodal TM:
- The modal (box/diamond) dimension has S5 clusters (equivalence classes under accessibility)
- The temporal (F/P) dimension is linear, so "clusters" are individual worlds

**Property B (Omega-Repetition Within Clusters)**: For temporal F-obligations, persistence
through repetition requires a mechanism to re-encounter worlds. In a strictly linear model
over N or Z, worlds never repeat. Bulldozing applies to the MODAL S5 clusters, not the
temporal dimension.

**Critical Observation**: Segerberg's original bulldozing applies to REFLEXIVE clusters in
transitive frames (like K4, S4, GL). For strictly linear tense logic (our setting), there are
NO reflexive clusters — each world is a distinct maximal consistent set. Bulldozing in the
tense-logic sense transforms the accessibility BETWEEN worlds, not within a cluster.

For tense logic completeness over Z (our frame), the correct analog of bulldozing is:

**The Fair Scheduling Construction**: Rather than building a chain by choosing one
successor deterministically, build a "universal" chain that enumerates ALL possible
successor worlds in a dovetailed sequence. The key is that the successor worlds are
CHOSEN to include specific F-obligations, not just chosen freely by Lindenbaum.

### What the Construction Must Guarantee

For bimodal TM over Z (integers), the restricted forward chain must satisfy:

1. **F-persistence**: If F(psi) ∈ chain(k), then either psi ∈ chain(k+1) OR F(psi) ∈ chain(k+1)
   (F-obligations cannot be destroyed, only resolved or deferred)

2. **Bounded deferral**: F-obligations at depth d cannot be deferred more than B steps in total
   (where B = closure_F_bound phi)

3. **F-resolution**: For any F(psi) that has been deferred for B steps, psi must appear in
   chain(k + B)

The current construction satisfies NEITHER (1) nor (2). The `boundary_resolution_set` enforces
resolution only at the maximum depth (when FF(psi) ∉ deferralClosure), but sub-maximal
F-obligations can be lost during Lindenbaum extension.

### Adapting Bulldozing: The Seeded Lindenbaum Approach

The correct adaptation of Segerberg's technique is NOT the dovetailed selection approach
(Plan 8), but rather a **SEEDED Lindenbaum construction** that forces F-persistence:

**Modified constrained_successor_restricted** with the following seed change:

Current seed:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking(phi, u) ∪ boundary_resolution_set(phi, u)
```

Proposed seed:
```
g_content(u) ∪ FORCED_F_content(phi, u) ∪ p_step_blocking(phi, u) ∪ boundary_resolution_set(phi, u)
```

Where `FORCED_F_content(phi, u)` is defined as:

For each F(psi) ∈ u: include EITHER psi (resolve) OR F(psi) (defer) in the seed,
but NOT allow the Lindenbaum extension to add G(neg psi) (which would destroy F(psi)).

This is implemented by adding F(psi) to the seed for ALL F(psi) ∈ u, regardless of depth.
Since F(psi) is in the seed, and the Lindenbaum extension EXTENDS the seed, F(psi) ∈
successor. Then the deferral disjunction (psi ∨ F(psi)) is also in the seed, so the successor
contains either psi or F(psi) — F-persistence holds by construction.

**Formal definition**:

```lean
def f_persistence_formulas (u : Set Formula) : Set Formula :=
  {chi | ∃ psi, chi = Formula.some_future psi ∧ Formula.some_future psi ∈ u}
-- i.e., F_content(u) itself: the set of all F-formulas that are in u
```

Then include `f_persistence_formulas u ⊆ seed`.

Since `f_content(u) ⊆ deferralClosure(phi)` (as F-formulas in u are in deferralClosure),
the seed still stays within deferralClosure, preserving the DeferralRestrictedMCS invariant.

### How F-Persistence Enables Proving k < B

With F-persistence added to the seed, the construction guarantees:

```
F(psi) ∈ chain(k) → F(psi) ∈ chain(k+1) ∨ psi ∈ chain(k+1)
```

This means F-obligations can only be:
1. **Resolved**: psi appears in the next world (depth decreases by 1)
2. **Deferred**: F(psi) appears in the next world (depth stays the same but nesting continues)

But with `boundary_resolution_set` forcing resolution at max depth, and F-persistence
preventing creation of NEW F-obligations beyond the deferralClosure, we get:

- At each chain step, the number of DISTINCT F-nesting depths decreases OR stays constant
- After at most B steps, every formula at depth d must be resolved (it can only defer at most
  B times before hitting the boundary condition)
- Therefore k < B: the chain position for any F-obligation resolves before chain(B)

This is the MISSING LINK that closes lines 3006 and 3037: with F-persistence, the k >= B
case becomes provably impossible because F-obligations at depth < B-1 still track depth bounds.

---

## Comparison With Current Approach

| Property | Current Construction | Bulldozing-Adapted Construction |
|----------|---------------------|--------------------------------|
| Seed content | G-content + deferral disjunctions + BRS | G-content + F-persistence + BRS |
| F-persistence | NOT guaranteed (Lindenbaum can add G(neg psi)) | GUARANTEED by seed inclusion |
| Depth tracking | d < B proved, k < B not proved | Both d < B and k < B provable |
| Stabilization lemma | Unprovable (construction-level gap) | Provable by construction |
| k >= B case | Cannot be refuted | Provable to be impossible |
| Plan 8 blocker | F-persistence fails (obligation lost) | F-persistence holds (obligation propagated) |
| Current sorry (line 3006) | `sorry` — cannot derive False | `exfalso` by F-persistence + depth bound |
| Current sorry (line 3037) | `sorry` — same gap | `exfalso` by same argument |

---

## Risks and Blockers

### Risk 1: Consistency of Extended Seed (MEDIUM)

Adding `f_persistence_formulas u` to the seed requires proving the extended seed is
consistent. The current `constrained_successor_seed_restricted_consistent` proof works
because the seed is a subset of `u` (a consistent set). Adding F-content of u to the seed
means the seed is still a subset of u (since f_content(u) ⊆ u), so the consistency proof
should transfer.

**Assessment**: This is provable. f_content(u) ⊆ u and u is consistent, so the extended
seed remains a subset of u and hence consistent.

### Risk 2: DeferralClosure Containment (LOW)

The extended seed must stay within deferralClosure(phi). F-content of u (where u ⊆
deferralClosure) is automatically within deferralClosure. The f_persistence_formulas are
of the form F(psi) where F(psi) ∈ u ⊆ deferralClosure, so F(psi) ∈ deferralClosure. ✓

### Risk 3: Breaking Existing Proofs (MEDIUM)

Modifying `constrained_successor_seed_restricted` or the construction could break
theorems that depend on the current seed definition. Specifically:
- `constrained_successor_restricted_extends` — seed subset still holds ✓
- `constrained_successor_restricted_is_mcs` — depends on seed consistency (Risk 1) ✓
- `constrained_successor_restricted_succ` — depends on f_step and g_persistence ✓
- `constrained_successor_restricted_p_step` — depends on blocking formulas, unaffected ✓

**Assessment**: Adding to the seed should not break existing proofs since:
- Consistency is maintained (seed is still a subset of u)
- All existing seed elements are still present
- The Lindenbaum extension still produces a DeferralRestrictedMCS

### Risk 4: Lindenbaum Extension Still Has Freedom (HIGH)

Even with F(psi) in the seed, the Lindenbaum extension may STILL add G(neg chi) for some
chi ≠ psi. This means F(chi) ∈ chain(k) is NOT in the seed unless F(chi) ∈ u was added.

**Clarification**: If we add ALL f_content(u) to the seed (not just the selected psi), then:
- For each F(chi) ∈ u: F(chi) ∈ seed ⊆ successor
- F(chi) ∈ successor means G(neg chi) ∉ successor (by MCS consistency)
- So Lindenbaum cannot add G(neg chi), preserving F(chi) in the successor

This means F-persistence is guaranteed for ALL F-formulas in u, not just the selected one.

### Risk 5: P-step Constraints Still Hold (LOW)

The existing p_step proof uses `p_step_blocking_formulas_restricted` which adds H(neg chi)
to the seed when certain P-conditions fail. This is orthogonal to f_persistence_formulas.

### Blocker: F-Persistence Proof at Boundary

Even with F-persistence, the boundary case (BRS) forces `chi ∈ successor` when
FF(chi) ∉ deferralClosure. In this case, F(chi) may NOT be in successor (chi is, F(chi) is
not). This means F-persistence holds for non-boundary formulas only.

**Resolution**: This is correct behavior — at the boundary, the obligation is RESOLVED
(chi ∈ successor), not deferred. The BRS handles this case. F-persistence is not required
for boundary formulas because they are resolved, not deferred.

---

## Confidence Level

**Confidence: HIGH** (for the construction design; medium for full Lean formalization effort)

- The conceptual connection between Segerberg's bulldozing and F-persistence is clear
- The construction modification (adding f_content to seed) is minimal and targeted
- The proof that k < B follows directly from F-persistence + depth bound is compelling
- The key risks are manageable (consistency, no breaking changes)
- The main uncertainty is the actual Lean proof complexity for the modified BRS consistency

---

## Recommended Next Steps

### Step 1: Modify the seed definition

Add `f_persistence_formulas u` to `constrained_successor_seed_restricted`:

```lean
-- New definition:
def constrained_successor_seed_bulldozed (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪
  p_step_blocking_formulas_restricted phi u ∪
  boundary_resolution_set phi u ∪
  f_content u  -- ADD: persist all F-obligations
```

### Step 2: Prove F-persistence theorem

```lean
theorem constrained_successor_restricted_f_persistence (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_F_top : F_top ∈ u) (psi : Formula) (h_F_psi : F psi ∈ u) :
    F psi ∈ constrained_successor_restricted_bulldozed phi u h_mcs h_F_top := ...
-- Proof: F(psi) ∈ u → F(psi) ∈ f_content(u) → F(psi) ∈ seed → F(psi) ∈ successor
```

### Step 3: Prove k < B is impossible given F-persistence + depth bound

```lean
theorem k_lt_B_from_f_persistence (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
    (k : Nat) (theta : Formula) (d : Nat) (h_d_lt : d < closure_F_bound phi)
    (h_iter_in : iter_F d theta ∈ chain(k)) :
    k < closure_F_bound phi := ...
```

### Step 4: Close lines 3006 and 3037

Replace `sorry` with `exact k_lt_B_from_f_persistence ...`

### Step 5: Verify consistency proof for extended seed

The critical lemma:

```lean
theorem constrained_successor_seed_bulldozed_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) (h_F_top : F_top ∈ u) :
    SetConsistent (constrained_successor_seed_bulldozed phi u) := ...
-- Key: seed ⊆ u (since g_content ⊆ u, deferral disjunctions ⊆ deferralClosure,
-- f_content(u) ⊆ u, and BRS ⊆ deferralClosure), and u is consistent.
```

---

## Summary

Segerberg's bulldozing technique works by making each cluster (reflexive component) of a
canonical model into an omega-sequence where every world recurs infinitely — ensuring
F-obligations are eventually satisfied through exhaustive repetition. For our setting (linear
tense logic over Z with deferralClosure restriction), the correct adaptation is NOT the
dovetailed formula selection (Plan 8) but a **seeded Lindenbaum construction** that includes
all F-content of the current world in the successor seed.

This forces F-persistence: F(psi) ∈ chain(k) → F(psi) ∈ chain(k+1), making it impossible
for F-obligations to be "lost" during Lindenbaum extension. Combined with the existing
`boundary_resolution_set` (which forces resolution at maximum depth), this gives both:
1. F-persistence at sub-maximal depths (F-obligations propagate forward)
2. F-resolution at maximal depth (boundary_resolution_set forces psi into the successor)

Together, these properties imply that any F-obligation at depth d must be resolved within
at most B chain steps, making k >= B provably impossible and closing lines 3006 and 3037.

Plan 8's blocker (F-persistence failure during dovetailed selection) is resolved because
the SEED includes all F-formulas, not just the selected one. The Lindenbaum extension
cannot destroy F-obligations that are already in the seed.

---

## References

- Segerberg, K. (1971). An Essay in Classical Modal Logic. Uppsala.
- Plan 8: specs/067.../plans/08_dovetailed-omega-fmcs.md (Phase 3 blocker)
- Research report 34: specs/067.../reports/34_team-research.md (current blocker analysis)
- Summary 12: specs/067.../summaries/12_chain-resolution-summary.md (fuel invariant gap)
- SuccChainFMCS.lean lines 3006, 3037 (sorry sites)
- SuccExistence.lean:296 (boundary_resolution_set definition)
