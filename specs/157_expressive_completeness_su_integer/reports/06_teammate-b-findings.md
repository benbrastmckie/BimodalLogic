# Teammate B Findings: Alternative Proof Strategies for Phase 6

**Date**: 2026-05-17
**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Focus**: Alternative approaches that avoid the Dedekind formula blocker and resolve
           the snce_separable circularity in Phase 6

---

## Key Findings

### Finding 1: What WF Measures Have Been Tried and Why They Failed

Report 05 (Teammate B) documents the tried-and-failed approaches in detail:

**Attempt A: Structural induction alone (fails)**
The structural IH gives `is_separable phi` and `is_separable psi` as subformula results.
But `snce_separable` needs `is_separable (.snce phi' psi')` where phi', psi' are the
SEPARATED EQUIVALENTS, not the original subformulas. The separated form can be arbitrarily
larger, so structural IH never applies to it.

**Attempt B: WF induction on junction_depth directly (fails)**
`junction_depth (.snce phi psi) = max (junction_depth_S phi) (junction_depth_S psi)`, which
does not decrease toward subformulas. The recomposed formula `.snce phi' psi'` (where phi',
psi' are separated equivalents) has `junction_depth <= 1` (proved in TemporalClosure.lean
as `snce_of_boxfree_sep_jd_le_one`), but proving separability at junction_depth 1 still
requires Cases 5-8, and Cases 5-8 currently call `all_separable` which uses the axioms.
The junction_depth measure alone does not break the cycle.

**Attempt C: Position tracking / restricted subst_separable (fails)**
Report 04 Teammate B proposed using `abstract_untl_preserves_separated` (now proved in
Hierarchy.lean) to show that abstraction followed by substitution preserves separation.
This works for the individual components phi' and psi', but when they are joined as snce
args, substituting `untl A B` back into the snce args creates U-under-S -- which is
exactly the Case 5-8 scenario. The approach cannot avoid Cases 5-8 when the same `untl A B`
type appears in BOTH phi' and psi' (which can happen even in trivial separated formulas).
Report 04 Teammate B explicitly confirmed this failure in "Example 3 correction".

**Attempt D: Compound lexicographic measure (2-component, verified to compile)**
Report 05 Teammate B confirmed that nested `Nat.strongRecOn` on `(junction_depth, count_U_subformulas)`
with `Prod.Lex Nat.lt Nat.lt` COMPILES in Lean 4 (verified via lean_run_code). The outer IH
gives `∀ m1 < n1, ∀ m2, P m1 m2` and the inner IH gives `∀ m2 < n2, P n1 m2`. However,
the actual PROOF of the inductive step was not completed because `abstract_snce` (the dual
of `abstract_untl`) is not yet implemented, and the per-case jd-decrease lemmas are missing.

### Finding 2: What the Correct GHR94 Measure Is

GHR94 Chapter 10.2 uses a 4-level nested induction, but the levels map to a 2-component
top-level WF measure in Lean:

**Level 1 (outermost): junction_depth** -- Lemma 10.2.8
  When jd > 0: find an S-subformula inside a U-subterm, abstract it out (via `abstract_snce`),
  apply Lemma 10.2.7 (jd=0 case) to the modified formula, resubstitute the S-subformula.
  The resubstituted S-pieces have strictly smaller jd (they are inside a U, which is inside
  the original formula, contributing +1 to jdU).

**Level 2: count_U_subformulas** -- Lemma 10.2.6/10.2.7
  When jd = 0 but count_U > 0: abstract one U-type U(A,B), replacing all occurrences with
  a fresh atom p. This reduces count_U by at least 1 (if phi had single U-type, to 0). Apply
  Lemma 10.2.5 (single-U case) to the abstracted formula, then substitute back.

