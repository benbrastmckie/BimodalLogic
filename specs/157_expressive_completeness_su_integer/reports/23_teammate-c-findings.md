# Teammate C Findings: Critical Analysis of the "Encoding Gap" Claim

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Artifact**: 23
**Teammate**: C (Critic)
**Focus**: Challenge the "encoding gap" claim and analyze failure modes
**Date**: 2026-05-19

---

## Key Findings

1. The "encoding gap" claim in the Phase B handoff is **partially correct but misdiagnoses the root cause**. The real gap is not just in Cases 2/4/6/8 but in the fundamental mismatch between GHR94's language and the Lean encoding.

2. **GHR94 Case 2 output contains `¬U(A,B)` unexpanded** in the final formula, but the Lean implementation `elim_case_2_gen` introduces `all_future (neg A)` = `¬U(A, ⊤)` as a new U-type, which breaks `has_single_U_type _ A B` for `B ≠ ⊤`.

3. **The `has_single_U_type` approach is correct in principle but already blocked at the witness formulas for Cases 2, 4, 6, 8**, not merely at the "oracle" level. Agents have been chasing the oracle when the deeper issue is in the concrete witness formulas.

4. **The oracle circularity at JD=1 is a distinct but related problem**: it manifests as an identity roundtrip where abstracting U(A,B) from `.snce (.untl A B) q` and substituting back gives the same formula, with no measure decreasing.

5. **22 plan versions have failed** because each plan identifies one correct sub-problem but misses how the other sub-problems block the proposed fix.

---

## "Encoding Gap" Analysis: Reading GHR94 Case 2 vs. Lean Code

### What GHR94 Actually Says

GHR94 Lemma 10.2.3 Case 2 produces:

```
S(a ∧ ¬U(A,B), q) ≡
  [S(a, q∧¬A) ∧ ¬A ∧ ¬U(A,B)]
  ∨ [¬A ∧ ¬B ∧ S(a, ¬A∧q)]
  ∨ S(¬A∧¬B∧q∧S(a, ¬A∧q), q)
```

Key observation: `¬U(A,B)` appears **UNEXPANDED** in the first disjunct of the output. GHR94 is not required to expand `¬U(A,B)` because in GHR94's language, G (always-future) is a **primitive constructor**, so `¬U(A,B) ≡ G(¬A) ∨ U(¬A∧¬B, ¬A)` is an equivalence you can use or not use. When GHR94 leaves `¬U(A,B)` in the output, it remains a "pure future" component (negation of a pure future formula) and the `has_single_U_type` condition is satisfied because the only `U` subformula in `¬U(A,B)` is `U(A,B)` itself.

### What the Lean Code Does

In `elim_case_2_gen` (Eliminations.lean lines 353-420), the witness formula is:

```lean
let psi_l := Formula.and (Formula.and (.snce a (Formula.and q (Formula.neg A)))
  (Formula.neg A)) (.all_future (Formula.neg A))
```

Since `all_future φ = (some_future φ.neg).neg = ¬U(¬φ, ⊤)`, expanding:

```
all_future (neg A) = ¬U(A, ⊤)
```

This introduces a new `.untl A Formula.top` node. For any `B ≠ ⊤`, this breaks `has_single_U_type _ A B` because the `.untl` node in `all_future (neg A)` has args `(A, ⊤)` not `(A, B)`.

### Why the Lean Code Cannot Keep `¬U(A,B)` Unexpanded

The Lean code **cannot** leave `¬U(A,B)` in the first disjunct of `psi_l` (as GHR94 does) because `¬U(A,B)` in the Lean encoding is `.imp (.untl A B) .bot`. This formula:
- Contains `.untl A B` (the correct U-type)
- Is NOT syntactically separated unless A and B are both S-free (which is already assumed)

So GHR94's output formula **does** contain `¬U(A,B)` with `has_single_U_type`. But to reconstruct the backward direction of the equivalence proof (proving S(a∧¬U, q) from the disjunction), the Lean code needs to reconstruct `¬U(A,B)` from `G(¬A)`. This requires invoking `neg_until_equiv` (the GHR94 10.2.2 equivalence), which means Lean must keep track of `G(¬A)` as a separate formula component to feed back to `neg_until_equiv`.

