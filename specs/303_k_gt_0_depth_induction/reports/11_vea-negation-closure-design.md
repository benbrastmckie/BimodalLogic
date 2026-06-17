# V-EA Negation Closure Design: Between-Zone Backward Direction

**Task**: 303 (k_gt_0_depth_induction)
**Session**: sess_1781710390_4591d5
**Date**: 2026-06-17
**Phase**: 3 of plan v9
**Reference Grounding Tier**: Tier 1 (literature-backed, Rabinovich 2014)

## Executive Summary

The 2 remaining sorry at KampBypass.lean:600 and :646 require a **witness-count induction** approach (Rabinovich Lemma 5.3) rather than any reformulation within the existing depth-k mutual induction. The fundamental issue is that the between-zone existential `exists y in (t,x)` depends on TWO evaluation points (x and t), while ExistPart evaluates formulas at ONE point. No top/bot encoding, self-bootstrapping argument, or alternative IH usage can bridge this gap. The viable path is implementing Rabinovich's Lemma 5.3 as a standalone lemma that uses Prior-UZ/SZ to find attained first occurrences (PriorINF.lean, already proved) and performs induction on witness count (number of predicates to negate). Estimated effort: 500-800 lines, 4-8 implementation sessions.

## H3 Reference Grounding: Lemma-Level Mapping Table

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| Lemma 5.3 | Section 5, p.10 | `bracket_neg_pure` (NEEDED) | `BracketFormula n -> (z0 z1 : M.carrier) -> z0 < z1 -> NOT bf.holds M atomMap z0 z1 -> VBracketFormula.holds M atomMap neg_vbf z0 z1` | **MISSING** — core new lemma |
| Corollary 5.4 | Section 5, p.11 | `neg_bounded_existential_vea` (NEEDED) | `(P : Formula) -> (z0 z1 : M.carrier) -> NOT (exists z, z0 < z < z1 AND temporal_truth M z P) -> VVecEA2.holds M atomMap neg_vvea z0 z1` | **MISSING** — reduces to Lemma 5.3 |
| Lemma 5.1 Case 3 | Section 5, p.10-11 | `bracket_neg_general` (NEEDED) | Full negation closure for bracket formulas with interval types | **MISSING** — uses 5.3 + interval splitting |
| INF formula (eq 5.2) | Section 5, p.10 | `prior_hasDefinableINF` | `(M : OMS sig) -> semantic_prior_UZ M atomMap -> HasDefinableINF M atomMap` | **PROVED** (PriorINF.lean:141) |
| K+ operator | Section 5, p.10 | `kplus` / `kplus_formula` | `(M : OMS sig) (atomMap) (P : Formula) (t : M.carrier) -> Prop` | **PROVED** (PriorINF.lean:79-88) |
| Proposition 3.5 | Section 3, p.4 | `VecEA2.translateLeft` / `bracketBuildRight` | `BracketFormula n -> TemporalPred -> Formula` | **PROVED** (VecEATranslation.lean) |
| Lemma 3.4 (V-EA closure) | Section 3, p.4 | `BracketFormula.conj_to_bracket_exists` | V-EA closed under conj/disj/exists | **PROVED** (VecEAClosure.lean) |
| Proposition 4.2 | Section 4, p.6 | NOT directly needed | Negation of 2-free-var EA is V-EA | Subsumed by Lemma 5.1 |

## Research Findings

### Finding 1: The Problem Is Structural, Not a Missing Lemma

The sorry at line 600 requires: given `temporal_truth M t (Until (compat_disj AND quant_conj) top)`, produce `exists x, nf_eval_nf M (k'+2) 2 [x,t] sub_nf`.

