# Research Report: Task 945 - Teammate A Findings

**Task**: 945 - Design canonical model construction for TruthLemma
**Date**: 2026-02-27
**Focus**: Deep analysis of metalogic state, representation gaps, and canonical model design for TruthLemma

---

## Key Findings

### 1. The Single Remaining Sorry in the Active Completeness Chain

The entire BFMCS completeness chain -- from the truth lemma through weak and strong completeness, to the standard representation theorem -- depends on exactly ONE sorry-backed theorem:

```lean
-- TemporalCoherentConstruction.lean:580-600
theorem fully_saturated_bfmcs_exists_int
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B := by
  sorry
```

This theorem must produce a `BFMCS Int` satisfying THREE simultaneous properties: (1) context preservation at eval_family, (2) temporal coherence for ALL families (`forward_F` and `backward_P`), and (3) modal saturation (Diamond witnesses exist).

**Verified via lean_local_search**: `fully_saturated_bfmcs_exists_int` exists in `TemporalCoherentConstruction.lean`. The downstream dependencies `construct_saturated_bfmcs_int`, `construct_saturated_bfmcs_int_contains_context`, `construct_saturated_bfmcs_int_temporally_coherent` all use `.choose` on this theorem.

### 2. What `temporally_coherent` Requires and Why It Is Hard

```lean
-- TemporalCoherentConstruction.lean:296-299
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  forall fam in B.families,
    (forall t phi, F(phi) in fam.mcs t -> exists s, t <= s /\ phi in fam.mcs s) /\
    (forall t phi, P(phi) in fam.mcs t -> exists s, s <= t /\ phi in fam.mcs s)
```

This requires EVERY family in the bundle to satisfy `forward_F` and `backward_P`. The difficulty is that modal saturation adds NEW families (Diamond witnesses), and these must ALSO be temporally coherent.

**The fundamental tension** (documented extensively in research-007 of task 930 and research-009 of task 922):

- **Temporal coherence needs non-constant families**: Different MCSes at different times, so F(psi) at time t can find a witness at some later time s.
- **Modal saturation creates constant witness families**: Same MCS W at every time, chosen to contain the Diamond witness psi.
- **Constant families cannot be temporally coherent**: The set `{F(psi), neg(psi)}` is consistent, so Lindenbaum can produce an MCS W containing both. Such W violates `F(psi) -> psi` (needed for temporal saturation of a constant family).

### 3. The DovetailingChain: 2 Structural Sorries

The DovetailingChain (`DovetailingChain.lean`) builds an `FMCS Int` with proven `forward_G` and `backward_H` (all cross-sign cases resolved). The 2 remaining sorries are:

| Sorry | Location | Why It Fails |
|-------|----------|--------------|
| `buildDovetailingChainFamily_forward_F` | Line 1869 | F-formulas don't persist through GContent seeds; Lindenbaum can kill them |
| `buildDovetailingChainFamily_backward_P` | Line 1881 | Symmetric to forward_F for P-formulas/HContent |

**Verified via lean_local_search and grep**: These are the only 2 sorries in DovetailingChain.lean.

**Root cause**: The linear chain builds `M_{n+1}` from `GContent(M_n)`. The formula `F(psi) = neg(G(neg(psi)))` is NOT in GContent (only `G`-formulas are). Lindenbaum's non-constructive extension at step n+1 can introduce `G(neg(psi))`, killing the F-obligation. Twelve different approaches have been tried and documented in Task 916.

### 4. The CanonicalMCS Sorry-Free Solution (for a Single FMCS)

`CanonicalFMCS.lean` provides a sorry-free `FMCS CanonicalMCS` where `forward_F` and `backward_P` are trivially proven:

```lean
-- CanonicalFMCS.lean:265-283
theorem temporal_coherent_family_exists_CanonicalMCS
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
      ... forward_F ... backward_P ...
```

**Verified via lean_local_search**: `canonicalMCSBFMCS` exists as a sorry-free FMCS over CanonicalMCS.

**Why it works**: Domain elements ARE MCSes. Each F-obligation `F(psi) in w.world` gets a fresh Lindenbaum witness W (via `canonical_forward_F` in `CanonicalFrame.lean`). Since W is an MCS, it is automatically a domain element. The witness EXISTS at a DIFFERENT domain point than the original.

**Why it does not solve the full problem**: This is a SINGLE FMCS (one family). The truth lemma needs a BFMCS (bundle of families) with modal saturation. Building multiple families over CanonicalMCS that are DISTINCT at some points runs into the same temporal coherence problem: witness families must differ from the identity mapping, but non-identity families over CanonicalMCS face the same constant-family impossibility (research-009, Section 7).

### 5. What `bmcs_truth_lemma` Provides vs. What It Requires