The actual Lean proof backward direction (lines 401-419) reconstructs `G_s(¬A)` from the three components `(S(a, q∧¬A), ¬A(t), G_t(¬A))`. This requires `G` to be tracked as a standalone formula—hence `all_future (neg A)` in the witness.

**Conclusion**: The Phase B handoff claim is **correct**: Cases 2, 4, 6, 8 witnesses in the Lean encoding introduce `all_future (neg A)` = `¬U(A, ⊤)`, which contains `.untl A ⊤` rather than `.untl A B`, breaking `has_single_U_type _ A B` for B ≠ ⊤.

However, the handoff incorrectly frames this as an "encoding gap" unique to our language. GHR94's proof works because G/H are **primitive**—`¬U(A,B)` in GHR94 literally does not expand into new U-expressions. Our encoding MUST expand because we have no G primitive. This is an inherent structural incompatibility with GHR94's proof strategy at Lemma 10.2.4.

---

## Elimination Case Witness Analysis

### Case 1 (`case1_psi`)

**Witness**: `(S(a,q) ∧ S(a,B) ∧ B ∧ U(A,B)) ∨ (A ∧ S(a,B) ∧ S(a,q)) ∨ S(A∧q∧S(a,B)∧S(a,q), q)`

**has_single_U_type status**: YES, if `a` and `q` are U-free. The only `.untl` node is `U(A,B)` itself. `case1_psi_has_single_U_type` is **proved** in Hierarchy.lean (lines 2071-2082).

### Case 2 (`elim_case_2_gen` witness)

**Witness**: `psi_l ∨ psi1`
- `psi_l = S(a, q∧¬A) ∧ ¬A ∧ all_future(¬A)` = `S(a, q∧¬A) ∧ ¬A ∧ ¬U(A, ⊤)`
- `psi1 = case1_psi a q (¬A∧¬B) (¬A)` — the Case 1 witness for `U(¬A∧¬B, ¬A)`

**has_single_U_type `_ A B` status**: NO.
- `psi_l` contains `.untl A Formula.top` (via `all_future (neg A)`)
- `psi1 = case1_psi _ _ (¬A∧¬B) (¬A)` contains `.untl (¬A∧¬B) (¬A)`

Neither of these is `.untl A B` for arbitrary B.

**Note on `is_syntactically_separated psi_l`**: The code checks `is_syntactically_separated_all_future` (Defs.lean line 220-222), which returns `is_S_free φ`. So `psi_l` IS syntactically separated because `neg A` is S-free. But it fails `has_single_U_type _ A B`.

### Cases 4, 6, 8

By symmetry with Case 2 (all involve `¬U(A,B)`), they all introduce `all_future (neg A)` or `all_past (neg A)` or `U(¬A∧¬B, ¬A)` in their witnesses. None satisfy `has_single_U_type _ A B` for the original A, B.

### Cases 3, 5, 7

**Case 3**: By negation duality, same issue.
**Case 5**: Witness uses `Q_Z(A,B,C)` = `B ∨ A ∨ ¬S(C, ¬A)`. Contains `.untl A B` via the equivalence proof—needs checking but likely preserves U-type.
**Case 7**: `case7_separable_gen` — likely preserves U-type (involves U directly).

The handoff's claim that "Cases 2, 4, 6, 8" break `has_single_U_type` is confirmed. Cases 1, 5, 7 likely preserve it; Cases 3 may also break it via negation.

---

## Root Cause Assessment

There are **three distinct blockers** that have been conflated across 22 plan versions:

### Blocker 1: GHR94 Language Mismatch (Structural)

GHR94 has G/H as primitive constructors. Our Lean encoding uses 6 constructors without G/H. This means:
- GHR94's `¬U(A,B)` is kept as-is in separated output; it does NOT introduce new U-types
- Our encoding must rewrite `¬U(A,B)` into `G(¬A) ∨ U(¬A∧¬B, ¬A)`, introducing new U-types

