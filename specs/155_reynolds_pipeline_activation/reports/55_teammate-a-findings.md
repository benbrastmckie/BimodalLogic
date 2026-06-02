# Teammate A Findings: Primary Approach Analysis

## Task: 155 — Making `completeness_discrete` sorry-free
## Date: 2026-06-02

---

## Key Findings

### 1. The Dense Case Works Because of Cantor's Theorem — Not Because of Any Structural Property

The sorry-free `completeness_dense` proof succeeds for a specific mathematical reason: Cantor's theorem gives a **free** order isomorphism `LimitDomSubtype ≃o Rat`. This is possible because the dense chronicle construction produces a domain that is:
- Countable (union of finite stages)
- Densely ordered (when all MCSs contain F'T = ¬U(⊤,⊥))
- No min, no max

These four properties uniquely characterize Rat up to isomorphism. The Cantor isomorphism `iso` then makes the restricted coherence proofs trivial: every rational maps bijectively to a limit domain point, so `limit_F_resolution` witnesses map directly back.

The discrete case **cannot** use this trick. The discrete LimitDomSubtype is countable, discrete, no min, no max — but these properties do NOT uniquely characterize Z. A countable discrete linear order without endpoints could be Z, or Z+Z, or Z·Q, or any countable ordinal sum of copies of Z. The Z-isomorphism requires **IsSuccArchimedean** (every element is finitely many succ-steps from every other), which is exactly what's missing.

### 2. The Sorry Chain Is Real and Correctly Identified

```
completeness_discrete (Completeness.lean:309)
  → countermodel_discrete_reynolds (Transfer.lean:1203)
    → cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:1993)
      → succ_embed_surjective (ChronicleToCountermodel.lean:1667)
        → limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:790)
          → succ_cofinal (ChronicleToCountermodel.lean:776)
            → chronicle_gap_contradiction (ChronicleToCountermodel.lean:475) — SORRY
```

Note: Transfer.lean:1201 claims `countermodel_discrete_reynolds` "does NOT use IsSuccArchimedean" — this is **false**. The theorem body itself doesn't mention it, but the called lemmas `cantor_bfmcs_discrete_restricted_tc/fuc` both call `succ_embed_surjective` which uses it at line 1674. This is confirmed by `#print axioms completeness_discrete` showing `sorryAx`.

### 3. Two Fundamentally Different Paths Exist — Both Have Been Tried

**Path A (Current): Prove the chronicle IS succ-Archimedean (plans v50-v55)**

This tries to prove `chronicle_gap_contradiction` directly — showing that in the discrete case, the Burgess chronicle construction produces a single Z-orbit. All plans v50-v55 attempt this. The Z+Z counterexample (task 202) shows that `no_gaps_faithful` is FALSE for abstract Prior structures, but the question remains whether the specific Burgess construction avoids multi-orbit structures.

Plan v55 (frozen guard) claims that when C5 processes U(⊤,⊥) at a point, ⊥ enters the guard, preventing future insertions. This is plausible but the user is unconvinced. The concern: does the chronicle ACTUALLY process U(⊤,⊥) at every point, and does this guarantee the guard prevents ALL future insertions in the adjacent interval? The Burgess construction processes counterexamples in a specific order (C4/C5 alternating with a dovetail enumeration), and it's not clear that the U(⊤,⊥) processing happens early enough to freeze all intervals.

**Path B (Reynolds Theorem 14): Prove gaps don't occur at equivalence class boundaries**

This is Reynolds' ACTUAL proof strategy (Reynolds 1994, Section 7-8). It does NOT prove the chronicle is gap-free. Instead:
1. Define contemporaneous equivalence ~M on the chronicle
2. Use US expressive completeness to define a gap-detecting formula R
3. Use model surgery (replace bad interval by one representative class)
4. Prove temporal truth is preserved (Reynolds Lemma 12)
5. Derive contradiction: R holds in surgery model but the gap was removed

Task 202 report 13 ("blocker-analysis-correct-path.md") and report 17 ("deep-research-synthesis.md") document this approach in detail. The infrastructure is mostly built:
- `US_expressively_complete_over_prior` (sorry-free)
- `right_gap_class_formula` (defined)
- `no_boundary_at_successor` (sorry-free)
- `contemp_equiv_is_equiv` (sorry-free)

What's MISSING: the model surgery (Reynolds Lemmas 10-13) and formula correctness proof. Estimated ~700 lines. The 17th implementation cycle got blocked on De Bruijn index arithmetic (`eval_good_rel_lifted`), which is a fixable engineering problem.

### 4. Reynolds' Proof Structure (from the Paper)

Reynolds 1994 proves discrete completeness by:
1. **Corollary 3** (= Burgess): For any US/Z-consistent formula, there exists a countable, discrete, endpoint-free model satisfying Prior-UZ/SZ.
2. **Theorem 5** (US expressive completeness over Prior structures): U'(A,B) ≡ ⊥ in all Prior structures, so {U,S} is expressively complete.
3. **Theorem 14** (no gaps between equivalence classes): For any contemporaneous equivalence ~M on a Prior structure, classes don't end at gaps.
   - **Proof**: Lemmas 6-13 form a model surgery argument. Lemma 12 (truth preservation under surgery) is the bulk (~200 lines estimated in Lean).
4. **Theorem 15** (model replacement): For a countable discrete endpoint-free Prior structure with finite language, for all k, there exists a Z-flowed structure that is k-equivalent.
   - **Proof**: Define ~M as "M|[a,b] is very good" (i.e., all subintervals are good). This is contemporaneous. By Theorem 14, classes don't end at gaps. Since the order is discrete, class boundaries are at successor pairs. But all finite intervals are good (they're subintervals of Z), so adjacent classes can be glued — contradiction with having multiple classes. Hence M is good. Since M is countable, very good → good gives Z-equivalence via lexicographic sums.