The truth lemma (`TruthLemma.lean:260-398`) is **fully sorry-free** for all six cases (atom, bot, imp, box, all_future, all_past). Its signature:

```lean
theorem bmcs_truth_lemma (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam in B.families)
    (t : D) (phi : Formula) :
    phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

**Critical observation about usage**: The Box case (lines 321-346) uses ONLY `modal_forward` and `modal_backward` -- it does NOT invoke `temporally_coherent`. Temporal coherence is only used in the `all_future` and `all_past` backward cases (lines 355-398), where it extracts `forward_F` and `backward_P` for the SPECIFIC family being evaluated:

```lean
obtain <h_forward_F, h_backward_P> := h_tc fam hfam
```

However, because the Box case applies the IH to ALL families (`fam'`), and the IH for `G(psi)` at `fam'` would need temporal coherence of `fam'`, the current formulation requires temporal coherence of ALL families.

### 6. The Banned MCS-Membership Approach

The `bmcs_truth_lemma_mcs` approach (archived to Boneyard as `MCSMembershipCompleteness.lean`) broke the cross-dependency by defining Box using flat MCS membership:

```lean
| box phi => forall fam' in B.families, phi in fam'.mcs t  -- NOT recursive
```

This only needed temporal coherence for the eval family. However, it was BANNED (task 931) because the resulting "completeness" does not establish the standard meta-theorem -- it uses a non-standard validity notion.

**Verified via lean_local_search**: `bmcs_truth_lemma_mcs` exists only in `Boneyard/Bundle/MCSMembershipCompleteness.lean`.

### 7. The FMP Alternative: Sorry-Free Weak Completeness

`FMP/SemanticCanonicalModel.lean` provides sorry-free weak completeness via finite models:

```lean
noncomputable def fmp_weak_completeness (phi : Formula) :
    (forall w, semantic_truth_at_v2 phi w ... phi) -> |- phi
```

**Verified**: This is sorry-free, depending only on `propext`, `Classical.choice`, `Quot.sound`.

Research-009 of task 922 proposes extending FMP to strong completeness via the `bigAnd(Gamma)` trick. This would bypass the BFMCS construction entirely.

### 8. Complete Sorry Inventory (Active Metalogic)

| # | File | Line | Declaration | Dependency |
|---|------|------|-------------|------------|
| 1 | DovetailingChain.lean | 1869 | `buildDovetailingChainFamily_forward_F` | Used by `temporal_coherent_family_exists_theorem` |
| 2 | DovetailingChain.lean | 1881 | `buildDovetailingChainFamily_backward_P` | Used by `temporal_coherent_family_exists_theorem` |
| 3 | TemporalCoherentConstruction.lean | 600 | `fully_saturated_bfmcs_exists_int` | Used by all BFMCS/Representation completeness |

Sorries 1-2 feed into sorry 3, but sorry 3 has an ADDITIONAL blocker: combining temporal coherence with modal saturation, even if 1-2 were resolved.

---

## Current Gaps

### Gap A: The Combination Problem (fully_saturated_bfmcs_exists_int)

The core unsolved problem is constructing a BFMCS where:
1. ALL families satisfy forward_F and backward_P (temporal coherence)
2. Enough families exist to witness all Diamond formulas (modal saturation)

**Why this is hard**: Modal saturation adds witness families. Constant witness families fail temporal coherence. Non-constant witness families need their own DovetailingChain-like construction, but each chain has the F/P witness problem.

### Gap B: DovetailingChain forward_F/backward_P (2 sorries)

F-formulas don't persist through GContent seeds. The linear chain cannot guarantee that `F(psi)` present at time t will still be present when the encoding index of psi is reached. This is a genuine mathematical difficulty, not a formalization issue.

### Gap C: Standard Strong Completeness Without BFMCS

The FMP approach provides sorry-free WEAK completeness but not strong completeness. Extending it via the `bigAnd` trick is proposed but not yet implemented.

---

## Evidence (Verified via lean_local_search)

| Lemma | Exists? | File | Sorry-Free? |
|-------|---------|------|-------------|
| `fully_saturated_bfmcs_exists_int` | Yes | TemporalCoherentConstruction.lean | NO (sorry at line 600) |
| `bmcs_truth_lemma` | Yes | TruthLemma.lean | YES |
| `canonical_forward_F` | Yes | CanonicalFrame.lean | YES |
| `canonicalMCSBFMCS` (via `canonicalMCSBFMCS_root_contains`) | Yes | CanonicalFMCS.lean | YES |
| `bmcs_truth_lemma_mcs` | Yes | Boneyard only | YES (but banned) |
| `FamilyCollection.exists_fullySaturated_extension` | Yes | Boneyard/SaturatedConstruction.lean | Unknown (Boneyard) |
| `temporal_coherent_family_exists_theorem` | Not found by lean_local_search | DovetailingChain.lean | NO (2 sorries) |