**Impact**: The `is_separable_with_U_type` approach (strengthening 10.2.4-10.2.5) cannot be made to work for Cases 2, 4, 6, 8 without either (a) adding G/H as primitives, or (b) finding an alternative separated witness that uses only `U(A,B)`.

**What agents keep getting wrong**: Agents attempt to prove `case2_psi_has_single_U_type` and hit the `all_future (neg A)` barrier. Some recognize this means "add G/H primitives" but that would be a major refactor (affecting the entire codebase). Others try to use `¬U(A,B)` directly as the witness component but cannot prove separation because the proof assistant requires the expanded form for the backward equivalence direction.

### Blocker 2: JD=1 Oracle Circularity (Structural)

The abstract-substitute-callback pattern used in `no_S_nested_in_U_separable_param_jd` generates an identity roundtrip at JD=1:
- Formula: `.snce (.untl A B) q`
- Abstract U(A,B) → p: `.snce p q` (already separated)
- Substitute back: `.snce (.untl A B) q` (SAME FORMULA)

No single-formula measure decreases. This is a genuine circular proof obligation that cannot be resolved by induction on any simple measure of the callback formula alone.

**Impact**: `all_formulas_separable_aux` has 2 `sorry` calls at JD=1.

**What agents keep getting wrong**: Each approach tries to find a single measure that decreases. The fundamental insight from the JD=1 circularity handoff is correct: the roundtrip IS equivalent to `snce_separable` (an axiom). The proposed "fix" of changing the JD+1 definition shifts the gap, not eliminates it.

### Blocker 3: Mutual Dependency / Import Cycle (Engineering)

Even if Blockers 1 and 2 were resolved, `Hierarchy.lean` currently imports `SeparationThm.lean` (for `all_separable`, `snce_separable`) while `SeparationThm.lean` needs to import `Hierarchy.lean` to replace its 9 axioms. This import cycle must be resolved by creating an intermediate file or restructuring.

---

## Failure Mode Catalog (Across 22 Plan Versions)

### Failure Mode 1: Axiom Leak via `all_separable`

**Plans affected**: v1-v12 (various)
**Pattern**: The `all_formulas_separable_aux` theorem calls `snce_separable` or `all_separable` which are backed by axioms in `SeparationThm.lean`. Plans propose to "fix the axiom" but the fix requires `all_formulas_separable` which depends on the axiom being fixed—circular.
**Why recurring**: The axiom leak is the SYMPTOM (axioms appear in `lean_verify`), but the ROOT CAUSE is that the axiom bridges a genuine circular dependency in the proof structure.

### Failure Mode 2: False Claim that JD=1 Callback Has JD=0

**Plans affected**: v13-v16, v21
**Pattern**: Plans claim "at JD=1, the callback formula has JD=0, so the IH handles it." This is false for the identity roundtrip. The callback `.snce (.untl A B) q` has JD=1 (not 0) because `.untl A B` is nested under `.snce`, which is a junction.
**Why recurring**: The JD=1 counterexample is subtle. Agents apply the rule "S-free args → JD=0" but forget that the substitution places `.untl A B` BACK into S-arguments, restoring the JD.

### Failure Mode 3: Assumed U-Nesting-Depth Bound at JD=1

**Plans affected**: v17-v20 (Phase 4A)
**Pattern**: Plans propose `boxfree_sep_U_nesting_depth_le_one` — that box-normalized separated formulas have U-nesting-depth ≤ 1. This is FALSE. A separated formula can have `.untl (.untl p q) r` (outer untl with untl-containing S-free args).
**Why recurring**: The lemma SOUNDS plausible (separated means "no S nested in U"), but U-nesting-depth measures U-inside-U nesting, not S-inside-U. These are different.

### Failure Mode 4: `has_single_U_type` Approach for Cases 2/4/6/8