**Level 3 (inner to Lemma 10.2.5): has_single_U_type structural induction**
  When phi has exactly one U-type U(A,B): structural induction on phi. The snce case uses
  `snce_separable` -- but crucially, in THIS context, the snce args ALSO have single-U-type
  U(A,B) with S-free A,B, so the inductive call is structurally smaller.

**Level 4 (innermost to Lemma 10.2.4): event-splitting + Cases 1-4**
  The `snce C F` with single-U at top-level case: split event on U(A,B), giving 8 sub-cases.
  Cases 1-4 are proven. Cases 5-8 do NOT appear as separate lemmas at this level; they are
  resolved within the Lemma 10.2.6 induction (U in BOTH event AND guard means count_U in
  BOTH positions, which is handled by Level 2 taking count_U down to 0).

**Key insight**: Cases 5-8 as standalone lemmas are an ARTIFACT of the current architecture.
They represent `snce` formulas where the same U-type appears in both event and guard. In the
GHR94 hierarchy, these situations are never isolated as "Cases 5-8"; they are handled by
the Level 2 induction abstracting the U-type in one pass from the whole formula.

### Finding 3: Can `Nat.strongRecOn` with 2-Component Measure Work?

**Short answer**: Yes, the PATTERN compiles. The critical remaining work is the jd-decrease
proof.

From Report 05 Teammate B (Sample 1), the nested pattern:
```lean
theorem all_separable_restricted (P : Nat → Nat → Prop) ... : ∀ n1 n2, P n1 n2
```
using nested `Nat.strongRecOn` was verified to compile. The outer IH gives
`∀ m1 m2, m1 < n1 → P m1 m2` (ALL second-component values when jd strictly decreases).
This is the crucial property: once jd decreases, count_U can be anything.

What was NOT completed (and is still needed):
1. `abstract_snce` -- the dual of `abstract_untl`, extracting S(E,F) from inside U(A,B) arguments
2. `subformula_jd_le` -- monotonicity: if psi is a subformula of phi, then `jd psi <= jd phi`
3. `jd_snce_inside_untl_lt` -- the key decrease lemma: if S(E,F) is inside U(A,B), then
   `jd(S(E,F)) < jdU(U(A,B))`, which gives `jd(S(E,F)) < jd(outer formula)`

Report 05 Teammate B provides explicit proof sketches for all three (Samples 3-4 in that
report). The proof of `jd_snce_inside_untl_lt` follows from:
- `jdS(.untl A B) = 1 + max(jd A)(jd B)` (definition)
- `jd A >= jd S(E,F)` when S(E,F) is a subformula of A (monotonicity)
- Therefore `jdS(.untl A B) >= 1 + jd S(E,F)`, i.e., `jd S(E,F) < jdS(.untl A B)`
- And `jd(outer) >= jdS(.untl A B)` (outer contains untl as a subterm)

### Finding 4: Can We Bypass the Hierarchy Entirely for Cases 5-8?

No approach found can bypass the need for either the full hierarchy OR correct explicit
separated equivalents for Cases 5-8 on Z. Here is why:

**Approach A (abstraction): Always encounters Cases 5-8 situations**
As documented in Report 04 Teammate B Example 3 correction: when both phi' and psi' are
separated and both contain the same `untl A B`, forming `snce phi' psi'` and abstracting
`untl A B` produces `snce (with-atom-p) (with-atom-p)`. Substituting back introduces
`untl A B` in BOTH snce arguments. This is Cases 5-8 territory. No way around it.

**Approach B (Dedekind formulas for Z): Partially blocked**
Report 05 (Team synthesis) documents that:
- GHR94 Dedekind formulas fail on Z due to vacuous B-guards on empty open intervals (dense
  time assumption)
- K+=K-=FALSE (not TRUE) on Z with strict-U semantics
- G+(B) = G-(B) = bot on Z

The T200000 handoff explicitly states Case 7 has a CONCRETE DEFECT: the plan's D2 disjunct
contains `neg(untl A B)` in an snce-arg position, making it not syntactically separated.

