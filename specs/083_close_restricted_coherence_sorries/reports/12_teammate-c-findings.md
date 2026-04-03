# Teammate C Findings: Concrete Lean Code Analysis of g_content Blocker

**Task**: 83 - Close Restricted Coherence Sorries
**Focus**: Concrete analysis of all 26 sorry sites using `temp_t_future`/`temp_t_past`
**Date**: 2026-04-03

## Executive Summary

There are **26 sorry sites** across **5 files** in `Theories/Bimodal/Metalogic/`, all with the same pattern: they previously used the T-axiom (`G(phi) -> phi` or `H(phi) -> phi`) which was removed under strict semantics. These sorry sites fall into **4 distinct categories** that require **3 different fix strategies**. The critical finding is that **the `temporal_theory_witness_exists` seed does NOT include `g_content(M)`** -- it includes `G_theory(M)` (the G-wrapped formulas), so the forward_step successor does NOT directly contain `g_content` elements. This means the sorry in `forward_step_g_content` is a genuine gap, not a trivially-closable oversight.

## Sorry Site Inventory

### File-by-file count

| File | `temp_t_future` | `temp_t_past` | Total |
|------|----------------|---------------|-------|
| `UltrafilterChain.lean` | 4 | 3 | 7 |
| `DovetailedChain.lean` | 4 | 5 | 9 |
| `SuccChainFMCS.lean` | 3 | 1 | 4 |
| `TargetedChain.lean` | 2 | 2 | 4 |
| `MCSWitnessSuccessor.lean` | 1 | 1 | 2 |
| **Total** | **14** | **12** | **26** |

## Category Analysis

### Category 1: Lindenbaum Algebra `Derives` Goals (7 sites in UltrafilterChain.lean)

**Sites**: Lines 97, 267, 520, 565, 1009, 1318 (+ the `forward_G`/`backward_H` sites at 520, 565)

**Exact Lean type signature**:
```lean
show Derives φ.all_future φ   -- (temp_t_future)
show Derives φ.all_past φ     -- (temp_t_past)
```

These appear in the Lindenbaum algebra construction where the quotient requires proving `G_quot(toQuot phi) <= toQuot phi` (i.e., `G(phi) -> phi` is derivable). Under strict semantics, `G(phi) -> phi` is NOT derivable.

**What these prove**: `R_G` reflexivity (`R_G U U`), `R_H` reflexivity, `forward_G` (G-propagation along ultrafilter chains), `backward_H`, and `G_bot_le_bot` in seed consistency.

**Old proof**: Direct axiom application `temp_t_future phi`.

**Analysis**: These goals are **FALSE** under strict semantics. `Derives phi.all_future phi` means `[] |- G(phi) -> phi`, which is exactly the T-axiom that was removed because it is unsound under strict quantification (G quantifies over s > t, not s >= t).

**Required fix strategy**: These theorems need to be **deleted or restructured**, not patched. The Lindenbaum algebra approach assumes reflexive temporal accessibility relations, which strict semantics does not provide. The `R_G_refl` theorem is simply false under strict semantics, and the `forward_G` theorem must use a different proof strategy.

For `forward_G`: Instead of "G(a) in chain(t) implies a in chain(t') for t' >= t", the correct strict version would be "G(a) in chain(t) implies a in chain(t') for t' > t". This shifts the inequality from `>=` to `>`. However, the chain construction may need restructuring to make this work.

For `G_bot_le_bot` (line 1009): This is `G(bot) -> bot`. Under strict semantics, `G(bot)` means "bot at all future times s > t", which is vacuously true (there could be no future times, but seriality guarantees there are). With seriality, `G(bot)` implies there exists s > t with bot at s, which is indeed false. So `G(bot) -> bot` IS derivable from `G(phi) -> F(phi)` (seriality) and `F(bot) -> bot` (which follows from the semantics of F). This specific case CAN be fixed.

**Confidence**: HIGH that these need restructuring, not patching.

### Category 2: MCS g_content/h_content Propagation (11 sites across DovetailedChain, MCSWitnessSuccessor, UltrafilterChain)

