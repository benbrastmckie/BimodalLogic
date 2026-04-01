# Report 11: Alternative Approaches and Critical Analysis (Teammate D)

**Task**: 81 -- F/P Witness Representation Theorem
**Date**: 2026-04-01
**Type**: Critical analysis and alternative evaluation
**Focus**: Sorry map, alternatives E/F/G, and honest assessment of A-G

---

## 1. Complete Sorry Map

### 1.1 The Blocking Chain from `completeness_over_Int`

```
completeness_over_Int (FrameConditions/Completeness.lean:305)
  └─ bundle_validity_implies_provability (line 261)
       ├─ bfmcs_from_mcs_temporally_coherent (line 231) ← SORRY [S1]
       ├─ shifted_truth_lemma (sorry-free, requires B.temporally_coherent)
       ├─ construct_bfmcs_bundle (UltrafilterChain.lean:~3540, sorry-free)
       ├─ not_provable_implies_neg_consistent (sorry-free)
       └─ neg_consistent_gives_mcs_without_phi (sorry-free)
```

**S1** is the SOLE blocking sorry for `completeness_over_Int`. Everything else in `bundle_validity_implies_provability` is sorry-free.

`discrete_completeness_fc` (line 324) reduces to `completeness_over_Int` via sorry-free wiring.

### 1.2 All Sorries in SuccChainFMCS.lean (17 total)

| Line | Theorem | Category | Notes |
|------|---------|----------|-------|
| 1734 | `g_content_union_brs_consistent` | Restricted seed | G-wrap argument incomplete |
| 1763 | `augmented_seed_consistent` | Restricted seed | Depends on BRS consistency |
| **2082** | `constrained_successor_seed_restricted_consistent` | **Key gap** [S2] | BRS/f_content break G-lift |
| 5386 | `restricted_forward_bounded_witness_fueled` fuel=0 | Fuel exhaustion | Semantically unreachable |
| 5544 | `restricted_backward_bounded_witness_fueled` fuel=0 | Fuel exhaustion | Semantically unreachable |
| 5740 | `restricted_combined_bounded_witness_P_fueled` fuel=0 | Fuel exhaustion | Semantically unreachable |

### 1.3 Sorries in Other Files on Critical Path

| File | Line | Theorem | Impact |
|------|------|---------|--------|
| `RestrictedTruthLemma.lean` | 116 | `restricted_chain_G_propagates` | G propagation for DRM chain (n < m case) |
| `RestrictedTruthLemma.lean` | 158 | `restricted_chain_H_step` | H step for DRM chain |
| `SimplifiedChain.lean` | 195 | `targeted_restricted_seed_consistent` | G-lift for targeted seed |
| `SuccChainTruth.lean` | 311 | Box backward in truth lemma | Why bundling is needed |
| `FMP/TruthPreservation.lean` | 263, 281 | G/H reflexivity | FMP needs redesign (strict semantics) |

### 1.4 Sorry-Free Infrastructure (Verified)

| Component | File | Status |
|-----------|------|--------|
| `construct_bfmcs_bundle` | UltrafilterChain.lean:~3540 | Sorry-free (BUNDLE-level coherence) |
| `bundle_to_bfmcs` | FrameConditions/Completeness.lean:185 | Sorry-free |
| `shifted_truth_lemma` | ParametricTruthLemma.lean | Sorry-free (given `temporally_coherent`) |
| `boxClassFamilies_modal_forward/backward` | UltrafilterChain.lean | Sorry-free |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:2212 | Sorry-free |
| `past_theory_witness_exists` | UltrafilterChain.lean:2439 | Sorry-free |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean:79 | Sorry-free |
| `restricted_truth_lemma` | RestrictedTruthLemma.lean:291 | Sorry-free |
| `restricted_ext_neg_excludes_phi` | RestrictedTruthLemma.lean:381 | Sorry-free |
| `build_restricted_tc_family` | SuccChainFMCS.lean:~5866 | Sorry-free |
| `forward_dovetailed` (all properties) | DovetailedChain.lean | Sorry-free (G, H, box_agree) |

---

## 2. RestrictedTruthLemma.lean Assessment

### 2.1 Sorries Found

**Line 116**: `restricted_chain_G_propagates` -- G(psi) in chain(n) implies psi in chain(m) for m > n. The comment at line 103-115 explains the issue precisely: G(psi) in chain(n) implies psi in chain(n+1) by Succ, but for psi in chain(n+2) we need G(psi) in chain(n+1), which requires G(G(psi)) in chain(n). G(G(psi)) may not be in deferralClosure.