However, the Dedekind path for Case 5 specifically may survive if restated correctly. The
substitution K+=K-=T gives a 3-disjunct formula. Report 05 Teammate D confirmed this is
"high confidence" as a backup path (~200-350 LOC per case). But the T200000 handoff shows
this was NOT successfully implemented -- the plan's Case 7 formula was wrong.

**Approach C (direct semantic construction on Z): Not yet tried**
Report 04 Teammate B (Actionable Recommendation 2) suggested constructing Case 5's
separated equivalent using the discrete structure of Z:
- Let s be the S-witness: a^U(A,B) holds at s, q v U(A,B) holds for all r in (s,t)
- Sub-case A: U(A,B) starts before s (witness for U is < s)
- Sub-case B: U(A,B) starts at s
- Sub-case C: U(A,B) starts strictly between s and t
Each sub-case should produce separated components because the U-witness location is
explicitly constrained relative to the S-witness.

This approach has NOT been formalized. It is a genuine research gap.

**Conclusion**: No bypass exists. One of two approaches must be completed:
(i) The full GHR94 junction-depth hierarchy (~500-700 LOC), or
(ii) Explicit correct separated equivalents for Cases 5-8 on Z (~200-350 LOC per case).

### Finding 5: What `junction_depth` Means Precisely

From Defs.lean (lines 203-236), the mutually recursive definition is:

```
junction_depth (phi) = measure of maximum U/S alternation in phi

junction_depth (snce phi psi) = max (junction_depth_S phi) (junction_depth_S psi)
junction_depth (untl phi psi) = max (junction_depth_U phi) (junction_depth_U psi)
junction_depth (other phi...)  = propagated max through subformulas

junction_depth_S (snce phi psi) = max (junction_depth_S phi) (junction_depth_S psi)
junction_depth_S (untl phi psi) = 1 + max (junction_depth phi) (junction_depth psi)
junction_depth_S (other)        = propagated

junction_depth_U (snce phi psi) = 1 + max (junction_depth phi) (junction_depth psi)
junction_depth_U (untl phi psi) = max (junction_depth_U phi) (junction_depth_U psi)
junction_depth_U (other)        = propagated
```

Key consequences verified in TemporalClosure.lean:
- `jd_S_zero_imp_U_free`: if jdS(phi) = 0, then phi is U-free (no untl nodes)
- `jd_U_zero_imp_S_free`: if jdU(phi) = 0, then phi is S-free (no snce nodes)
- `s_free_junction_depth_zero`: S-free formulas have jd = 0
- `u_free_junction_depth_zero`: U-free formulas have jd = 0
- `snce_of_boxfree_sep_jd_le_one`: snce of box-normalized separated phi, psi has jd <= 1

**Does the recursive case analysis in Cases 5-8 actually reduce junction_depth?**

NOT in the current architecture. Cases 5-8 currently call `all_separable _` which is a
flat invocation that neither reduces nor tracks junction_depth. This is the core problem.

In the GHR94 hierarchy, Cases 5-8 as standalone configurations do NOT reduce jd within
a single step -- they would require the full Level 2/3 machinery (abstract-substitute cycle).
This is why the current "stand-alone Case N" architecture is wrong: the hierarchy approach
does not have standalone Case 5-8 lemmas at all. Instead, the snce case in the WF induction
handles Cases 5-8 situations INLINE by recognizing them as "jd = 1, apply Level 2 reduction
to get count_U decrease."

---

## Recommended Approach

### Primary: Full GHR94 Junction-Depth Hierarchy (HIGH CONFIDENCE, ~500-700 LOC)

This is the approach that most directly maps GHR94's proof structure and avoids needing
correct explicit formulas for Cases 5-8.

**The single master theorem**:
```lean
theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi
```

proved by nested `Nat.strongRecOn` on `(junction_depth phi, count_U_subformulas phi)`.