5. **Theorem 18** (completeness): Compose: consistent formula → Burgess model → Theorem 15 gives Z-equivalent model → formula satisfiable on Z.

### 5. The Constant-MCS Problem

The sorry at `chronicle_gap_contradiction` has two cases (lines 497-509 of ChronicleToCountermodel.lean):
- **Case A** (limit_f differs at a and b): A distinguishing formula exists. Model surgery applies. This is the Reynolds path.
- **Case B** (constant MCS: limit_f(a) = limit_f(b)): No formula distinguishes a and b. All k-types are identical. contemp_equiv holds for all sig/k. The Z+Z counterexample IS this case — constant MCS at every point, yet two orbits.

The constant-MCS case is where Path A (chronicle-specific argument) is needed. Reynolds' Theorem 14 does NOT handle this case — it only says class boundaries don't end at gaps, but with constant MCS there's only ONE class (all points are contemp_equiv). The gap exists WITHIN the single class, between two succ-orbits with identical MCS assignments.

**This is the genuine hard problem.**

### 6. How to Actually Resolve This

There are three honest approaches:

**Approach 1: Build the model on Z directly, bypassing the chronicle embedding entirely.**

The dense case succeeds because it builds the BFMCS on Rat and uses the Cantor isomorphism. Could we build the BFMCS on Z directly?

Currently, `cantor_bfmcs_discrete` constructs the BFMCS by:
1. Running the Burgess chronicle construction (producing LimitDomSubtype ⊂ Rat)
2. Defining `succ_embed : Z → LimitDomSubtype` (strictly monotone)
3. Defining `rooted_succ_discrete_fmcs : FMCS Z` via `fam.mcs t = limit_f(succ_embed(t))`

The BFMCS on Z is well-defined EVEN IF succ_embed is not surjective. The issue is that the restricted coherence proofs (`cantor_bfmcs_discrete_restricted_tc/fuc`) use `succ_embed_surjective` to map limit_dom witnesses back to integers.

**The fix**: Rewrite the restricted coherence proofs to use `succ_embed_squeeze` instead of `succ_embed_surjective`. When `limit_F_resolution` gives a witness y ∈ limit_dom with x < y, we don't need to find an integer mapping exactly to y — we need to find an integer whose succ_embed is ≥ y's position. Since succ_embed is strictly monotone and the embedded points are cofinal in one direction (they extend to +∞ since the chronicle has no maximum), we can find m with `succ_embed(m) ≥ y`, then use the MCS at y transferring along the guard.

Wait — this doesn't work cleanly. The restricted temporal coherence needs: "F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)". Since fam.mcs(t) = limit_f(succ_embed(t)), F(φ) gives a witness y in limit_dom with succ_embed(t) < y. We need an integer s with t < s AND φ ∈ limit_f(succ_embed(s)). If succ_embed is not surjective, y might not be in the range, and φ might not persist to the next embedded point.