**Plans affected**: v22 (Phase B), also proposed in v20 (Solution A)
**Pattern**: Propose strengthening `snce_single_U_depth_one_separable` to output `is_separable_with_U_type`. Works for Case 1 (`case1_psi_has_single_U_type` proved). Then hits `all_future (neg A)` in Cases 2, 4, 6, 8.
**Why recurring**: This is the most recent and "correct-seeming" approach. It works for Case 1. The failure at Cases 2/4/6/8 is not immediately obvious because the Lean COMPILATION of `elim_case_2_gen` succeeds (it proves separation and equivalence, just not `has_single_U_type`). Agents must inspect the actual witness formula to see the problem.

### Failure Mode 5: Structural IH Collapses Back to `snce_separable`

**Plans affected**: v14-v16 (junction depth restructuring)
**Pattern**: Proposals to use "event-guard decomposition" at JD=1 reduce to: given `is_separable a` and `is_separable b`, prove `is_separable (.snce a b)`. This IS `snce_separable`. No progress.
**Why recurring**: The JD induction's n=1 case genuinely requires either `snce_separable` or a proof that avoids structural decomposition altogether.

---

## What Agents Keep Getting Wrong

1. **Diagnosing the oracle as THE problem**: The oracle in `single_U_formula_separable_noax_param` is a symptom of the circular dependency between 10.2.5 and 10.2.7. Fixing the oracle requires EITHER making 10.2.5 fully self-contained (blocked by Blocker 1) OR making 10.2.7's depth-1 case not need 10.2.5 (blocked by Blocker 2).

2. **Treating `is_syntactically_separated` as sufficient for `has_single_U_type`**: A formula is syntactically separated if every `.snce` has U-free args and every `.untl` has S-free args. This is compatible with having MANY different `.untl` nodes—so separation does NOT imply `has_single_U_type`.

3. **Assuming `all_future (neg A)` is equivalent to `¬U(A,B)` modulo has_single_U_type**: They are SEMANTICALLY equivalent (over integer time), but structurally `all_future (neg A)` = `¬U(A, ⊤)` which has the wrong second argument.

4. **Treating the JD circularity and the U-type preservation failure as independent problems that can be fixed sequentially**: They are not independent. The JD=1 case requires 10.2.5 (for the callback), and 10.2.5's full oracle-freedom requires `has_single_U_type` preservation through 10.2.4, which fails at Cases 2/4/6/8.

5. **Not reading the actual Lean witness formulas**: The Phase B handoff correctly states the problem but arrives at it via a high-level argument. The specific mechanism (the `.all_future (Formula.neg A)` in `psi_l`) is visible in the code but agents don't inspect it directly.

---

## Recommended Fix Direction

The path of least resistance while maintaining zero-debt is one of three options, in order of estimated feasibility:

### Option 1: Keep `¬U(A,B)` Unexpanded in Case 2 Witnesses (Medium effort, medium risk)

Instead of the current `psi_l = S(a, q∧¬A) ∧ ¬A ∧ all_future(¬A)`, use a witness that keeps `¬U(A,B)` as a standalone component:

```
psi_l' = S(a, q∧¬A) ∧ ¬A ∧ ¬U(A,B)
```

This formula:
- IS syntactically separated: the first disjunct's `.snce` has U-free args (a, q∧¬A are U-free); the `¬U(A,B)` = `.imp (.untl A B) .bot` is pure-future (S-free A, B means `.untl A B` is syntactically separated, so `¬U(A,B)` is too).
- DOES have `has_single_U_type _ A B`: the only `.untl` node is `.untl A B`.

The challenge is the backward direction of the equivalence proof. GHR94's proof uses `G_s(¬A) ↔ ¬U(A,B) ∧ ¬A(s)` (restricted to the interval from s). We need:

```
S(a, q∧¬A) ∧ ¬A(t) ∧ ¬U_t(A,B) → ∃ s < t, a(s) ∧ ¬U_s(A,B) ∧ ∀ r∈(s,t), q(r)
```