**Required new infrastructure** (in order of implementation):

1. `abstract_snce` (~100-120 LOC, `Hierarchy.lean`):
   Dual of `abstract_untl`. Replaces all occurrences of `snce E F` inside U-arguments
   with a fresh atom. Required for the Lemma 10.2.8 inductive step.

2. `abstract_snce_preserves_S_free` / `abstract_snce_preserves_no_U_nested` (~100 LOC):
   Preservation lemmas dual to the existing `abstract_untl_*` lemmas.

3. `subformula_jd_le` (~60 LOC, `TemporalClosure.lean`):
   `∀ phi psi, psi is-subformula-of phi → junction_depth psi ≤ junction_depth phi`
   Proved by structural induction on phi.

4. `jd_snce_inside_untl_lt` (~50 LOC):
   `junction_depth (snce E F) < junction_depth_U (untl A B)` when `snce E F` is
   a subformula of A or B. Combined with `subformula_jd_le` and the definition of
   `junction_depth (outer)`, gives `jd(snce E F) < jd(outer)`.

5. `restricted_no_S_nested_separable` (~200 LOC, `NormalForm.lean` or new file):
   Main theorem using nested `Nat.strongRecOn` on `(jd, count_U)`.
   - Base case jd=0, count_U=0: phi is U-free. If also S-free, already separated.
     If has S but no U: U-free + no_S_nested_in_U means snce args have no U (trivially),
     so structural induction works trivially.
   - Base case jd=0, count_U>0: apply abstract_untl to reduce count_U. By `multi_U_formula_separable`
     route (which is the current Hierarchy.lean Lemma 10.2.6 infrastructure, minus the axiom use).
   - Inductive case jd>0: find `snce E F` inside some `untl A B` (Lemma 10.2.8 step).
     Apply `abstract_snce` to get phi' with no S inside that U. Apply ih at jd=0 (inner jd
     induction). Resubstitute `snce E F` at `jd(snce E F) < jd(phi)`. Apply outer ih.

6. `no_U_nested_in_S_separable` (~50-100 LOC):
   Derived from `no_S_nested_in_U_separable` via `swap_temporal` duality.
   Already have `swap_no_S_nested_gives_no_U_nested` and duality infrastructure in Duality.lean.

7. Replace 8 axioms in SeparationThm.lean (~60 LOC):
   Once theorems 5-6 are proved:
   - `snce_separable`: use `snce_of_boxfree_sep_no_S_nested` + `no_S_nested_in_U_separable`
   - `untl_separable`: use `untl_of_boxfree_sep_no_U_nested` + `no_U_nested_in_S_separable`
   - `all_past_separable`: use `all_past_of_boxfree_sep_no_S_nested` + `no_S_nested_in_U_separable`
   - `all_future_separable`: dual

**Infrastructure already in place** (no re-implementation needed):
- `abstract_untl` and all its preservation lemmas (Hierarchy.lean)
- `abstract_untl_preserves_separated` (proved in Phase 6 T191319 session)
- `abstract_untl_identity_on_U_free` (proved)
- `junction_depth_S_zero_imp_U_free`, `u_free_junction_depth_zero` (TemporalClosure.lean)
- `snce_of_boxfree_sep_no_S_nested` (TemporalClosure.lean)
- `swap_no_U_nested_gives_no_S_nested` (TemporalClosure.lean)
- `replace_box_separated_no_S_nested` (TemporalClosure.lean)
- Duality infrastructure (`swap_temporal`, `dual_separated`, etc.) in Duality.lean

### Secondary: Direct Semantic Construction for Cases 5-8 on Z (MEDIUM CONFIDENCE, ~200-400 LOC)

If the hierarchy approach proves intractable, construct explicit separated equivalents using
the discrete structure of Z. This requires:

For Case 5: `S(a ^ U(A,B), q v U(A,B))` with a, q, A, B all U-free and S-free.

