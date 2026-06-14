# Teammate B Findings: Alternative Approaches from Literature & VecEADecomp

**Task**: 273 - chronicle_gap_contradiction_proof
**Artifact**: 26
**Teammate**: B
**Focus**: Literature-grounded alternative formula design using Rabinovich 2014, GHR94 Ch.10, and existing VecEADecomp infrastructure

## Key Findings

### Finding 1: Rabinovich 2014 handles multi-variable existentials via interval decomposition, NOT per-variable temporal encoding

Rabinovich's Proposition 3.5 translates exists-forall formulas with one free variable into TL(Until, Since) using nested Until/Since that directly mirrors the interval decomposition. The critical mechanism (Section 3, pp. 90-94):

An exists-forall formula `psi(z_k)` with witness points `x_0 < ... < x_n` and the free variable `z_k` at position k in the ordering produces:

```
A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... )))   -- future part
A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... )))   -- past part
```

where `A_i` is the point type at witness `x_i` and `B_i` is the segment type between consecutive witnesses.

**Key insight for our problem**: Rabinovich does NOT encode individual witness conditions separately and combine them. Instead, the interval decomposition structure IS the formula. Witnesses are not referenced by their temporal position relative to a FIXED evaluation point; they are BETWEEN other witnesses in a chain. The nested Until/Since structure exactly captures the witness ordering.

This means: the approach of encoding `exists y` as `Since(char_y, top)` at x and then worrying about the y-t relationship is fundamentally wrong. Rabinovich would instead place y IN the bracket structure between t and x (or x and t), making the y-t order automatic.

### Finding 2: GHR94 Chapter 10 elimination lemmas handle mixed past/future by distributing conditions across the temporal structure

The 8 elimination lemmas in Lemma 10.2.3 (and the 12 extended cases in Lemmas 10.3.8-10.3.11 for Dedekind complete time) show how to eliminate a temporal operator `U(A,B)` from under the scope of `S`. The critical pattern:

**Elimination 1** (Lemma 10.2.3.1): `S(a AND U(A,B), q)` is equivalent to:
```
S(a, q) AND S(a, B) AND B AND U(A,B)     -- witness u > t
OR A AND S(a, B) AND S(a, q)              -- witness u = t
OR S(A AND q AND S(a,B) AND S(a,q), q)    -- witness u < t
```

This corresponds exactly to zone decomposition: the three disjuncts handle the case where the Until witness `u` is in the future of the current point (u > t), at the current point (u = t), or in the past (u < t). The point types and interval types are distributed across the Since/Until structure according to which zone the witness falls in.

**Relevance to our problem**: The fundamental difficulty is encoding the y-t order from x's perspective. GHR94's approach is to NOT do this from a single point. Instead, they decompose the formula so that conditions about y relative to t are placed at t's position in the temporal structure, and conditions about y relative to x are placed at x's position. The two are connected by the nesting structure of Until and Since.

### Finding 3: VecEADecomp.lean already has sorry-free zone theorems for ALL cases

VecEADecomp.lean (898 lines, 0 sorries) provides complete zone coverage for the depth-0 3-var existential `exists y, nf_eval_nf M 0 3 (y, x, t) ssn`:

| Zone | Theorem | VecEA2 evaluation |
|------|---------|-------------------|
| y < t < x | `nf_3var_zone_ytx_correct` | holds(t, x) with sinceWitnessPred at t |
| t < y < x | `nf_3var_bracket_tyx_correct` | holds(t, x) with bracket witness |
| t < x < y | `nf_3var_zone_txy_correct` | holds(t, x) with untilWitnessPred at x |
| x < y < t | `nf_3var_bracket_xyt_correct` | holds(x, t) with bracket witness |
| x < t < y | `nf_3var_zone_xty_correct` | holds(x, t) with untilWitnessPred at t |
| y < x < t | `nf_3var_zone_yxt_correct` | holds(x, t) with sinceWitnessPred at x |
| y = t | `nf_3var_eq_yt` | direct NF eval substitution |
| y = x | `nf_3var_eq_yx` | direct NF eval substitution |
| inconsistent | `nf_3var_order_contradiction` | False |

