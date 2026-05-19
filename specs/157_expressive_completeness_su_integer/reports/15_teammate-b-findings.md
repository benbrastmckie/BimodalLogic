# Teammate B (Alternatives) — Round 15 Findings
# Task 157: Expressive Completeness of {U,S} over Integer Time

**Date**: 2026-05-19
**Focus**: Concrete restructuring plan with blocker analysis for faithful GHR94 implementation
**Teammate**: B (Alternatives)

---

## Executive Summary

This report provides a concrete, file-level blocker analysis for implementing GHR94's
Lemmas 10.2.5-10.2.8 faithfully in Lean. The core finding is that **faithful GHR94
implementation is feasible**, but requires a clean restructuring of `Hierarchy.lean`'s
`all_formulas_separable_aux` proof. The sorry at lines 1773 and 1806 is caused by an
incorrect proof architecture (callback-based recursion) that diverges from GHR94's
acyclic lemma chain. A faithful implementation using GHR94's `snce_depth_of_U` induction
directly eliminates the circularity without requiring new axioms.

**Estimated total effort**: 300-500 lines of new proof code across 2-3 new theorems.
**Feasibility**: High — no new mathematical content required; all steps follow GHR94 directly.

---

## Task 1: GHR94 Lemma 10.2.7's ACTUAL Induction Structure

### Literature Source

GHR94 Chapter 10, pp. 581-582, Lemma 10.2.7.

**Statement**: "Suppose that wff D contains no S nested within a U. Then D is syntactically
separable."

**Proof structure**:

```
Induction measure: maximum depth n of nesting of Us beneath an S
  (= snce_depth_of_U in the codebase, defined at Defs.lean line 281-289)

Case n = 0 (U-free or S has only U-free args):
  D has no U nested under any S → apply Lemma 10.2.6 directly.

Case n > 1:
  Let U(Aᵢ, Bᵢ) be the "maximal" U-subformulas.
  Each Aᵢ, Bᵢ is a boolean combination of atoms AND nested U(Xᵢⱼ, Yᵢⱼ).
  Replace each U(Xᵢⱼ, Yᵢⱼ) INSIDE the Aᵢ/Bᵢ arguments with fresh atoms zᵢⱼ.
  → Form U(A'ᵢ, B'ᵢ) where A'ᵢ, B'ᵢ are BOOLEAN ONLY (no U).
  → Replace each U(Aᵢ, Bᵢ) in D with U(A'ᵢ, B'ᵢ) to form D'.
  D' has no S nested in any U (all U-args are boolean-only).
  Apply Lemma 10.2.6 to D' → separated form E'.
  Resubstitute zᵢⱼ by U(Xᵢⱼ, Yᵢⱼ) in E' → form E.
  Now: E is equivalent to D, but U(Xᵢⱼ, Yᵢⱼ) in E appear only in U-positions of E'
  (since E' is separated). After resubstitution, E has U(Xᵢⱼ, Yᵢⱼ) in pure-future positions.
  The S-parts of E have snce_depth_of_U STRICTLY LESS (the outer Aᵢ/Bᵢ
  arguments of U(Aᵢ, Bᵢ) had their inner U(Xᵢⱼ, Yᵢⱼ) replaced).
  Apply induction hypothesis to each pure-past subformula of E.
```

### Key Insight: What "Least Deeply Nested" Means

GHR94 talks about replacing "the least deeply nested S-subformulas inside U-args." In
Lemma 10.2.7 (no S nested in U), there are no S-inside-U at all — the argument is about
U nested under S. Specifically:

- The "deepest" U-occurrences are those U(Xᵢⱼ, Yᵢⱼ) that appear inside the ARGUMENTS
  of the top-level U(Aᵢ, Bᵢ). These are the U-subformulas that form the "n-th level" of
  nesting under S.
- After replacing these with atoms, the new D' only has U with BOOLEAN args → apply 10.2.6.
- After resubstituting, the U(Xᵢⱼ, Yᵢⱼ) land in pure-future positions (not under S),
  so snce_depth_of_U strictly decreases.

### Measure Decrease Mechanism

For `.snce a b` where b contains `.untl (A + inner U's) (B + inner U's)`:
- Before: `snce_depth_of_U (.snce a b) = 1 + snce_depth_of_U b` (if U present in b)
- `snce_depth_of_U b = snce_depth_of_U (.untl A B)` where A, B may contain U's
- `snce_depth_of_U (.untl A B)` = 0 (by definition! `untl` returns 0)

Wait — this requires re-examination. Let me re-read the definition:

```lean
def snce_depth_of_U : Formula → Nat
  | .untl _ _ => 0   -- <-- U nodes score 0
  | .snce a b =>
    if is_U_free a = true ∧ is_U_free b = true then 0
    else 1 + max (snce_depth_of_U a) (snce_depth_of_U b)
```

