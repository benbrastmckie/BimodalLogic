# Task 303: Critic Analysis — k>0 Depth Induction for `existPart_succ_n1_bypass`

**Role**: Teammate C (Critic)
**Date**: 2026-06-16
**Focus**: Gaps, false assumptions, and blind spots in proposed research approaches

---

## Summary of Verified Facts

Before listing concerns, here is what the code actually shows (ground truth):

1. **Single active sorry on the discrete path**: `KampBypass.lean:104` (`sorry` in the `succ k'` case of `existPart_succ_n1_bypass`). This is the SOLE `sorryAx` blocking `completeness_discrete`. The axiom audit at `Completeness.lean:367` confirms this unambiguously.

2. **`nf_exist_backward_prior` (NfCharFormula.lean:542)** also has a `sorry`, but it is NOT on the critical path. The code at `NfCharFormula.lean:641-650` explicitly bypasses it: depth 1 uses `existPart_succ_n1_bypass_k0` directly, and depth k+2 uses `existPart_succ_n1_bypass`. The `nf_exist_backward_prior` sorry is dead code for the discrete completeness goal.

3. **`stavi_expressive_completeness` and its sorry chain are NOT on the discrete completeness path.** `PriorExpressiveness.lean:338-340` explicitly states: "the sole consumer of `stavi_expressive_completeness` was this theorem, and it now uses `kamp_prior_expressive_completeness` instead." The Stavi path is fully bypassed.

4. **The k=0 bypass used ~4446 lines** (KampBypassCore.lean: 2160 lines, KampBypassUntil.lean: 979 lines, KampBypassSince.lean: 1307 lines). The current sorry is the one-liner `sorry` at `KampBypass.lean:104` in the `succ k'` case. The entire k=0 infrastructure becomes the template.

5. **The RabinovichPath/ was archived as dead code (task 302, 2026-06-16)**, not because it was mathematically wrong. The `RabinovichGeneralized.lean` file (now in Boneyard) was a generalized mutual induction approach — it had the same sorry at the same place (`existPart_succ` at line 471), but with additional scaffolding. It was archived because it had no live downstream consumers in its current form, not because its approach was incorrect.

---

## Key Findings

### Finding 1: The 200-400 Line Estimate Is Almost Certainly Wrong (CONFIDENCE: HIGH)

**Concern**: The task claims 200-400 lines for the k>0 case. The k=0 case required 4446 lines split across three files.

**Evidence**: The k=0 bypass is complex because it must:
- Encode depth-0 3-var existentials as temporal formulas using zone decomposition (VecEADecomp, ZoneBridge)
- Handle 5 distinct YZone classifications (below_t, eq_t, between_tx, eq_x, above_x)
- Verify y-t order faithfully (the v1 formula was defective and had to be replaced)
- Handle three separate sub-cases (Until, Since, equality) each with pre-conditions + enriched_point_type

**For k>0**, the `sub_nf : NormalForm sig (k+1) 2` has a quantifier component `sub_nf.2 : NormalForm sig k 3 → Bool`. At k=0, `NormalForm sig 0 3` is purely atomic (no quantifiers), so the 3-var conditions reduce to predicate + order checks. At k>0, `NormalForm sig k 3` has its OWN quantifier component, meaning each `ssn` in the quantifier profile itself encodes nested existentials `∃ z, nf_eval_nf M (k-1) 4 [z,y,x,t] ssn'`.

**The depth-0 zone strategy cannot directly extend to depth k>0** because:
- At depth 0, `depth0_3var_exist_formula_v1` encodes `∃ y` using Since/Until to find y in a zone
- At depth k>0, we need `∃ y, nf_eval_nf M k 3 [y,x,t] ssn` — but `ssn : NormalForm sig k 3` is NOT purely atomic
- Finding the formula for `∃ y, nf_eval_nf M k 3 [y,x,t] ssn` requires ANOTHER bypass application at arity 3 and depth k

**This is the ExistPart(k) → ExistPart(k+1) inductive step for n≥2 cases, which the archived `RabinovichGeneralized.lean` explicitly identified as "sorry — depends on n=1 case" (line 471).** The n=1 bypass is the prerequisite, not the complete solution.

**Revised estimate**: The k>0 bypass, if it follows the same zone-encoding approach at depth k, likely requires:
- A new `NormalForm sig k 3` → Formula encoding (analogous to `depth0_3var_exist_formula` but at depth k)
- This encoding requires `char_k` for (k-1)-var NFs, plus zone analysis at depth k
- The same 5-zone structure, same Until/Since pre-condition apparatus

A conservative estimate is 2000-4000+ lines, not 200-400.

### Finding 2: The "Second Sorry Chain" Concern Is Invalid (CONFIDENCE: HIGH)

**Concern from task**: Does the Stavi sorry chain block anything?