The Until formula extracts x with `compat_disj` true at x (giving x's 1-var NF type) and `quant_conj` true at x (currently trivially true: top/bot). The backward direction needs to establish `nf_eval_nf` at [x,t], which requires BOTH:
- Atom agreement: from 1-var NF type + known order (provable)
- Quantifier conditions: `(exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> sub_nf.2 ssn` for each ssn

The quantifier condition involves the non-constant env [y,x,t]. The root issue: ExistPart's contract evaluates the formula at ONE point with CONSTANT parent env. The between-zone case needs information about the INTERVAL (t,x), which no single-point formula can encode in general (Z counterexample with constant predicates, proved in plan v9 Phase 2 analysis).

### Finding 2: Rabinovich's Solution Path (Lemma 5.3)

Rabinovich handles this via induction on **witness count** (number of existential points inside the interval), not depth. The key mechanism:

**Lemma 5.3** (pure existential negation): The negation of `exists x_1 ... x_n in (z0, z1) with P_1(x_1) AND ... AND P_n(x_n)` is V-EA over Dedekind complete chains.

**Proof by induction on n:**
- Base (n=0): trivially true (no witnesses to deny)
- Step (n -> n+1): If P_1 does not occur in (z0, z1), done. Otherwise, let `r0 = inf{z in (z0, z1) | P_1(z)}` (exists by Dedekind completeness / Prior-UZ).
  - **Key**: On Prior structures, `r0` is ATTAINED (Prior-UZ gives first occurrence directly, see `prior_hasDefinableINF` line 141)
  - Split at r0: the interval (z0, z1) decomposes into (z0, r0) where P_1 does NOT hold (by definition of infimum) and (r0, z1) where we have one fewer predicate to negate
  - The sub-intervals have FEWER predicates to deny, so the induction proceeds

**Corollary 5.4** reduces the bounded existential negation (which is what the sorry needs) to Lemma 5.3 by converting bracket formulas to pure existentials via the F_i construction: `F_i = alpha_i AND (beta_{i+1} Until F_{i+1})`.

### Finding 3: Mapping to the Lean Codebase

The between-zone existential at k > 0 has the form:
```
exists y, t < y < x AND nf_eval_nf M (k'+1) 3 [y,x,t] ssn
```

This is a single-witness bracket formula on (t, x) with:
- n = 1 witness (y)
- Point type at y = temporal formula characterizing depth-(k'+1) 1-var NF of y (from `CharPart(k'+1)`, available via `char_kp1`)
- Interval types = True (no constraints on intermediate points, since we only need y's existence, not a gap pattern)

For the NEGATION (when `sub_nf.2 ssn = false`): we need to show `NOT exists y in (t,x) with NF conditions`. By Lemma 5.3 (once proved), this negation is V-EA, hence TL-definable by Prop 3.5.

For the POSITIVE case (when `sub_nf.2 ssn = true`): we need to show the existential IS characterizable. The key insight: the existential has the form of a SINGLE-witness bracket formula, which is directly a VecEA2 formula — already translatable to temporal via `VecEA2.translateLeft` (proved in VecEATranslation.lean).

### Finding 4: Architecture of the Solution

**Replace top/bot encoding with proper bracket-formula encoding:**

For each `ssn : NormalForm sig (k'+1) 3` in the Until zone (t < x):

1. Decompose the sub-existential `exists y, nf_eval [y,x,t] ssn` by y's zone relative to t and x:
   - y = x: constant-env, use ih_exist (already works, eq-zone template)
   - y = t: constant-env, use ih_exist
   - y > x: Until-type existential from x (constant-env at x)
   - y < t: Since-type existential from t (constant-env at t)
   - t < y < x: **Between-zone bracket formula** — THE HARD CASE
   - x < y < t: impossible in Until zone (since t < x)

2. For the between-zone case (t < y < x):
   - Express as bracket formula: `[char_y](t, x)` where `char_y` encodes y's required NF type
   - At depth k'+1, `char_y` includes both predicates (from CharPart(k'+1)) and quantifier sub-conditions
   - The quantifier sub-conditions at depth k' are themselves encodable by the IH

3. Translate the bracket formula to temporal via `bracketBuildRight` (Prop 3.5, proved)

4. For the negation case (sub_nf.2 ssn = false):
   - Need `NOT exists y in (t,x) with conditions`
   - Apply Lemma 5.3: the negation is V-EA
   - Translate V-EA to temporal via Prop 3.5

### Finding 5: What Lemma 5.3 Needs in Lean

The key new lemma needed is:

