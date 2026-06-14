# Research Report: How the Literature Proof Actually Works

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Session**: sess_1781389120_27fede
- **Date**: 2026-06-13
- **Agent**: lean-research-hard-agent
- **Status**: researched
- **Tier**: Tier 1 (literature-backed, lean4 strict)

## Summary

This report traces the EXACT proof mechanism in GHR94 Ch. 9-10 and Rabinovich 2014 for
eliminating existential quantifiers from monadic FO formulas over linear time, and maps
each step to the codebase. The central finding: the literature proofs work at the FORMULA
level, not the NF level. Both approaches require the separation property as an ingredient
to eliminate auxiliary predicates, and both are structurally different from the approach
attempted in 35+ dispatches.

## Reference Grounding Table (Tier 1)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| GHR94 Thm 9.3.1 | Separation => expressive completeness | (not formalized) | `separation_property -> expressively_complete` | MISSING |
| GHR94 Thm 9.3.1 inductive step | Auxiliary predicates R_=, R_>, R_< | (not formalized) | `exists z psi(t,z,Q) -> temporal_formula` | MISSING |
| GHR94 Lem 10.2.2 | Negation of Until on integers | `neg_until_equiv_prior` | `SeparationBridge.lean` | SORRY-FREE |
| GHR94 Lem 10.2.3 | 8 elimination lemmas (U from under S) | (not formalized) | `S(a /\ U(A,B), q) -> separated_formula` | MISSING |
| GHR94 Lem 10.2.8 | Syntactic separation for U,S | (not formalized) | `any_formula -> syntactically_separated` | MISSING |
| GHR94 Thm 10.2.10 | Expressive completeness of U,S over Z | `kamp_prior_expressive_completeness` | `KampPrior.lean` | SORRY (via chain) |
| Rab14 Def 3.1 | Exists-forall formula | `ExistsForallSpec` / `BracketFormula` | `ExistsForallNF.lean` | EXISTS |
| Rab14 Prop 3.5 | EA formula -> TL(U,S) translation | `VVecEA2.translateLeft/Right` | `VecEATranslation.lean` | PARTIAL (sorry at n>0 Since) |
| Rab14 Lem 3.4(3) | EA closed under exists | `Lemma 3.2(3)` | `ExistsForallNF.lean` | SORRY-FREE (structurally trivial) |
| Rab14 Prop 4.2 | Negation closure of EA | `neg_2var_vec_ea` | `NegationClosureProp42.lean` | SORRY-FREE |
| Rab14 Prop 4.3 | Every FO formula is V-EA | (bypassed: use NF-specific approach) | --- | BYPASSED |
| Rab14 Thm 4.4 | Kamp's theorem | `kamp_prior_expressive_completeness` | `KampPrior.lean` | SORRY (via chain) |

## Q1: The GHR94 Auxiliary Predicate Trick (Theorem 9.3.1)

### Step-by-Step Mechanism

GHR94 Theorem 9.3.1 proves: if TL(U,S) has the separation property over a class T of
linear flows, then TL(U,S) is expressively complete over T.

The proof proceeds by induction on quantifier depth m of a monadic FO formula phi(t, Q_1, ..., Q_n).

**Base case (m=0)**: phi(t) is quantifier-free. Replace t=t by top, t<t by bot, Q_i(t) by q_i.

**Inductive step (m+1)**: It suffices to handle `exists z psi(t, z, Q)` where psi has depth <= m.

**Step 1: Introduce auxiliary predicates.** Since t is free in psi, the atomic subformulas
involving t have the forms: Q_i(t), t < y, t = y, y < t. Fix t and introduce:
- R_=(y) := (t = y) -- the singleton {t}
- R_>(y) := (t > y) -- the past of t
- R_<(y) := (t < y) -- the future of t

Rewrite psi as psi'(z, Q, R_=, R_>, R_<) where t appears only in Q_i(t).

**Step 2: Factor out Q_i(t).** Since t is free, push the Q_i(t) atoms out of the quantifier:

    exists z psi' <==> disjunction_j [alpha_j(t) /\ exists z psi_j(z, Q, R_=, R_>, R_<)]

where alpha_j is quantifier-free and involves only Q_i(t), and psi_j has no Q_i(t) and
has quantifier depth <= m.

