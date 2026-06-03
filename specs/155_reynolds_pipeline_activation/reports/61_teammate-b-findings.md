# Teammate B Findings: Alternative Approaches for chronicle_gap_contradiction

**Task**: Eliminate all sorries from `completeness_discrete`
**Focus**: Blocker 2 — `chronicle_gap_contradiction` and the constant-MCS case
**Researcher**: Teammate B — Alternative Approaches

---

## Key Findings

### 1. The sorry chain structure (current state)

The `sorryAx` in `completeness_discrete` does NOT flow through `chronicle_gap_contradiction` as of the current codebase. The Completeness.lean audit comment at line 388 is outdated. The actual sorry chain for `completeness_discrete` is:

```
completeness_discrete
  → countermodel_discrete_reynolds (Transfer.lean:1203)
    → cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:1992)
      → succ_embed_surjective (ChronicleToCountermodel.lean:1666)
        → limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:789)
          → succ_cofinal (ChronicleToCountermodel.lean:773)
            → chronicle_gap_contradiction [sorry]
```

However, the code at line 1673 (`letI := limitDomSubtype_isSuccArchimedean fc A h_mcs h_fc h_discrete`) still invokes the dead-code path. The docstring at lines 811-817 claims `succ_embed_surjective` uses the axiom directly, but the actual Lean code at line 1673 still invokes `limitDomSubtype_isSuccArchimedean` (the sorry-carrying definition), not a named axiom. No declaration named `limitDomSubtype_isSuccArchimedean_axiom` exists anywhere in the codebase — it appears only in comments, indicating the axiom bypass described in the documentation was never actually implemented.

**Critical implication**: The sorry at `chronicle_gap_contradiction` remains the root blocker for `completeness_discrete`. The `succ_embed_surjective` path is still live and still depends on the sorry chain.

### 2. What Reynolds 1994 actually does (Theorem 15, Section 8)

Reynolds does NOT prove `IsSuccArchimedean` directly. The proof in Section 8 (pages 130-131) proceeds as follows:

1. Define contemporaneous equivalence `~M` on M by: a ~M b iff every subinterval [t,u] ⊆ [min(a,b), max(a,b)] is "good" (≡k some interval of Z).

2. Lemma 17 shows `~M` is a contemporaneous equivalence relation (transitivity uses lexicographic sums of good structures).

3. By Theorem 14 (no gaps): `~M` classes do not end at gaps (the one_class machinery in the Lean formalization).

4. The key argument at page 131 (bottom): "If M is good then we are done. So suppose not. Thus M is not very good. So there is a < b ∈ M such that M⌈a,b is not good. Thus M⌈a,b is not very good and we have two disjoint ~M classes. Now a's class cannot end at a gap on the right (by Theorem 14) so it must include a point c but not the successor c+1 of c. This cannot be because M⌈c,c+1, like all finite structures, is very good and ~ is transitive."

This is the **one_class theorem** argument. Reynolds reaches the Z-model not by proving the chronicle is isomorphic to Z, but by showing every bounded interval is ≡k some interval of Z, then using lexicographic sums (Lemma 16). The `IsSuccArchimedean` property of the chronicle is a **corollary** of one_class, not a premise.

### 3. The one_class → very_good → good pipeline exists and is sorry-free

The Lean formalization has the full Reynolds pipeline already proved:

- `one_class` (NoGapsDiscreteProof.lean): sorry-free, proven via `no_gaps_discrete_model_surgery`
- `one_class_implies_very_good` (ShiftAndGlue.lean:919): sorry-free
- `very_good_implies_good` (ShiftAndGlue.lean:831): sorry-free
- `chronicle_is_good_direct` (ShiftAndGlue.lean:950): sorry-free, uses Reynolds pipeline without IsSuccArchimedean

The path `chronicle_is_good_direct` gives: for any ChronicleAsPriorModel with semantic_prior_UZ/SZ, the chronicle is "good" at any depth k. "Good" means ≡k-equivalent to an interval of Z.

### 4. Why `succ_embed_surjective` still needs IsSuccArchimedean

`succ_embed_surjective` (line 1666) proves that the succ-based embedding ℤ → LimitDomSubtype is surjective. It calls `exists_succ_iterate_of_le` at line 1694, which is precisely the `IsSuccArchimedean.exists_succ_iterate_of_le` field. The proof structure:

- Given w : LimitDomSubtype, case-split on root ≤ w vs w < root
- Use IsSuccArchimedean to get n with succ^[n](root) = w

This IS the place where IsSuccArchimedean is consumed. The sorry is not in succ_embed_surjective itself but in the `limitDomSubtype_isSuccArchimedean` definition it uses.

### 5. The constant-MCS case: what it means and why it blocks

The `chronicle_gap_contradiction` proof (line 472) has two sub-cases:

**Case A (line 501)**: `limit_f(a.val) ≠ limit_f(b.val)`. This case has a substantial inline proof sketch using `gap_contradicts_prior`. The sorry at line 741 is in a subroutine needed by the non-equiv proof: showing that `contemp_equiv sig 0 M a b` is false. The comment notes that depth 0 only checks quantifier-free sentences without free variables, so depth 0 is trivially true for everything — need depth k ≥ 1.

**Case B (line 499)**: `limit_f(a.val) = limit_f(b.val)`. This is the constant-MCS case. The comment (lines 495-502) says: "A proof that constant MCS + chronicle structure implies the succ-orbit covers the domain (making this case vacuously false) requires induction on the omega-chain construction." This case is marked sorry with the note that the Z+Z counterexample shows it cannot be resolved by abstract model surgery alone.

### 6. The Z+Z counterexample and why it falsifies the PriorModelData approach

The `ReynoldsModelSurgery.lean` documentation (lines 310-327) explicitly marks `no_gaps_faithful` as FALSE and explains why: two copies of Z with constant MCS at every point satisfy all `PriorModelData` hypotheses yet have a Dedekind gap. The gap is non-definable by any temporal formula, consistent with Reynolds Theorem 5 (no definable gaps). This is why the abstract approach `no_gaps_faithful` → `prior_model_is_succ_archimedean` is a dead end.

### 7. Commented-out proof evaluation

The commented-out proof (lines 488-762) is long (275 lines) and partially complete. The Case A proof is elaborate but contains the sorry at line 741 (depth-0 problem). The Case B proof is a single sorry at line 500. The symmetric sub-case of Case A (lines 745-761) is also sorryed "for brevity."

Fixing the commented-out proof requires at minimum:
1. Fixing the depth-0 issue (use k ≥ 1 in the contemp_equiv application)
2. Proving Case B (constant-MCS implies succ-orbit covers domain)
3. Completing the symmetric Case A sub-case

### 8. Can coherence conditions (restricted_tc, restricted_fuc) be proved WITHOUT succ_embed_surjective?

The proofs of `cantor_bfmcs_discrete_restricted_tc` (line 1992) and `cantor_bfmcs_discrete_restricted_fuc` (line 2048) both call `succ_embed_surjective` (at lines 2012, 2028, 2065, 2096). These are used to convert domain witnesses (in LimitDomSubtype) back to integer witnesses. Without surjectivity, the witnesses stay in LimitDomSubtype and cannot be expressed as integers, breaking the BFMCS construction.

**Alternative**: Could use `discrete_embed` (the forward-only embedding ℤ → LimitDomSubtype built from `NoMaxOrder`/`NoMinOrder` iterated choice) and prove the coherence conditions using monotonicity of `discrete_embed` without surjectivity. But this would require that the C5 witnesses from `limit_satisfies_c5_strong` land on `discrete_embed`-embedded points, which is not guaranteed without a surjectivity argument.

---

## Recommended Approach

### Reynolds Bypass (highest confidence)

Reynolds' actual proof (Section 8, Theorem 15) does not prove IsSuccArchimedean at the chronicle level. It proves that M is "good" (≡k some interval of Z), then uses this goodness to build the Z-model via lexicographic sums. The Lean formalization already has this pipeline completely proved in `chronicle_is_good_direct` (ShiftAndGlue.lean:950).

The remaining work is to USE `chronicle_is_good_direct` to build the coherence conditions for `cantor_bfmcs_discrete` WITHOUT going through `succ_embed_surjective`. The specific steps:

1. **Show that for any two consecutive elements a, a+1 in the embedding, the MCS assignments agree on a good Z-interval** — this would give the temporal coherence (restricted_tc) and Until/Since coherence (restricted_fuc) directly from the goodness of the chronicle.

2. **Alternative to succ_embed_surjective for restricted_tc**: The forward direction needs: F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s). Currently this uses `limit_F_resolution` (finds a domain witness y) then `succ_embed_surjective` (converts y to integer m). An alternative: since `succ_embed` is strictly monotone and covers the image densely (no gaps between consecutive succ-embed values when U(T,bot) holds everywhere), any domain point y between succ_embed(t+offset) and succ_embed(t+offset+1) cannot exist by `succ_embed_no_gap`. But y might equal one of the boundary points. The key lemma needed is: in the discrete case, any domain point IS a succ_embed value. This IS succ_embed_surjective — circular.

3. **Omega-chain induction approach**: `succ_reaches_dom_N` (lines 98-398) attempts to prove that every domain point is reached by succ iteration from a stage-N point. The induction in the succ case (Case 3, line 119) has a sorry at line 392 for the "below-min boundary" case. If this case could be proved, the entire chain would follow without needing abstract gap elimination.