**Finding**: It does not. `PriorExpressiveness.lean` bypasses `stavi_expressive_completeness` entirely. `US_expressively_complete_over_prior` delegates directly to `kamp_prior_expressive_completeness` (line 359), which in turn depends on `existPart_succ_n1_bypass`. The Stavi sorries at `StaviCompleteness.lean:2421, 2503, 2871` are NOT on the `completeness_discrete` path.

**The single sorry chain is**:
```
completeness_discrete
→ countermodel_discrete_reynolds_v2
→ limitdom_is_good (GoodStructuresModelSurgery)
→ no_gaps_discrete_model_surgery
→ US_expressively_complete_over_prior
→ kamp_prior_expressive_completeness
→ nf_characterizable_temporal_prior (KampPrior.lean)
→ nf_characterizable_temporal_prior_classical (NfCharFormula.lean)
→ nf_2var_exist_formula_prior (NfCharFormula.lean)
→ existPart_succ_n1_bypass (KampBypass.lean:104) ← SOLE BLOCKER
```

### Finding 3: The `nf_exist_backward_prior` Sorry Is Dead Code (CONFIDENCE: HIGH)

**Concern from task**: Does closing the KampBypass sorry also close the NfCharFormula sorry?

**Finding**: They are independent AND the NfCharFormula sorry is already dead code. `NfCharFormula.lean:636-650` shows the 3-case match:
- `k = 0`: uses `nf_2var_exist_depth0_tl` (sorry-free)
- `k = 1`: uses `existPart_succ_n1_bypass_k0` directly (sorry-free, bypasses k>0)
- `k + 2`: uses `existPart_succ_n1_bypass` (the one sorry)

The `nf_exist_backward_prior` theorem at line 503 is a `private theorem` whose `sorry` at line 542 is NOT called by `nf_2var_exist_formula_prior` — that theorem uses a different structure. The relevant sorry is only in `KampBypass.lean:104`.

### Finding 4: Type-Level Mismatch Creates a Structural Gap (CONFIDENCE: HIGH)

**The core mathematical problem with a naive inductive approach**:

At k>0, `existPart_succ_n1_bypass` for `sub_nf : NormalForm sig (k+1) 2` must produce a temporal formula for:
```
∃ x, nf_eval_nf M (k+1) 2 [x,t] sub_nf
  ≡ (∀ a, atom_eval [x,t] a ↔ sub_nf.1 a) ∧
    (∀ ssn : NormalForm sig k 3, (∃ y, nf_eval_nf M k 3 [y,x,t] ssn) ↔ sub_nf.2 ssn)
```

The quantifier part requires encoding `∃ y, nf_eval_nf M k 3 [y,x,t] ssn` for each `ssn : NormalForm sig k 3`. This is a **3-variable existential at depth k with base [x,t]** — NOT the standard 2-variable existential at depth k with base [t].

The k=0 bypass handles this because at depth 0, `NormalForm sig 0 3` is purely atomic — there are no inner quantifiers, so zone classification suffices. At depth k>0:
- `NormalForm sig k 3` has quantifier data `ssn.2 : NormalForm sig (k-1) 4 → Bool`
- Encoding `∃ y` requires a 4-variable existential at depth k-1: `∃ z, nf_eval_nf M (k-1) 4 [z,y,x,t] ssn'`
- This requires ExistPart at arity 4 and depth k-1

**This is the "arity-climbing" problem from `RabinovichGeneralized.lean:464-468`**, which was explicitly noted as requiring the same root blocker as n=1. The n=1 bypass (what task 303 targets) is NECESSARY but NOT SUFFICIENT unless the quantifier profile encoding can reduce arity-n back to arity-2.

### Finding 5: The Prior Composition Property Is the Mathematical Heart (CONFIDENCE: HIGH)

**The `nf_exist_backward_prior` sorry comment (NfCharFormula.lean:524-541) describes the actual mathematical requirement**:

> "To recover nf_eval_nf M (k+1) 2 [x,t] sub_nf: (b) Quantifier conditions: for each ssn, (∃ y, nf_eval_nf M k 3 [y,x,t] ssn) ↔ sub_nf.2 ssn. Part (b) requires the Prior composition property: On Prior structures, the depth-k 3-var NF of (y,x,t) is determined by x's depth-(k+1) 1-var NF (nf_x) + t's predicates (parent_atoms) + y's position + Prior-UZ/SZ."

This is the **Feferman-Vaught composition for Prior linear orders** — a non-trivial result that says knowledge of x's 1-variable NF plus the structure of the Prior intervals suffices to determine all 3-variable NFs.

**Question for implementer**: Is this composition property actually provable from the existing infrastructure (`semantic_prior_UZ`, `semantic_prior_SZ`)? The comment says "this is the content of Feferman-Vaught composition for Prior linear orders" but doesn't cite a specific lemma. The k=0 bypass works WITHOUT this property because depth-0 3-var NFs are purely atomic. At k>0, this property is needed but may require new lemmas not in the current infrastructure.