**Step 3: Apply the induction hypothesis.** Each psi_j has depth <= m with variables
z, Q, R_=, R_>, R_<. By IH there exists a temporal formula A_j(q, r_=, r_>, r_<) with:

    ||A_j||_z^h = 1 iff psi_j(z, h(q), h(r_=), h(r_>), h(r_<))

Then B = disjunction_j (A[alpha_j] /\ Q_exists A_j) where Q_exists is "Pq or q or Fq".

**Step 4: Specialize the interpretation.** Set h*(r_=) = {t}, h*(r_<) = {s | t < s},
h*(r_>) = {s | s < t}. Then ||B||_t^{h*} = 1 iff exists z psi(t, z, h*(Q)).

But B still contains the auxiliary atoms r_=, r_>, r_<. These must be eliminated.

**Step 5: Apply separation to eliminate auxiliary atoms.** Since TL(U,S) has separation,
B is equivalent to a boolean combination of pure future, pure past, and pure present
formulas:

    B <==> beta(B_{+i}, B_{-j}, B_0)

**Step 6: Substitute the canonical interpretations.** For each:
- Pure past B_{-j}: on the past of t, h* has r_> = top, r_= = bot, r_< = bot.
  So B*_{-j} = B_{-j}[r_> := top, r_= := bot, r_< := bot]
- Pure future B_{+i}: on the future of t, h* has r_< = top, r_= = bot, r_> = bot.
  So B*_{+i} = B_{+i}[r_> := bot, r_= := top, r_< := bot]
  CORRECTION: r_< is the set {s | t < s}, so points in the FUTURE satisfy r_<.
  So B*_{+i} = B_{+i}[r_> := bot, r_= := bot, r_< := top]
- Present B_0: at t itself, r_= = top, r_< = bot, r_> = bot.
  So B*_0 = B_0[r_= := top, r_< := bot, r_> := bot]

Then B* = beta(B*_{+i}, B*_{-j}, B*_0) no longer contains r_=, r_>, r_<. And
||B*||_t^h = ||B||_t^{h*} for any h (because the auxiliary atoms have been eliminated).

### Worked Example

Take phi(t) = exists z (P(z) /\ z > t /\ exists w (Q(w) /\ w < z /\ w > t)).

**Step 1**: phi = exists z [P(z) /\ R_<(z) /\ exists w (Q(w) /\ w < z /\ R_<(w))].
(Here R_<(y) means t < y, i.e., y is in the future of t.)

The inner formula psi_1(z) = P(z) /\ R_<(z) /\ exists w (Q(w) /\ w < z /\ R_<(w))
has quantifier depth 1. The variable t appears only via R_<.

**Step 2**: No Q_i(t) to factor out. alpha = top.

**Step 3**: By IH on psi_1(z, Q, R_<, P):
The inner exists w is itself handled by IH at the next level:
- exists w (Q(w) /\ w < z /\ R_<(w)) becomes a temporal formula A_inner at z
  that talks about "some point in the past of z with Q and in the future of t."
  Under h*(R_<) = {s | t < s}, this becomes S(Q /\ R_<, top) at z.
  
Then psi_1(z) = P(z) /\ R_<(z) /\ S(Q /\ R_<, top)(z).
IH gives A_1 = P /\ R_< /\ S(Q /\ R_<, top).

**Step 4**: B = F(A_1) = F(P /\ R_< /\ S(Q /\ R_<, top)).
Under h*: ||B||_t = exists z > t [P(z) /\ z > t /\ exists w < z (Q(w) /\ w > t)].
This is correct!

**Step 5**: Apply separation to B = F(P /\ R_< /\ S(Q /\ R_<, top)).
This formula mixes future (F, P, R_<) and past (S, Q, R_<). The separation property
rewrites it. By GHR94 Chapter 10, we use the elimination lemmas:
- F(P /\ R_< /\ S(Q /\ R_<, top)) -- R_< is "in the future of t," which from t's
  perspective is "always true in the future." So in a separated form:
  - R_< at any point s > t is TRUE
  - S(Q /\ R_<, top) at s > t: "exists w < s with Q(w) /\ w > t" becomes
    "S(Q, top) if t < w < s is nonempty, but need w > t"

The full separation is complex but the result is:
B* = U(P /\ S(Q, top), top) -- i.e., "there exists a future P-point s with a Q-point
between t and s" -- which is U(P, Q) in effect.

Actually: the precise separated form would be F(P /\ Hq) which is known to equal
Hq /\ q /\ U(P, Q) (from GHR94 Example 9.2.1). In our case with R_< substituted by
top, the formula simplifies accordingly.