**Line 158**: `restricted_chain_H_step` -- H(psi) in chain(n) implies psi in chain(n-1). The standard proof via `Succ_implies_h_content_reverse` requires full MCS, not DRM.

### 2.2 Could Fixing THESE Be Easier?

**No.** Both sorries have clear mathematical reasons why they fail:

1. **G-propagation** (line 116): The comment at line 109-111 explains that the truth lemma does NOT need G-propagation. The truth lemma only proves `chain(n) <-> ext(n)` equivalence for subformulaClosure formulas. Semantic G-propagation follows from the truth lemma + frame properties, not from chain-level G-propagation.

2. **H-step** (line 158): Similarly, the comment at line 153-155 says this is NOT required for the restricted truth lemma.

Both are marked sorry for potential Phase 4 use but are NOT blocking the current completeness path. The `restricted_truth_lemma` at line 291 is sorry-free and does not depend on either of these.

---

## 3. Alternative E: Direct Semantic Model (Bypass BFMCS)

### 3.1 Concept

Instead of building a BFMCS from the chain and proving `temporally_coherent`, build a `TaskFrame`/`TaskModel` directly from the restricted chain and prove the truth lemma for THAT model.

### 3.2 Feasibility Analysis

**What would be needed**:

1. **TaskFrame construction**: Define worlds as the extended chain elements `restricted_chain_ext phi tc_fam n` indexed by `Int`. Define Omega as the singleton set containing this history. Define the accessibility relation from `box_class_agree`.

2. **TaskModel construction**: Define valuation from atom membership in the extended chain.

3. **Truth lemma**: Prove `psi in ext_chain(n) <-> truth_at model omega history n psi` for `psi in subformulaClosure(phi)`.

**The truth lemma is the critical part**. The cases:
- **Atoms**: By definition of valuation. Trivial.
- **Bool connectives**: By MCS properties of ext_chain(n). Standard.
- **Box**: Requires that Omega contains only one history. In singleton-Omega, Box reduces to identity. This is actually problematic -- the validity hypothesis quantifies over ALL Omega sets, but our model has only one history. The soundness direction works, but the completeness direction needs Box(psi) in MCS iff psi in all box-class-equivalent MCSes.
- **G(psi)**: G(psi) in ext_chain(n) iff psi in ext_chain(m) for all m >= n. This requires forward_G on the extended chain for subformulaClosure formulas. The restricted truth lemma gives ext_chain(n) membership <-> DRM membership for closure formulas, and the DRM chain has G-persistence via Succ.
- **F(psi)**: F(psi) in ext_chain(n) implies exists m >= n with psi in ext_chain(m). This is forward_F. **This is the same problem.**
- **H(psi), P(psi)**: Symmetric.

### 3.3 Assessment

**Alternative E does NOT avoid the chain consistency issue.** The F/P cases still require proving that F-obligations resolve within the same chain. The only thing bypassed is the BFMCS wrapper, but the mathematical content is identical.

**Code estimate**: ~300-500 lines for the model construction + truth lemma. But the forward_F sorry would reappear.

**Verdict: DOES NOT SOLVE THE CORE PROBLEM.**

---

## 4. Alternative F: Compactness/Ultraproduct

### 4.1 Concept

Use compactness of TM logic (proved via the finite closure of the target formula) to shortcut the chain construction. Since `subformulaClosure(phi)` is finite, the completeness proof might be achievable via a finite model argument.

### 4.2 Analysis

The FMP (Finite Model Property) path exists in `Metalogic/Decidability/FMP/`. It has:
- `ClosureMCS.lean`: Closure-MCS bundle construction (sorry-free)
- `FiniteModel.lean`: Finite model from closure MCS (sorry-free)
- `Filtration.lean`: Filtration construction (sorry-free)
- `TruthPreservation.lean`: **2 sorries** at lines 263 and 281

The 2 sorries in TruthPreservation.lean are for `mcs_all_future_closure` and `mcs_all_past_closure`, which assert G(psi) -> psi and H(psi) -> psi. These are VALID under reflexive semantics but INVALID under strict semantics (TM uses strict G/H: "at all FUTURE times" not "at all times >= now").