The discrete nature of Z means U(A,B) has a definite first moment it holds after any
given time. Construct three disjuncts:
- D1: `S(a, B) ^ (A v (B ^ U(A,B)))` -- U-witness is at or before the S-event point
- D2: `S(A ^ S(a,B), A v B v neg_S(neg q, neg A)) ^ A v (B ^ U(A,B)) ^ neg_S(neg q, neg A)`
  where all S-args are U-free by construction
- D3: `S(a ^ A, q)` -- handles the case where A holds permanently after the event point

Each disjunct must be verified to:
(a) be syntactically separated per `is_syntactically_separated`
(b) be semantically equivalent to the original on Z

The T200000 handoff confirmed the plan's Case 7 formula was WRONG (D2 contained `neg(untl A B)`
in an snce-arg). Any such construction must be carefully checked for U-freeness of snce-args.

For Cases 6-8: follow from Case 5 by combining with `neg_until_equiv` expansion.

### Tertiary: Prove Phase 7 in Parallel (HIGH CONFIDENCE)

Phase 7's remaining sorries (ExpressiveCompleteness.lean lines ~667, ~685, `.all` and `.ex`
quantifier elimination cases) are completely independent of Phase 6 axiom elimination.
Report 04 Teammate C confirmed this. Phase 7 should proceed in parallel.

---

## Critical Implementation Details

### Why Cases 5-8 Are Not Standalone in the Hierarchy

The central architectural confusion is that `case5_separable` through `case8_separable` in
NormalForm.lean are standalone lemmas. In the GHR94 hierarchy, there are NO such lemmas.
The 8 cases in GHR94 are PATTERNS that arise when decomposing a formula `S(C, F)` with
single U-type at top level. Cases 5-8 patterns (U in both event AND guard) are handled
within the Level 2 induction (`multi_U_formula_separable`) because abstracting the U-type
from the WHOLE formula -- event and guard simultaneously -- removes the same U from both
positions in a single pass.

Implementation consequence: the `case5_separable` through `case8_separable` lemmas in
NormalForm.lean may ultimately be REMOVED or refactored. They are architecture artifacts
that do not correspond to GHR94 lemmas. The `single_U_formula_separable` (Lemma 10.2.5)
handles all 8 patterns via its structural induction + `snce_separable` call -- but that
call will ultimately resolve to the WF induction via `no_S_nested_in_U_separable`.

### The `all_past`/`all_future` Primitive Constructor Problem

`junction_depth (.all_past phi) = junction_depth phi` (passes through unchanged).

This means simple jd induction cannot handle `all_past` directly. The T191319 handoff and
Report 05 Teammate B both identified this problem. The solutions:

**Solution 1 (confirmed viable)**: Apply `expand_temporal` preprocessing UPFRONT before
the induction. On Z, `all_past phi ~ neg(snce (neg phi) top)`. After expansion, no primitive
`all_past`/`all_future` constructors remain. The expanded formula satisfies `has_no_allpast_allfuture`.
Then run the jd-induction on the expanded formula.

**Solution 2**: Note that `all_past phi` with `no_S_nested_in_U` means `no_S_nested_in_U phi`
(the predicate recurses through `all_past`). So in the `no_S_nested_in_U_separable` proof,
the `all_past` case reduces to the `phi` case directly. Since we have:
- `all_past_of_boxfree_sep_no_S_nested`: confirmed structural property
- If `phi` is separable, `all_past phi` is separable -- but this IS the axiom we want to prove

So for `all_past phi` where `phi` satisfies `no_S_nested_in_U`: we need to show `all_past phi`
is separable. This requires the separated equivalent of `phi` to be U-free for direct separation.
When phi has U subterms (e.g., `all_past (untl A B)`), we need to "factor out" the U -- which
is where the Level 2 induction (abstract_untl) applies.