Each zone theorem produces a VecEA2 with the correct orientation. The VecEA2 can then be translated to a temporal formula via the sorry-free `VecEA2.translateLeft` / `VecEA2.translateRight` infrastructure.

**Critical observation**: The zone theorems take `(M : OrderedMonadicStructure sig) (t x : M.carrier)` as parameters and produce `VecEA2.holds M atomMap t x <-> exists y, nf_eval_nf M 0 3 (y,x,t) ssn`. The VecEA2 is NOT parameterized by M -- it is a pure formula-level construction. This means we can build the VecEA2 statically and translate it to a temporal formula that works for ALL models.

### Finding 4: The blocker is NOT at depth 0 -- VecEADecomp already solves depth 0

The current KampBypass.lean already uses VecEADecomp successfully for the depth-0 case. The `enriched_bypass_until` function builds a VVecEA2 from zone-classified VecEA2s and translates via `VVecEA2.translateLeft`. The depth-0 case (k=0 in `existPart_succ_n1_bypass_k0`) delegates correctly.

The 10 sorries in KampBypass.lean are all in the proof of semantic equivalence between the VecEA2-based formula and the NF existential. Specifically:

| Sorry | Location | Nature |
|-------|----------|--------|
| `existPart_succ_n1_bypass_k0_eq` L690 | Equality (x=t) direction | Formula ↔ NF eval at (t,t) |
| L752 | t-predicate compatibility sub-case | Inner sorry of x=t |
| `zone_3var_exist_iff_1var` L842 | Zone reduction for Until direction | 3-var ↔ 1-var + orders |
| `backward_holdsLeft_of_nf_eval` L923 | endpointLeft (pre-conditions at t) | NF eval → endpointLeft |
| L935 | endpointRight (eq_x, above_x zones) | NF eval → endpointRight |
| L939 | bracket (between_tx zone) | NF eval → bracket witnesses |
| `forward_nf_eval_of_holdsLeft` L997 | holdsLeft → NF eval reconstruction | Full forward direction |
| `existPart_succ_n1_bypass_k0_since` L1109 | Since direction (x < t) | Mirror of Until |
| `existPart_succ_n1_bypass` L1197 | General k > 0 | Higher depth (not depth-0) |

These sorries are "wiring" sorries -- the mathematical content is already in VecEADecomp's zone theorems, but the semantic bridge between VecEA2.holdsLeft and nf_eval_nf has not been fully connected.

### Finding 5: The REAL blocker is the ternary composition at depth k+1

At depth k+1, `sub_nf.2 : NormalForm sig k (n+2) -> Bool` records for each ssn whether `exists y, nf_eval_nf M k 3 (y,x,t) ssn`. This is a depth-k 3-var existential. To encode this as a temporal formula evaluated at x (or t), we need to know that the 3-var existential can be expressed temporally. But this is exactly the P_3(k) instance of the generalized theorem -- which requires solving the same problem at higher arity.

The fundamental mathematical fact (Rabinovich 2014, Lemma 3.2(2)): every exists-forall formula with m >= 3 free variables is equivalent to a conjunction of exists-forall formulas with at most 2 free variables. This reduction is done by projecting pairs of variables and combining.

**But**: the Lean formalization parameterizes NFs by (depth, arity), and the depth-k reduction from 3-var to 2-var uses the SAME depth k, not depth k-1. So there is no induction leverage on depth alone -- you also need arity reduction.

This is precisely why plan v29 proposed the generalized P_n(k) theorem with induction on k and arity n as parameter. The base case P_n(0) is sorry-free (`existPart_zero`). The step P_n(k+1) uses P_{n+1}(k) -- depth decreases but arity increases. Since depth eventually reaches 0 and P_n(0) is already proved for all n, the induction terminates.

## Recommended Approach

### Option A (Recommended): Fill the depth-0 wiring sorries, then build the k+1 induction

The 10 sorries in KampBypass.lean should be attacked in two waves:

**Wave 1 (depth-0 wiring, ~8 sorries)**: These are all mechanical. The VecEADecomp zone theorems provide the correct VecEA2 for each zone. The `enriched_vecEA2_until` construction in KampBypass already builds the right VVecEA2. What's missing is:

1. `zone_3var_exist_iff_1var` (L842): Case-split on `ssn_zone_until ssn` and apply the corresponding VecEADecomp theorem. For each zone, the 3-var existential reduces to a predicate condition + order condition on y, which is exactly what the zone theorem proves. Estimated: 200 lines of case analysis.

2. `backward_holdsLeft_of_nf_eval` endLeft (L923): For each ssn in below_t or eq_t zone, use `h_eval_quant` (the quantifier part of nf_eval) to determine whether the 3-var existential holds, then verify the zone-based temporal formula at t. Estimated: 100 lines.

3. `backward_holdsLeft_of_nf_eval` endRight (L935): Similarly for eq_x and above_x zones at x. Estimated: 80 lines.

4. `backward_holdsLeft_of_nf_eval` bracket (L939): For positive between_tx zones, extract the bracket witness y from the 3-var existential. y is between t and x by the zone constraint, so it directly serves as a bracket witness. Estimated: 60 lines.

5. `forward_nf_eval_of_holdsLeft` (L997): From holdsLeft, extract x from Until, extract char_1(nf_x) holding at x, reconstruct atom part of nf_eval from nf_x compatibility, reconstruct quantifier part from each zone formula at t and x. Estimated: 150 lines.

6. `existPart_succ_n1_bypass_k0_since` (L1109): Mirror of the Until case. Estimated: 300 lines (copy-adapt from Until).

7. `existPart_succ_n1_bypass_k0_eq` (L690): When x = t, the formula is evaluated directly at t. Each 3-var zone collapses (y < t, y = t, y > t). Estimated: 100 lines.

Total for Wave 1: ~1000 lines of mechanical proofs.

**Wave 2 (k+1 induction, 1 sorry)**: `existPart_succ_n1_bypass` at L1197 for k > 0. This requires the arity-climbing insight: use the IH at depth k for (n+1)-var existentials to encode each 3-var sub-NF condition. The enriched formula at x encodes `char_{k+1}(nf_x)` (from the IH for 1-var NFs) conjuncted with the quantifier profile (each ssn condition encoded via `Classical.choose` on the IH at depth k for 3-var existentials).

This is the approach described in plan v29, Phase 2. The main difference from Wave 1 is that zone conditions at depth k+1 are NOT purely atomic -- they involve depth-k quantifier conditions. But the IH at depth k provides temporal formulas for these conditions, and the enriched formula is constructed by building a VVecEA2 with these IH-formulas as TemporalPred components.

Estimated: 200-300 lines.

### Option B (Alternative): Direct interval decomposition without per-ssn encoding

Instead of encoding each ssn separately and combining, follow Rabinovich's approach more literally: treat the full existential `exists x, nf_eval_nf M (k+1) 2 (x, t) sub_nf` as a SINGLE exists-forall formula and build the VecEA2 directly.