**This means the FMP path is blocked by a fundamental semantic mismatch**: the filtration proof assumes reflexive temporal operators, but TM uses strict (irreflexive) ones.

### 4.3 Could we fix the FMP?

The FMP redesign would require:
1. Redefining the filtration to handle strict temporal operators
2. Proving truth preservation under the strict semantics
3. Handling the fact that strict G/H do not satisfy the T-axiom (G(phi) -> phi is NOT valid in strict semantics... wait, but TM DOES have `temp_t_future: G(phi) -> phi` as an axiom)

Actually, re-reading the axiom list: TM includes `Axiom.temp_t_future a` which gives `G(a) -> a`. This IS the T-axiom. So semantically, G(phi) -> phi IS valid in TM. The sorry comment says "(Gψ → ψ) is NOT valid" but the axiom `temp_t_future` says otherwise.

**CRITICAL OBSERVATION**: There may be a discrepancy between the axiom system (which includes `temp_t_future`: G -> identity) and the semantics (which uses strict future: s > t, not s >= t). If the semantics uses strict future `∀ s > t`, then G(phi) -> phi is NOT semantically valid, creating a soundness gap. But if the axiom is present, either:
(a) The semantics actually uses `s >= t` (then FMP sorries are closeable), or
(b) There's a genuine soundness gap in the system

This deserves investigation but is outside the scope of task 81.

### 4.4 Ultraproduct Approach

Classical ultraproduct methods require:
1. A family of finite models (from compactness/FMP)
2. An ultrafilter on the index set
3. Los's theorem to transfer truth

This is heavy Mathlib machinery that does not exist in the codebase. Estimated effort: 1000+ lines, multiple new files, and deep Mathlib imports. Not practical.

**Verdict: FMP path blocked by semantic issue. Ultraproduct impractical.**

---

## 5. Alternative G: Direct Fix of Existing Sorry

### 5.1 The Sorry at SuccChainFMCS.lean:2082

Reading lines 1790-2082, the sorry is in `constrained_successor_seed_restricted_consistent`, which asserts that the restricted constrained successor seed is consistent.

The seed is:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u) ∪ boundary_resolution_set(phi, u)
```

The first three components are subsets of u (proven at lines 1796-1803), making them trivially consistent. The problem is `boundary_resolution_set(phi, u)`, which contains formulas `psi` where `F(psi) ∈ u`. These formulas are NOT necessarily in u.

### 5.2 The Proof Attempt (lines 1805-2082)

The proof strategy is:
1. If L has no BRS elements, L ⊆ u, consistent by u's consistency.
2. If L has a BRS element psi, use deduction theorem to get L' ⊢ neg(psi) where L' ⊆ u.
3. Then u derives neg(psi). But we also have F(psi) ∈ u.
4. The G-lift argument: if all elements of L' are G-liftable, then G_list ⊢ G(neg(psi)), giving G(neg(psi)) derivable from u, contradicting F(psi) = neg(G(neg(psi))) ∈ u.

**The gap**: Not all elements of L' are G-liftable. The `deferralDisjunctions` and `p_step_blocking_formulas_restricted` elements are in u but do NOT have G-wrapped versions in u. The comment at lines 2059-2075 explains this precisely.

### 5.3 Can We Fix This Differently from Options A, B, C?

**Option G1: Restrict BRS to avoid non-G-liftable conflicts**

Only include `psi` in BRS when `psi` is provably consistent with the G-liftable part of the seed. This weakens BRS but may still give enough F-obligations resolved for forward_F.

**Problem**: This doesn't change the fundamental issue. The consistency argument needs to handle the FULL seed, not just the G-liftable part.

**Option G2: Use `temporal_theory_witness_consistent` directly**

The existing `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79) proves `{psi} ∪ g_content(M)` is consistent when `F(psi) ∈ M` and M is a full MCS. The proof uses the G-lift argument on g_content only.

For the restricted case, we need `{psi} ∪ simplified_seed` consistent. The simplified_seed includes g_content(u) plus deferralDisjunctions(u) and p_step_blocking. The latter two are in u but NOT G-liftable.

**Could we prove**: `{psi} ∪ g_content(u)` is consistent (by analogy with WitnessSeed), then separately argue that adding deferralDisjunctions and p_step_blocking doesn't break consistency?