Note: `temporal_coherent_family_exists_theorem` was not found by lean_local_search despite existing in DovetailingChain.lean (lines 1897-1910). This may be due to search indexing not covering deeply nested declarations.

---

## Architectural Analysis: The Design Space for Task 945

### What the Task Asks

Task 945 asks to design a canonical model construction satisfying the TruthLemma. The truth lemma IS already fully proven -- the problem is constructing the BFMCS that satisfies its hypotheses (`B.temporally_coherent`).

### Three Viable Design Paths

#### Path 1: Weaken `temporally_coherent` to Eval-Only

**Idea**: Reformulate the truth lemma to only require temporal coherence of the family being evaluated, not all families. This breaks the cross-dependency where Box forces IH application to all families, which forces temporal coherence of all families.

**Challenge**: The truth lemma is proven by structural induction on the formula. The Box case applies the IH to all families. If the IH for `G(psi)` at family `fam'` requires temporal coherence of `fam'`, then all families need temporal coherence.

**Resolution**: The cross-dependency can be broken IF the Box case does not recurse into temporal sub-formulas of the inner formula at witness families. This is exactly what `bmcs_truth_lemma_mcs` achieved (Box = flat membership, not recursive truth). The challenge is doing this while maintaining a STANDARD validity definition.

**Key insight for a new approach**: The truth lemma currently proves `phi in fam.mcs t <-> bmcs_truth_at B fam t phi` by induction on `phi`. For the Box case with inner formula `G(psi)`, the forward direction goes: `Box(G(psi)) in fam.mcs t` implies (by `modal_forward`) `G(psi) in fam'.mcs t` for all `fam'`, then (by IH) `bmcs_truth_at B fam' t (G(psi))` for all `fam'`. The IH at `fam'` for `G(psi)` needs temporal coherence of `fam'`.

Could we instead prove that `G(psi) in fam'.mcs t` DIRECTLY implies the truth condition `forall s >= t, bmcs_truth_at B fam' s psi` without going through the IH? This would require a SEPARATE argument that MCS membership of `G(psi)` implies truth of `psi` at future times. But this is exactly what the truth lemma for `psi` at `fam'` provides... which requires the full IH.

**Verdict**: Path 1 requires a fundamentally different proof structure (not structural induction on the formula) or a different truth definition. The banned MCS-membership approach IS a valid way to break the cycle, but has been deliberately rejected.

#### Path 2: Non-Constant Temporally Coherent Witness Families

**Idea**: Instead of constant witness families for Diamond formulas, construct non-constant witness families that satisfy forward_F and backward_P.

**How it could work**: For each Diamond(psi) obligation in some family's MCS at some time t, build a full DovetailingChain-like FMCS where:
- `fam'.mcs 0` (or the relevant time point) contains `psi`
- `fam'` satisfies forward_F and backward_P

**Challenge**: Each such FMCS would inherit the 2 DovetailingChain sorries (forward_F, backward_P). Solving those sorries for even ONE family requires either:
- An omega-squared construction (estimated 20-40 hours)
- A tree-structured chain
- A completely new approach

**Key question**: Can we leverage the CanonicalMCS construction? For CanonicalMCS domain, each witness family could be the identity mapping `canonicalMCSBFMCS` with a different root. But as analyzed in research-009 Section 7, identity-mapping families all agree at every point, so there is no modal diversity -- `modal_backward` fails because all families map `w` to `w.world`.

**A critical insight I have NOT seen documented**: What if witness families over CanonicalMCS are NOT the identity mapping, but instead a SHIFTED identity? For each Diamond(psi) witness MCS W, define:

```
witness_family_W.mcs(v) = v.world    -- for all v except "the evaluation point"
```

No -- this still maps v to v.world, giving the same MCS at every point for every family, making them all equivalent.

**The real insight**: Over CanonicalMCS domain, we need witness families where `fam'.mcs(w)` for the same `w` can return DIFFERENT sets for different families. The identity mapping `fam.mcs(w) = w.world` makes all families identical. To get modal diversity, we need families like:

```
eval_family.mcs(w) = w.world
witness_family_W.mcs(w) = W.world    -- constant at W
```

But the constant family `mcs(w) = W.world` has the temporal coherence problem.

**Alternative**: Use a "pointed shift" family:

```
witness_family_W.mcs(w) = (compose some reindexing with w.world)
```

This is unexplored territory. The CanonicalR structure (a tree-like preorder) might allow creative reindexing. But this is speculative.

**Verdict**: Path 2 requires resolving the DovetailingChain sorries (hard) or finding a novel non-constant temporally-coherent witness family construction.