### Key Insight

The GHR94 approach uses the separation property AS AN INPUT to prove expressive completeness.
It does NOT prove separation first -- it assumes it and shows how to eliminate quantifiers.
Chapter 10 then proves separation for TL(U,S) independently, completing the circle.

This means the GHR94 approach for our codebase would require:
1. First prove the separation property for TL(U,S) over integer time (Ch. 10)
2. Then use Thm 9.3.1 to get expressive completeness

This is a DIFFERENT architecture from what the codebase implements.

## Q2: How the 8 Elimination Lemmas Remove Auxiliary Predicates

### The Elimination Mechanism (GHR94 Lemma 10.2.3)

The separation procedure has TWO phases:
1. **Elimination**: Pull each occurrence of U out from under each S (and vice versa)
2. **Induction on junction depth**: Repeat until no U is nested under S or vice versa

The 8 elimination lemmas handle every possible position of U(A,B) (or negU(A,B)) inside
S(a, q):

| Case | Formula | Key idea |
|------|---------|----------|
| 1 | S(a /\ U(A,B), q) | Case split on whether U(A,B) witness is past, present, or future of t |
| 2 | S(a /\ negU(A,B), q) | Use Lemma 10.2.2 negation, then reduce to Case 1 |
| 3 | S(a, q or U(A,B)) | Consider negation, use Lemma 10.2.2 and Case 2 |
| 4 | S(a, q or negU(A,B)) | Direct semantic argument |
| 5 | S(a /\ U(A,B), q or U(A,B)) | Combine Cases 1 and 3 |
| 6 | S(a /\ negU(A,B), q or U(A,B)) | Combine Cases 2 and 3 |
| 7 | S(a /\ U(A,B), q or negU(A,B)) | Case split on where A is true |
| 8 | S(a /\ negU(A,B), q or negU(A,B)) | Reduce to previous via negation identity |

**Example (Case 1 in detail)**: S(a /\ U(A,B), q) holds at t iff there exists s < t with:
- a holds at s, U(A,B) holds at s, q holds everywhere on (s,t).
- U(A,B) at s means: exists u > s with A(u) and B on (s,u).

Three sub-cases for u relative to t:
- u > t: S(a,q) /\ S(a,B) /\ B /\ U(A,B) [B extends from s through t to u]
- u = t: A /\ S(a,B) /\ S(a,q) [A at t, B from s to t]
- u < t: S(A /\ q /\ S(a,B) /\ S(a,q), q) [A at some u in (s,t)]

Result: U(A,B) no longer appears under S; it only appears at the top level.

### How This Applies to R_=, R_>, R_< Elimination

After Step 5 of the GHR94 proof (applying separation), the formula B is rewritten as a
boolean combination of pure past, pure future, and present formulas. Each "pure" sub-formula
still contains the auxiliary atoms r_=, r_>, r_<. The SUBSTITUTION step (Step 6) replaces
them with constants (top or bot) based on the region.

The separation procedure is what makes Step 6 VALID. Without separation, B might have a
subformula like F(p /\ S(r_<, q)) where r_< is TRUE in the future (so at points PAST of
some future point s > t, r_< might be true or false depending on whether the point is
above or below t). Separation disentangles these cross-temporal dependencies.

### Separation is the HARD part

The 8 elimination lemmas (Lemma 10.2.3) and their composition into the full separation
theorem (Lemma 10.2.8) is the MAIN technical content of Chapter 10. The induction on
"junction depth" (Definition in 10.2.8) requires 600+ lines of equivalences.

For Dedekind complete time (Section 10.3), the separation is even more complex because
the K+/K- connectives are needed to handle limit behavior, adding 4 more elimination cases
and the Gamma+/Gamma- connectives.

## Q3: Mapping to Our Codebase

### What Exists