If `{psi} ∪ g_content(u)` is consistent and `deferralDisjunctions(u) ∪ p_step_blocking(u) ⊆ u`, then `{psi} ∪ g_content(u) ∪ (deferralDisjunctions(u) ∪ p_step_blocking(u))` is consistent iff there's no finite subset deriving bot. Any such finite subset either:
- Uses only elements from u (consistent)
- Uses psi plus elements from u (this IS the tricky part)

Actually, `{psi} ∪ g_content(u) ∪ stuff_from_u` = `{psi} ∪ subset_of_u`. And we need this to be consistent.

From `L ⊆ {psi} ∪ subset_of_u` and `L ⊢ bot`:
- By deduction theorem: L' ⊢ neg(psi) where L' ⊆ u
- So u derives neg(psi)
- We need u to NOT derive neg(psi). But u CAN derive neg(psi) if neg(psi) ∈ u!

When `F(psi) ∈ u`, we have `neg(G(neg(psi))) ∈ u`. In a full MCS, this means `G(neg(psi)) ∉ u`. But it does NOT mean `neg(psi) ∉ u`. An MCS can contain both `F(psi)` and `neg(psi)` simultaneously (F(psi) says psi at some FUTURE time, neg(psi) says not NOW).

**So `{psi} ∪ subset_of_u` CAN be inconsistent** when `neg(psi) ∈ u`.

This is the EXACT same problem as SimplifiedChain.lean:195.

### 5.4 The SimplifiedChain Approach

SimplifiedChain.lean already tries this (lines 155-205). The sorry at line 195 captures exactly this gap: when target ∈ L, the deduction theorem gives L_base ⊢ neg(target), but L_base ⊆ u only gives us that u can derive neg(target), which is NOT a contradiction with F(target) ∈ u.

The full proof requires the G-lift argument from `temporal_theory_witness_consistent` applied to a context that separates G-liftable elements from non-G-liftable ones.

### 5.5 Verdict on Alternative G

**Alternative G reduces to the same mathematical problem as the targeted seed consistency in SimplifiedChain.lean.** The fundamental blocker is: the G-lift consistency argument works for `{psi} ∪ g_content(M)` but fails when non-G-liftable elements from u are in the seed.

The existing `forward_temporal_witness_seed_consistent` (WitnessSeed.lean) proves consistency for `{psi} ∪ {a | G(a) ∈ M}`. This IS sufficient if the successor seed only contains G-liftable elements plus the target. But the Succ relation requires p_step_blocking and deferralDisjunctions which are not G-liftable.

**To fix this directly**: One would need to prove that adding p_step_blocking and deferralDisjunctions to a consistent seed doesn't break consistency. Since both are subsets of u, this requires showing that no derivation from `{psi} ∪ g_content(u) ∪ p_step_blocking(u) ∪ deferralDisjunctions(u)` reaches bot. The key insight would be that derivations from the non-G-liftable parts can be "absorbed" into u-based reasoning without introducing the target.

**This is non-trivial but may be tractable via a refined deduction argument**. Specifically: separate L into L_G (G-liftable) and L_U (non-G-liftable but in u). Apply deduction theorem to eliminate psi, giving L_G ∪ L_U ⊢ neg(psi). G-lift L_G to get G(L_G) ∪ L_U ⊢ G(neg(psi)). Since G(L_G) ⊆ u and L_U ⊆ u, we get u ⊢ G(neg(psi)), contradicting F(psi) ∈ u.

**BUT**: The step "L_G ∪ L_U ⊢ neg(psi) implies G(L_G) ∪ L_U ⊢ G(neg(psi))" is NOT a valid inference in general. The generalized necessitation rule `L ⊢ phi implies G(L) ⊢ G(phi)` requires ALL premises to be G-wrapped, not just some.

**This is the FUNDAMENTAL mathematical obstruction for all approaches (A through G).** The G-lift only works when ALL seed elements are G-liftable.

---

## 6. BFMCS Bundle Architecture Assessment

### 6.1 What is Sorry-Free

| Component | Status |
|-----------|--------|
| `construct_bfmcs_bundle` | Sorry-free (builds BFMCS_Bundle with bundle-level coherence) |
| `bundle_to_bfmcs` | Sorry-free (discards temporal fields) |
| `boxClassFamilies_modal_forward/backward` | Sorry-free |
| `boxClassFamilies_bundle_forward_F/backward_P` | Sorry-free (BUNDLE-level, cross-family) |
| `shifted_truth_lemma` | Sorry-free (given `temporally_coherent`) |
| `bundle_validity_implies_provability` | Sorry-free (given `bfmcs_from_mcs_temporally_coherent`) |