The most promising path that does NOT require proving IsSuccArchimedean via abstract means:

**Path: Directly prove succ_embed_surjective via omega-chain stage induction**

Every element of `limit_dom` arrives in some stage of the omega_chain construction. At stage N, the only new element `w` added is the MCS satisfying C5 for the current frontier. This element is the unique successor of the previous stage's maximum. Therefore, by induction, every element of `limit_dom` is reachable by finitely many succ steps from the root.

The sorry at line 392 (below-min boundary in `succ_reaches_dom_N`) is the precise missing piece. The claim is: if a.val < min(dom(N)), then we can still show succ^[k](a) = b for some k by using properties of the omega_chain construction. This requires knowing how new elements are inserted relative to existing ones.

### Fix the depth-0 issue in Case A (secondary, if omega-chain approach works)

The sorry at line 741 is about showing that `contemp_equiv sig 0 M a b` is False when `ψ ∈ limit_f(a.val)` and `ψ ∉ limit_f(b.val)`. The comment says depth 0 only checks closed sentences (no free variables), so `contemp_equiv sig 0 M a b` is trivially true — not useful. The fix: use depth k = 1 or higher where predicates at individual points matter. At depth 1, `contemp_equiv sig 1 M a b` means every sub-interval [min(a,b), max(a,b)] restricted to between any two elements satisfies the same monadic sentences of depth ≤ 1. At depth 1, atomic sentences like ψ ∈ limit_f(-) ARE checked. Changing `0` to `1` throughout the Case A proof would fix this issue.

---

## Evidence/Examples

### Reynolds 1994 Theorem 15 bottom (p.131)

"Now a's class can not end at a gap on the right (by theorem 5 and the fact that Prior-UZ and dual imply Prior-U and dual) so it must include a point c but not the successor c + 1 of c. This can not be because M⌈c, c + 1, like all finite structures, is very good and ~ is transitive."

This is the one_class argument. Reynolds concludes IsSuccArchimedean (or equivalently, that succ-iterates are cofinal) as a direct consequence of one_class + no-gaps, not as an independent proof.

The Lean formalization already encodes this logic in `chronicle_is_good_direct`. The gap is in connecting this goodness result to the BFMCS coherence machinery.

### Reynolds 1994 Lemma 16 (lexicographic sums)

Lemma 16 (p.130) states: if N is countable and very good then it is good. The proof uses lexicographic sums of good bounded sub-structures to build a structure ≡k to an interval of Z. This is precisely `very_good_implies_good` in ShiftAndGlue.lean.

### The omega-chain insertion property

From `ChronicleConstruction.lean` (line 1004), the chronicle omega-chain construction adds at each stage N+1 a new point between consecutive existing points, or beyond the current max/below the current min. The proof of `succ_reaches_dom_N` handles "both in dom(N)" (IH) and "both new at N+1" (unique new element). The failing case "a ∈ dom(N), b = new at N+1 but below min(dom(N))" requires showing that the new point added below the minimum is reachable from a. This requires knowing where below the minimum the new point is inserted and that it is exactly pred(current_min), not some arbitrary new minimum.

---

## Confidence Level: Medium

The core finding — that the sorry chain is through `succ_embed_surjective` → `limitDomSubtype_isSuccArchimedean` → `succ_cofinal` → `chronicle_gap_contradiction` — is HIGH confidence (directly traced in code). The assessment that the depth-0 issue can be fixed by using k=1 is HIGH confidence (the comment in the code explains the problem exactly). The assessment that the omega-chain induction approach can prove `succ_reaches_dom_N` is MEDIUM confidence — the stage-N below-boundary case has been attempted before (per the DEAD APPROACH comment at line 391) and found difficult, but the analysis above suggests it may be tractable with the right invariant about omega_chain construction. The claim that the one_class pipeline can bypass succ_embed_surjective is LOW confidence — a concrete construction would be needed.

**Summary of prioritized recommendations**:

1. **Highest priority**: Prove `succ_reaches_dom_N` Case 3b (below-min boundary) via omega-chain properties. This would complete the stage-induction proof of IsSuccArchimedean without abstract model surgery, and would remove the sorry from `limitDomSubtype_isSuccArchimedean` entirely.

2. **Secondary**: Fix the depth-0 issue in Case A of `chronicle_gap_contradiction` (change k=0 to k=1 and verify the contemp_equiv argument works). Then Case A becomes a viable proof path.

3. **Tertiary**: Prove Case B (constant-MCS implies succ-orbit cofinal) via a separate chronicle-specific invariant showing that constant-MCS at all points is impossible given the C5 construction (each stage adds a new MCS satisfying a non-trivial C5 requirement), or showing that constant-MCS and the h_orbit_bounded hypothesis combine to give a contradiction via Z1/Prior-UZ.
