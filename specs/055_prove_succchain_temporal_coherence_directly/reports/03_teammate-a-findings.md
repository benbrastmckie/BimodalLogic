# Task 55: Within-Chain Temporal Coherence Resolution
## Teammate A Findings Report

**Focus**: Within-chain resolution strategies for SuccChain temporal coherence (Phase 3 blocker)

---

## Key Findings

1. **The deferral mechanism is a structural disjunction**: `constrained_successor_seed u = g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)` where `deferralDisjunctions(u) = {phi ∨ F(phi) | F(phi) ∈ u}`. Every F-obligation at step n is either resolved (phi ∈ successor) or re-deferred (F(phi) ∈ successor). The Lindenbaum extension can perpetually choose F(phi), so there is NO forced resolution. **Confidence: Very High.**

2. **`temporal_theory_witness_exists` gives wrong kind of witness**: The phases 1-2 infrastructure proves there EXISTS an MCS W with phi ∈ W and G-theory agreement. But W is constructed from `set_lindenbaum({phi} ∪ temporal_box_seed(M))` — it need not appear in M0's forward chain at any index. The gap is precisely the step from "phi is consistent with G-obligations" to "phi appears in THIS chain." **Confidence: Very High.**

3. **`bounded_witness` is the right structure, but requires F-boundedness**: `bounded_witness` at `CanonicalTaskRelation.lean:650` works as follows: given `iter_F n phi ∈ u` and `iter_F (n+1) phi ∉ u`, walking `n` Succ-steps forces `phi` into the terminal world. This is exactly what `succ_chain_forward_F` needs. The problem: we need `iter_F (n+1) phi ∉ u` for SOME `n`, which requires F-boundedness in the SuccChain. **Confidence: Very High.**

4. **`f_nesting_is_bounded` is mathematically false for arbitrary MCS**: Explicitly marked `@[deprecated f_nesting_is_bounded_restricted]` at `SuccChainFMCS.lean:730` with `sorry`. The counterexample: `{F^n(p) | n ∈ Nat}` is consistent and extends to an MCS via Lindenbaum. This is NOT fixable for the plain SuccChain. **Confidence: Very High.**

5. **`f_nesting_is_bounded_restricted` is proven (no sorry) for `RestrictedMCS`**: At `SuccChainFMCS.lean:693`. `RestrictedMCS phi M` asserts `M ⊆ closureWithNeg psi` for some target formula `psi`. Since the closure is finite, F-iterations eventually leave it. This is the correct theorem — the issue is that the plain SuccChain does not carry RestrictedMCS evidence. **Confidence: Very High.**

6. **The `TemporalContent.lean` comment explicitly acknowledges the problem**: Lines 40-44 state: "Resolution of F-obligations requires a non-linear construction (e.g., omega-squared) rather than relying on linear g_content propagation. See DovetailingChain.lean for details." `DovetailingChain.lean` does not exist — this is the file the "resolving chain" construction should produce. **Confidence: High.**

7. **The `boxClassFamilies_temporally_coherent` proof delegates entirely to `SuccChainTemporalCoherent`**: At `UltrafilterChain.lean:1674`, it uses `tcf.forward_F` where `tcf = SuccChainTemporalCoherent(W)`. If we replace `SuccChainTemporalCoherent` with a resolving chain construction, the rest of the architecture does not need to change. **Confidence: Very High.**

---

## Analysis of the Deferral Mechanism

### Exact Mechanism (`SuccExistence.lean:68-78`, `SuccExistence.lean:356-367`)