This approach needs the chronicle structure to guarantee that if φ ∈ limit_f(y) for some y between succ_embed(t) and succ_embed(t+1), then φ propagates to succ_embed(t+1). This is NOT guaranteed — the MCS can change between consecutive embedded points.

**Verdict: Approach 1 does not work without additional structure.**

**Approach 2: Complete the Reynolds model surgery (Path B from task 202).**

This follows Reynolds' actual proof. The mathematical content is well-understood, the infrastructure is largely built, and the remaining work is ~700 lines of Lean code implementing the model surgery. The main obstacles are:
- De Bruijn index arithmetic for `eval_good_rel_lifted` (fixable)
- Surgery truth preservation (200 lines, 30 subcases — laborious but not conceptually hard)

However, this only handles Case A (distinguishing formula exists). For Case B (constant MCS), the Reynolds surgery is vacuously satisfied — one class, no class boundaries, no gaps between classes. But the succ-Archimedean property can STILL fail within the single class.

Wait — re-reading Reynolds more carefully. Reynolds' Theorem 15 defines ~M as "very good" equivalence: a ~M b iff M|[a,b] is very good. His Lemma 17 shows this is contemporaneous. Then Theorem 14 says classes don't end at gaps. The final argument: if M is not good, then M is not very good, so there exist a < b with M|[a,b] not good. Hence a and b are in different ~M classes. But a's class can't end at a gap (Theorem 14), so it must include a point c where c's successor c+1 is NOT in a's class. But M|[c, c+1] (a finite structure) is trivially very good, so c ~M c+1, contradicting c+1 not being in a's class.

**THIS IS THE KEY INSIGHT.** The constant-MCS problem DOES NOT ARISE in Reynolds' proof, because his equivalence relation ~M is defined by "very goodness" of subintervals, NOT by k-type equality. Even if all MCS assignments are identical, two points a, b can still have a ~M b fail if M|[a,b] is not very good (contains a bad subinterval). The model surgery eliminates gaps at class boundaries, and then the discrete structure forces all classes to cover the whole domain.

**This means the Reynolds model surgery approach (Path B) IS sufficient to resolve the problem completely — including the constant-MCS case.** The trick is that Reynolds uses a DIFFERENT equivalence relation than k-type equivalence.

**Approach 3: Prove chronicle_gap_contradiction directly (Path A / plan v55).**

This requires showing the Burgess construction with discrete MCS (U(⊤,⊥) everywhere) produces a single Z-orbit. The frozen guard argument is the latest attempt. It's a chronicle-specific argument that doesn't follow the literature.

---

## Recommended Approach

**Follow Reynolds' actual proof (Approach 2/Path B), implementing the model surgery for `no_gaps_discrete` in GoodStructuresModelSurgery.lean.**

This is the mathematically honest approach that the user requested. It follows the literature step by step. The key insight is that Reynolds' contemporaneous equivalence relation ~M (defined by "very goodness" of subintervals) is the RIGHT equivalence relation — not k-type equivalence or chronicle-specific equivalence. This sidesteps the constant-MCS problem entirely.

### Why This Works Where Previous Plans Failed

Previous plans (v50-v55) tried to prove the chronicle is Z-isomorphic. Reynolds doesn't do this. Instead:
1. He proves that contemporaneous equivalence classes don't end at gaps (Theorem 14, via model surgery).
2. He concludes the structure is good (Theorem 15, via the finiteness of successor pairs + transitivity of ~M).
3. He gets a Z-equivalent structure (Lemma 16, via lexicographic sums of good subintervals).

The sorry at `chronicle_gap_contradiction` is trying to prove something STRONGER than needed. We don't need the chronicle to be Z-isomorphic. We need the contemporaneous equivalence classes to not end at gaps, which is what Reynolds' model surgery proves.

### Concrete Steps

1. **Close `gap_prior_UZ_contradiction` and `gap_prior_SZ_contradiction`** in GoodStructuresModelSurgery.lean (~700 lines, following the 11-piece plan from task 202 report 17).
2. **Wire `no_gaps_discrete`** to delegate to `no_gaps_discrete_model_surgery`.
3. **Verify the downstream chain**: `no_gaps_discrete` → `one_class` → `chronicle_is_good_direct` → `countermodel_discrete_reynolds` → `completeness_discrete`.

### Critical Observation About the Current Architecture