The key: `abstract_untl (all_past phi) A B p = all_past (abstract_untl phi A B p)`. After
abstracting ALL U-types, we get `all_past (U-free phi')`. A U-free `all_past` arg is a valid
`is_syntactically_separated` formula (since `is_syntactically_separated (all_past psi) = is_U_free psi`).
So the abstract-then-substitute approach DOES handle `all_past` via the same Level 2 induction.
No `expand_temporal` needed.

### Correctness of the `no_S_nested_in_U` Definition (Report 05 Correction)

Report 05 Teammate C correctly identified that `no_S_nested_in_U (snce phi psi)` is
RECURSIVE (requires `no_S_nested_in_U phi` and `no_S_nested_in_U psi`), NOT a U-free
requirement. Verified in Defs.lean lines 319-328:

```lean
def no_S_nested_in_U : Formula -> Prop
  | .untl phi psi => is_S_free phi = true ∧ is_S_free psi = true  -- restriction on U-args
  | .snce phi psi => no_S_nested_in_U phi ∧ no_S_nested_in_U psi  -- RECURSIVE
```

Consequence: `snce (untl p q) r` satisfies `no_S_nested_in_U` (since `is_S_free p = true`
and `is_S_free q = true`), but is NOT syntactically separated (snce requires U-free args).
The snce case in `no_S_nested_in_U_separable` IS the hard case.

This means the snce case of the main theorem -- at jd > 0 -- handles exactly the situations
where untl appears inside snce args. The Level 2 (count_U) induction abstracts these out.

---

## Evidence and Examples

### Example 1: Where Measure Decrease Occurs

Consider `phi = snce (untl p q) (atom r)` where p, q, r are atoms.

- `no_S_nested_in_U phi` = true (p, q are S-free; r trivially)
- `is_syntactically_separated phi` = false (snce arg `untl p q` is not U-free)
- `junction_depth phi = junction_depth_S (untl p q) = 1 + max(jd p)(jd q) = 1 + 0 = 1`
- `count_U_subformulas phi = 1`

To prove `is_separable phi` via the hierarchy:
1. jd = 1 > 0: but actually this formula has NO S inside any U (p, q, r are atoms).
   Wait -- jd_S(untl p q) = 1, so jd(phi) = 1. But is there an S inside a U? NO.
   The formula `snce (untl p q) r` has U-under-S (the untl is inside the snce arg), not
   S-under-U. So jd_S of the snce arg (untl p q) = 1. This is the Level 2 case, not Level 1.

Actually for Level 1 (jd > 0 means S-inside-U), we would need something like
`snce (untl (snce a b) (snce c d)) e`. The S(a,b) and S(c,d) are inside U, giving jd > 1.

For `phi = snce (untl p q) r` (jd = 1, atoms only):
- Abstract `untl p q` from phi: `abstract_untl phi p q fresh = snce (atom fresh) r`
- `snce (atom fresh) r` is syntactically separated (both args are atoms)
- Substitute back: `subst_formula (snce (atom fresh) r) fresh (untl p q) = snce (untl p q) r = phi`
- phi is separable if and only if `snce (untl p q) r` has a separated equivalent
- The separated equivalent is just... `snce (untl p q) r` itself is NOT separated
- The separated equivalent is: `S(p ^ U(p,q), q)` by Case 1 application (U(p,q) in event only)
  Wait, that's for `snce (and p (untl p q)) r`. For `snce (untl p q) r`, this is Case 1 with a=top.

Actually `snce (untl p q) r = snce (and top (untl p q)) r` semantically, so Case 1 applies
(a=top, q replaced by atom r). Case 1 gives a separated formula. This is the Lemma 10.2.4
path (single U at top level in snce-args).

So for jd = 1 formulas, Cases 1-4 handle the simple configurations. Case 5-8 configurations
(same U in BOTH event and guard) at jd = 1 are handled by Level 2: abstract out the U from
BOTH positions simultaneously, produce a U-free snce (separated trivially), then substitute
back -- but at jd = 1, the substitution introduces U at jd = 1 in both positions, and after
abstracting all U at once via Level 2, the count_U decreases to 0.