**Sites**:
- `temporal_witness_g_persistence` (UltrafilterChain.lean:2591)
- `forward_step_g_content` (DovetailedChain.lean:142)
- `forward_dovetailed_forward_G` (DovetailedChain.lean:224)
- `forward_dovetailed_backward_H` (DovetailedChain.lean:277, 282)
- `backward_step_h_content` (DovetailedChain.lean:762)
- `backward_dovetailed_backward_G` (DovetailedChain.lean:891, 896)
- `backward_dovetailed_backward_H` (DovetailedChain.lean:912, 917)
- `build_targeted_successor_g_persistence` (MCSWitnessSuccessor.lean:259)
- `build_targeted_predecessor_h_persistence` (MCSWitnessSuccessor.lean:319)

**Exact Lean type signature** (representative):
```lean
-- In temporal_witness_g_persistence:
have h_T : [] ⊢ (Formula.all_future a).imp a := sorry
-- Used to conclude: G(a) ∈ W implies a ∈ W (for W an MCS)

-- In forward_step_g_content:
exact SetMaximalConsistent.implication_property (forward_step_mcs M h_mcs phi)
  (theorem_in_mcs (forward_step_mcs M h_mcs phi)
    (sorry /* was: temp_t_future a */)) h_Ga_W
-- Pattern: we have G(a) ∈ W, need a ∈ W
```

**What the old proof did**: Used `temp_t_future a` to get `[] |- G(a) -> a`, then applied `implication_property` to get `a ∈ W` from `G(a) ∈ W`.

**Critical analysis of the seed construction**:

The `temporal_theory_witness_exists` theorem produces a witness W from the seed `{phi} ∪ temporal_box_seed(M)` where:
```lean
temporal_box_seed M = G_theory M ∪ box_theory M
G_theory M = { f | ∃ a, f = Formula.all_future a ∧ Formula.all_future a ∈ M }
```

This means the seed contains `G(a)` for each `G(a) ∈ M`, NOT `a` itself. The Lindenbaum extension W is guaranteed to contain `G(a)` (by seed extension), but getting `a ∈ W` from `G(a) ∈ W` requires the T-axiom.

**Proposed replacement**: Modify the seed to include `g_content(M)` directly:
```lean
temporal_box_seed M = G_theory M ∪ g_content M ∪ box_theory M
```
Then `a ∈ W` follows directly from seed extension without needing the T-axiom. However, this requires reproving that the enlarged seed is consistent. The consistency proof currently works because every element of `G_theory(M) ∪ box_theory(M)` lifts back to M via necessitation. Adding `g_content(M)` elements requires a new argument: if `L ⊆ g_content(M)` derives bot, then by temporal necessitation `G(L)` derives `G(bot)`, and `G(L) ⊆ M`, so M derives `G(bot)`, and `G(bot) -> F(bot) -> bot` (via seriality + F-semantics) gives a contradiction.

Wait -- that argument uses `G(bot) -> bot` which is itself what we're trying to avoid. The consistency proof for the extended seed is nontrivial.

**Alternative approach**: Instead of modifying the seed, modify the `Succ` relation itself to require only `G_theory(M) ⊆ N` (G-preservation) rather than `g_content(M) ⊆ N`. Then the chain construction works without needing `a ∈ W` from `G(a) ∈ W`. The truth lemma would use the chain's G-preservation (G(a) propagates forward) combined with the strict semantics (truth at future times, not current time) to validate G formulas.

**Confidence**: MEDIUM-HIGH. The seed enrichment approach has a subtle circularity in its consistency proof. The `Succ` redefinition approach is more promising but requires careful analysis of downstream impacts.

### Category 3: DeferralRestrictedMCS g_content Self-Containment (4 sites in SuccChainFMCS.lean)

**Sites**: Lines 1244, 4009, 4276, 4419

**Exact Lean type signature**:
```lean
-- g_content_subset_deferral_restricted_mcs (line 1244):
have h_T : [] ⊢ (Formula.all_future chi).imp chi := sorry
-- Used in: by_contra h_not_in ... derive contradiction using T-axiom

-- predecessor_deferral_seed_consistent (line 4009):
have h_T : [] ⊢ (Formula.all_past chi).imp chi := sorry
-- Used in: consistency proof for predecessor seed

-- successor_deferral_seed_lindenbaum_g_step (line 4276):
have h_T : [] ⊢ (Formula.all_future chi).imp chi := sorry
-- Used in: G(chi) ∈ u implies chi ∈ u for DeferralRestrictedMCS

-- successor_deferral_seed_consistent, neg_neg_bot case (line 4419):
have h_T : [] ⊢ G_neg_neg_bot.imp neg_neg_bot := sorry
-- Specific: G(neg(neg(bot))) -> neg(neg(bot))
```