```lean
/-- Rabinovich Lemma 5.3: negation of pure bounded existential is V-EA.
    On Prior structures, if NOT (exists y in (z0, z1) with P(y)),
    then a V-bracket formula holds on (z0, z1). -/
theorem bracket_neg_pure {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (hz : z0 < z1)
    (h_neg : ¬ ∃ y : M.carrier, z0 < y ∧ y < z1 ∧ temporal_truth M atomMap y P) :
    -- The negation is expressible as: forall y in (z0, z1), NOT P(y)
    -- Which is: the interval type "NOT P" holds on (z0, z1)
    ∀ y : M.carrier, z0 < y → y < z1 → ¬ temporal_truth M atomMap y P
```

Wait — this is trivial (just push_neg). The actual non-trivial Lemma 5.3 handles MULTIPLE predicates:

```lean
/-- Rabinovich Lemma 5.3 (multi-predicate): negation of
    "exists x_1 ... x_n in (z0, z1) with P_1(x_1) AND ... AND P_n(x_n)"
    is equivalent to a V-bracket formula. -/
theorem neg_multi_witness_vbracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (predicates : List Formula) (z0 z1 : M.carrier) (hz : z0 < z1) :
    (¬ ∃ ws : List M.carrier, ws.length = predicates.length ∧
       ws.Chain' (· < ·) ∧ z0 < ws.head! ∧ ws.getLast! < z1 ∧
       ∀ i (hi : i < predicates.length),
         temporal_truth M atomMap (ws[i]'(by omega)) (predicates[i]'hi)) →
    ∃ vbf : VBracketFormula, vbf.holds M atomMap z0 z1
```

But for our actual use case, we only have ONE between-zone witness (y), so n = 1. This dramatically simplifies things.

### Finding 6: Simplification for Single-Witness Case

For the between-zone sorry, we have a SINGLE witness y between t and x. The negation reduces to:

```
NOT (exists y, t < y < x AND conditions(y))
= forall y in (t, x), NOT conditions(y)
= interval type "NOT conditions" holds on (t, x)
```

This is a **0-witness bracket formula** — simply an interval type constraint! It translates to temporal as `Box (NOT conditions) on (t, x)`, which in TL(Until, Since) is `NOT (conditions Until True)` restricted to the interval (t, x).

More precisely: `NOT exists y in (t,x) with P(y)` at evaluation point t is equivalent to `NOT (P Until (char_x AND top))` where `char_x` identifies x. But on general structures, we cannot uniquely identify x via a temporal formula evaluated at t.

HOWEVER, on Prior structures with the Until construction already finding x via `compat_disj`, we can encode the negation WITHIN the Until formula itself:

The corrected approach: instead of encoding quant_conj as top/bot, encode it using **proper temporal formulas that are correct AT x** given x's known 1-var NF type.

### Finding 7: The Key Realization — Use GeneralExistPart WITH the NF Precondition

Re-examining `generalExistPart_from_classical`: it produces formula A (top or bot) such that:
```
nf_eval_nf M (k+1) r e env_nf → (temporal_truth M (e[0]) A ↔ ∃ y, nf_eval M k (r+1) [y|e] ssn)
```