### Example 2: Why the 2-Component Measure Is Sufficient

Claim: `(junction_depth, count_U_subformulas)` with `Prod.Lex Nat.lt Nat.lt` suffices.

For the snce case of `no_S_nested_in_U_separable`:
- `phi = snce phi1 phi2` with `no_S_nested_in_U phi`
- `jd phi = max(jdS phi1)(jdS phi2)`

**If jd phi > 0**: there exists a U(A,B) in phi1 or phi2 with an S(E,F) inside A or B.
Apply `abstract_snce` to extract S(E,F): S(E,F) has `jd S(E,F) < jd phi` (subformula + alternation).
By outer IH (at jd < jd phi, ANY count_U), `S(E,F)` is separable.
Resubstitute: the resulting formula has jd <= jd phi - 1 (since the S-inside-U was removed).
Apply outer IH again.
STRICTLY DECREASES jd.

**If jd phi = 0 but count_U phi > 0**: phi1, phi2 are U-free (jdS = 0 implies U-free).
But wait -- jd = max(jdS phi1)(jdS phi2) = 0 means jdS phi1 = 0 AND jdS phi2 = 0.
And jdS phi = 0 implies phi is U-free (proved in TemporalClosure.lean).
So phi1 and phi2 are U-free. Then `snce phi1 phi2` has U-free args: IS SEPARATED.
count_U = 0 in this case (phi1, phi2 are U-free). So this case doesn't arise.

Wait, something is off. Let me recheck:

For `phi = snce (untl p q) r` (jd = 1 as shown above):
- `jdS (untl p q) = 1 + max(jd p)(jd q) = 1`
- `jd phi = max (jdS (untl p q)) (jdS r) = max 1 0 = 1`
- count_U phi = 1

So this is the jd = 1, count_U = 1 case. The jd > 0 branch: is there an S inside a U?
`junction_depth_S (untl p q) = 1` but this measures S-nesting-below this node (from the S
perspective). Actually, jd_S counts alternation from S's viewpoint: `jdS (untl phi psi) = 1 + max(jd phi)(jd psi)`.
`jdS (untl p q) = 1 + max(jd p)(jd q) = 1 + 0 = 1`.

But `jd phi = max(jdS (event))(jdS (guard)) = max 1 0 = 1`. This means the formula
has junction_depth 1 due to U-under-S at depth 1.

However, the issue is: is there actually an S inside a U? `untl p q` has no S inside it
(p and q are atoms). So this should be the "no S inside U" case but jd = 1??

Re-reading the definition: `junction_depth (snce phi psi) = max (junction_depth_S phi) (junction_depth_S psi)`.
And `junction_depth_S (untl phi psi) = 1 + max (junction_depth phi) (junction_depth psi)`.
So even if there is NO S inside the untl's arguments (p, q are atoms with jd = 0), the
formula `untl p q` has `jdS = 1` because jdS counts "how deep is this U below any enclosing S
context". Since we're asking from the S-context of the outer snce, the untl contributes 1.

This means jd = 1 formulas include BOTH:
(a) formulas with actual S-inside-U (like `snce (untl (snce a b) c) d`)
(b) formulas like `snce (untl p q) r` where U is inside S but no S is inside the U

For case (b) (Level 2 scenario: no S inside U, but U under S), count_U > 0:
- Abstract the U: `abstract_untl phi A B fresh = snce (atom fresh) r` (U-free, separated)
- count_U decreases from 1 to 0
- Apply inner IH (same jd = 1, count_U < 1)

At inner base case (jd = 1, count_U = 0): phi is U-free (since jd = 1 means jdS > 0 somewhere,
but if count_U = 0 there are no untl nodes). Wait -- jd = 1 and count_U = 0 is impossible:
if jd > 0, there must be a U-under-S somewhere, which means count_U > 0.