#### Path 3: Bypass BFMCS Entirely via FMP Strong Completeness

**Idea**: Extend the sorry-free FMP weak completeness to strong completeness using the `bigAnd(Gamma)` trick, completely avoiding the BFMCS construction.

**How it works**:
1. `semantic_consequence Gamma phi` means: in all models, if all of Gamma is true, then phi is true
2. For finite Gamma (List Formula), let `conj = bigAnd(Gamma)`
3. `semantic_consequence Gamma phi` implies `valid (conj.imp phi)` (standard argument)
4. By FMP weak completeness: `derives [] (conj.imp phi)`
5. Combined with `Gamma derives conj` (conjunction introduction): `Gamma derives phi`

**Challenge**: Requires implementing `bigAnd` (conjunction of a list), conjunction introduction/elimination, and the bridge between context satisfaction and conjunction truth. The deduction theorem already exists.

**Verdict**: Path 3 is the most promising for achieving sorry-free strong completeness with bounded effort (estimated 2-4 hours per research-009). It sidesteps the BFMCS construction entirely.

---

## Confidence Level

**HIGH confidence** in the factual findings (sorry locations, type signatures, architectural analysis). All key lemmas verified via lean_local_search. The codebase has been read comprehensively.

**HIGH confidence** that Path 3 (FMP strong completeness) is achievable with moderate effort.

**HIGH confidence** that the BFMCS temporal coherence + modal saturation combination problem (Gap A) is a genuine mathematical difficulty, not a formalization artifact. Twelve approaches have been tried over multiple tasks (812, 827, 843, 857, 881, 916, 922, 930, 932) and all have failed or been documented as dead ends.

**MEDIUM confidence** in the assessment that no novel BFMCS construction can solve Gap A. The design space for non-constant temporally coherent witness families is large and has not been exhaustively explored. However, the fundamental obstacle (F-formula non-persistence through GContent seeds) appears to be a genuine mathematical fact.

---

## Recommendations for Task 945

### Recommended Design: Pursue Path 3 (FMP Strong Completeness)

The canonical model construction for the TruthLemma already exists and works (the TruthLemma is sorry-free). The problem is NOT the TruthLemma -- it is the BFMCS construction that feeds it. Rather than finding a new BFMCS construction, bypass it entirely:

1. **FMP strong completeness** via `bigAnd(Gamma)` trick -- achievable, bounded effort
2. Accept that the BFMCS Int-indexed chain has known mathematical gaps (3 sorries)
3. The CanonicalMCS approach solves temporal coherence for a single FMCS but not for a full BFMCS

### If BFMCS Must Be Pursued

The only unexplored territory I can identify is:

**Idea: Per-formula-depth temporal coherence**

The truth lemma uses structural induction on `phi`. The Box case applies the IH to the SUBFORMULA of Box, which has strictly smaller depth. If we could stratify temporal coherence by formula depth:
- Families need temporal coherence only for formulas up to depth `d`
- The Box case at depth `d+1` only needs the IH at depth `d`
- Witness families for `Box(phi)` where `depth(phi) = d` need temporal coherence for formulas of depth `< d`

At depth 0 (atoms), temporal coherence is vacuous. This stratification might allow witness families to be temporally coherent "enough" without needing full F/P witnesses.

This idea is SPECULATIVE and may not pan out. It would require a reformulation of the truth lemma using well-founded induction on formula depth, with a depth-bounded temporal coherence requirement. The formalization complexity is unclear.

---

## File References

| File | Path | Sorry Count | Role |
|------|------|-------------|------|
| TruthLemma.lean | `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` | 0 | Sorry-free truth lemma |
| TemporalCoherentConstruction.lean | `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` | 1 | `fully_saturated_bfmcs_exists_int` (sorry) |
| DovetailingChain.lean | `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` | 2 | forward_F, backward_P (sorry) |
| Completeness.lean | `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | 0 | BFMCS completeness (sorry-free given construction) |
| Representation.lean | `Theories/Bimodal/Metalogic/Representation.lean` | 0 | Standard semantics bridge (sorry-free given construction) |
| BFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` | 0 | BFMCS structure definition |
| BFMCSTruth.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` | 0 | Standard truth definition |
| ModalSaturation.lean | `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` | 0 | Modal saturation infrastructure |
| CanonicalFrame.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` | 0 | canonical_forward_F/P (sorry-free) |
| CanonicalFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` | 0 | Sorry-free FMCS over CanonicalMCS |
| SemanticCanonicalModel.lean | `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | 0 | FMP weak completeness (sorry-free) |
| Construction.lean | `Theories/Bimodal/Metalogic/Bundle/Construction.lean` | 0 | Lindenbaum + constantBFMCS |
| FMCSDef.lean | `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` | 0 | FMCS structure definition |