**How**: At depth k+1, `sub_nf` decomposes into atom conditions (which determine x's position relative to t) and quantifier conditions (which determine a conjunction of 3-var existential conditions). Group the quantifier conditions by y's zone relative to (t, x), and for each zone, build the appropriate temporal component:
- y < t zone: sinceWitnessPred at t (endpoint left)
- t < y < x zone: bracket witness in the VecEA2
- y > x zone: untilWitnessPred at x (endpoint right)

This avoids per-ssn encoding entirely. Instead of `conjunction of (ssn_formula OR neg ssn_formula)`, we build a SINGLE VecEA2 whose bracket, endpoint left, and endpoint right encode exactly the conditions that exist-y-witnesses must satisfy in each zone.

**Advantage**: Avoids the blocker where two ssn values with different y-t orders but the same y-x and x-t orders produce conflicting temporal formulas at the same position.

**Disadvantage**: Requires building VecEA2 with TemporalPred components that are themselves conjunctions/disjunctions of depth-k IH formulas. The bracket formula `BracketFormula n` uses `TemporalPred` for point and segment types, which are just wrapped `Formula` values. Since `Formula` is closed under all connectives, this is structurally sound.

**Feasibility**: Medium. This is essentially what `enriched_vecEA2_until` already does for the Until direction, but it needs to be made fully correct for all zones and connected to the NF evaluation semantics.

### Option C (Least change): Fill only the wave-1 sorries, mark k>0 as future work

If the goal is to make maximal progress on the sorry count, filling the 8 depth-0 sorries in KampBypass.lean is the lowest-risk option. This closes `existPart_succ_n1_bypass_k0` (the k=0 case) and reduces the sorry count by 8, leaving only the k>0 sorry and the Since direction. The k>0 sorry is then a well-isolated target for future work.

## Evidence

### Rabinovich's Composition Method (Section 5)

The key to Rabinovich's proof of Proposition 4.2 (negation closure) is the interval splitting:

```
A_i^-(z_0, z) = [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z)
A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., beta_{n+1}, alpha_{n+1}](z, z_1)
```

When a new point z is inserted into interval (z_0, z_1), the negation decomposes into cases based on which sub-interval fails. This is the SAME structure as the zone decomposition in VecEADecomp.lean: the point y partitions the interval (t, x) and each zone determines a specific sub-interval pattern.

### GHR94's Q-lemma technique (Lemma 10.3.6)

GHR94 introduces `Q(A,B,C)` as an abbreviation that replaces `C => U(A,B)` with a SEPARATED formula (no U under S). This is the key technique for handling mixed past/future content.

The Q-lemma's conditions (Lemma 10.3.6):
1. `forall z in (t0, t1), C(z) => U(A,B)(z)` can be replaced by `forall z in (t0, t1), Q(A,B,C)(z)` given a boundary condition at t0.
2. Conversely, `forall z in (t0, t1), Q(A,B,C)(z)` gives back `C => U(A,B)` given a boundary condition at t1.

This is used in the 12 Dedekind-complete elimination lemmas (Lemma 10.3.11) to separate K+/K- from under S, and in the Gamma+/Gamma- eliminations (Lemma 10.3.10). The technique handles the exact situation where a past condition (involving S) must encode a future condition (involving U) that references a specific relationship between variables.

### VecEADecomp's zone theorem structure

The zone theorems in VecEADecomp encode the y-t order in the STRUCTURE of the VecEA2, not as a temporal formula at a single point:

- `sinceWitnessPred` (y < t): `TemporalPred = pred_t AND Since(pred_y, top)` -- this is evaluated at t's position (endpointLeft), so `Since(pred_y, top)` at t means `exists y < t, pred_y(y)`.
- `untilWitnessPred` (y > x): `TemporalPred = pred_x AND Until(pred_y, top)` -- evaluated at x's position (endpointRight), so `Until(pred_y, top)` at x means `exists y > x, pred_y(y)`.
- bracket (t < y < x): `BracketFormula.single pred_y top top` -- y is a bracket witness between t and x. The y-t and y-x orders are STRUCTURAL (guaranteed by the bracket position).

This is exactly Rabinovich's approach: the interval decomposition encodes position as structure, not as a temporal formula evaluated at a single point.

## Confidence Level

- **Finding 1 (Rabinovich's approach)**: HIGH -- direct from the paper, well-understood.
- **Finding 2 (GHR94 elimination)**: HIGH -- the 8 integer lemmas and 12 Dedekind lemmas are concrete.
- **Finding 3 (VecEADecomp coverage)**: VERY HIGH -- code is sorry-free and verified.
- **Finding 4 (depth-0 is solved)**: VERY HIGH -- direct code inspection.
- **Finding 5 (k+1 blocker)**: HIGH -- matches plan v29 analysis and prior reports.
- **Recommended approach (Option A)**: MEDIUM-HIGH -- the depth-0 wiring is mechanical but voluminous (~1000 lines). The k+1 induction (Wave 2) involves genuine mathematical content but follows the established pattern. Risk is in Lean type-checking complexity, not mathematical correctness.
- **Option B (direct VecEA2)**: MEDIUM -- structurally cleaner but requires more new infrastructure.
- **Option C (wave 1 only)**: HIGH -- lowest risk, highest confidence, limited impact.