There is a **mismatch** in the current code: `completeness_discrete` uses `countermodel_discrete_reynolds` which goes through `cantor_bfmcs_discrete_restricted_tc/fuc` → `succ_embed_surjective` → `IsSuccArchimedean`. But the Reynolds pipeline (`no_gaps_discrete` → `one_class` → `chronicle_is_good_direct` → truth transfer) is a SEPARATE chain that does NOT use `succ_embed_surjective`.

The question is: **after closing `no_gaps_discrete`, does the sorry-free chain reach `completeness_discrete`?**

Looking at the code:
- `countermodel_discrete_reynolds` (Transfer.lean:1203) uses `cantor_bfmcs_discrete_restricted_tc/fuc` which use `succ_embed_surjective`.
- The Reynolds pipeline would produce a countermodel via a different path: chronicle → good structure → Z-interval → TaskFrame.
- But task 202 found this path BLOCKED by the WorldState/TaskFrame packaging mismatch (Transfer.lean).

So closing `no_gaps_discrete` makes the mathematical content sorry-free but does NOT directly close the sorry in `completeness_discrete`. The sorry chain goes through `succ_embed_surjective`, which needs `IsSuccArchimedean`, which needs `succ_cofinal`, which needs `chronicle_gap_contradiction`.

**This means we need EITHER:**
- (a) Close `chronicle_gap_contradiction` (the current sorry) — which requires proving IsSuccArchimedean for the chronicle, OR
- (b) Reroute `completeness_discrete` to use the Reynolds pipeline output instead of `cantor_bfmcs_discrete_restricted_tc/fuc`, which requires solving the TaskFrame packaging problem from task 202.

Neither path is simple. Path (a) is what plans v50-v55 attempt. Path (b) is what task 202 attempted and found blocked.

**However**, there's a third option: **(c) Prove `succ_embed_surjective` using the Reynolds model surgery results, rather than via `chronicle_gap_contradiction`.** If `no_gaps_discrete` is proved, then `one_class` follows, meaning all points in the chronicle are contemp_equiv (k-type equivalent for all k). This means M is "very good" (all subintervals are good). "Very good" implies "good" (sorry-free). "Good" + countable implies M ≃o Z-interval (sorry-free, via Lemma 16). This Z-isomorphism IS the succ-Archimedean property.

So the path would be:
```
no_gaps_discrete (close via model surgery)
  → one_class (follows)
    → M is very good (follows from one_class_implies_very_good, sorry-free)
      → M is good (follows from very_good_implies_good, sorry-free)
        → M ≃o Z (follows from countable + good, Lemma 16)
          → IsSuccArchimedean (follows from Z-isomorphism)
            → succ_embed_surjective (follows)
              → cantor_bfmcs_discrete_restricted_tc/fuc (follows)
                → completeness_discrete (follows)
```

**THIS is the correct architecture.** The Reynolds model surgery closes `no_gaps_discrete`, which cascades through `one_class` → `very_good` → `good` → Z-isomorphism → IsSuccArchimedean → succ_embed_surjective → completeness_discrete.

## Evidence/Examples

1. **Reynolds 1994, Theorems 14-15**: The paper explicitly proves discrete completeness via model surgery + very-goodness equivalence, not by direct Z-embedding.
2. **Dense completeness (sorry-free)**: Shows the parametric canonical model approach works when you have an order isomorphism to the target domain.
3. **Task 202 report 13**: Correctly identifies Path B as the right approach, with `no_gaps_discrete` as the key sorry.
4. **Task 202 report 17**: Provides a detailed 11-piece implementation plan for the model surgery, estimated ~700 lines.
5. **Z+Z counterexample**: Shows that abstract `no_gaps_faithful` is false, but `no_gaps_discrete` (Reynolds Theorem 14) IS true because it's about class boundaries, not about the domain being gap-free.

## Confidence Level

**High** for the mathematical analysis and the identification of the Reynolds model surgery as the correct approach.

**Medium** for the estimate that the implementation will succeed — the model surgery is ~700 lines of non-trivial Lean code, and previous implementation attempts got blocked on De Bruijn index issues. But these are engineering problems, not mathematical obstacles.

The critical insight is that closing `no_gaps_discrete` via Reynolds' model surgery cascades through existing sorry-free infrastructure (`one_class` → `very_good` → `good` → Z-isomorphism → IsSuccArchimedean) to close the entire chain. This means the current `completeness_discrete` wiring through `succ_embed_surjective` IS the right architecture — it just needs the upstream sorry (`no_gaps_discrete`) to be closed.