| Component | Status | File | Notes |
|-----------|--------|------|-------|
| NF evaluation (`nf_eval_nf`) | SORRY-FREE | NormalForm.lean | Core n-var NF semantics |
| Depth-0 characteristic formulas | SORRY-FREE | Separation/KampTranslation.lean | `nf_depth0_char_formula` |
| VecEA2 pipeline (Prop 3.5) | SORRY-FREE | VecEATranslation.lean | `VVecEA2.translateLeft_correct` |
| VecEA2 negation (Prop 4.2) | SORRY-FREE | NegationClosureProp42.lean | `neg_2var_vec_ea` |
| NF-to-VecEA bridge (depth 0) | SORRY-FREE | NfToVecEA.lean | 634 lines, depth-0 only |
| GHR94 Lem 10.2.2 (neg Until/Since) | SORRY-FREE | SeparationBridge.lean | `neg_until_equiv_prior` |
| Forward direction (exists->formula) | SORRY-FREE | NegationClosure.lean | `nf_exist_formula_nested_forward` |
| Backward direction depth-0 | SORRY-FREE | NegationClosure.lean:79 | `backward_depth0` |
| Backward direction depth k+1 | SORRY | NegationClosure.lean:1716 | `nf_exist_formula_nested_backward` |
| Projection/drop-last composition | SORRY-FREE | NfComposition.lean | `nf_drop_last`, `intra_structure_extend` |

### What Is Missing

1. **MonadicFormula type / nf_to_monadic_fo conversion**: The codebase does NOT have a monadic
   FO formula type or a function converting NF evaluation to monadic FO formulas. There is
   no `MonadicFormula`, `monadic_fo`, `nf_to_formula`, or `toFormula` anywhere in the Kamp
   directory. The `ExistsForallSpec` and `BracketFormula` types exist but serve a different
   purpose (interval decomposition rather than general monadic FO).

2. **Separation procedure (GHR94 Ch. 10.2)**: The 8 elimination lemmas are NOT formalized.
   Only the negation equivalence (Lemma 10.2.2) is present. The full separation procedure
   (Lemmas 10.2.4-10.2.8) would require formalizing all 8 cases + the junction depth induction.

3. **GHR94 Theorem 9.3.1 (separation => expressive completeness)**: Not formalized. The
   codebase takes the Rabinovich approach instead.

4. **Formula-level approach**: The codebase works entirely at the NF level (NormalForm sig k n),
   not at the formula level (monadic FO). This is a fundamental architectural choice that
   makes the GHR94 approach difficult to graft on.

### The NF-to-FO Conversion Question

The codebase does NOT have nf_to_monadic_fo. The reason: the codebase bypasses the
formula level entirely. Instead of:
  NF eval -> monadic FO formula -> TL(U,S) via Kamp
it does:
  NF eval -> directly construct temporal formula via master_induction

This is more direct but hits the composition wall because the backward direction at
depth k+1 requires reconstructing n-var NF evaluation from temporal formula truth,
which the formula-level approach handles via the separation property.

## Q4: The Rabinovich Approach (Proposition 4.3 + Lemma 3.4(3))

### How Lemma 3.4(3) Works

**Lemma 3.4(3)**: The class of V-exists-forall formulas is closed under existential
quantification. If phi is V-exists-forall, so is exists x phi.

**Proof**: By Lemma 3.2(3), for every exists-forall formula
  psi(z_0,...,z_m) = exists x_n...exists x_0 (ordering /\ point_types /\ interval_types),
the formula exists z_i psi is also exists-forall -- simply move z_i into the list of
existentially quantified variables.

**Concretely**: If phi(x, z_0) = exists x_1...exists x_n (z_0 < x_1 < ... < x_n,
alpha_j(x_j), beta_j on intervals), then:

exists x phi(x, z_0) = exists x exists x_1...exists x_n (ordering /\ alpha_j /\ beta_j)

where x is placed somewhere in the ordering relative to z_0. By the definition of
exists-forall formulas, the ordering constraints enumerate all possible positions of x
among x_1,...,x_n, so the result is a DISJUNCTION of exists-forall formulas (one for
each position of x).

**Critical point**: This is structurally trivial because EXISTS commutes with EXISTS.
Adding one more existential variable to an exists-forall formula just extends the
prefix. The hard part is NEGATION (Proposition 4.2), not existential quantification.

### How Proposition 4.3 Works

**Prop 4.3**: Every FO formula is equivalent over Dedekind complete chains to a
V-exists-forall formula.

**Proof by structural induction**:
- Atomic: immediate (0-variable exists-forall).
- Disjunction: V-EA is closed under disjunction (trivial).
- Negation: By Prop 4.2, the negation of an EA formula with <= 2 free variables is V-EA.
  By Lemma 3.2(2), every EA formula is equivalent to a conjunction of EA formulas with
  at most 2 free variables. So neg(EA) = neg(conj of 2-var EAs) = disj of neg(2-var EAs),
  each of which is V-EA by Prop 4.2.