Actually: `jd phi = 0` iff `junction_depth_S` of all snce-args is 0 iff all snce-args are
U-free. So jd > 0 implies some snce-arg contains untl, implies count_U > 0. The base case
for the inner induction (count_U = 0) only applies at jd = 0. And jd = 0 formulas are
already separated (proved in TemporalClosure.lean via `expanded_jd_zero_imp_separated`).

**Conclusion**: The 2-component measure IS correct and sufficient. There is no jd > 0 with
count_U = 0 case to worry about.

---

## Confidence Levels

| Approach | Confidence | LOC Estimate | Key Risk |
|----------|------------|--------------|----------|
| Full GHR94 hierarchy (primary) | HIGH (85%) | 500-700 | `abstract_snce` + jd-decrease proofs |
| Direct Z semantics for Cases 5-8 | MEDIUM (55%) | 200-400/case | Formula correctness on Z |
| Dedekind formulas for Z | LOW-MEDIUM (35%) | 200-350/case | Plan's Case 7 D2 was wrong |
| abstract_untl position tracking | VERY LOW (10%) | N/A | Definitively refuted |
| `expand_temporal` preprocessing | MEDIUM (60%) | +100 LOC | Eliminates all_past/all_future issue |

---

## Actionable Recommendations

1. **Implement `abstract_snce`** (~100-120 LOC in Hierarchy.lean): This is the single
   highest-leverage missing piece. Once `abstract_snce` and its preservation lemmas exist,
   the Lemma 10.2.8 inductive step (Teammate B Report 05 Sample 2) can be written.

2. **Prove `subformula_jd_le`** (~60 LOC in TemporalClosure.lean): Structural induction
   on formula. Needed for `jd_snce_inside_untl_lt`.

3. **Prove `jd_snce_inside_untl_lt`** (~50 LOC): The key jd-decrease lemma from Report 05
   Teammate B Sample 4. Assembles from `subformula_jd_le` + definition unfolding.

4. **Attempt `no_S_nested_in_U_separable` with nested `Nat.strongRecOn`**: Following the
   pattern from Report 05 Teammate B Sample 1 (verified to compile). The key cases:
   - jd = 0: formula is separated (already proved, `expanded_jd_zero_imp_separated`)
   - jd > 0: abstract the innermost S-inside-U, use outer IH at lower jd

5. **Derive temporal closure from the master theorem**: Once step 4 succeeds, the 8 axioms
   become theorems via the existing TemporalClosure.lean infrastructure
   (`snce_of_boxfree_sep_no_S_nested` etc.).

6. **Do not pursue Dedekind formulas** for Cases 5-8 as primary path: The plan's Case 7
   was confirmed wrong (T200000 handoff). The formula construction requires careful
   verification per `is_syntactically_separated`, and fixing one error may introduce others.
   Retain as backup only.

---

## References

- GHR94 Ch 10.2-10.3 (Lemmas 10.2.4-10.2.8 hierarchy)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` lines 203-236 (junction_depth), lines 319-328 (no_S_nested_in_U)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` (junction_depth helpers, box normalization, no_S_nested_in_U properties)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (abstract_untl, preservation lemmas, single_U_formula_separable)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` (case5-8_separable using all_separable -- the circularity point)
- `/home/benjamin/Projects/ProofChecker/specs/157_expressive_completeness_su_integer/handoffs/phase-6-handoff-20260517T200000.md` (latest blocker, Case 7 D2 formula error)
- `/home/benjamin/Projects/ProofChecker/specs/157_expressive_completeness_su_integer/reports/05_teammate-b-findings.md` (Lean compilation verification, per-case decrease analysis)
- `/home/benjamin/Projects/ProofChecker/specs/157_expressive_completeness_su_integer/reports/04_teammate-b-findings.md` (position tracking refutation, Example 3 correction)
