# Teammate C (Critic) Findings -- Task 273 Encoding Flaw Fix Approaches

**Date**: 2026-06-15
**Role**: Critic -- gaps, soundness issues, and blind spots in proposed approaches
**Session**: sess_1750006800_critic_c

---

## Key Findings

### Finding 1: Report 36's "Approach C" (Individual Bounded Until) Mis-States the Formula Semantics

**Risk**: HIGH
**Confidence**: HIGH

Report 36 (literature bracket proof) proposes per-SSN bounded Until formulas:
```
seg_guard Until (char_y(ssn_i) AND (seg_guard Until char_1(nf_x)))
```

In Lean, `Formula.untl event guard` means `exists s > t, event(s) AND forall r in (t,s), guard(r)` (Truth.lean:128-129). So `Formula.untl (char_y.and (Formula.untl char_1_nfx seg_guard_f)) seg_guard_f` at t means:

```
exists y > t, [char_y(y) AND (exists x' > y, char_1_nfx(x') AND forall r in (y, x'), seg_guard(r))]
  AND forall r in (t, y), seg_guard(r)
```

This says: "there exists y > t with char_y(y), seg_guard on (t,y), and then there exists SOME x' > y with char_1(nf_x) at x' and seg_guard on (y, x')."

**The critical problem**: x' is NOT the x from the outer existential in the proof. It is a FRESH existential witness. There is no guarantee that x' = x (the actual outer witness from the Until case). In the forward direction, when we have this formula holding at t, we extract:
1. A witness y with char_y(y) and seg_guard on (t, y)
2. A witness x' > y with char_1(nf_x) at x' and seg_guard on (y, x')

But the proof needs witnesses in the interval (t, x) for a SPECIFIC x that is the outer existential. The formula's x' is an inner existential -- it could be ANY point satisfying char_1(nf_x) after y. If there are multiple points satisfying char_1(nf_x), x' might not equal the x from `endpointRight`.

**Impact on forward direction**: When reconstructing nf_eval from the formula, we get y in (t, x') for SOME x' satisfying char_1(nf_x). But `enriched_bypass_until` packages everything as a VVecEA2 with endpointRight at a specific x, and the between_tx zone means `t < y < x`. If x' != x, we cannot place y in the correct zone.

**Counter-argument**: The formula is supposed to be evaluated WITHIN the context of `holdsLeft`, where x is already fixed as the Until witness. The `endpointRight` at x gives `char_1(nf_x)` at x. So x satisfies char_1(nf_x). The bounded Until gives x' also satisfying char_1(nf_x). If we can show x = x' (or at least y < x), the forward direction works.

**But**: We CANNOT show x = x'. And we cannot show y < x from the nested Until alone. The nested Until gives y > t and x' > y with char_1(nf_x) at x'. There is no constraint forcing y < x. The x' from the inner Until might be a DIFFERENT point than x.

**Conclusion**: Approach C has a forward-direction soundness gap. The nested Until does not guarantee that the inner witness x' matches the outer x from the VecEA2. Report 36 states "This completely avoids the ordering problem" (line 275) but introduces a DIFFERENT problem: witness identity.

---

### Finding 2: The Current Encoding (Formula.snce char_y top at x) Has a KNOWN-FIXABLE Flaw, Not an Architectural One

**Risk**: MEDIUM
**Confidence**: HIGH

The current encoding at KampBypass.lean:481-485 uses `Formula.snce char_y Formula.top` in endpointRight, evaluated at x. This gives `exists y < x, char_y(y)` with no lower bound `t < y`.

Report 35 and Report 36 both declare this "unsound." But the BACKWARD direction at lines 2032-2047 actually works correctly: given nf_eval with a witness y in (t,x), it constructs the Since formula at x using that witness. The backward direction is COMPLETE -- the sorry at L2081 is in the BRACKET case only.

The FORWARD direction (L2205) is where the flaw bites: given `Formula.snce char_y top` at x (i.e., `exists y < x, char_y(y)`), we extract y < x but cannot conclude t < y. This is the actual sorry at L2205.

**Key insight the other reports miss**: The formula does not need to independently encode `t < y`. In the VecEA2 structure, `holdsLeft` requires endpointLeft at t AND endpointRight at x AND bracket on (t,x). The bracket `BracketFormula.trivial seg_guard` says `seg_guard` holds everywhere in (t,x). If seg_guard = conjunction of negated char_y for negative between_tx SSNs, then seg_guard tells us something about the interval (t,x) but does NOT constrain arbitrary y < x to lie in (t,x).

However, the forward proof could potentially use the SEG_GUARD information to exclude the possibility y <= t: if y <= t and char_y(y) holds, then y satisfies some NF profile. If that NF profile is incompatible with the "below_t" zone ordering constraints, we get a contradiction. This depends on the NF profile encoding zone information in the ordering bits, not just predicate bits.

**The problem**: `nf_y_proj` strips ordering information. Two SSNs differing only in y's zone (between_tx vs. below_t) can have the same `nf_y_proj`. So a point y <= t could satisfy char_y = nf_depth0_char_formula(nf_y_proj(ssn)) if it has the same predicate profile as some between_tx SSN.

**Conclusion**: The encoding flaw IS real for the forward direction. The question is whether the fix needs to change the FORMULA (as Approach C proposes) or just the PROOF STRATEGY.

---

### Finding 3: Approach C's Conjunction of Bounded Untils Breaks the VVecEA2 Architecture

**Risk**: HIGH
**Confidence**: HIGH

The current `enriched_vecEA2_until` returns `Sigma n, VecEA2 n` which is consumed by `enriched_bypass_until` via `VVecEA2.translateLeft`. The `VVecEA2.translateLeft_correct` theorem (VecEATranslation.lean:280-284) establishes correctness of the translation. This is SORRY-FREE infrastructure.

If we replace the bracket + endpointRight encoding with a conjunction-of-bounded-Untils (Approach C), we CANNOT use the VVecEA2 framework at all. The resulting formula is not a VecEA2. This means:

1. `enriched_bypass_until` must return `Formula` directly (not via `VVecEA2.translateLeft`)
2. `VecEA2.translateLeft_correct` can no longer be used as a bridge
3. The proof of `existPart_succ_n1_bypass_k0_until` (L2210 ff.) must be restructured to NOT go through `holdsLeft`

**Estimated blast radius**: Lines 1932-2205 (backward and forward lemmas) are structured around `holdsLeft`. Replacing the formula changes the proof obligation type. Both `backward_holdsLeft_of_nf_eval` and `forward_nf_eval_of_holdsLeft` become inapplicable -- they prove things about `VecEA2.holdsLeft`, not about arbitrary temporal formulas.

**What the team research (Report 35) underestimates**: Report 35 estimates 150-300 lines for the disjunction pointTypes redesign. If we go with Approach C instead, the blast radius is larger: the entire VecEA2-based proof structure for the Until case (~300 lines) must be rewritten from scratch, not merely patched.

---

### Finding 4: The Since Encoding Flaw is NOT a Simple Mirror of the Until Flaw

**Risk**: MEDIUM
**Confidence**: HIGH

Report 35 Finding 4 states the Since direction "has its own soundness flaw" at L586: positive between_xt SSNs encoded as `Formula.untl char_y Formula.top` at x gives `exists y > x, char_y(y)` without upper bound `y < t`.

This is CORRECT. But the Since case differs structurally from the Until case in a way the reports overlook:

1. **Until case**: Uses `VVecEA2.translateLeft` which goes through `VecEA2.holdsLeft` with bracket + endpointRight. The bracket is responsible for the between_tx zone. The flaw is in the bracket encoding.

2. **Since case**: Uses `formula_disjList` directly with `Formula.snce pt_x guard` (L591). There is NO bracket formula involved. The between_xt positive SSNs are encoded as `Formula.untl char_y Formula.top` inside `pt_x` (L586), which is the "event" of the outer Since.

**The Since fix is simpler**: Since there is no VecEA2/bracket machinery to work around, the Since case can be fixed by changing the `Formula.untl char_y Formula.top` at x (L586) to a bounded Until formula that terminates at t. But wait -- the formula is evaluated at x, and t > x, so we need `exists y, x < y AND y < t AND char_y(y)`. This is `Formula.untl (char_y AND Formula.snce (pre_at_t_formula) Formula.top) seg_guard` -- but this requires knowing what formula characterizes t, which is `pre_at_t`.

Actually, re-reading L591: the outer formula is `Formula.snce pt_x guard` at t, meaning `exists x < t, pt_x(x) AND guard on (x, t)`. So `pt_x` is evaluated at the witness x. Inside `pt_x`, `Formula.untl char_y top` at x means `exists y > x, char_y(y)` -- unbounded.

**The correct fix for Since**: Replace `Formula.untl char_y Formula.top` (L586) with a formula at x that says `exists y in (x, t), char_y(y) AND seg_guard on (x, y)`. But `t` is the evaluation point of the OUTER formula, not directly accessible inside `pt_x`. The outer Since already establishes x < t and guard on (x, t). So a bounded Until at x terminating at t would be: `Formula.untl (char_y) guard` at x, which gives `exists y > x, char_y(y) AND guard on (x, y)`. The guard already holds on (x, t) (from the outer Since's guard clause). BUT the Until does not know it should terminate before t. It could find y > t.

**This is the SAME problem again**: the temporal formula at a single point cannot express a two-endpoint bounded existential without nesting or a bracket.

---

### Finding 5: The Disjunction PointTypes Approach (Report 35 Recommendation) Has an Unresolved Injectivity Gap

**Risk**: HIGH
**Confidence**: HIGH

Report 35 recommends making all pointTypes the same disjunction:
```
pointTypes[i] = char_y(ssn_0) OR ... OR char_y(ssn_{n-1})
```

**Backward direction** works: sort witnesses, each satisfies its own NF hence the disjunction. CONFIRMED sound.

**Forward direction** has the `nf_y_proj` injectivity gap:

Given n ordered witnesses from `IntervalPattern.holds`, each satisfies the disjunction. We need to show that ALL n distinct NFs are witnessed. By NF mutual exclusivity, each witness satisfies EXACTLY one NF. But if `nf_y_proj` is NOT injective on `pos_between`, then two different SSNs `ssn_a, ssn_b` could have the same `nf_y_proj`, meaning a single witness could "count" for both. With n witnesses and < n distinct NF profiles, pigeonhole does not give us all n SSNs covered.

**Can `nf_y_proj` be non-injective?** YES. Two SSNs in `pos_between` differ in their 3-variable atoms (indices 0,1,2 for y,x,t). The `pos_between` filter selects SSNs with `between_tx` zone (so same ordering bits for y vs x and y vs t) and positive in sub_nf. Two SSNs could differ ONLY in their x-atom or t-atom values (indices 1 and 2), while having the same y-atom values (index 0). Since `nf_y_proj` extracts only the y-atom (index 0), they would have the same `nf_y_proj`.

But wait: the `ssn_xt_compatible` filter at L454 also filters by x-atoms matching `nf_x_1var` and t-atoms matching `parent_atoms`. If the x-atoms and t-atoms are FIXED by compatibility, and the zone ordering bits are fixed by `between_tx`, then the ONLY free bits are the y-atoms (index 0). This means: two SSNs in `pos_between` can differ ONLY in their y-atom assignment. Since `nf_y_proj` extracts exactly the y-atoms, `nf_y_proj` IS injective on `pos_between`.

**Wait, let me verify**: `ssn_xt_compatible` checks that ssn's x-predicates match `nf_x_1var` and t-predicates match `parent_atoms`. But `nf_x_1var` varies per outer disjunct (one per `nf_x`). Within a single disjunct (fixed `nf_x`), the x-atoms and t-atoms ARE fixed. And within `between_tx` zone, the ordering bits are also fixed (t < y, y < x, etc.). So the only varying bits are the y-predicate bits. This makes `nf_y_proj` injective on `pos_between` within a single disjunct.

**Resolution**: The injectivity gap is actually resolvable. Within a single `enriched_vecEA2_until` call (fixed `nf_x`), `nf_y_proj` is injective on `pos_between` because all other atom bits are fixed by the compatibility check and zone classification. This needs to be PROVED as a lemma (approximately 15-30 lines), but it is straightforward from the definitions.

**Conclusion**: The injectivity gap is real but closeable. Report 35 correctly identifies it as an open question but does not resolve it.

---

### Finding 6: Seg_Guard Does NOT Need Updating for Disjunction PointTypes Approach

**Risk**: LOW
**Confidence**: HIGH

The seg_guard at KampBypass.lean:458-460 is:
```lean
let seg_guard : TemporalPred :=
  formula_conjList (neg_between.map fun ssn =>
    (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)
```

It is a conjunction of NEGATED char_y formulas for NEGATIVE between_tx SSNs. Moving positive between_tx conditions from endpointRight to endpointLeft (or to the bracket's pointTypes) does not change which SSNs are NEGATIVE. The seg_guard remains the same.

The backward proof at L2092-2136 (bracket case) shows seg_guard holds everywhere in (t,x) by using `h_eval_quant` for negative SSNs. This argument is completely independent of where the positive SSNs are encoded.

---

### Finding 7: The y=t Boundary Case IS Resolved by Until Semantics

**Risk**: LOW
**Confidence**: HIGH

The current `between_tx_temporal_iff` lemma (L1898-1923) shows:
```
(exists y, nf_eval_nf M 0 3 [y, x, t] ssn) <-> (exists y, t < y AND y < x AND preds_match(y))
```

For the `between_tx` zone, the SSN encodes `t < y` (strict). So witnesses y > t by definition. The boundary case y = t is excluded by the zone classification. Any approach using Until semantics (`exists s > t, ...`) correctly gives s > t (strict), which aligns with the zone requirement.

The failure mode where y = t was concerning for an approach that used `char_y.neg` added to endpointLeft (evaluated at t). That approach would need `NOT char_y` at t, which could fail if t itself satisfies char_y. But the `between_tx` zone explicitly encodes `t < y`, so t cannot be a between_tx witness. This boundary issue is resolved by the zone system, not by the temporal formula.

---

### Finding 8: Report 35's Phase Recommendation Has a Hidden Dependency

**Risk**: MEDIUM
**Confidence**: MEDIUM

Report 35 recommends:
- Phase A: Verify Since soundness + close Since case (L2380, L2382)
- Phase B: Disjunction pointTypes redesign (Until bracket)
- Phase C: Close bracket and forward sorries

**Hidden dependency**: If Phase B changes the DEFINITION of `enriched_vecEA2_until` (the bracket construction), this changes the FORMULA produced by `enriched_bypass_until` which in turn changes the formula in `existPart_succ_n1_bypass_k0_until`. The forward direction theorem `forward_nf_eval_of_holdsLeft` operates on the OLD formula structure. Changing the definition means the forward theorem must be re-proved from scratch, not just patched.

Phase B and Phase C are NOT independent: Phase B changes the formula, Phase C proves things about the changed formula. They should be treated as a single implementation unit.

Also, if the Since case (Phase A) is attempted BEFORE the Until case is redesigned, and the Since fix follows a similar pattern (bounded Until/Since), the implementation patterns established in Phase A may need to be REVISED when Phase B reveals the right approach. This is a sequencing risk: doing Phase A first could create rework if Phase B invalidates the Since approach.

**Recommendation**: Investigate the Until fix (Phase B) first to establish the correct pattern, then mirror for Since. This reverses Report 35's recommended order.

---

## Risk Assessment Summary

| # | Finding | Risk | Confidence |
|---|---------|------|------------|
| 1 | Approach C mis-states semantics; forward direction has witness-identity gap | HIGH | HIGH |
| 2 | Current encoding flaw is in forward direction only; backward works | MEDIUM | HIGH |
| 3 | Approach C breaks VVecEA2 architecture; large blast radius | HIGH | HIGH |
| 4 | Since flaw is NOT a simple mirror; no bracket machinery to work around | MEDIUM | HIGH |
| 5 | Disjunction PointTypes injectivity gap is closeable (y-atoms only vary) | HIGH (but closeable) | HIGH |
| 6 | Seg_guard does not need updating | LOW | HIGH |
| 7 | y=t boundary case resolved by zone system | LOW | HIGH |
| 8 | Phase ordering risk: Until should be investigated before Since | MEDIUM | MEDIUM |

## Highest-Risk Items

1. **Approach C (individual bounded Untils) is NOT ready for implementation**: It has both a semantic gap (Finding 1: witness identity) and an architectural gap (Finding 3: breaks VVecEA2). Report 36's confidence that this "completely avoids the ordering problem" is overstated.

2. **Disjunction PointTypes (Report 35 recommendation) is the strongest approach**, but requires closing the nf_y_proj injectivity lemma (Finding 5). I believe this IS closeable based on the compatibility filter analysis, making it the highest-value target.

3. **The Since case needs its own analysis separate from the Until pattern**: Finding 4 shows the Since direction does not use VecEA2/bracket machinery, so the fix approach will differ structurally from whatever works for Until.

## Evidence

- Truth.lean:128-131: `Formula.untl phi psi = exists s > t, phi(s) AND forall r in (t,s), psi(r)` -- phi is event, psi is guard
- Truth.lean:130-131: `Formula.snce phi psi = exists s < t, phi(s) AND forall r in (s,t), psi(r)` -- same convention
- KampBypass.lean:461-463: bracket is `BracketFormula.trivial seg_guard` i.e. n=0, no bracket witnesses
- KampBypass.lean:481-485: positive between_tx encoded as `Formula.snce char_y Formula.top` in endpointRight
- KampBypass.lean:585-587: positive between_xt encoded as `Formula.untl char_y Formula.top` in pt_x
- KampBypass.lean:2032-2047: backward proof for between_tx WORKS (uses between_tx_temporal_iff correctly)
- KampBypass.lean:2205: forward sorry -- this is where the encoding flaw bites
- KampBypass.lean:2380-2382: Since sorries (both forward and backward)
- VecEATranslation.lean:250-257: VecEA2.holdsLeft definition
- VecEATranslation.lean:259-268: VecEA2.translateLeft_correct (sorry-free)
- VecEAFormula.lean:305-317: BracketFormula.trivial and trivial_holds
- ExistsForallNF.lean:106-132: IntervalPattern.holds with strict-increase requirement