The `constrained_successor_seed` is:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)
```
where `deferralDisjunctions(u) = { phi ∨ F(phi) | F(phi) ∈ u }`.

When Lindenbaum extends this seed to an MCS `v`, the MCS must choose for each `phi ∨ F(phi)`:
- Either `phi ∈ v` (F-obligation resolved), or
- `F(phi) ∈ v` (F-obligation re-deferred to the next step)

Lindenbaum's lemma offers no fairness guarantee. An adversarial (or simply unlucky) choice at every step yields a chain where F(phi) propagates infinitely without phi ever appearing.

### Why `temporal_theory_witness_exists` Does Not Directly Help

`temporal_theory_witness_exists` (UltrafilterChain.lean:1158) gives: if `F(phi) ∈ M`, then there exists MCS W with:
- `phi ∈ W`
- `G(a) ∈ M → G(a) ∈ W` (G-theory agreement)
- `box_class_agree M W`

The witness W is constructed by `set_lindenbaum({phi} ∪ temporal_box_seed(M))`. This W could be any MCS in the same box class — there is no requirement that W = `forward_chain M0 k` for any `k`.

The gap: the SuccChain construction at each index `n` builds `forward_chain M0 n` deterministically (given prior choices). W may not coincide with any of these.

---

## Proposed Resolution Strategies

### Strategy 1: Resolving Chain Construction (Recommended, HIGH feasibility)

**Core idea**: Replace the SuccChain's `ForwardChainElement.next` with a construction that schedules F-obligation resolution fairly. At step `n`, pick an F-obligation from a queue and force it using `temporal_theory_witness_consistent`.

**Formal structure**:

Define a "resolving successor" that, given current MCS `M` and a target formula `phi` (the formula to resolve):
1. Use `temporal_theory_witness_consistent M h_mcs phi h_F` to show `{phi} ∪ G_theory(M) ∪ box_theory(M)` is consistent.
2. Apply `set_lindenbaum` to extend this to an MCS `W` with `phi ∈ W`.
3. `W` is the resolving successor.

This directly gives `Succ M W`:
- **G-persistence**: `G_theory M ⊆ W` by construction (the seed includes `G_theory M`).
- **F-step**: `f_content(M) ⊆ W ∪ f_content(W)`. This needs proof: we have `G(a) ∈ M → G(a) ∈ W`, but we need to show each `F(psi) ∈ M` satisfies `psi ∈ W ∨ F(psi) ∈ W`. Since W is an MCS and W contains `phi`, it need not contain all other F-obligations. **This requires the seed to include `deferralDisjunctions(M)` as well**, making the seed:
  ```
  {phi} ∪ G_theory(M) ∪ box_theory(M) ∪ deferralDisjunctions(M)
  ```
  This is still consistent by the same argument as `temporal_theory_witness_consistent` (extend the context by deferral disjunctions, which are derivable from F-formulas in M).

**Fair scheduler**: Enumerate F-obligations in M using a queue. The chain at step `n` resolves the `n mod |pending|`-th pending obligation. When all are resolved, continue with the standard constrained successor.

**Proof obligations for the resolving chain**:
- `resolving_succ`: Succ M W (G-persistence + F-step) ✓ (from seed structure)
- `resolving_F_resolved`: `phi ∈ W` (the targeted obligation is resolved) ✓ (from seed)
- `G_persistence_preserved`: `G(a) ∈ M → G(a) ∈ W` ✓ (from seed)
- `box_class_preserved`: `box_class_agree M W` ✓ (from temporal_theory_witness_exists)
- `p_step`: `p_content(W) ⊆ M ∪ p_content(M)` — requires p_step_blocking in the seed too

**Modified seed for resolving successor targeting phi**:
```lean
resolving_successor_seed (u : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ G_theory u ∪ box_theory u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

**Consistency of this seed**: Follows from `temporal_theory_witness_consistent` extended with:
- `deferralDisjunctions(u)` is consistent with `{phi} ∪ G_theory(u) ∪ box_theory(u)`: each `psi ∨ F(psi)` is derivable from `F(psi) ∈ u`, and the full set remains consistent because `{phi} ∪ G_theory(u) ∪ box_theory(u)` is already consistent and the disjunctions are satisfiable witnesses.
- `p_step_blocking_formulas(u)` is consistent with the above: the blocking formulas are `H(neg chi)` for `P(chi) ∉ u` and `chi ∉ u`, which don't conflict with phi or G-theory.

**Estimated complexity**: ~300-400 lines:
- `resolving_successor_seed` definition and consistency lemma (~80 lines)
- `resolving_ForwardChainElement` structure and construction (~60 lines)
- Fair scheduler formalization (Nat-indexed queue or priority-based) (~100 lines)
- `resolving_forward_chain` with Succ proof (~80 lines)
- `resolving_chain_forward_F`: the key theorem that each F-obligation is resolved in finite time (~100 lines)

### Strategy 2: Omega-Squared / Dovetailing Construction (HIGH feasibility, more infrastructure)

**Core idea**: This is the approach hinted at in `TemporalContent.lean:43` and the planned `DovetailingChain.lean`. Build a chain of length ω² that handles all F-obligations via a dovetailing scheme.

**Structure**: For F-obligations `{phi_1, phi_2, ...}` at base world M0:
- Steps 0..k1: resolve phi_1 (using F-nesting on the resolving successor)
- Steps k1..k2: resolve phi_2
- Etc.

At each resolution step, new F-obligations may arise. The key invariant: any F-obligation introduced at step n will be resolved by step n + |deferralClosure(phi_n)|.

**Key difference from Strategy 1**: Strategy 1 uses a per-step fair scheduler that forces resolution at a specific step. Strategy 2 separates "segment construction" (resolve obligation i) from "gluing segments" (maintaining Succ between segment endpoints).

**Advantage**: Cleaner separation of concerns, more compositional.
**Disadvantage**: More infrastructure; requires reasoning about the composition of Succ chains.

**Estimated complexity**: ~500-600 lines (larger due to segment gluing proofs).

### Strategy 3: Modify the SuccChain Seed to Force Resolution (MEDIUM feasibility, invasive)

**Core idea**: At each step n, the `constrained_successor_seed` should FORCE resolution of the "lexicographically smallest" pending F-obligation by including that formula directly in the seed rather than as a disjunction.

```lean
-- Modified seed that includes target phi directly:
constrained_resolving_seed (u : Set Formula) (target : Formula) : Set Formula :=
  {target} ∪ g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

**Problem**: This is essentially Strategy 1's resolving successor seed. The difficulty is maintaining G-theory in the seed (the current seed uses `g_content` which strips G-wrapping). We need both `g_content(u)` (for Succ's G-persistence) and `G_theory(u)` (for the consistency proof). Actually, `g_content(u) ⊆ G_theory(u)` — the G_theory gives the G-wrapped versions.

**Verdict**: This collapses into Strategy 1. The key insight is that the seed must include `{target}` alongside `G_theory(M)` (not just `g_content(M)`) to use `temporal_theory_witness_consistent` for the consistency argument.

### Strategy 4: Restrict to DeferralRestrictedMCS and Use `f_nesting_is_bounded_restricted`

**Core idea**: The existing `f_nesting_is_bounded_restricted` works for `RestrictedMCS phi M`. If we can wrap the base world M0 in `DeferralRestrictedSerialMCS` and use the restricted chain, the `bounded_witness` argument goes through without modification.

**Problem identified in summaries**: The boundary case sorries remain at lines ~3077 and ~3236 (SuccChainFMCS.lean). These are for the case where `F(psi) ∈ deferralClosure` but `FF(psi) ∉ deferralClosure`. The `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` lemmas both carry sorries for this boundary case.

**Root cause of boundary sorries**: At the maximum F-depth in `deferralClosure`, the negation completeness argument fails: we cannot derive `GG(neg psi)` because `GG(neg psi) = neg FF(psi)`, and `FF(psi) ∉ deferralClosure` means we cannot place `neg FF(psi)` in the restricted chain via negation completeness.

**Verdict**: NOT recommended. The boundary sorries are mathematically hard (the summary says "structurally unresolvable via restriction"). Strategy 1 bypasses this entirely by using a non-restricted construction.

---

## Code Sketches

### Resolving Successor Seed Consistency (Core Lemma)

```lean
-- The key lemma: the resolving seed is consistent when F(phi) ∈ M
theorem resolving_successor_seed_consistent
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent ({phi} ∪ G_theory M ∪ box_theory M ∪
                   deferralDisjunctions M ∪ p_step_blocking_formulas M) := by
  -- 1. Show {phi} ∪ G_theory M ∪ box_theory M is consistent
  --    (= temporal_theory_witness_consistent)
  have h_core := temporal_theory_witness_consistent M h_mcs phi h_F
  -- 2. The deferralDisjunctions are each derivable from F-formulas in M, hence consistent
  --    with anything consistent with M's G-theory.
  --    Each "psi ∨ F(psi)" is a theorem given F(psi) ∈ M via M's closure.
  -- 3. The p_step_blocking formulas are consistent by the same argument as
  --    constrained_successor_seed_consistent.
  -- Full proof: adapt constrained_successor_seed_consistent, adding phi to seed.
  sorry -- proof sketch only; exact adaptation needed
```

### Resolving Forward Chain Element

```lean
structure ResolvingForwardChainElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  has_F_top : F_top ∈ world
  -- Queue of pending F-obligations (decreasing each time one is resolved)
  pending : List Formula
  -- Invariant: every phi in pending has F(phi) in world
  pending_valid : ∀ phi ∈ pending, Formula.some_future phi ∈ world

noncomputable def ResolvingForwardChainElement.next
    (e : ResolvingForwardChainElement) : ResolvingForwardChainElement :=
  match e.pending with
  | [] =>
    -- No pending obligations: use standard constrained successor
    { world := constrained_successor_from_seed e.world e.is_mcs e.has_F_top
      is_mcs := constrained_successor_from_seed_mcs e.world e.is_mcs e.has_F_top
      has_F_top := F_top_propagates _ _ e.is_mcs _ _ e.has_F_top
      pending := []
      pending_valid := fun _ h => h.elim }
  | phi :: rest =>
    -- Resolve phi using temporal theory witness
    let W := (temporal_theory_witness_exists e.world e.is_mcs phi
               (e.pending_valid phi (List.mem_cons_self phi rest))).choose
    { world := W
      is_mcs := (temporal_theory_witness_exists ...).choose_spec.1
      has_F_top := SetMaximalConsistent.contains_F_top _
      -- Remove phi from pending, add newly arising F-obligations
      pending := rest -- simplified; full version tracks new obligations
      pending_valid := sorry -- requires showing F-obligations of W include rest
    }
```

### Forward F Coherence for Resolving Chain

```lean
-- Key theorem: for any F(phi) ∈ resolving_chain M0 n, phi appears eventually
theorem resolving_chain_forward_F (M0 : ResolvingSerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ resolving_chain M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ resolving_chain M0 m := by
  -- phi is in the pending queue at position n (or needs to be added)
  -- By the fair scheduler, phi will be reached in at most |pending| more steps
  -- At that step m, phi is forced into the world by the resolving_successor
  sorry -- proof sketch only
```

---

## References

| Location | Relevance |
|----------|-----------|
| `SuccExistence.lean:68-78` | `deferralDisjunction` and `deferralDisjunctions` definitions |
| `SuccExistence.lean:356-367` | `constrained_successor_seed` definition |
| `SuccExistence.lean:469-478` | `constrained_successor_from_seed` using Lindenbaum |
| `SuccChainFMCS.lean:163-171` | `ForwardChainElement.next` using constrained successor |
| `SuccChainFMCS.lean:693-703` | `f_nesting_is_bounded_restricted` (works for RestrictedMCS) |
| `SuccChainFMCS.lean:718-735` | `f_nesting_is_bounded` (marked false, sorry) |
| `SuccChainFMCS.lean:811-847` | `succ_chain_forward_F` (uses false f_nesting_is_bounded) |
| `SuccChainFMCS.lean:1156-1159` | `SuccChainTemporalCoherent` (uses forward_F) |
| `UltrafilterChain.lean:962-963` | `G_theory` definition |
| `UltrafilterChain.lean:1047-1048` | `temporal_box_seed` definition |
| `UltrafilterChain.lean:1111-1152` | `temporal_theory_witness_consistent` (phases 1-2, no sorry) |
| `UltrafilterChain.lean:1158-1195` | `temporal_theory_witness_exists` (phases 1-2, no sorry) |
| `UltrafilterChain.lean:1668-1679` | `boxClassFamilies_temporally_coherent` (delegates to SuccChainTemporalCoherent) |
| `CanonicalTaskRelation.lean:650-655` | `bounded_witness` (works when F-boundedness available) |
| `TemporalContent.lean:40-44` | Explicit acknowledgement that F-resolution needs non-linear construction |

---

## Recommendation

**Pursue Strategy 1 (Resolving Chain Construction)**. The core architecture is:

1. Define `resolving_successor_seed(M, phi) = {phi} ∪ G_theory(M) ∪ box_theory(M) ∪ deferralDisjunctions(M) ∪ p_step_blocking_formulas(M)`.
2. Prove consistency via `temporal_theory_witness_consistent` + extension lemmas for deferral disjunctions.
3. Define `ResolvingForwardChainElement` with an F-obligation queue.
4. Build `resolving_forward_chain` that processes one queue item per step.
5. Prove `resolving_chain_forward_F`: each F-obligation is processed in finite time.

The key technical challenge is the fair scheduling proof. The simplest approach: for each MCS M at step n, the pending F-obligations are `f_content(M)` (which is finite for the non-degenerate case... actually, `f_content` of an arbitrary MCS may be infinite).

**Critical subtlety**: f_content(M) can be infinite. The fair scheduler needs to work with finite sets. Options:
- Restrict to formulas in `deferralClosure(phi_0)` for some target phi_0 (makes f_content finite, links back to RestrictedMCS approach — but avoids the boundary case)
- Use a different enumeration: the scheduler processes obligations in order of "age" (when they first appeared) using a well-ordering argument

**Simplest path to a working proof**: Use the resolving chain only for the "target formula" case — given base world M0 with `F(phi) ∈ M0`, construct a chain that resolves phi at step 1, then continues with the standard constrained successor. This gives:

```lean
theorem succ_chain_forward_F_direct (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m
```

by constructing a ONE-STEP resolving witness: let W = the MCS from `temporal_theory_witness_exists`, build `SuccChainFMCS(MCS_to_SerialMCS W h_W)`, shift by n+1, and observe that this shifted chain satisfies the existential at time n+1.

**BUT**: this "one-step witness" is in a DIFFERENT SuccChain than M0's. The result ∃ m, n < m ∧ phi ∈ DIFFERENT_chain.mcs m does not satisfy the requirement that phi ∈ succ_chain_fam M0 m.

This confirms the fundamental difficulty: the witness must be IN THE SAME chain as M0. The resolving chain construction IS the right approach — it builds a chain where the resolution is baked in from the start, so succ_chain_fam IS the resolving chain.

**Recommended implementation path**:
1. Build a new `ResolvingChainFMCS` that replaces `SuccChainFMCS` entirely
2. The new construction uses temporal witnesses to guarantee F-resolution
3. Replace all uses of `SuccChainFMCS` in `boxClassFamilies` with `ResolvingChainFMCS`
4. Estimated: 400-500 lines total

The `TemporalContent.lean` comment ("See DovetailingChain.lean") suggests this is the intended long-term design. Task 55 Phase 3 essentially needs to create `DovetailingChain.lean` (or inline its contents into `UltrafilterChain.lean`/`SuccChainFMCS.lean`).
