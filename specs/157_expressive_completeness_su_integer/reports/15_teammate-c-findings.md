# Teammate C (Critic) Findings: Round 15

## Adversarial Analysis: Hidden Problems with "Just Follow GHR94"

This report challenges the consensus recommendation to restructure the Lean implementation
to faithfully follow GHR94. Seven critical problems are documented below.

---

## Problem 1: GHR94 Lemma 10.2.7 DOES Hide a Circularity

The prior round claimed GHR94's proof is acyclic. This is partially correct, but the claim
needs sharper analysis. The actual circularity risk appears at a specific transition point.

### What GHR94 10.2.7 Actually Says

Lemma 10.2.7 (no S nested in U → separable) proceeds by induction on "the maximum depth n
of nesting of Us beneath an S". The proof for n > 1:

1. Pick the least-nested U(Aᵢ, Bᵢ) occurrences
2. Inside each Aᵢ, Bᵢ, replace inner U(Xᵢⱼ, Yᵢⱼ) with fresh atoms zᵢⱼ → get A'ᵢ, B'ᵢ
3. Replace U(Aᵢ, Bᵢ) with U(A'ᵢ, B'ᵢ) throughout D → get D'
4. Apply "the preceding lemma" (10.2.6) to D' to get separated E'
5. Back-substitute zᵢⱼ → U(Xᵢⱼ, Yᵢⱼ) in E' to get E
6. Apply the **induction hypothesis** to the "pure past subformulae" of E

Step 6 is where the risk lies. The induction hypothesis is on the nesting depth of U beneath
S. The "pure past subformulae" of E that contain U are formulas like Aᵢ, Bᵢ nested under S.
GHR94 asserts these have strictly smaller nesting depth because "the level of nesting of U in
U(Aᵢ, Bᵢ) must be strictly greater than that in its subformula U(Xᵢⱼ, Yᵢⱼ)."

This is **correct** — the depth measure IS strictly decreasing. But the current Lean
implementation uses `snce_depth_of_U` rather than GHR94's "nesting depth of U beneath S"
measure, which creates a definitional gap (see Problem 5 below).

### The Resubstitution Step

After step 5, the formula E has U(Xᵢⱼ, Yᵢⱼ) inside S-contexts. GHR94 says to apply the IH
to "each of these pure past subformulas." But these subformulas are NOT simply D with smaller
depth — they are the SEPARATED CONSTITUENTS of E' with U substituted back in.

The question: do these reconstituted formulas satisfy `no_S_nested_in_U`? Yes, because by
hypothesis D has no S nested in U, and the substitution puts U(Xᵢⱼ, Yᵢⱼ) (which has S-free
arguments, since we started with no S nested in any U) inside U-free positions of E'.

**Conclusion on Problem 1**: GHR94 10.2.7 is NOT circular — the argument is valid — but the
Lean proof must carefully track that the callback formulas from `subst_in_separated_separable`
satisfy `no_S_nested_in_U`, not just `junction_depth ≤ 1`. The current implementation attempts
this via `no_S_nested_in_U_separable_param_jd` but the n=1 case produces `sorry` calls
at lines 1773 and 1806 of Hierarchy.lean, precisely because the JD=1 callback cannot be
handled without appealing to the very theorem being proved.

---

## Problem 2: The n=1 Gap is the Real Residual Circularity

The current `all_formulas_separable_aux` contains two `sorry` calls (lines 1773, 1806). Both
appear in the n=1 case of the junction depth induction:

```lean
-- n = 1: callback JD ≤ 1, handled by ih_jd 0 for JD = 0 (sorry for JD = 1).
exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
    ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
```

The sorry is `junction_depth ζ ≤ 0` — i.e., the callback formula at JD=1 produces a
callback of its own at JD≤1, and the JD=0 IH cannot handle JD=1 callbacks.

This is NOT a GHR94 faithfulness problem. GHR94 simply says "use the IH" without specifying
which measure. The Lean proof NEEDS a way to show that when n=1, the callback formulas
produced by `no_S_nested_in_U_separable_param_jd` have junction_depth = 0 (not merely ≤ 1).

**Critical finding**: The n=1 gap does NOT come from unfaithfulness to GHR94. It comes from
a precision mismatch: `callback_jd_le_one` gives JD ≤ 1, but the IH for n=1 only handles
JD ≤ 0 as its callback. A "faithful GHR94 restructuring" would still need to close this gap.