The formula is evaluated at `e[0]`. For our case with env `[x, t]` (r=2, index 0 = x):
- `env_nf = sub_nf` (the 2-var NF we're trying to establish)
- Formula A is evaluated at x
- The precondition is `nf_eval_nf M (k'+2) 2 [x,t] sub_nf`

The circularity: we need nf_eval at [x,t] to USE the formula, but we're trying to PROVE nf_eval at [x,t].

**But here's the key**: `generalExistPart_from_classical` gives A = top when the existential is satisfiable (some M₀ exists). AND the forward direction of A = top is:

```
nf_eval_nf M (k'+2) 2 [x,t] sub_nf → True → ∃ y, nf_eval M (k'+1) 3 [y,x,t] ssn
```

This forward direction is PROVED (via NF agreement transfer from M₀). So IF we could establish the NF precondition, the existential follows automatically.

The question becomes: **can we establish nf_eval_nf M (k'+2) 2 [x,t] sub_nf from the atom part alone, with the quantifier part deferred?**

Answer: NO. `nf_eval_nf` at depth k'+2 is `(atoms correct) ∧ (∀ ssn, (∃ y, ...) ↔ sub_nf.2 ssn)`. Both parts are needed simultaneously.

### Finding 8: The Correct Solution — Reformulate the Until Formula

The fix is to change WHAT the Until formula encodes. Instead of:
```
Until(compat_disj AND quant_conj_trivial, top)
```
(which is always trivially satisfiable and carries no quantifier information)

Use:
```
Until(compat_disj AND quant_conj_proper, top)
```

Where `quant_conj_proper` uses **proper temporal formulas** for each ssn:
- For ssn where sub_nf.2 ssn = true AND the sub-existential has constant-env (y's zone is eq_yx, eq_yt, y>x, or y<t): use `ih_exist` formula (evaluated at x, correct)
- For ssn where sub_nf.2 ssn = true AND the sub-existential has between-zone (t < y < x): use `Since(char_y_predicates, char_t)` — a temporal formula at x that finds y between t and x based on y's predicate type
- For ssn where sub_nf.2 ssn = false: use negation of the corresponding positive formula

The crucial question: does the Since formula `Since(P, Q)` at x correctly characterize "exists y in (t, x) with P(y) and Q somewhere below y"?

`Since(P, Q)(x)` = exists s < x such that P(s) holds and Q holds at some r with s < r < x... No, that's wrong.

Actually: `P Since Q` at x means: exists s < x such that Q(s) holds and P holds on all r with s < r < x. This is NOT what we need.

What we need: exists y with t < y < x and conditions(y). On Prior structures, we know t < x (from Until zone). The temporal formula `char_y Since char_t` at x would mean: exists s < x with char_t(s) and char_y on (s, x). This doesn't constrain s = t.

### Finding 9: Resolution via Enriched Bracket Construction

The correct approach follows the k=0 pattern (KampBypassUntil.lean):

At k=0, the between-zone case (t < y < x) is handled by constructing a VecEA2 with:
- 1 bracket witness (y)
- Point type: char_y (depth-0 predicate matching y's NF type)
- Segment types: negations of incompatible NF types

The VecEA2 is then translated to a temporal formula via `bracketBuildRight`, and correctness follows from the VecEADecomp zone theorems.

**At k > 0, the same construction works** but with char_y being a TEMPORAL formula (from CharPart(k'+1)) rather than a depth-0 atom literal formula. The VecEA2 / bracket formula infrastructure uses `TemporalPred` (which wraps `Formula`), so it ALREADY supports temporal formulas as point types.

The key insight: the existing k=0 infrastructure (VecEADecomp, VecEATranslation, KampBypassUntil/Since) generalizes to k > 0 if we:
1. Replace `nf_depth0_char_formula` (depth-0 atom literals) with `char_kp1` (depth-(k'+1+1) temporal characteristic formulas from CharPart(k'+2))
2. Replace the depth-0 zone decomposition with a depth-(k'+1) zone decomposition
3. Show the resulting bracket formula is correct for depth-(k'+1) existentials

### Finding 10: Effort and Feasibility Assessment

**What already exists (reusable without modification):**
- VecEA2 / BracketFormula / VVecEA2 types and semantics (VecEAFormula.lean, 300 lines)
- bracketBuildRight / VecEA2.translateLeft — temporal translation (VecEATranslation.lean, 400 lines)
- VecEAClosure — V-EA closure properties (VecEAClosure.lean, 260 lines)
- PriorINF — HasDefinableINF for Prior structures (PriorINF.lean, 190 lines)
- CharPart(k'+1+1) — temporal characteristic formulas at all depths (KampMutualInduction.lean, sorry-free)

**What needs to be built:**
1. **Depth-(k'+1) bracket-formula construction** (~100-150 lines): For each ssn, build a BracketFormula (or VecEA2) whose holds semantics is equivalent to `exists y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn` restricted to the between-zone. This generalizes the k=0 construction in KampForward.lean.

2. **Correctness of depth-(k'+1) bracket construction** (~200-400 lines): Prove that the bracket formula is semantically equivalent to the sub-existential. The k=0 case takes ~500 lines across VecEADecomp.lean and ZoneBridge.lean; the k>0 generalization should be comparable or shorter since it reuses CharPart for the point types.

3. **Negation direction (for sub_nf.2 ssn = false)** (~100-200 lines): Show that if the bracket formula does NOT hold (the existential is false), then its negation is TL-definable. For a single-witness bracket formula, the negation is simply the universal `forall y in (t,x), NOT point_type(y)`, which translates to `NOT (point_type Until char_x)` at t, or equivalently `Henceforth(NOT point_type) Until char_x` — expressible via the GHR94 negation equivalence (SeparationBridge.lean).

4. **Integration into KampBypass.lean backward direction** (~100-150 lines): Replace the sorry with the proper bracket-formula-based encoding and prove the backward direction using bracket formula semantics.

**Total estimated new code**: 500-900 lines
**Total estimated effort**: 4-8 implementation sessions (each ~1-2 hours of agent time)

## Adversarial Self-Verification

| # | Claim | Challenge | Result |
|---|---|---|---|
| 1 | The between-zone case reduces to a single-witness bracket formula | Could it require multiple witnesses? | **VERIFIED**: At any given depth, `exists y in (t,x) with nf_eval [y,x,t] ssn` has exactly ONE existential variable (y). The depth-(k'+1) quantifier sub-conditions of ssn involve FURTHER existentials, but those are at depth k' (lower) and are handled by the CharPart/ExistPart IH. The top-level structure is genuinely single-witness. |
| 2 | CharPart(k'+1+1) provides the point type for the bracket formula | Could CharPart require preconditions that don't hold at the bracket witness? | **VERIFIED**: CharPart is unconditional — it provides `temporal_truth M atomMap y (char_kp1_kp1 nf_y) ↔ nf_eval_nf M (k'+1+1) 1 (fun _ => y) nf_y` for ALL y, no preconditions. |
| 3 | Prop 3.5 (bracketBuildRight) handles temporal-formula point types | Is there a restriction that point types must be atomic? | **VERIFIED**: `TemporalPred` wraps `Formula` (any formula). `bracketBuildRight` and `VecEA2.translateLeft` work with arbitrary `TemporalPred`. The proofs use only `temporal_truth` evaluation, which is defined for all formulas. |
| 4 | The Z counterexample doesn't apply to the bracket approach | Could the bracket formula also fail on Z? | **VERIFIED**: The bracket formula `[char_y](t, x)` is a 2-variable formula that DOES distinguish (t=0, x=2) from (t=0, x=1) because the bracket holds iff there exists y in (t,x) — which depends on the GAP SIZE. The bracket formula's evaluation inherently involves BOTH endpoints, avoiding the 1-variable limitation. |
| 5 | The negation case (sub_nf.2 ssn = false) doesn't need full Lemma 5.1 | Could the single-witness negation require the full multi-witness machinery? | **VERIFIED for single-witness**: For n=1, `NOT exists y in (t,x) with P(y)` is simply `forall y in (t,x), NOT P(y)`. This is an interval-type constraint (0-witness bracket formula). It translates to temporal as `NOT (P Until T)` restricted to before x, which is expressible without any INF machinery. The full Lemma 5.1/5.3 is only needed for MULTI-witness negations (n > 1), which DON'T arise at the top level of our problem. |
| 6 | No circular dependency with the mutual induction | Does using CharPart(k'+2) at depth k'+2 create a loop? | **VERIFIED**: The mutual induction provides CharPart(k'+2) BEFORE ExistPart(k'+2). The between-zone sorry is inside ExistPart(k'+2). So CharPart(k'+2) is available as hypothesis, not as something being proved. No circularity. |
| 7 | The quantifier sub-conditions of ssn (at depth k') are handled by IH | Could there be sub-conditions that escape the IH? | **PARTIALLY VERIFIED**: The depth-(k'+1) NF ssn has quantifier part: `exists z, nf_eval M k' 4 [z,y,x,t] chi`. This is a depth-k' existential with 3 free variables [y,x,t] — a NON-constant env. This requires ExistPart(k') at arity 3 with non-constant env... which is the SAME problem at lower depth! **Resolution**: By induction on k, ExistPart(k') at arity 3 is available (from the mutual induction step at depth k'). The key: at depth k', the arity-3 case reduces via constenv_2var_determines (since the 3 free vars [y,x,t] at lower depth still have the same fundamental structure). Actually wait — ExistPart(k') at arity 3 requires constant parent env. The parent env IS [y,x,t] which is non-constant. This IS the recursive version of the same problem. **CONCLUSION**: The bracket approach resolves the IMMEDIATE problem (characterizing `exists y in (t,x)`) but the INNER quantifier conditions of ssn at depth k' face the same issue recursively. However, since depth decreases (k' < k'+1), the recursion terminates. At depth 0, all quantifier conditions are purely atomic (no further existentials), and the k=0 infrastructure handles everything. |

## Revised Direction

Based on adversarial verification item 7, the solution has recursive structure:
- At depth k'+1, the between-zone existential needs a bracket formula whose point type encodes the full depth-(k'+1) NF type of y
- The depth-(k'+1) NF type of y includes quantifier conditions at depth k'
- Those depth-k' conditions may themselves involve between-zone existentials with 3-var non-constant envs
- But these are at LOWER DEPTH, and by the mutual induction, they are already handled

The mutual induction guarantees:
- `CharPart(k'+2)`: gives temporal formulas for ALL 1-var NF types at depth k'+2 (what we need for `char_y`)
- `ExistPart(k'+1)`: gives temporal formulas for constant-env existentials at depth k'+1
- The bracket construction uses `CharPart(k'+2)` for point types, which is available from the IH

**The solution IS well-founded.** The bracket formula's point type is `char_kp1_kp1 nf_y` (from CharPart at the CURRENT depth level), which already incorporates all sub-quantifier conditions from lower depths. We don't need to recurse manually — the CharPart formula already handles everything internally.

## Concrete Design for Phase 4

### Step 1: Generalize ssn zone classification to depth k'+1

Currently `classify_ssn_zone` in KampForward.lean handles depth-0 3-var NFs. For depth k'+1, the zone classification uses the ATOM part of `ssn : NormalForm sig (k'+1) 3`:
```lean
let zone := ssn.1 (.order ⟨0, _⟩ ⟨2, _⟩ _)  -- y < t?
let zone := ssn.1 (.order ⟨2, _⟩ ⟨0, _⟩ _)  -- t < y?
let zone := ssn.1 (.order ⟨0, _⟩ ⟨1, _⟩ _)  -- y < x?
let zone := ssn.1 (.order ⟨1, _⟩ ⟨0, _⟩ _)  -- x < y?
```

This works at any depth (atom parts are always present).

### Step 2: Build bracket-formula encoding for between-zone

For the between-zone (t < y < x) with depth-(k'+1) 3-var ssn:

```lean
-- Point type for y: temporal formula characterizing y's NF type
-- y's 1-var NF type is determined by ssn's predicate atoms at index 0
let nf_y_type : NormalForm sig (k'+1+1) 1 := <project from ssn's pred atoms>
let point_type_y : TemporalPred := ⟨char_kp1 nf_y_type⟩

-- The bracket formula: exists y in (t,x) with char_kp1(nf_y_type)(y)
-- AND sub-quantifier conditions hold at y
-- The char_kp1 ALREADY encodes all quantifier conditions (it's the full NF characteristic)
-- So the bracket formula is simply: [char_kp1(nf_y_type)](t, x) with interval type True

let bf_between : BracketFormula 1 := {
  pointTypes := fun _ => point_type_y
  segmentTypes := fun _ => TemporalPred.top  -- no interval constraints needed
}
```

Wait — this is incomplete. The char formula for y's 1-var NF characterizes `nf_eval_nf M (k'+2) 1 (fun _ => y) nf_y_type`. But the sub-existential requires `nf_eval_nf M (k'+1) 3 [y,x,t] ssn`, which is a 3-var condition — not just 1-var.

The 3-var condition decomposes as:
- Atoms: predicates at y match ssn preds at index 0 (captured by 1-var NF of y — partial)
- Atoms: orders y < x, t < y (guaranteed by zone)
- Atoms: predicates at x match ssn preds at index 1 (from compat_check — already verified)
- Atoms: predicates at t match ssn preds at index 2 (from parent_atoms — already verified)
- Quantifiers: for each chi, (exists z, nf_eval [z,y,x,t] chi) ↔ ssn.2 chi

The quantifier part involves 4-var conditions at depth k'. These are NOT captured by y's 1-var char formula alone.

### Step 3: Resolving the Sub-Quantifier Conditions

The depth-(k'+1) 3-var NF ssn's quantifier part has: for each chi : NF(k', 4), `(exists z, nf_eval M k' 4 [z,y,x,t] chi) ↔ ssn.2 chi`.

On a Prior structure, if two environments agree on their full NF type, they agree on all existentials (by nf_agreement_from_shared_nf). So if we can establish that [y,x,t] has the SAME 3-var NF type as M₀'s [y₀,x₀,t₀] (from the classical satisfiability case), then all quantifiers match.

BUT establishing 3-var NF agreement between [y,x,t] and [y₀,x₀,t₀] requires the same kind of cross-structure transfer that generalExistPart_from_classical uses — which requires the full NF as precondition.

**Resolution**: Use the approach from `generalExistPart_from_classical` but at the POINT where we already have the bracket witness y:

1. From the bracket formula semantics, we get y with the correct 1-var NF type
2. From compat_disj, we get x with the correct 1-var NF type
3. From parent_atoms, we get t with the correct 1-var NF type
4. Plus we know the orders: t < y < x
5. The question: do items 1-4 determine the full 3-var NF of [y,x,t]?

Answer: **YES on Prior structures** (via the composition theorem). If:
- y has 1-var NF = nf_y
- x has 1-var NF = nf_x (compatible with sub_nf)
- t has 1-var NF = parent_atoms
- t < y < x
- All depth-k' existentials between any pair match (by ExistPart at lower depth)

Then the 3-var NF of [y,x,t] is uniquely determined. This is a composition argument.

BUT this composition argument is the thing that's FALSE in general (NfComposition.lean docstring: "generalized_composition as previously stated is FALSE for n >= 2 on general linear orders").

So the composition approach won't work either.

### Step 4: The Actual Correct Approach — Enriched Bracket Formula

The resolution is to make the bracket formula's point type encode the FULL 3-var condition, not just y's 1-var type.

For the between-zone existential `exists y, nf_eval M (k'+1) 3 [y,x,t] ssn`:
- Atoms at y: determined by ssn's pred atoms at index 0 → use char_kp1 for y's type
- Atoms involving x and t: already known from compat_disj and parent_atoms
- Orders: t < y < x guaranteed by zone
- Quantifiers at [y,x,t]: need `(exists z, nf_eval k' 4 [z,y,x,t] chi) ↔ ssn.2 chi`

The quantifier sub-conditions `exists z, nf_eval k' 4 [z,y,x,t] chi` with env [y,x,t] have the SAME structural problem at lower depth. But at depth k'=0, there are no quantifier conditions (depth-0 NFs are purely atomic), so the base case is trivial.

For k' > 0, we need to apply the same enriched-bracket approach recursively. This is exactly Rabinovich's induction on depth: at each depth level, the between-zone existentials at depth k are handled by the bracket formula approach, using CharPart/ExistPart at depth k-1 for the sub-conditions.

**The mutual induction already provides this**: CharPart(k'+2) gives a formula for y's FULL depth-(k'+2) 1-var NF type, which INCLUDES all quantifier sub-conditions involving only y. The remaining conditions involve BOTH y AND x/t — these are the multi-variable conditions that the mutual induction cannot express via a single-point formula.

### Final Assessment: The Sorry Requires a New Mutual Induction Conjunct

The between-zone sorry CANNOT be closed within the current 2-conjunct mutual induction (CharPart + ExistPart). The fundamental issue:

1. ExistPart evaluates at ONE point with CONSTANT parent env
2. The between-zone case needs a formula correct for the INTERVAL (t, x)
3. No single-point formula can characterize the interval condition in general

**Required new conjunct** (or alternative architecture):

Option A: Add `BracketPart(k)` — for all bracket formulas with depth-k temporal point/interval types, the bracket formula is TL-definable (already proved by Prop 3.5 / bracketBuildRight). This doesn't directly help because the issue is the NEGATION, not the positive direction.

Option B: Add `NegBracketPart(k)` — for all bracket formulas with depth-k types, the NEGATION is V-EA and hence TL-definable. This is Rabinovich's Lemma 5.1 specialized to our setting.

Option C: Reformulate ExistPart to use TWO evaluation points (breaking backward compatibility with all call sites) — impractical.

Option D: Accept that the between-zone condition is determined by the POSITIVE bracket formula (which IS TL-definable), and prove the backward direction by:
1. The Until formula encodes the bracket formula directly (not top/bot)
2. Extracting x from Until gives us temporal truth of the bracket formula at t
3. The bracket formula semantics directly give us the between-zone witness y
4. With y extracted, establish nf_eval_nf at [y,x,t] using atoms + cross-structure transfer

**Option D is the most promising and does NOT require Lemma 5.1.** Here's why:

The POSITIVE case (sub_nf.2 ssn = true, meaning the existential DOES hold): We build the bracket formula `bf` and translate it to temporal formula `A` via bracketBuildRight. We put `A` (not top!) in quant_conj. In the backward direction, extracting x from Until gives `temporal_truth M x A`. By bracketBuildRight correctness, this gives us `bf.holds M t x`, which means `exists y in (t,x) with point_type(y)`. So we GET the witness y with the required temporal conditions.

The NEGATIVE case (sub_nf.2 ssn = false): We put `A.neg` in quant_conj. Extracting from Until gives `NOT temporal_truth M x A`, hence `NOT bf.holds M t x`, hence `NOT exists y in (t,x) with conditions`.

**This approach requires**:
1. Building bracket formulas for each ssn's between-zone case (generalizing KampForward.lean)
2. Showing the bracket formula semantics match `exists y, nf_eval_nf` at the current depth
3. The bracket formula only encodes y's predicates and the orders — NOT the sub-quantifier conditions at depth k'

The sub-quantifier issue remains: the bracket formula finds y with matching predicates, but doesn't guarantee the sub-quantifier conditions hold.

**Final conclusion**: The only way to guarantee sub-quantifier conditions is through NF agreement (via generalExistPart_from_classical's mechanism). This requires the full 2-var NF precondition, which is what we're trying to prove.

The sorry is genuinely hard and requires either:
1. Rabinovich's Lemma 5.1 (negation closure with witness-count induction), ~500-1500 lines
2. A fundamentally different proof architecture that avoids the constant-env limitation

## Tactic Survey Results

N/A — this is a design research phase, not an implementation phase.

## Recommendations

1. **The sorry CANNOT be closed within the current architecture.** The 2-conjunct mutual induction (CharPart + ExistPart) is structurally insufficient for the between-zone backward direction at k > 0.

2. **Implement Rabinovich Lemma 5.3 (single-predicate base case first).** Start with the single-witness case which covers the immediate need. The multi-witness generalization can come later.

3. **Estimated effort for a minimal closure**: 500-800 lines in a new file (e.g., BracketNegClosure.lean), implementing:
   - Enriched bracket formula construction for depth-(k'+1) between-zone existentials
   - Bracket-to-temporal translation (already exists)
   - Backward direction proof using bracket semantics + NF transfer at lower depth
   - Prior-UZ/SZ for first-occurrence guarantees

4. **The sorry count will NOT decrease to 0 in a single phase.** A realistic path:
   - Phase 4a: Replace top/bot with proper bracket formulas for the POSITIVE case (sub_nf.2 ssn = true) — this makes the formula informative
   - Phase 4b: Prove the backward direction for the positive case using bracket semantics
   - Phase 4c: Handle the negative case (sub_nf.2 ssn = false) using bracket negation
   - Phase 4d: Close the sorry entirely

5. **Mark Phase 3 as [COMPLETED] with findings documented.** Phase 4 should be re-scoped based on this research.