**What the old proofs did**: All four use `G(chi) -> chi` (or `H(chi) -> chi`) within a DeferralRestrictedMCS (DRM) context to show that if `G(chi) ∈ u`, then `chi ∈ u`. This is needed for the proof that `g_content(u) ⊆ u` when u is a DRM.

**Analysis**: The theorem `g_content_subset_deferral_restricted_mcs` states that `g_content(u) ⊆ u` for any DRM u. This is **FALSE** under strict semantics in general. A DRM is a maximally consistent subset of the deferral closure. Having `G(chi) ∈ u` does NOT imply `chi ∈ u` without the T-axiom.

However, the DRM construction (via `successor_deferral_seed`) starts from a seed that includes `g_content(u_parent)`. So the DRM u does contain the g_content elements from its parent, but not necessarily its OWN g_content (i.e., formulas chi where G(chi) was added during Lindenbaum extension).

**Proposed fix**: The DRM construction needs restructuring. The `successor_deferral_seed` is:
```lean
g_content u ∪ deferralDisjunctions u
```
This directly puts `g_content(u)` in the seed, so any MCS v extending this seed has `g_content(u) ⊆ v`. The theorem that needs to work is `g_content(v) ⊆ v` (the g_content of the NEW MCS v is in v itself). This requires that if `G(chi)` was added during Lindenbaum extension, then `chi ∈ v`. This is where the T-axiom was used, and it cannot be replaced.