**The gap is closeable** — but by showing that when the formula entering
`no_S_nested_in_U_separable_param_jd` has JD = 1, the callbacks actually have JD = 0. This
requires a tighter bound than `callback_jd_le_one`. Specifically: when the input to
`no_S_nested_in_U_separable_param_jd` has JD ≤ 1, substituting `.untl A B` (with S-free
A, B) into the U-free arguments of a separated formula of JD ≤ 1 gives callbacks with
`.snce` having U-free arguments (because the input at JD ≤ 1 with `no_S_nested_in_U` means
U appears at most one level under S, so after box-normalization and separation, the U-free
positions of the separated form do not contain nested S-under-U). This is provable but not
trivially so.

---

## Problem 3: `is_separable` vs `is_syntactically_separated` — The Existential Gap

GHR94 produces an EXPLICIT transformed formula at every step. In Lean:
- `is_syntactically_separated : Formula → Bool` — decidable, EXPLICIT
- `is_separable : Formula → Prop` — existential, non-constructive

The current proof chain is:
1. Eliminaton cases (1-8): produce explicit `psi` with `is_syntactically_separated psi`
2. Multi-U abstraction (10.2.6): produces explicit `psi` via roundtrip
3. Hierarchy (10.2.7-10.2.8): passes `is_separable` (existential) through

This matters for the "just follow GHR94" recommendation because GHR94 constructs explicit
separated formulas at every step. The Lean proof uses `is_separable` (existential) throughout
the hierarchy, which is mathematically correct but means the proof does NOT produce a
computable separation procedure — only existence.

**This is NOT a blocker** but the team should be aware: a "faithful" GHR94 implementation
would either be constructive throughout (expensive) or deliberately shift to existential at a
specific layer. The current code does the latter. Restructuring to be "more faithful to GHR94"
will not fix the sorry calls unless the team also tightens the JD bounds.

---

## Problem 4: The BOX Modality — A Genuine Extra Complication

GHR94 works with {U, S} only. The Lean codebase has a BOX modality with these properties:
- `int_truth M t (.box _) := True` (treated as degenerate true)
- `is_syntactically_separated (.box _) := true` (box treated as atomic)

The current implementation handles box via `replace_box_with_top` and `replace_box_equiv`.
In the hierarchy theorem (lines 1747-1758), after getting separated forms ψa, ψb for the
sub-formulas, the proof applies:
```
let χa := replace_box_with_top ψa
let χb := replace_box_with_top ψb
```

This step calls `snce_of_boxfree_sep_no_S_nested` and `snce_of_boxfree_sep_jd_le_one`.

**The problem**: Box normalization is applied AFTER getting a separated form. If ψa contains
`.box` nodes, they have `is_syntactically_separated .box _ = true` (trivially), but they may
interfere with `no_S_nested_in_U` tracking. Specifically: `no_S_nested_in_U (.box φ) ↔
no_S_nested_in_U φ` — this is correctly handled. However, `replace_box_with_top` changes the
formula in a way that `replace_box_equiv` must verify preserves `int_equiv`.

**The critical question for restructuring**: If we "faithfully follow GHR94" and build the
hierarchy purely for {U, S}, where exactly does box normalization plug in? The current code
integrates it INTO the hierarchy theorem. A restructured hierarchy would need either:
(a) A pre-processing step that eliminates box BEFORE the hierarchy, or
(b) Continued integration of box normalization within each hierarchy level.

Option (a) is cleaner but requires showing that box elimination (replacing box with True) is
semantically valid at the INTEGER SEMANTICS level — which it is, since `int_truth M t (.box _)
= True` is how the codebase defines it. This is an instance of the codebase's design choice
(box is degenerate for the integer separation theorem) and should remain valid after
restructuring. But the team should explicitly document that box handling is NOT part of GHR94
and verify that `replace_box_with_top` / `replace_box_equiv` proofs do not need rebuilding.

---

## Problem 5: `snce_depth_of_U` vs GHR94's "Depth of Nesting of Us Beneath an S"

GHR94 Lemma 10.2.7 uses induction on "the maximum depth n of nesting of Us beneath an S."