- Existential quantification: By Lemma 3.4(3) (closure of V-EA under exists).

### The Structure of Prop 4.2 (Negation Closure)

This is the HARD part. The negation of an EA formula with 2 free variables (z_0, z_1) and
bracket notation [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1) is V-EA.

The proof uses induction on n (number of existential witnesses) with a case decomposition
based on WHERE the pattern fails:
- Case 1: alpha_0 fails at z_0 (endpoint type mismatch)
- Case 2: alpha_0 holds but the interval pattern never gets started
- Case 3: alpha_0 holds, the pattern starts but fails at some interior point

The INF formula (Notation 5.2) uses Dedekind completeness to find the infimum of the
set where the first predicate holds. This is the only place where Dedekind completeness
is used.

### Rabinovich vs GHR94 Comparison

| Aspect | GHR94 | Rabinovich |
|--------|-------|-----------|
| Target | Separation => expressive completeness | EA normal form => TL |
| Hard step | 8 elimination lemmas (syntactic) | Negation closure (semantic) |
| Approach | Syntactic rewriting | Interval decomposition |
| Circularity | Assumes separation, proves completeness | Self-contained |
| Prior dependency | Not needed (works on all linear flows) | Uses Dedekind completeness |

## Q5: Which Approach Is Most Implementable?

### Current State Assessment

The codebase has invested heavily in a THIRD approach (neither GHR94 nor Rabinovich):
**NF-level master induction** with formula construction per NF type. This approach has:

- P1(k) sorry-free for all k (given P2(k-1))
- P2(0) sorry-free
- P2(k+1) blocked at `nf_exist_formula_nested_backward` (line 1716)
- Forward direction sorry-free
- Backward direction requires: from temporal formula truth, reconstruct the fact that
  `nf_eval_nf M (k+1) 2 (x, t) sub_nf`, specifically the quantifier part sub_nf.2

### The Three Paths

**(A) GHR94 Approach**: NF eval -> auxiliary predicates -> separation -> eliminate

**Estimated effort**: 2000-4000 lines. Would require:
1. Monadic FO formula type (~200 lines)
2. NF-to-monadic-FO conversion (~300 lines)
3. All 8 elimination lemmas for integer time (~800 lines)
4. Junction depth induction (Lemmas 10.2.4-10.2.8) (~400 lines)
5. GHR94 Theorem 9.3.1 (~400 lines)
6. Wiring to existing infrastructure (~200 lines)

**Risk**: Very high. Essentially a parallel formalization. Does not leverage any of the
existing 2400+ lines of sorry-free code. The 8 elimination lemmas alone are a major
formalization effort.

**Verdict**: NOT RECOMMENDED. Too much new code; does not reuse existing infrastructure.

**(B) Rabinovich Approach**: NF eval -> V-EA formula -> Prop 3.5 translation

**Estimated effort**: 1000-2000 lines. Would require:
1. NF-to-EA formula conversion (~300 lines) -- connecting nf_eval_nf to BracketFormula/ExistsForallSpec
2. Prop 4.2 negation closure for 2-var EA (~300 lines) -- ALREADY DONE: `neg_2var_vec_ea`
3. Prop 4.3 structural induction (~200 lines) -- mostly wiring
4. Prop 3.5 translation correction (~200 lines) -- `bracketBuildLeft_correct` has sorries at n>0

**Advantages**: Prop 4.2 is already sorry-free. The VecEA2 infrastructure is largely
built. Main gap is the NF-to-EA bridge and fixing the Since-direction translation.

**Risk**: Medium. The VecEADecomposition.lean file is QUARANTINED (Case C soundness blocked).
The Prop 3.5 Since-direction (`bracketBuildLeft_correct`) has 2 sorries at general n.

**Verdict**: PARTIALLY VIABLE but requires fixing quarantined code.

**(C) Hybrid/Direct: Fix nf_exist_formula_nested_backward directly**

**Estimated effort**: 200-500 lines if the RIGHT lemma is found.

The backward direction at depth k+1 needs ONE key fact:

**Given**: x such that `nf_eval_nf M (k+1) 1 (fun _ => x) nf_x` (from char_kp1), and
for each positive interval ssn, y such that `nf_eval_nf M (k+1) 1 (fun _ => y) nf_y`
(from the Since/Until in the formula), and `nf_full_compat_right` passes.