This requires showing `¬A(t)` and `¬U_t(A,B)` together imply `∃ s < t` with the right properties. This IS mathematically valid (because at t, ¬U(A,B) holds, so there's no A-reaching-B after t; combined with ¬A(t), this is the "G(¬A)-at-t" condition which combined with S(a, q∧¬A) reconstructs the original formula). The Lean proof would need to reconstruct `G_s(¬A)` from `¬U_t(A,B)` and the snce guard.

**Risk**: The backward equivalence proof may be harder to formalize than the current proof that uses `neg_until_equiv` directly.

### Option 2: Add G/H as Primitive Constructors (High effort, low risk once done)

Add `all_future` and `all_past` as primitive Formula constructors, removing their current definitions as abbreviations. This exactly matches GHR94's language:
- `has_single_U_type` for `all_future φ = True` (vacuously, since it's not `.untl`)
- Case 2 witness `psi_l` naturally contains `all_future (neg A)` as a primitive, NOT a `.untl` expansion

**Estimated effort**: The formula type change propagates through the entire codebase (semantics, proof system, decidability). Likely 2-4 days of work. But mathematically straightforward.

### Option 3: Well-Founded Recursion on Global Measure (High effort, high risk)

Prove termination of the oracle chain using a well-founded induction on a measure like `ω² × junction_depth + ω × count_U_subformulas + snce_depth_of_U`. This avoids needing `has_single_U_type` preservation and avoids adding G/H primitives.

**Risk**: Formalizing the termination argument in Lean 4 across the three nested inductions is technically complex. The handoffs have already shown that simple single-measure approaches fail.

---

## Confidence Level

- **Confidence in "encoding gap" claim being correct**: HIGH (95%). The Lean code for `elim_case_2_gen` definitively introduces `all_future (neg A)` = `¬U(A, ⊤)` into the witness formula, and `has_single_U_type` requires all `.untl` nodes to have exactly args `(A, B)`. For general `B`, `⊤ ≠ B`.

- **Confidence that GHR94 Case 2 output keeps `¬U(A,B)` unexpanded**: HIGH (90%). The GHR94 text explicitly shows `¬U(A,B)` in the first disjunct. GHR94's proof of Case 2 uses 10.2.2 equivalence only to convert the hypothesis `¬U(A,B)` into `G(¬A) ∨ U(¬A∧¬B, ¬A)` in the FORWARD direction, but the OUTPUT formula is stated with `¬U(A,B)`.

- **Confidence that Option 1 (unexpanded witness) is mathematically valid**: HIGH (85%). The formula `S(a, q∧¬A) ∧ ¬A(t) ∧ ¬U_t(A,B)` does capture the correct semantic condition for the G(¬A) branch of Case 2.

- **Confidence that Option 1 Lean proof is feasible without sorry**: MEDIUM (60%). The backward direction requires reconstructing the S-witness from `¬U_t(A,B)` without using `neg_until_equiv` in the way the current code does. May require a new lemma.

- **Confidence in the JD=1 circularity analysis**: HIGH (95%). The identity roundtrip counterexample is explicit and has been verified by multiple handoffs.

- **Confidence that adding G/H primitives (Option 2) would fully resolve the blockage**: HIGH (90%). With G/H as primitives, `has_single_U_type` becomes vacuously true for `all_future`/`all_past` nodes, the Case 2 witnesses directly preserve U-type, and the entire `is_separable_with_U_type` approach would work.

---

## Summary for Plan Synthesis

The central correction this Critic report provides:

1. **The "encoding gap" diagnosis is correct**, but the proposed fixes in the Phase B handoff are too pessimistic about Option 1 (keeping `¬U(A,B)` unexpanded). The handoff says "a completely different approach is needed" but Option 1 (unexpanded witness) may be achievable with ~50-80 LOC of new backward-direction proof.

2. **The JD=1 circularity is a SEPARATE problem** from the has_single_U_type failure. Even if has_single_U_type is fixed for 10.2.4-10.2.5, the 10.2.8 JD=1 circularity remains. Both must be addressed.

3. **Recommended immediate action**: Attempt to prove `elim_case_2_gen` with the alternative witness `psi_l' = S(a, q∧¬A) ∧ ¬A ∧ ¬U(A,B)` and verify `has_single_U_type`. If the backward direction proof succeeds, repeat for Cases 4, 6, 8. If it fails within 2 hours, escalate to Option 2 (add G/H primitives).