### 6.2 What Has Sorries

Only `bfmcs_from_mcs_temporally_coherent` (S1). This theorem bridges bundle-level coherence to family-level coherence.

### 6.3 Could We Route Around?

The completeness proof structure in `bundle_validity_implies_provability` is clean and tight. The only sorry enters via `h_tc : B.temporally_coherent`. If we could provide ANY BFMCS with `temporally_coherent`, the proof would close.

The question is: can we build an alternative BFMCS where families have `forward_F` and `backward_P`?

---

## 7. The "Strategic Sorry" Option

### 7.1 How Many Sorries Are Critical?

Exactly **1** sorry blocks completeness: `bfmcs_from_mcs_temporally_coherent` (S1).

All other sorries are either:
- In the restricted chain infrastructure (S2 and descendants), which is an ALTERNATIVE path
- Fuel exhaustion cases (semantically unreachable)
- In the FMP path (separate issue)
- In non-blocking helper lemmas

### 7.2 Could We Close S1 with a Targeted Proof?

S1 requires proving that EACH family in `boxClassFamilies M h_mcs` has `forward_F` and `backward_P`. Each family is `shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k`.

`SuccChainFMCS` uses the UNRESTRICTED chain. The unrestricted chain has `forward_G` and `backward_H` but NOT `forward_F/backward_P` because F-nesting is unbounded.

To close S1 directly, we would need to prove `forward_F` for the unrestricted `SuccChainFMCS`. This requires proving F-obligations eventually resolve. The standard approach is fair scheduling/dovetailing. But as shown in DovetailedChain.lean:287-600, the dovetailed approach fails because F-formulas don't persist through Lindenbaum extensions.

**The DovetailedChain.lean file is a 600-line investigation** that proves forward_G, backward_H, g_content propagation, and box_class_agree -- ALL sorry-free -- but concludes at line 587: "THIS APPROACH FUNDAMENTALLY DOESN'T WORK for same-family forward_F with Lindenbaum-based chains."

### 7.3 Conclusion

Closing S1 directly requires solving the F-persistence problem, which is the fundamental mathematical obstacle. No amount of targeted proof work can fix S1 without either:
(a) Using a different chain construction (restricted or constrained)
(b) Proving a new consistency theorem for seeds with non-G-liftable elements

---

## 8. Critical Evaluation of All Approaches

### 8.1 The Fundamental Obstacle (All Approaches)

Every approach to same-family forward_F requires proving: given `F(psi) ∈ chain(t)`, there exists `s >= t` with `psi ∈ chain(s)` in the SAME chain.

The only known consistency argument for including `psi` in a seed is the G-lift argument (`temporal_theory_witness_consistent`), which requires ALL seed elements to be G-liftable.

But the Succ relation requires elements that are NOT G-liftable (deferralDisjunctions, p_step_blocking). So the seed for ANY approach that maintains the Succ relation will include non-G-liftable elements.

### 8.2 Option A: Targeted Seed (one F-obligation at a time)

**Essence**: Build a seed with `{psi} ∪ g_content(u)`, prove consistent via G-lift, then extend to full Succ-satisfying DRM.

**The gap**: After extending to DRM, the extension adds non-G-liftable elements. But the consistency of `{psi} ∪ g_content(u)` is already proven (WitnessSeed.lean:79). The question is whether the DRM extension preserves `psi`.

**Assessment**: The targeted seed `{psi} ∪ g_content(u)` IS consistent (sorry-free). The Lindenbaum extension to a DRM WILL include psi (by Lindenbaum extending a consistent set). So the DRM successor DOES contain psi. The remaining question is whether this DRM successor satisfies Succ (g_content persistence, p_step).

**Potential**: HIGH. The G-lift argument is already proven for the targeted seed. The DRM extension preserves the target. The only gap is showing the extended DRM also has the right Succ properties.

### 8.3 Option B: Filtered f_content

**Essence**: Include only F-obligations where neg(psi) is not derivable from g_content.

**Assessment**: This is trying to carefully select which F-obligations to resolve. But the core issue remains: the consistency argument for the full seed.

**Potential**: MEDIUM. Adds complexity without fundamentally changing the G-lift obstruction.

### 8.4 Option C: Dovetailed Chain (Fair Scheduling)

**Essence**: Build a chain that resolves F-obligations one at a time via fair scheduling.