**Need**: For each ssn, `(exists y, nf_eval_nf M k 3 (y,x,t) ssn) <-> sub_nf.2 ssn = true`.

The forward direction (sub_nf.2 ssn = true -> exists y) is what the formula encodes for
interval ssn's. For non-interval ssn's, `nf_full_compat_right` checks consistency.

The backward direction (exists y -> sub_nf.2 ssn = true) requires:
sub_nf.2 ssn = (nf_characteristic M (k+1) 2 (x,t)).2 ssn.

But sub_nf is a PARAMETER, not necessarily the characteristic NF at (x,t). The formula
was constructed for this SPECIFIC sub_nf, and its filtering (nf_full_compat_right) ensures
that if nf_x is the right 1-var NF, then sub_nf's non-interval conditions are consistent.

**The key insight I have not seen explored**: Rather than proving sub_nf = characteristic
NF at (x,t), prove it via the UNIQUENESS of NF evaluation. If we can show that
`nf_eval_nf M (k+1) 2 (x,t) sub_nf` holds (both atom and quantifier parts), then
sub_nf = nf_characteristic M (k+1) 2 (x,t) by `nf_eval_unique`.

The atom part is established by the formula (h_atom_part in backward_2var_nf_agreement).
The quantifier part (h_quant) is what we need. And h_quant has BOTH directions:
- sub_nf.2 ssn = true -> exists y: this is what the formula provides (for interval ssn's
  via Since/Until witnesses, for non-interval ssn's via nf_full_compat_right).
- exists y -> sub_nf.2 ssn = true: this is the HARD direction.

**However**: the formula filtering (nf_full_compat_right) is designed so that for the
SPECIFIC nf_x selected by the formula, sub_nf.2 ssn = false for all ssn's that are
atom-incompatible with nf_x. But for atom-COMPATIBLE ssn's where sub_nf.2 ssn = false,
the formula does NOT encode anything (the negative conditions are absent from the guard).

This means: if there exists a y in the model such that nf_eval_nf M k 3 (y,x,t) ssn holds
for an ssn with sub_nf.2 ssn = false, the formula would still be true (the formula only
checks positive conditions), creating a false positive.

**This is the fundamental gap**: the formula `nf_exist_formula_nested` does NOT encode
negative quantifier conditions. The guard is `Formula.top` (line 847). A correct formula
would need to assert "for each ssn with sub_nf.2 ssn = false, there is NO y in the interval
with the ssn-compatible 1-var NF."

**Path C1 (Enriched Formula)**: Modify `nf_exist_formula_nested` to encode negative interval
conditions in the guard. For each ssn with sub_nf.2 ssn = false and ssn_in_interval_right,
add a guard clause: G(neg(disj of char_kp1 nf_y for compatible nf_y)). This would make the
backward direction hold because the formula explicitly forbids false-positive witnesses.

Estimated effort for C1: 300-500 lines. Modify formula construction, re-prove forward
direction (should still work since adding guard constraints only strengthens the formula),
then backward direction becomes much more tractable.

**Path C2 (Characterize the gap)**: Prove that on Prior structures, if nf_full_compat_right
passes for nf_x, then sub_nf.2 ssn = false for all ssn with sub_nf.2 ssn = false is
AUTOMATICALLY satisfied (i.e., no such y exists). This would require showing that
nf_full_compat_right is a COMPLETE filter on Prior structures.

Estimated effort for C2: 400-800 lines. Requires a non-trivial inductive argument about
what nf_full_compat_right actually guarantees.

**Verdict**: Path C1 (enriched formula) is the shortest path. The formula needs negative
guard conditions to make the backward direction provable.

### Recommendation

**Path C1: Enrich the formula with negative interval guards.**

1. Modify `nf_exist_formula_nested` (NegationClosure.lean:793-894) to add negative
   interval conditions to the guard.

2. The guard for the Until case should be:
   ```
   for each ssn with sub_nf.2(ssn) = false AND ssn_in_interval_right(ssn):
     G(neg(disj of char_kp1(nf_y) for all nf_y compatible with ssn at var 0))
   ```
   This says: no point in (t,x) has a 1-var NF compatible with a forbidden interval ssn.

3. The guard for the Since case should be symmetric.

4. Forward direction: given exists x with nf_eval_nf, the guard holds because if
   sub_nf.2(ssn) = false, then no y in the interval can have the full 3-var NF ssn
   (since (x,t) has the 2-var NF sub_nf which says ssn is unrealized).

5. Backward direction: from the formula truth, the guard gives us that no y has a
   forbidden-ssn-compatible 1-var NF. Combined with the positive conditions, this
   recovers h_quant exactly.

**HOWEVER**: Step 4 above has a subtle problem. sub_nf.2(ssn) = false means no y
has nf_eval_nf M k 3 (y,x,t) ssn. But the guard says no y has a 1-var NF compatible
with ssn at var 0. These are NOT equivalent: a y could have a compatible 1-var NF
(right predicates) but NOT satisfy the full 3-var NF ssn (wrong 2-var NFs at (y,x)
or (y,t) or wrong quantifier conditions). So the guard would be TOO STRONG in the
forward direction.

**Corrected approach**: The guard should forbid the conjunction of ALL conditions that
together imply nf_eval M k 3 (y,x,t) ssn. At depth 0, this is just atoms (predicates
and order), which the 1-var NF handles. At depth k+1, this requires quantifier conditions
too, creating the same recursion problem.

This means Path C1 does NOT avoid the composition problem. It just pushes it into the
guard construction.

### Revised Recommendation

After careful analysis, the fundamental mathematical obstacle is the same regardless of
approach: **reconstructing n-var NF agreement from 1-var NF information**.

The ONLY approach that avoids this is the formula-level approach (GHR94 or Rabinovich),
because it works with monadic FO formulas rather than NFs. In the formula-level approach,
the separation property handles the cross-temporal dependencies that the NF approach
cannot.

**Best path forward**: **Fix the VecEA translation (Path B)**. Specifically:

1. Fix `bracketBuildLeft_correct` (NfToVecEA.lean:472-475) -- 2 sorries for general n.
   This is the Since-direction analog of the sorry-free `bracketBuildRight_correct`.

2. Build the NF-to-EA bridge at depth k+1: convert `exists x, nf_eval_nf M (k+1) 2 (x,t) sub_nf`
   into a V-EA formula, using Lemma 3.4(3) (closure under exists) and the already sorry-free
   `neg_2var_vec_ea` (Prop 4.2).

3. Apply the sorry-free VecEA2 translation to get a TL(U,S) formula.

4. The correctness proof follows from the composition of: nf_eval iff EA.holds iff TL.truth.

**Estimated total**: 500-800 lines, mostly fixing `bracketBuildLeft_correct` and building
the NF-to-EA bridge.

## Adversarial Self-Verification

### Challenged Claims

1. **Claim**: "generalized_composition is FALSE" -- VERIFIED. The counterexample is
   documented in NfComposition.lean lines 22-36 with a clean proof sketch. M = (Z, <),
   env1 = (0, 2), env2 = (0, 1), k = 1.

2. **Claim**: "Path C1 (enriched formula) avoids the composition problem" -- REVISED.
   The guard in the forward direction requires that no y has a forbidden-ssn-compatible
   NF, but this is STRONGER than sub_nf.2 ssn = false at depth > 0. Corrected in the
   analysis above.

3. **Claim**: "Prop 4.2 negation closure is sorry-free" -- VERIFIED via lean_local_search
   for `neg_2var_vec_ea` (NegationClosureProp42.lean). The file is not quarantined.

4. **Claim**: "bracketBuildLeft_correct has 2 sorries" -- VERIFIED. NfToVecEA.lean:472
   and :475 are both `sorry`.

5. **Claim**: "VecEADecomposition.lean is quarantined" -- VERIFIED. The file header
   explicitly says "QUARANTINED (Task 273, Plan v23)".

### Uncertain Claims (Confidence Levels)

1. "Path B estimated at 500-800 lines" -- MEDIUM confidence. The bracketBuildLeft_correct
   fix could be straightforward (mirror bracketBuildRight_correct) or could surface new
   issues with BracketFormula.prepend in the Since direction.

2. "NF-to-EA bridge at depth k+1 is buildable" -- LOW-MEDIUM confidence. The conversion
   from nf_eval_nf to BracketFormula.holds requires encoding the quantifier conditions
   (sub_nf.2) as interval patterns, which is conceptually the same as what
   nf_exist_formula_nested does. The advantage is that the EA framework has sorry-free
   negation closure (Prop 4.2), but the bridge itself may face the same composition issues.

### Recommendations Modified After Verification

The Path C1 recommendation was REVISED to Path B after adversarial verification revealed
that enriching the formula guard does not avoid the composition problem at depth > 0.

## Tactic Survey Results

No tactics were tested in this research session (pure literature/codebase analysis).

## Literature Proof Structure

### GHR94 Chapter 9-10 Proof Architecture

```
Ch. 9: Separation <=> Expressive Completeness
  Thm 9.3.1: Separation => Completeness
    [IH on quantifier depth m]
    Step 1: Auxiliary predicates R_=, R_>, R_<
    Step 2: Factor out Q_i(t) from quantifier scope
    Step 3: Apply IH to get temporal formula B with auxiliary atoms
    Step 4: Specialize interpretation h*
    Step 5: Apply separation to B
    Step 6: Substitute top/bot for auxiliary atoms
  Thm 9.3.4: Completeness => Separation
    [via truth table lemma 9.1.5 + monadic separation 9.3.2/9.3.3]

Ch. 10: Prove Separation for U,S over integer time
  Lem 10.2.1: Distributivity of U/S over or/and
  Lem 10.2.2: Negation of U/S
  Lem 10.2.3: 8 elimination lemmas (U from under S)
  Lem 10.2.4-10.2.7: Induction lemmas (one U, multiple U, nested U)
  Lem 10.2.8: Full separation by junction depth induction
  Thm 10.2.9-10.2.10: Separation + expressive completeness
```

### Rabinovich 2014 Proof Architecture

```
Section 3: Exists-Forall Normal Form
  Def 3.1: EA formula (interval decomposition)
  Lem 3.2: Closure under conjunction, 2-var reduction, exists
  Lem 3.4: V-EA closed under disj, conj, exists
  Prop 3.5: V-EA with 1 free var => TL(U,S)

Section 4: Main Argument
  Prop 4.2: neg(EA with <=2 free vars) is V-EA [HARD]
  Prop 4.3: Every FO formula is V-EA [structural induction]
  Thm 4.4: Kamp's theorem [compose Prop 4.3 + Prop 3.5]

Section 5: Proof of Prop 4.2 (Interval Splitting)
  Lem 5.1: neg([alpha_0,...,alpha_n](z_0,z_1)) is V-EA
  Lem 5.3: Base case (all beta_i = True)
  Cor 5.4: neg(exists z [pattern](z_0,z)) is V-EA
  Full proof: Case decomposition on failure mode + IH on n
```

## Memory Candidates

### Candidate 1: GHR94 Auxiliary Predicate Architecture
**Keywords**: GHR94, auxiliary predicates, separation, R_=, R_>, R_<, Theorem 9.3.1
**Content**: The GHR94 approach to expressive completeness introduces auxiliary unary
predicates R_=(y) = (t=y), R_>(y) = (t>y), R_<(y) = (t<y) to convert the free variable
t into atom-level information, applies the IH to get a temporal formula with auxiliary
atoms, then uses the SEPARATION PROPERTY to decompose into pure past/future/present
components, and finally substitutes top/bot for the auxiliary atoms based on the region.
This approach requires separation as INPUT, not as OUTPUT.

### Candidate 2: Composition Lemma is False
**Keywords**: generalized_composition, Feferman-Vaught, counterexample, NfComposition
**Content**: The naive composition lemma "same depth-(k+1) 1-var NFs + matching orders
implies same depth-k n-var NFs" is FALSE. Counterexample: M = (Z, <), env1 = (0,2),
env2 = (0,1), k=1. All integers have same 1-var NF (translation symmetry), 0<2 iff 0<1,
but depth-1 2-var NFs differ (zone "strictly between" is nonempty for (0,2) but empty for
(0,1)). The correct statement needs depth-(k+1) PAIRWISE 2-var NF agreement.

### Candidate 3: Formula Guard Gap in nf_exist_formula_nested
**Keywords**: nf_exist_formula_nested, guard, negative conditions, backward direction
**Content**: The formula nf_exist_formula_nested uses guard = Formula.top (trivially true)
and does NOT encode negative quantifier conditions (sub_nf.2(ssn) = false for interval ssn).
This makes the backward direction unprovable: the formula accepts false positives where
a forbidden-type witness exists in the interval. Enriching the guard with negative conditions
does not help at depth > 0 because the guard would need to distinguish full 3-var NF
compatibility from 1-var NF compatibility, requiring the same composition argument.