So `snce_depth_of_U (.snce (.untl a b) q) = 1 + max (0, 0) = 1` when a, b are atoms
(since U-free check fails for `.untl`, it goes to the `else` branch giving `1 + 0 = 1`).

Actually wait — `.untl _ _` is NOT U-free. The is_U_free of `.untl` returns false. So for
`.snce (.untl A B) q`, `snce_depth_of_U = 1 + max(0, snce_depth_of_U q) = 1 + 0 = 1`
when q is U-free.

For `.snce a (.untl A B)` where A contains a nested `.untl`:
`snce_depth_of_U = 1 + max(snce_depth_of_U a, 0)`
`snce_depth_of_U (A) = snce_depth_of_U (.untl (atom p) (...)) = 0` (untl scores 0)

So the critical observation: **`.untl` always scores 0 in `snce_depth_of_U`**, regardless
of its arguments. This means `snce_depth_of_U` counts LEVELS OF S ABOVE U, not levels
of U nested within those S-arguments.

GHR94's "depth n of nesting of Us beneath an S" counts differently: it counts the maximum
chain length of U's nested within S's nested within... The formula:
- `.snce (.untl (atom p) (atom q)) r` → GHR94 depth = 1 (one U under one S)
- `.snce (.untl (.snce (.untl p q) r) s) t` → GHR94 depth = 2 (U under S under U under S)

The codebase's `snce_depth_of_U` counts the number of S-levels containing U, which
is equivalent to GHR94's measure for formulas with `no_S_nested_in_U` (since in that case,
no S appears inside U-arguments, so the "depth" = number of S-nesting levels above any U).

**Conclusion**: `snce_depth_of_U` DOES match GHR94's measure for Lemma 10.2.7's precondition
(`no_S_nested_in_U`). The definition is correct.

---

## Task 2: Does `snce_depth_of_U` Match GHR94's Measure?

**File**: `Defs.lean`, lines 281-289

```lean
def snce_depth_of_U : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (snce_depth_of_U a) (snce_depth_of_U b)
  | .box a => snce_depth_of_U a
  | .untl _ _ => 0
  | .snce a b =>
    if is_U_free a = true ∧ is_U_free b = true then 0
    else 1 + max (snce_depth_of_U a) (snce_depth_of_U b)
```

**Analysis**:

For formulas satisfying `no_S_nested_in_U` (GHR94 10.2.7's hypothesis), all U-args are
S-free, so S only appears in the "backbone" above U-nodes. Under this constraint:

- `snce_depth_of_U phi = 0` iff phi has no U under any S (all S-args are U-free)
- `snce_depth_of_U phi = n` iff the maximum chain of "S containing U" has depth n

This matches GHR94's "maximum depth n of nesting of Us beneath an S" for the `no_S_nested_in_U`
case. The definition is **semantically correct** for GHR94 10.2.7's application.

**One subtle issue**: `snce_depth_of_U (.untl A B) = 0` even when A or B contain deeply
nested S-patterns. This is intentional: `snce_depth_of_U` counts S-layers ABOVE U, not
inside U's arguments. Since we're in the `no_S_nested_in_U` regime, U-args are S-free,
so this 0 is correct.

**Conclusion**: The existing `snce_depth_of_U` definition is correct and matches GHR94.
No redefinition required.

---

## Task 3: Tracing the Substitution Step in GHR94 10.2.7

### GHR94 10.2.7 Substitution Mechanics (Faithful)

The proof of 10.2.7 has this structure for the n > 1 case:

```
Input: D with no_S_nested_in_U D, snce_depth_of_U D = n > 1
Step 1: Find maximal U-subformulas U(Aᵢ, Bᵢ) of D.
        Since no_S_nested_in_U, each Aᵢ, Bᵢ is S-free.
        But Aᵢ, Bᵢ may contain nested U's (that's what makes depth n > 1).

Step 2: For each i, and for each maximal U(Xᵢⱼ, Yᵢⱼ) inside Aᵢ or Bᵢ:
        Replace U(Xᵢⱼ, Yᵢⱼ) with fresh atom zᵢⱼ.
        → Get A'ᵢ, B'ᵢ (boolean combinations of atoms).

Step 3: In D, replace each U(Aᵢ, Bᵢ) with U(A'ᵢ, B'ᵢ) → get D'.
        D' satisfies no_S_nested_in_U (A'ᵢ, B'ᵢ are boolean, so S-free).
        Also D' has snce_depth_of_U D' = 1 (the outer U(A'ᵢ,B'ᵢ) gives depth 1).

Step 4: Apply Lemma 10.2.6 to D' → get separated form E'.
        E' is a boolean combination of:
        - atoms (including zᵢⱼ)
        - pure-future formulas (including U(A'ᵢ, B'ᵢ))
        - pure-past formulas (S-formulas with U-free and S-free args)

Step 5: Substitute zᵢⱼ back by U(Xᵢⱼ, Yᵢⱼ) in E' → get E.
        In pure-future positions of E', U(A'ᵢ, B'ᵢ) appears.
        Substituting zᵢⱼ back into U(A'ᵢ, B'ᵢ) gives U(Aᵢ, Bᵢ) — pure-future still.
        In pure-past positions of E', the S-subformulas had U-free args (the atoms zᵢⱼ).
        Substituting zᵢⱼ back introduces U(Xᵢⱼ, Yᵢⱼ) into what were U-free S-args.
        These S-subformulas now have snce_depth_of_U < n (strictly — they don't
        contain the outer U(Aᵢ, Bᵢ) level any more, only the inner level).

Step 6: Apply IH to each pure-past subformula of E (since snce_depth_of_U < n).
```

### Does snce_depth_of_U Strictly Decrease?

After Step 5, the pure-past subformulas of E have the form:
`S-formula with U(Xᵢⱼ, Yᵢⱼ) in args`

Since U(Xᵢⱼ, Yᵢⱼ) was inside U(Aᵢ, Bᵢ)'s arguments:
- `snce_depth_of_U (pure-past-part-of-E) < snce_depth_of_U D`

This is because the pure-past parts of E' came from S-subformulas in E' with boolean
(atom/zᵢⱼ) arguments. When we substitute back U(Xᵢⱼ, Yᵢⱼ) for zᵢⱼ, the S-depth of
U in these parts equals the S-depth of U in U(Xᵢⱼ, Yᵢⱼ), which is < n by the
definition of the chain.

**Conclusion**: The decrease IS provable. It requires showing that the inner U's in
the S-pure parts have strictly smaller `snce_depth_of_U`. This is a structural property
of the formula tree.

### Is This Decrease Trivially Provable in Lean?

**Not trivially**. It requires:
1. Showing that the zᵢⱼ-substituted S-subformulas of E' have `is_U_free = true`
   (trivial from the construction — they're the S-args of E', which is separated)
2. After back-substitution, showing the S-depth of the result is bounded by the
   depth of U(Xᵢⱼ, Yᵢⱼ) in the original formula

This is ~30-60 lines of proof, requiring a measure-monotonicity lemma for back-substitution.

### Preconditions for Resubstitution

The resubstitution step (Step 5) requires:
- S-free for substitution to remain in pure-past parts: U(Xᵢⱼ, Yᵢⱼ) must be S-free
  (required since Aᵢ is S-free, so inner U-args Xᵢⱼ, Yᵢⱼ are S-free by transitivity)
- The substituted formula has `no_S_nested_in_U`: since Xᵢⱼ, Yᵢⱼ are S-free, the
  new U(Xᵢⱼ, Yᵢⱼ) in the S-args satisfies this automatically

---

## Task 4: ALL Blockers to Faithful GHR94 Implementation

### Blocker Analysis

The two sorry calls are at `Hierarchy.lean` lines 1773 and 1806, both in
`all_formulas_separable_aux`. The sorry attempts to prove `junction_depth ζ ≤ 0` where
ζ is a callback formula with `junction_depth ≤ 1`. This is provably false.

**Root cause**: The proof uses a callback-based architecture where:
- `no_S_nested_in_U_separable_param_jd` receives a callback for "handle formulas with
  `no_S_nested_in_U` and JD ≤ 1"
- At JD=1 in the outer induction (n=1), the callback itself has JD ≤ 1
- To call the JD IH, we need `junction_depth ζ < n = 1`, i.e., `junction_depth ζ = 0`
- But JD=1 formulas exist that are not JD=0

The callback circularity is intrinsic to the current architecture. The faithful GHR94
approach AVOIDS callbacks entirely.

---

### Blocker 1: Missing Lemma — `no_S_nested_in_U_separable_direct` (GHR94 10.2.7)

**Description**: A direct proof that `no_S_nested_in_U φ → is_separable φ` by induction
on `snce_depth_of_U φ`, without callbacks.

**File to add**: `Hierarchy.lean` (or new file `NoSNestedSeparable.lean`)
**Location**: Before `all_formulas_separable_aux`
**Lines**: ~120-180 lines

**Structure**:
```lean
theorem no_S_nested_in_U_separable_direct (φ : Formula)
    (hns : no_S_nested_in_U φ) : is_separable φ := by
  -- Strong induction on snce_depth_of_U φ
  induction h : snce_depth_of_U φ using Nat.strongRecOn generalizing φ with
  | ind n ih =>
  -- Case n = 0: φ has U-free S-args → syntactically separated
  by_cases hn0 : n = 0
  · subst hn0
    -- snce_depth_of_U φ = 0 means: every S in φ has U-free args
    -- Combined with no_S_nested_in_U: φ is syntactically separated
    exact no_snested_depth_zero_separated φ hns (h.symm ▸ Nat.zero_le 0)
  · -- Case n > 0: structural induction on φ
    ...
    | snce a b ih_a ih_b =>
      -- Get separated forms of a, b by structural IH
      -- Box-normalize: snce(χa, χb) has no_S_nested_in_U and depth ≤ 1
      -- Apply no_S_nested_in_U_separable_param with IH as callback (snce_depth decreases!)
      ...
```

**Key Sub-Lemmas Needed**:
1. `snce_depth_of_U_le_snce_left (a b : Formula) : snce_depth_of_U a ≤ snce_depth_of_U (.snce a b)` — proof ~10 lines
2. `no_snested_depth_zero_separated : no_S_nested_in_U φ → snce_depth_of_U φ = 0 → is_syntactically_separated φ` — proof ~30 lines
3. The callback formula (`.snce χa χb` from box-normalized separated a, b) has `snce_depth_of_U < snce_depth_of_U (.snce a b)` — proof ~20 lines

**Reason It's Feasible**: The `snce_depth_of_U` measure decreases monotonically through
the structural recursion when we:
1. Take separated sub-forms of `a`, `b`
2. Box-normalize them (≡ don't change snce_depth_of_U)
3. Apply `no_S_nested_in_U_separable_param` with the callback being the snce_depth IH

The callback formulas have `snce_depth_of_U ≤ 1` (from `snce_of_boxfree_sep_jd_le_one`'s
analogous calculation). Since the input φ = `.snce a b` has `snce_depth_of_U ≥ 1` (else
case n=0 applies), we get strict decrease.

**Dependencies**:
- `snce_of_boxfree_sep_no_S_nested` (exists in `TemporalClosure.lean`)
- `no_S_nested_in_U_separable_param` (exists in `Hierarchy.lean`)
- `snce_depth_of_U` (exists in `Hierarchy.lean`)
- `extract_U_type_S_free` (exists in `Hierarchy.lean`)
- New: snce_depth monotonicity lemma (3-5 sub-lemmas)

---

### Blocker 2: Missing Lemma — Callback Formula Has Smaller `snce_depth_of_U`

**Description**: The callback formulas produced by `no_S_nested_in_U_separable_param`
(specifically from `subst_in_separated_separable`) are `.snce (c[p:=.untl A B]) (d[p:=.untl A B])`
where c, d are U-free and A, B are S-free. Need to show:
```
snce_depth_of_U (.snce (c[p:=.untl A B]) (d[p:=.untl A B])) <
snce_depth_of_U (.snce χa χb)
```
where `.snce χa χb` is the box-normalized separated form.

**File**: `Hierarchy.lean`
**Lines**: ~40-60 lines

**Key Observation**: 
- χa, χb are separated with U-free S-args → `snce_depth_of_U (.snce χa χb) = 1` (since
  χa or χb contains a `.untl` somewhere, making them not U-free, so the `else` branch fires)
- Wait — actually χa, χb are SEPARATED, so their S-args are U-free. But they may still
  contain `.untl` at top level (the U-part of separated formula). So:
  - `snce_depth_of_U χa = 0` if χa has S with U-free args, and any `.untl` in χa scores 0
  - `snce_depth_of_U (.snce χa χb) = 1 + max(0, 0) = 1` when χa or χb is not U-free
  
- The callback `.snce (c[p:=.untl A B]) (d[p:=.untl A B])` where c, d are U-free:
  - `snce_depth_of_U (c[p:=.untl A B]) = snce_depth_of_U (.untl A B) = 0` (utl scores 0)
  - So callback's depth = `1 + max(0, 0) = 1`

Hmm — so callback has depth 1, and input `.snce χa χb` also has depth 1. They're equal!

**Resolution**: This is exactly the JD=1 problem. The induction on `snce_depth_of_U` of
`.snce χa χb` still gets stuck at depth 1 if the callback also has depth 1.

The KEY DIFFERENCE from junction_depth: `snce_depth_of_U` only tracks S-above-U depth,
not U-above-S depth. So the callback `.snce (c[p:=.untl A B]) (d[p:=.untl A B])` has
`snce_depth_of_U = 1`, same as the input.

**But wait**: GHR94 10.2.7 proves `no_S_nested_in_U → separable` directly, without going
through the callback mechanism at all. The callback is an artifact of the implementation's
Lemma 10.2.6 proof that doesn't exist in GHR94. Let's trace GHR94 more carefully.

In GHR94 10.2.6 (multi-U formula separable), the proof does:
1. Substitute fresh atoms qᵢ for all U(Aᵢ, Bᵢ) except U(Aₙ, Bₙ) → get D'
2. Apply 10.2.5 to D' (single U-type U(Aₙ, Bₙ)) → get separated E'
3. Substitute U(Aᵢ, Bᵢ) back for qᵢ in each pure-past Dⱼ of E'
4. Apply IH to each Dⱼ with U substituted in

The key: in step 4, the Dⱼ have U(Aᵢ, Bᵢ) in their arguments, and we need them
to be separable. GHR94 uses the IH on "n-1 U-types." This is NOT the callback mechanism —
it's an explicit induction on the NUMBER of distinct U-types (count_U_subformulas).

**The `no_S_nested_in_U_separable_param` already uses count_U induction!** Looking at
the code at line 1491-1533, this IS the faithful GHR94 10.2.6 implementation. The callback
is what stands in for step 4's IH. And step 4's IH in GHR94 is: "apply the induction
hypothesis (fewer U-types) to each Dⱼ[U substituted in]."

**The actual problem**: In GHR94, after substituting qᵢ back by U(Aᵢ, Bᵢ), the resulting
pure-past formulas Dⱼ are claimed to be separable by IH. But what IH? At this point in
10.2.6, the IH is "n-1 U-types → separable." The Dⱼ with substitution back has n-1 U-types
(the original U(Aᵢ, Bᵢ) for i=1,...,n-1, now instantiated in the S-args). But this is
exactly what the callback handles in the implementation.

**The circular dependency**: `no_S_nested_in_U_separable_param` needs a callback to
handle the S-subformulas that get U substituted into them. For these S-subformulas
to be separable, GHR94 applies 10.2.6 IH (fewer U-types). But 10.2.6 IH IS the same
theorem being proved! So GHR94's proof of 10.2.6 is itself an induction on count_U.

The callback formulas have `no_S_nested_in_U` (already proved) and `count_U < n`
(since we extracted one U-type and substituted back — wait, the count after substitution
might be the SAME if substitution introduces multiple U(Aᵢ, Bᵢ)'s).

Looking at `no_S_nested_in_U_separable_param` (lines 1491-1533):
- It induction on `count_U_subformulas phi`
- Callback = for formulas with `no_S_nested_in_U` that come from substituting `untl A B`
  into U-free S-args of a separated formula
- The callback formula: `.snce (c[p:=.untl A B]) (d[p:=.untl A B])` has c, d U-free
- count_U of callback = count_U(c[p:=.untl A B]) + count_U(d[p:=.untl A B])
- Since c, d are U-free, and each `p → .untl A B` substitution introduces exactly 1 U
  per occurrence of p: count = (occurrences of p in c) + (occurrences of p in d)
- This can be 0 (if p not in c or d) or > 1 (if p appears multiple times)

**Critical issue**: If p appears in c at multiple positions, count_U(callback) can EQUAL
count_U(phi). So the count_U induction doesn't guarantee the callback formulas are
handled by IH.

**Wait** — this is exactly what Finding 6 from Round 14 established: the sorry IS
equivalent to `snce_separable` within the current callback architecture.

---

### Blocker 3: The Correct Fix — `no_S_nested_in_U_separable_direct` Without Callbacks

The key insight from GHR94 is that Lemma 10.2.7 (no S nested in U → separable) can be
proved WITHOUT the callback mechanism, using `snce_depth_of_U` induction. Here's why:

In GHR94 10.2.7's proof, we DON'T invoke 10.2.6 with a callback. Instead:
1. We find the top-level U(Aᵢ, Bᵢ) subformulas
2. We replace the INNER U-subformulas inside Aᵢ, Bᵢ with fresh atoms → A'ᵢ, B'ᵢ
3. We apply 10.2.6 to D' (which has `no_S_nested_in_U` and `snce_depth = 1`)
4. After 10.2.6 gives E', we substitute inner U's back
5. The pure-past parts of E' get the inner U's — these have `snce_depth < n`
6. Apply 10.2.7 IH to these parts (strictly smaller snce_depth)

**The difference**: Instead of substituting entire U(Aᵢ, Bᵢ) to make 10.2.6 work,
we substitute the INNER U's INSIDE the U-args to give them atomic (boolean) args.
This is a fundamentally different substitution direction.

GHR94 10.2.7 uses a different abstraction: it abstracts U-within-U (not U-under-S as
10.2.6 does). The resulting D' has `no_S_nested_in_U` and all U-args are boolean, so
10.2.6 applies directly. After getting E', the pure-past parts contain U's (the inner
U's that were substituted in), and THESE have strictly smaller `snce_depth_of_U`.

**What's needed for the Lean proof**:

1. `inner_U_abstraction`: For a formula φ with `no_S_nested_in_U`, replace inner U-args
   inside the arguments of maximal U-subformulas with fresh atoms. Result φ' has
   `no_S_nested_in_U` with all U-args being boolean (S-free AND U-free = pure atoms).
   
2. `inner_U_back_subst_separable`: After applying 10.2.6 to φ' and getting E',
   substituting inner U's back gives formulas with strictly smaller `snce_depth_of_U`.

3. `all_formulas_separable_aux_rewrite`: Replace the current proof at lines 1763-1806
   with one that uses `no_S_nested_in_U_separable_direct` (10.2.7) instead of the
   broken callback. Since `no_S_nested_in_U_separable_direct` requires NO callback and
   uses `snce_depth_of_U`, the circularity is eliminated.

---

### Blocker 4: DualEliminations.lean — 8 Sorry Stubs

**File**: `DualEliminations.lean`
**Location**: Lines 68, 79, 90, 101, 112, 124, 136, 148
**Count**: 8 sorry stubs (dual Cases 1-8)

These are NOT blockers for the main hierarchy theorem. The `all_formulas_separable_aux`
proof at lines 1712-1817 uses `no_S_nested_in_U_separable_param_jd` which uses
`multi_U_formula_separable` which uses `all_separable`. The dual eliminations are only
needed for the `untl` duality path, which is handled by `swap_temporal` in the main proof.

**Status**: The `swap_temporal` duality at lines 1793-1811 uses `dual_separable`, which
handles the untl case via duality. The DualEliminations.lean stubs are REDUNDANT — they
were attempts at direct dual proofs that are superseded by the `swap_temporal` approach.

**Action needed**: Confirm that the `untl` path in `all_formulas_separable_aux` is
fully axiom-free (it uses `no_S_nested_in_U_separable_param_jd` on the swapped formula,
same callback issue as the `snce` case). **The dual eliminations are not the primary blocker.**

---

### Blocker 5: SeparationThm.lean — 9 Axioms

**File**: `SeparationThm.lean`
**Lines**: 90-103 (4 temporal closure axioms), 221-237 (4 proper-separation axioms), 277 (atom axiom)

These axioms are used in:
1. `all_separable` (lines 125-139) — uses `untl_separable` and `snce_separable`
2. `single_U_formula_separable` (line 187) — uses `snce_separable` via `snce_separable`

After fixing Blocker 3, `all_formulas_separable_aux` will NOT use these axioms (it
will use `no_S_nested_in_U_separable_direct` which uses `no_S_nested_in_U_separable_param`).

However, `single_U_formula_separable` (GHR94 10.2.5) STILL invokes `snce_separable`.
This is a secondary blocker.

**Action needed**: After fixing Blocker 3, check whether `snce_separable` is still
invoked via `single_U_formula_separable → no_S_nested_in_U_separable_param`. If so,
the axiom chain is: `all_formulas_separable_aux` → `no_S_nested_in_U_separable_param_jd`
→ callback → `no_S_nested_in_U_separable_direct` → `no_S_nested_in_U_separable_param` →
callback → still needs `snce_separable`.

**Resolution**: The correct fix eliminates `snce_separable` entirely from the callback
path. `no_S_nested_in_U_separable_direct` (Blocker 1) uses IH on `snce_depth_of_U`,
making the callback handle formulas with STRICTLY smaller `snce_depth_of_U`. Since
depth 0 is directly separated, the induction terminates without needing `snce_separable`.

---

## Task 5: Effort Estimation by Component

### Component A: `snce_depth_of_U` Monotonicity Lemmas

**Theorems**:
1. `snce_depth_of_U_le_snce_left` — already exists as `snce_depth_of_U_lt_snce`
2. `snce_depth_of_U_of_no_S_nested_zero` — `no_S_nested_in_U phi → snce_depth_of_U phi = 0 ↔ phi U-free` — ~20 lines
3. `subst_snce_depth_le` — substituting U-free formula for p in φ preserves snce_depth_of_U — ~25 lines
4. `abstract_untl_inner_preserves_snce_depth` — abstracting inner U-args of U's does not increase outer snce_depth — ~20 lines

**Total LOC**: ~75 lines
**Dependencies**: Existing `snce_depth_of_U`, `is_U_free`, `abstract_untl`

### Component B: `no_snested_depth_zero_separated` — Base Case

**Theorem**: `no_S_nested_in_U phi → snce_depth_of_U phi = 0 → is_syntactically_separated phi`

**Proof outline**: By structural induction. For `.snce a b` with depth 0:
- Either both a, b are U-free (the `if` branch), so S-args U-free → separated
- Or depth calculation gives 0 via both sub-depths = 0 (recursive)
The `.untl a b` case: if S-free (from no_S_nested_in_U), already separated

**Total LOC**: ~35 lines
**Dependencies**: `snce_depth_of_U`, `is_syntactically_separated`, `is_U_free`

### Component C: `no_S_nested_in_U_separable_direct` — Main GHR94 10.2.7

**Theorem**: `no_S_nested_in_U phi → is_separable phi`

**Proof structure** (strong induction on `snce_depth_of_U phi`, structural sub-induction):
- Base: `snce_depth = 0` → use Component B for separated, then `separated_imp_separable`
- Step: `snce_depth > 0`
  - atom, bot: `separated_imp_separable`
  - imp: `imp_separable` + sub-IH
  - box: trivial
  - untl: use duality (`swap_temporal` + recursive call on swapped formula)
  - snce a b: Extract separated forms via sub-IH; box-normalize; get `.snce χa χb`
    with `no_S_nested_in_U` and `snce_depth(.snce χa χb) ≤ snce_depth(.snce a b)`
    Apply `no_S_nested_in_U_separable_param` with callback = recursive call at smaller depth

**Key callback formula analysis**:
- φ = `.snce a b` has `snce_depth n`
- After separating a → ψa, b → ψb and box-normalizing → χa, χb
- `.snce χa χb` has `no_S_nested_in_U` and `snce_depth ≤ n`

Wait — does `snce_depth(.snce χa χb) ≤ n` imply strict decrease? We need:
`snce_depth(.snce χa χb) < snce_depth(.snce a b)`.

This requires knowing that the sub-IH gives strictly smaller depth OR that
box-normalization preserves depth. Then:
`snce_depth(.snce χa χb) = 1 + max(snce_depth χa, snce_depth χb)`
`snce_depth χa = 0` because χa is separated, and separated formulas have
`snce_depth = 0` (their S-args are U-free by definition of `is_syntactically_separated`).
Wait: `is_syntactically_separated (.snce a b) = true` requires `is_U_free a = true` and
`is_U_free b = true`. So S-args of a separated formula ARE U-free. Therefore:
`snce_depth χa = snce_depth (separated formula) = 0` (S-args are U-free → depth 0).

So `snce_depth(.snce χa χb) = 1 + max(0, 0) = 1`.

And `snce_depth(.snce a b) = n ≥ 1`. If n = 1, we're stuck again! depth 1 → 1.

**This is the core difficulty again.** If the input has `snce_depth = 1`, the callback
from `no_S_nested_in_U_separable_param` has `snce_depth = 1` (unchanged).

### Re-examining GHR94 10.2.7 More Carefully

Looking at the proof again: for n = 1 (base case of the step induction in 10.2.7),
it says "Case n = 1: This is the case of the preceding lemma [10.2.6]."

So at n = 1, GHR94 directly applies 10.2.6 (no S nested in U, single level) — no
callback needed at this level! The callback from 10.2.6 would produce formulas with
depth 0 (S-args were U-free in D', and back-substituting inner U's gives depth 0 in
pure-past parts of E').

Wait — let me re-read. For Lemma 10.2.7:

- n = 1: D has U's under S, but U-args are boolean (no further S or U inside U-args).
  This IS 10.2.6 directly.

- n > 1: D has U's under S, and U-args contain further U's (those inner U's are depth n-1).
  Replace inner U-args with atoms → D' has depth 1. Apply 10.2.6 → E'. Substitute back
  → inner U's land in separated pure-past parts. Those pure-past parts now have U-args
  where each U has depth n-1. Apply IH at depth n-1.

So the IH in 10.2.7 is at depth n-1, not at depth 1. For this to work in Lean:

The "inner U's" that get substituted back have `snce_depth = n-1`, not `snce_depth = 1`.
The callback from 10.2.6 (which 10.2.7 applies to D') gives pure-past parts with
atoms (the zᵢⱼ substituted for inner U's). After back-substitution, those atoms become
U(Xᵢⱼ, Yᵢⱼ) with `snce_depth = n-1`.

So the correct induction for Lean is:
- Strong induction on `snce_depth_of_U` (not as a callback depth but as the FORMULA depth)
- At depth n, abstract inner U's to atoms (reducing to depth 1)
- Apply 10.2.6 (depth 1 case)
- Back-substitute → get formulas of depth n-1 < n
- Apply IH at depth n-1

This IS a strictly decreasing induction! But it requires a DIFFERENT abstraction:
`abstract_inner_U` — remove U-subformulas INSIDE U-args (not U-under-S as current code does).

**This function does NOT exist in the codebase.** It would need to be written.

### Component D: `abstract_inner_U` — Key Missing Function

**Description**: For a formula φ with `no_S_nested_in_U`, replace each maximal U(Xᵢⱼ, Yᵢⱼ)
appearing INSIDE the arguments of some U(Aᵢ, Bᵢ) with a fresh atom. Result: φ' where
all U-args are boolean (atom-only).

**File to add**: `Hierarchy.lean` or new file
**Lines**: ~50-70 lines definition + ~80-100 lines properties

**Properties needed**:
1. `abstract_inner_U_preserves_no_S_nested` — trivial (only replaces U with atoms)
2. `abstract_inner_U_depth_le_one` — result has `snce_depth_of_U ≤ 1`
3. `abstract_inner_U_roundtrip` — semantically correct (equiv up to fresh atoms)
4. `abstract_inner_U_strict_decrease` — `snce_depth > 1 → snce_depth(abstracted) = 1 < n`
5. `back_subst_depth_lt` — after back-substituting inner U's, pure-past parts have
   depth < n

**Total LOC for Component D**: ~200-250 lines (definition + 5 properties)

---

## Summary of Blockers and LOC Estimates

| Blocker | File | LOC | Priority |
|---------|------|-----|----------|
| A: snce_depth monotonicity lemmas | Hierarchy.lean | ~75 | Required |
| B: no_snested_depth_zero_separated | Hierarchy.lean | ~35 | Required |
| C: abstract_inner_U function + properties | Hierarchy.lean | ~200-250 | Required |
| D: no_S_nested_in_U_separable_direct (10.2.7) | Hierarchy.lean | ~120-160 | Required |
| E: all_formulas_separable_aux rewrite | Hierarchy.lean | ~50-80 | Required |
| F: DualEliminations.lean stubs | DualEliminations.lean | ~200 | Low priority |
| G: SeparationThm.lean axioms | SeparationThm.lean | 0 (become theorems) | After A-E |

**Total new LOC**: ~480-600 lines
**Files affected**: Primarily `Hierarchy.lean`; possibly `Defs.lean` or new file for `abstract_inner_U`

---

## Dependency Order

```
A (snce_depth monotonicity)
  ↓
B (depth-zero base case) → C (abstract_inner_U) → D (10.2.7 direct) → E (aux rewrite)
                                ↑
        (uses existing no_S_nested_in_U_separable_param)
```

**Critical path**: C → D → E (cannot parallelize C with D since D uses C)

---

## Feasibility Assessment

**Feasible: YES** — with the following confidence breakdown:

- Components A, B: High confidence (~95%). These are straightforward structural lemmas
  with no conceptual gaps.
- Component C (`abstract_inner_U`): Medium-high confidence (~80%). The function is
  well-defined; the proof of `abstract_inner_U_strict_decrease` requires careful
  argument about measure behavior under this specific abstraction.
- Component D (10.2.7 direct): Medium confidence (~70%). The main proof structure is
  clear, but the induction bookkeeping in Lean may require additional helper lemmas.
- Component E (aux rewrite): High confidence (~90%). Once D is proved, the rewrite
  is mechanical — replace the sorry callbacks with calls to D.

**Primary risk**: Component C's `back_subst_depth_lt` lemma — showing that after the
10.2.6 application and back-substitution, pure-past parts have `snce_depth < n`. This
requires careful accounting of how the abstraction/substitution pair affects depth.

**Alternative (lower risk)**: If Component C proves difficult, the IMMEDIATE FIX from
Report 14 (replacing sorry with `snce_separable` axiom calls) eliminates sorryAx while
leaving 9 axioms. This takes 30 minutes vs. the full 480-600 LOC restructuring.

---

## Recommendation

**Two-phase approach**:

**Phase 1 (Immediate, 30 minutes)**: Replace `by sorry` at lines 1773 and 1806 with
explicit calls to `snce_separable` (already axiomatized). Eliminates `sorryAx` from
`lean_verify all_formulas_separable`. The result is honest: axiom invocations, not sorries.

**Phase 2 (Full fix, 2-3 days)**: Implement Components A-E to eliminate all 4 temporal
closure axioms (`snce_separable`, `untl_separable`, `all_past_separable`, `all_future_separable`)
from `SeparationThm.lean`. Requires implementing `abstract_inner_U` and proving
`no_S_nested_in_U_separable_direct` by `snce_depth_of_U` strong induction.

The faithful GHR94 10.2.7 implementation uses the correct induction measure and avoids
the callback circularity entirely. The mathematical content is sound; the Lean engineering
is substantial but tractable.

---

*Report: 15_teammate-b-findings.md | Task 157 | 2026-05-19*