### Finding 6: The Boneyard Evidence Confirms the n≥2 Dependency (CONFIDENCE: HIGH)

**From `RabinovichGeneralized.lean` (archived 2026-06-16)**:

The file was archived as "Dead code — Rabinovich approach path with no live downstream consumers." It was NOT archived because the mathematics was wrong. The structure it had was correct but incomplete:
- `existPart_succ` at line 399 correctly identifies the n=1 case delegating to `existPart_succ_n1_bypass`
- The n≥2 case at line 471 was `sorry` with comment: "depends on n=1 case — same root blocker"

**This confirms**: Even after closing the n=1 sorry in `KampBypass.lean`, there remains a separate sorry for the n≥2 case in the mutual induction. The task description frames this as "the SOLE remaining sorry blocking `completeness_discrete`" — this appears correct (since the n≥2 case is NOT on the live critical path to `completeness_discrete`), but implementers should be aware that the full Kamp proof for all arities remains incomplete.

### Finding 7: Additional Active Sorries Not on the Discrete Path (CONFIDENCE: MEDIUM)

**The following sorries exist but are NOT blocking `completeness_discrete`**:

| File | Sorries | Status |
|------|---------|--------|
| `Bundle/UntilSinceCoherence.lean` | 2 | Not on discrete path (dense case only) |
| `Bundle/SuccExistence.lean` | 3 | Not on discrete path |
| `Bundle/SuccRelation.lean` | 7 | Not on discrete path |
| `StaviCompleteness.lean` | 3 | Bypassed by Kamp path |
| `OrderedSum.lean` | 1 | Dense case only |
| `Expressiveness/SplitPoint.lean` | 0 actual | Comments only |
| `ChronicleToCountermodel.lean` | Multiple | Dead code (explicitly marked) |
| `Theorems/ModalS5.lean` | 1 | Unrelated to completeness_discrete |

**None of these affect `completeness_discrete`**. But if the user later targets `completeness` (the full theorem, not just discrete), the Bundle and Chronicle sorries become relevant.

---

## Recommended Approach

Given these findings, the implementer should:

1. **Recalibrate scope**: The 200-400 line estimate assumes the k>0 bypass is structurally identical to k=0. It is not — the quantifier profile encoding is genuinely harder. Plan for 1000-3000+ lines.

2. **Identify the key lemma**: The bypass for k>0 needs a lemma that says: "Given x's depth-(k+1) 1-var NF (`nf_x : NormalForm sig (k+1) 1`), the 3-var depth-k existential `∃ y, nf_eval_nf M k 3 [y,x,t] ssn` is determined by `nf_x.2 ssn'` for appropriate 2-var sub-NFs." This is the composition property and is the mathematical crux.

3. **Check whether the zone approach scales**: The k=0 bypass uses zone decomposition (5 YZone cases) to encode 3-var existentials. Verify whether the same zone structure applies at depth k — specifically, whether `∃ y, nf_eval_nf M k 3 [y,x,t] ssn` can be expressed via Since/Until formulas at x using `char_k` for depth-k 1-var NFs.

4. **Do NOT assume `nf_exist_backward_prior` is the target**: The `sorry` at `NfCharFormula.lean:542` is private and dead. The real target is `KampBypass.lean:104`.

5. **Verify the n≥2 dependency is truly dead**: The `completeness_discrete` axiom audit says the sole blocker is `existPart_succ_n1_bypass`. If n≥2 is needed for the n=1 proof (as a helper lemma), the n≥2 sorry becomes a secondary blocker. The archived `RabinovichGeneralized.lean:457-471` suggests n≥2 "depends on n=1" as a prerequisite, not the reverse — but confirm this direction holds in the bypass approach.

---

## Evidence Summary

| Claim | Evidence Location | Confidence |
|-------|-------------------|------------|
| Sole sorry is KampBypass.lean:104 | Completeness.lean:367 | HIGH |
| Stavi chain is bypassed | PriorExpressiveness.lean:338-340 | HIGH |
| nf_exist_backward_prior is dead | NfCharFormula.lean:636-650 | HIGH |
| k>0 needs 3-var existential encoding | KampBypassCore.lean:37 | HIGH |
| Depth-0 zone approach fails for k>0 | KampBypassCore.lean:82-84 | HIGH |
| RabinovichPath archived as dead, not wrong | Boneyard/RabinovichPath/RabinovichGeneralized.lean:1-3 | HIGH |
| n≥2 sorry exists but not blocking | Boneyard/RabinovichPath/RabinovichGeneralized.lean:471 | MEDIUM |
| 200-400 line estimate too low | KampBypassCore/Until/Since.lean sizes (4446 total) | HIGH |