**The real question**: Do downstream proofs actually NEED `g_content(v) ⊆ v`, or do they only need `g_content(u) ⊆ v` (parent's g_content in successor)? If only the latter, the sorry can be avoided entirely. The `Succ` relation requires `g_content(u) ⊆ v`, which is satisfied by the seed construction directly.

**For line 4419** (the `neg_neg_bot` case): This is `G(neg(neg(bot))) -> neg(neg(bot))`. Since `neg(neg(bot))` is a propositional tautology (derivable from empty), we can prove `neg(neg(bot)) ∈ u` directly via `theorem_in_mcs`, without needing the T-axiom at all. This specific case has a CLEAN FIX.

**Confidence**: HIGH for the specific neg_neg_bot case (line 4419). MEDIUM for the general g_content self-containment; requires analysis of whether downstream proofs need `g_content(v) ⊆ v` or only `g_content(u_parent) ⊆ v`.

### Category 4: Targeted Chain Temporal Coherence (4 sites in TargetedChain.lean)

**Sites**: Lines 242, 346, 478, 512

**Exact Lean type signature**:
```lean
-- targeted_forward_chain_forward_G (line 242):
(sorry /* was: temp_t_future phi */)
-- In context: G(phi) propagated to chain(m), need phi at chain(m) by T-axiom

-- targeted_backward_chain_backward_H (line 346):
(sorry /* was: temp_t_past phi */)
-- In context: H(phi) propagated to chain(m), need phi at chain(m) by T-axiom

-- targeted_fam_forward_G (line 478):
(sorry /* was: temp_t_future phi */)
-- In context: G(phi) propagated to fam(t'), need phi at fam(t')

-- targeted_fam_backward_H (line 512):
(sorry /* was: temp_t_past phi */)
-- In context: H(phi) propagated to fam(t'), need phi at fam(t')
```

**What the old proofs did**: These prove "G(phi) at chain(n) implies phi at chain(m) for m >= n" by:
1. Propagating G(phi) from n to m using temp_4 + G_step (this part is fine)
2. Applying T-axiom `G(phi) -> phi` at chain(m) to get `phi ∈ chain(m)` (this is the sorry)

**Analysis**: These theorems are **FALSE** as stated under strict semantics. If G quantifies over strictly future times only, then `G(phi) ∈ chain(n)` means phi holds at all times AFTER n, not AT n. So the correct statement would be:

```lean
-- STRICT version:
-- G(phi) at chain(n) implies phi at chain(m) for m > n (strictly greater)
```

Or equivalently, phi at chain(n+1), chain(n+2), etc., but NOT at chain(n) itself.

**Proposed fix**: Change the theorem statements to use strict inequality:
```lean
theorem targeted_forward_chain_forward_G ... (h_lt : n < m) ... :
    phi ∈ targeted_forward_chain M0 h_mcs targets m
```

Then the proof works: G(phi) at chain(n) propagates G(phi) to chain(n+1) via G_step. At chain(n+1), by the Succ relation, `g_content(chain(n)) ⊆ chain(n+1)`, so `phi ∈ chain(n+1)` directly from the seed construction. For m > n+1, continue propagating G(phi) and extracting phi via the seed.

Wait -- this uses `g_content ⊆ successor`, which is exactly the Category 2 sorry. So this fix is contingent on Category 2 being resolved first.

**Alternative**: If the chain construction ensures `G_theory(chain(n)) ⊆ chain(n+1)` (which it does, by `forward_step_G_agree`), then `G(phi) ∈ chain(n+1)`. To get `phi ∈ chain(n+1)`, we STILL need g_content, which circles back to the same problem.

The fundamental issue is that strict semantics means "phi at the NEXT time point, not the current one". The chain construction builds chain(n+1) as a witness for chain(n). By construction:
- `G(phi) ∈ chain(n)` implies `G(phi) ∈ chain(n+1)` (G_agree)
- But we need `phi ∈ chain(n+1)`, which requires T-axiom or seed inclusion

**Confidence**: HIGH that these need strict inequality + Category 2 resolution.

## The Fundamental Blocker: Seed Enrichment vs Succ Redefinition

All 26 sorry sites ultimately reduce to a single mathematical fact: under strict semantics, `G(phi) ∈ M` does NOT imply `phi ∈ M` for the same MCS M.

There are two resolution paths:

### Path A: Enrich the Seed (add g_content to temporal_box_seed)

**Approach**: Change `temporal_box_seed M = G_theory M ∪ box_theory M` to include `g_content M`:
```lean
temporal_box_seed M = G_theory M ∪ g_content M ∪ box_theory M
```

**Pros**:
- Directly fixes Category 2 (g_content propagation)
- Minimal structural change to the codebase
- The Succ relation definition is preserved

**Cons**:
- Requires proving the enlarged seed is consistent, which is nontrivial
- The consistency proof needs: "if L ⊆ g_content(M) derives bot, then M is inconsistent"
- This requires a proof that involves temporal necessitation + seriality

**Consistency argument sketch**: Suppose L = [a1, ..., ak] with each G(ai) ∈ M, and L derives bot. Then:
1. By temporal necessitation of propositional tautologies + temp_k_dist, we can show `G(a1 ∧ ... ∧ ak) -> G(bot)`
2. By temp_4, `G(ai) -> G(G(ai))`, so `G(a1 ∧ ... ∧ ak)` is derivable from `{G(a1), ..., G(ak)}`
3. So M derives `G(bot)`
4. By seriality, `G(bot) -> F(bot)`. By definition, `F(bot) = neg(G(neg(bot)))`, and `neg(bot)` is a tautology, so `G(neg(bot))` is derivable, making `F(bot)` false. Wait, `F(phi) = neg(G(neg(phi)))`, and `F(bot) = neg(G(top))`. Under seriality, `G(top) -> F(top)` = `G(top) -> neg(G(neg(top))) = G(top) -> neg(G(bot))`. Hmm, this gets circular.

Actually, seriality axiom is `G(phi) -> F(phi)`, i.e., `G(phi) -> neg(G(neg(phi)))`. So `G(bot) -> neg(G(neg(bot))) = neg(G(top))`. But `G(top)` is derivable (by temporal necessitation of top). So `G(bot)` implies `neg(G(top))`, which contradicts `G(top)`. Hence `G(bot) -> bot` via this chain. The consistency proof works!

More precisely:
1. `G(top)` is derivable (temporal necessitation of `|- top`)
2. `G(bot) -> F(bot)` by seriality
3. `F(bot) = neg(G(neg(bot))) = neg(G(top))`
4. So `G(bot) -> neg(G(top))`
5. From M deriving `G(bot)` and `G(top)` being a theorem in M, M derives bot

This means the seed enrichment IS consistent, and `G(bot) -> bot` is derivable from seriality + temporal necessitation.

**Does NOT fix**: Category 1 (Lindenbaum algebra) -- these need restructuring regardless.

### Path B: Restructure Chain Theorems with Strict Inequality

**Approach**: Change all "phi at chain(m) for m >= n" to "phi at chain(m) for m > n" (or use the chain step directly).

**Pros**:
- Mathematically correct under strict semantics
- No need to modify seeds

**Cons**:
- Requires modifying theorem STATEMENTS, not just proofs
- Cascading changes to all downstream callers
- Category 2 still needs fixing (g_content propagation is needed for Succ)

## Recommendations

### Priority Order for Fixes

1. **Prove `G(bot) -> bot` from seriality** (unlocks the seed consistency argument)
2. **Enrich `temporal_box_seed` with `g_content`** and prove consistency (fixes Category 2 + 4)
3. **Fix Category 3 case-by-case**: neg_neg_bot case is trivial; general case may not be needed if Succ only requires parent g_content
4. **Restructure Category 1** (Lindenbaum algebra): change R_G/R_H to use strict accessibility, restructure forward_G/backward_H with strict inequality
5. **Propagate strict inequality** through Category 4 (TargetedChain) theorem statements

### Derivation of G(bot) -> bot (Key Lemma)

```lean
theorem G_bot_implies_bot : [] ⊢ (Formula.all_future Formula.bot).imp Formula.bot := by
  -- G(bot) -> F(bot) by seriality
  have h_serial := DerivationTree.axiom [] _ (Axiom.seriality_future Formula.bot)
  -- F(bot) = neg(G(neg(bot))) = neg(G(top))
  -- G(top) is a theorem (temporal necessitation of top)
  have h_top : [] ⊢ Formula.neg Formula.bot := Bimodal.Theorems.Combinators.identity Formula.bot
  have h_G_top : [] ⊢ (Formula.neg Formula.bot).all_future :=
    DerivationTree.temporal_necessitation _ h_top
  -- F(bot) and G(top) together derive bot
  -- F(bot) = neg(G(top)), so F(bot) ∧ G(top) -> bot
  -- Chain: G(bot) -> F(bot) = neg(G(top)), but G(top) is a theorem, contradiction
  sorry -- Exact derivation tree construction needed
```

The exact derivation tree would chain: `G(bot)` --(seriality)--> `F(bot)` = `neg(G(neg(bot)))` = `neg(G(top))`, then combine with `G(top)` (a theorem) to derive bot.

### Summary of Fix Feasibility

| Category | Sites | Fix Strategy | Feasibility | Confidence |
|----------|-------|-------------|-------------|------------|
| 1: Lindenbaum Algebra | 7 | Restructure R_G/R_H for strict access | Hard | HIGH |
| 2: MCS g_content propagation | 11 | Enrich seed with g_content | Medium | HIGH |
| 3: DRM self-containment | 4 | Case analysis; may not be needed | Easy-Medium | MEDIUM |
| 4: Targeted chain coherence | 4 | Strict inequality + seed fix | Medium | HIGH |

**Total estimated effort**: The seed enrichment (Path A) is the most impactful single change, resolving 15 of 26 sorry sites (Categories 2 + 4). Category 1 requires Lindenbaum algebra restructuring. Category 3 may partially resolve itself if downstream proofs only need parent g_content.

## Key Definitions Referenced

```lean
-- g_content: formulas phi where G(phi) ∈ M
def g_content (M : Set Formula) : Set Formula := {phi | Formula.all_future phi ∈ M}

-- Succ: immediate successor relation
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v

-- temporal_theory_witness_exists seed:
-- {phi} ∪ G_theory(M) ∪ box_theory(M)
-- where G_theory(M) = {G(a) | G(a) ∈ M}  (NOT g_content!)

-- successor_deferral_seed:
-- g_content(u) ∪ deferralDisjunctions(u)
-- This DOES include g_content directly

-- Formula.next:
def next (φ : Formula) : Formula := Formula.untl Formula.bot φ
-- X(phi) = bot U phi
```