The Lean definition (lines 1281-1289):
```lean
def snce_depth_of_U : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (snce_depth_of_U a) (snce_depth_of_U b)
  | .box a => snce_depth_of_U a
  | .untl _ _ => 0    -- U itself contributes 0
  | .snce a b =>
    if is_U_free a = true ∧ is_U_free b = true then 0
    else 1 + max (snce_depth_of_U a) (snce_depth_of_U b)
```

For a `.untl` node, this returns 0. For a `.snce` whose args contain U, it adds 1.

GHR94's measure for Lemma 10.2.5 (single U-type): "induction on the maximum number k of
nested Ss above any U(A,B)." This is the DUAL of what `snce_depth_of_U` computes.

GHR94's measure for Lemma 10.2.7: "maximum depth n of nesting of Us beneath an S."

The Lean `snce_depth_of_U` computes: number of S ancestors of any U node. For example:
- `S(a, U(A,B))` → `snce_depth_of_U = 1` (one S above U)
- `S(a, S(b, U(A,B)))` → `snce_depth_of_U = 2` (two S above U)

This is EXACTLY what GHR94 calls "depth n of nesting of Us beneath an S" for Lemma 10.2.7.

However, `snce_depth_of_U` is only used in Step 5b/5c of the file (lines 1281 onwards) for
the `single_U_formula_separable` proof. The main hierarchy theorem in Step 5d uses
`junction_depth` instead. These are DIFFERENT induction measures:
- `snce_depth_of_U`: S-depth above U (GHR94's 10.2.5/10.2.7 measure)  
- `junction_depth`: alternation depth of U/S nesting (GHR94's 10.2.8 measure)

The current code actually uses BOTH, which matches GHR94's two-level structure (10.2.7 feeds
into 10.2.8). This is faithful to GHR94. However, `snce_depth_of_U` is NOT currently the
primary driver of the sorry calls — the JD-level induction is.

**Conclusion on Problem 5**: The definitions are consistent with GHR94. The sorry calls
arise from the junction depth induction, not from the snce_depth_of_U definition.

---

## Problem 6: DualEliminations — 8 More Sorries That "Faithful GHR94" Does Not Automatically Fix

The `DualEliminations.lean` file has 8 sorry calls, one per dual case. Each sorry appears
because:

1. The primary cases (S out of U) produce `is_syntactically_separated psi`
2. The dual cases (U out of S) need `is_S_free psi`  
3. Swapping with `swap_temporal` converts `is_syntactically_separated` to
   `is_syntactically_separated (swap psi)`, but the comment on line 63 explains:
   > is_S_free(swap(psi)) = is_U_free(psi) — we'd need psi to be U-free, but psi is only
   > guaranteed to be separated (may have U at top level).

The "faithful GHR94" recommendation from prior rounds notes that "GHR94 Lemma 10.2.8 handles
both S-in-U and U-in-S cases." This is true. GHR94 uses duality IMPLICITLY — the book says
"the dual results hold" without separate proofs. The Lean formalization needs EXPLICIT dual
proofs because the conclusion type differs (`is_syntactically_separated` vs `is_S_free`).

**The dual sorries cannot be trivially eliminated by "following GHR94 faithfully"**. They
require either:
(a) Strengthening the primary cases to also show the separated result is U-free (when
    possible), or
(b) Proving that a separated formula equivalent to U(a^S(A,B), q) can be chosen to be S-free,
    which is a separate argument about the STRUCTURE of what Case 1 produces.

Looking at GHR94's Case 1 (dual): U(a ∧ S(A,B), q) is equivalent to... GHR94 doesn't give
an explicit formula but says "use duality." The explicit formula from Case 1 (primary):
S(a ∧ U(A,B), q) ≡ [S(a,q) ∧ S(a,B) ∧ B ∧ U(A,B)] ∨ [A ∧ S(a,B) ∧ S(a,q)] ∨ S(...)

After swapping U↔S, we get an equivalent for U(a ∧ S(A,B), q). The swapped formula WILL be
S-free only if the primary formula was U-free — which it is not, because U(A,B) appears in
the primary formula. After swapping, U(A,B) becomes S(A,B), so the swapped formula DOES
contain S. But we need the separated equivalent to be S-free.

**The fix**: The dual cases need their own explicit separation arguments for each of the 8
cases, showing that the dual formula can be separated into an S-free form. This is the same
amount of work as the primary cases — it cannot be shortcutted by duality alone.

Alternatively: redesign `DualEliminations.lean` to accept `is_separable` as the conclusion
(not `is_S_free`), since the hierarchy theorem (10.2.8) only needs separability, not S-freeness
specifically. This would eliminate all 8 sorry calls immediately.

---

## Problem 7: Reynolds 1994 Uses the SAME Proof Structure — No Alternative Route

The Reynolds 1994 paper proves completeness of US/Z. Its proof structure (Section 6) cites
GHR94 (reference [6] in Reynolds, "Temporal Logic: Mathematical Foundations...") for the
expressive completeness result. Reynolds does NOT present an alternative separation proof —
he USES GHR94's separation theorem as a black box. Section 6 of Reynolds states:

> "Now by the expressive completeness of U and S there is temporal R true in any Prior
> structure exactly where p(x) is."

Reynolds assumes GHR94's expressive completeness (Theorem 5.3.1) and builds the integer
model-finding argument on top of it. The proof technique (Section 8, Theorem 15) uses
lexicographic sums of -k-equivalent structures, not an alternative separation argument.

**Conclusion on Problem 7**: Reynolds 1994 provides NO alternative separation proof structure.
The team cannot use Reynolds as an "escape hatch" from GHR94's proof structure. Reynolds is
relevant to the COMPLETENESS proof, not the SEPARATION proof. The codebase correctly focuses
on GHR94 Chapter 10.

---

## Summary: What "Just Follow GHR94" Actually Requires

The "just follow GHR94" recommendation, while pointing in the right direction, understates
what is needed. The actual remaining work is:

### Problems that ARE addressed by faithful GHR94 restructuring:
- Removing the `all_separable` axiom (callback circularity) — YES, this is the right fix
- Organizing the lemma chain 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8 — YES, already done in structure

### Problems that are NOT addressed by "just follow GHR94":

1. **The n=1 JD gap** (lines 1773, 1806): Requires showing that when the input to
   `no_S_nested_in_U_separable_param_jd` has JD ≤ 1, the callbacks have JD = 0 (not just ≤ 1).
   This needs a tighter lemma: `callback_jd_is_zero_when_input_jd_one`.

2. **The dual elimination sorries** (8 calls in DualEliminations.lean): Either prove 8
   explicit dual cases, or change the conclusion from `is_S_free` to `is_separable`.
   Changing to `is_separable` is the path of least resistance and is mathematically valid,
   since the hierarchy only needs separability.

3. **Box modality integration**: Not a blocker but needs explicit design decision — either
   pre-process box away before the hierarchy, or continue integrating within it.

### Recommended concrete actions (adversarially ranked by risk):

**Highest Risk (do first)**: Prove `callback_jd_is_zero_when_input_jd_one` — this closes
the n=1 sorry. The key insight: when the formula entering the separation has `no_S_nested_in_U`
AND JD ≤ 1, after abstraction and separation the callback `.snce` formulas have JD = 0 because
the separated form of a JD=1 no_S_nested_in_U formula has `.snce` with U-free args (snce
arguments are U-free in any separated formula, and substituting `.untl A B` with S-free args
into a U-free formula of JD=0 gives JD=1, but the callback is the RESULT formula `.snce c' d'`
where c', d' are U-free after the re-abstraction step — actually need to trace carefully).

**Medium Risk**: Change DualEliminations.lean conclusions from `is_S_free` to `is_separable`.
This immediately eliminates 8 sorries without new mathematical content. The hierarchy theorem
needs `is_separable` for the dual direction, not `is_S_free`.

**Low Risk but Needed**: Document that box normalization is a codebase-specific addition not
in GHR94, and verify that `replace_box_with_top`/`replace_box_equiv` proofs are standalone.

---

## Bottom Line

The "just follow GHR94" recommendation is NECESSARY but NOT SUFFICIENT. The two remaining
sorry calls in `all_formulas_separable_aux` (lines 1773, 1806) require a specific lemma about
JD bounds of callback formulas that is not explicitly stated in GHR94. GHR94's proof works
because its induction hypotheses are flexible enough to handle the callback depth — but Lean's
strong induction on `junction_depth` requires an explicit JD bound for every recursive call.

The team should NOT commit to a plan that says "restructure to follow GHR94 faithfully and
the sorries will disappear." They should instead commit to a plan that says:
"Restructure to follow GHR94 AND prove `callback_jd_is_zero_when_input_jd_one` AND change
DualEliminations conclusions to `is_separable`."

The JD=1 gap is the hardest and most likely to require further team research.