**Assessment**: DovetailedChain.lean:287-600 proves this DOES NOT WORK for Lindenbaum-based chains. F-formulas don't persist. The file's own conclusion (line 587) says "THIS APPROACH FUNDAMENTALLY DOESN'T WORK."

However, if combined with constrained successors (that preserve f_content via the Succ relation), F-persistence IS maintained. The chain would use `constrained_successor_from_seed` modified to also include the scheduled formula's target.

**Potential**: MEDIUM-HIGH if combined with constrained successors. LOW for pure Lindenbaum chains.

### 8.5 Option D (this analysis): Various Alternatives

- **Alternative E** (Direct semantic model): Does not avoid the problem. Verdict: REJECTED.
- **Alternative F** (Compactness/FMP): FMP is blocked by semantic mismatch. Ultraproduct impractical. Verdict: REJECTED.
- **Alternative G** (Direct fix of S2): Reduces to the same G-lift obstruction. Verdict: SAME AS A.

### 8.6 The Genuine Simplest Path

**The WitnessSeed approach (variant of Option A)** is the simplest:

1. `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79) already proves `{psi} ∪ g_content(M)` consistent when `F(psi) ∈ M` for full MCS.

2. `temporal_theory_witness_exists` (UltrafilterChain.lean:2212) already proves the existence of a full MCS W containing psi with G_theory preserved and box_class_agree.

3. The gap: converting this to a DRM successor that satisfies Succ. The existing `constrained_successor_from_seed` does exactly this for unrestricted MCS.

**The key insight I want to emphasize**: We do NOT need to prove S2 (`constrained_successor_seed_restricted_consistent`). We can build the completeness proof using a DIFFERENT chain that resolves one F-obligation per step, using the ALREADY PROVEN `temporal_theory_witness_exists`.

Specifically:
1. Start from DRM M_0 containing neg(phi)
2. Lindenbaum-extend M_0 to full MCS M_0'
3. Build a dovetailed chain from M_0' using `temporal_theory_witness_exists` at each step, resolving one F-obligation per step via fair scheduling
4. Each step produces a full MCS (sorry-free)
5. G-persistence is proven (DovetailedChain.lean, sorry-free)
6. H-duality is proven (DovetailedChain.lean, sorry-free)
7. Forward_F: when the scheduler resolves F(psi), it uses `temporal_theory_witness_exists` which puts psi in the successor

**The remaining gap for this approach**: F-persistence. When F(psi) ∈ chain(t), we need F(psi) ∈ chain(n) at the resolution step n > t. DovetailedChain.lean:587 shows this fails for Lindenbaum chains.

**BUT**: if we modify the chain to use `constrained_successor_from_seed` instead of `temporal_theory_witness_exists`, we get f_step (F(psi) ∈ chain(t) implies psi ∈ chain(t+1) OR F(psi) ∈ chain(t+1)). This gives F-persistence: F-obligations are either resolved or deferred, never lost. Combined with fair scheduling that forces resolution, forward_F follows.

The problem with this: `constrained_successor_from_seed` requires a seed that includes f_content, and that seed's consistency proof (S2) is the blocked sorry.

**We're back to square one.** Every approach that provides both F-persistence AND scheduled resolution requires seeds with non-G-liftable elements.

---

## 9. A Genuinely New Idea: Two-Phase Construction

### Concept

Separate the chain construction into two phases:

**Phase A**: Build a G-liftable-only chain using `temporal_theory_witness_exists`. This gives forward_G, backward_H, box_class_agree, and resolves ONE F-obligation per step. F-persistence is NOT guaranteed, but some F-obligations ARE resolved.

**Phase B**: For each unresolved F-obligation F(psi) at time t, prove that psi MUST appear somewhere in the chain via a contradiction argument:
- If psi never appears, then neg(psi) ∈ chain(s) for all s >= some s_0 (by MCS and eventual stability)
- Eventually G(neg(psi)) ∈ chain(s) for large s (if neg(psi) stabilizes)
- But G(neg(psi)) contradicts F(psi) if F(psi) still exists at that point

**The challenge with Phase B**: neg(psi) being in chain(s) does NOT imply G(neg(psi)) ∈ chain(s). The chain's Lindenbaum extension could include neg(psi) at every step without ever including G(neg(psi)).

**Potential fix**: Use `temp_4_future` (G(psi) -> G(G(psi))) combined with the chain's G-persistence to argue that if G(neg(psi)) ever enters, it persists forever AND was derivable from earlier elements. But G(neg(psi)) might never enter.

**This approach fails for the same reason as DovetailedChain.lean:540-555.** Lindenbaum can keep neg(psi) in the chain at every step without ever committing to G(neg(psi)), thereby keeping F(psi) alive but never resolving it.

---

## 10. Recommended Approach

### 10.1 The Honest Assessment

After surveying all seven approaches and two new alternatives:

**No approach completely avoids the fundamental obstruction**: the G-lift consistency argument only covers G-liftable seed elements, but the Succ relation requires non-G-liftable elements.

**The closest to a solution is Option A** (targeted seed), specifically the variant where:
1. The successor seed is `{target} ∪ g_content(u)` (provably consistent by WitnessSeed.lean)
2. This is extended to a DRM via `deferral_restricted_lindenbaum`
3. The DRM extension preserves the target (by Lindenbaum)
4. The DRM automatically satisfies deferralDisjunctions and p_step_blocking within deferralClosure

**The gap in Option A is proving**: the DRM extension of `{target} ∪ g_content(u)` satisfies Succ with the previous u. Specifically:
- g_content(u) ⊆ successor: YES, g_content(u) is in the seed, seed ⊆ successor
- p_step: needs H(neg(chi)) in successor when F(chi) ∉ u. This follows from DRM maximality within deferralClosure IF we can show H(neg(chi)) is consistent with the seed.

### 10.2 Final Recommendation

**Option A (targeted seed)** with the following specific approach:

1. Prove `targeted_seed_to_drm_satisfies_succ`: when `{target} ∪ g_content(u)` is extended to a DRM, the result satisfies Succ(u, successor). This requires showing that the DRM's maximality within deferralClosure automatically gives the p_step_blocking and deferralDisjunctions properties.

2. Build the chain using this targeted successor at each step, resolving one F-obligation per step via fair scheduling.

3. Forward_F follows from: (a) F-persistence via the Succ f_step property, and (b) scheduled resolution.

**The key unsolved step is proving Succ(u, successor) when the successor is built from `{target} ∪ g_content(u)` extended to a DRM.** This is a well-defined, isolated mathematical problem that should be tractable.

### 10.3 Confidence Level

**LOW-MEDIUM**. The fundamental G-lift obstruction affects all approaches. Option A is the most promising because it separates the tractable part (targeted seed consistency) from the unclear part (Succ properties of the extended DRM). But I cannot guarantee the Succ properties hold.

### 10.4 Effort Estimate

- Option A (if Succ properties work): ~200-400 lines
- Time to determine if Succ properties work: ~1-2 focused proof sessions
- If Succ properties fail: Back to exploring fundamentally different approaches

---

## Appendix: Search Queries and Sources

### Files Read
- `FrameConditions/Completeness.lean` (full file, 394 lines)
- `Metalogic/Algebraic/RestrictedTruthLemma.lean` (full file, 432 lines)
- `Metalogic/Bundle/SuccChainFMCS.lean` (lines 1-80, 1750-2120, 3650-3730, 5370-5430, 5700-5760)
- `Metalogic/Bundle/SimplifiedChain.lean` (full file, 206 lines)
- `Metalogic/Algebraic/DovetailedChain.lean` (full file, 605 lines)
- `Metalogic/Completeness/SuccChainCompleteness.lean` (full file, 177 lines)
- `Metalogic/Decidability/FMP/FMP.lean` (lines 1-80)
- `Metalogic/Decidability/FMP/TruthPreservation.lean` (sorry context)
- `Metalogic/Algebraic/UltrafilterChain.lean` (sorry occurrences)
- `Metalogic/Bundle/SuccChainTruth.lean` (sorry occurrences)
- `Metalogic/Bundle/Construction.lean` (sorry occurrences)
- `Boneyard/BundleTemporalCoherence/README.md` (full file)
- Reports 09 and 10 from prior research

### Key Findings Count
- 17 sorries identified in SuccChainFMCS.lean
- 310 total sorry occurrences across 45 files in the Bimodal directory
- 1 blocking sorry for completeness_over_Int (S1)
- 1 key gap in restricted chain infrastructure (S2)
- 0 sorries in DovetailedChain.lean (all properties sorry-free except forward_F which is unimplemented)
- 2 sorries in FMP/TruthPreservation.lean (semantic mismatch)
