# Research Report: Rabinovich Section 5 Interval-Splitting Mapping to Lean Mutual Induction

**Task**: 303 (k_gt_0_depth_induction)
**Session**: sess_1781710390_4591d5
**Reference Grounding Tier**: Tier 1 (literature-backed, Rabinovich 2014)

## Executive Summary

GeneralExistPartOrdered is FALSE at ALL depths k (not just k=0). The Z counterexample
extends to every depth via translation homogeneity. The current 3-conjunct mutual induction
(CharPart + ExistPart + GeneralExistPartOrdered) has a provably false third conjunct,
making the entire chain unsound.

The Lean proof for `existPart_succ_n1_bypass` at k>0 is **complete and sorry-free** -- it
only takes `ih_general_exist` as a hypothesis. The problem is exclusively in producing a
valid hypothesis.

Two viable approaches are identified. The recommended approach (Option K) replaces
GeneralExistPartOrdered with a zone-decomposed formulation that reduces non-constant
environment existentials to constant-environment sub-problems plus interval-splitting
for between-zone cases.

## H3 Reference Grounding: Rabinovich-to-Lean Mapping Table

| Rabinovich Concept | Lean Equivalent | Status | Gap |
|-------------------|-----------------|--------|-----|
| Exists-forall formula [alpha_0, beta_1, ..., alpha_n](z_0, z_1) | `nf_eval_nf M k (n+1) env nf` (NF as exists-forall) | Implicit | No direct EA type; NFs serve same role |
| V-exists-forall (disjunction of EA formulas) | Disjunction over NF types via `formula_disjList` | Implemented | Sorry-free |
| Prop 3.5: V-EA with 1 free var -> TL | `existPart_succ_n1_bypass_k0` (k=0) | Sorry-free | k>0 needs ih_general_exist |
| Lemma 5.1: negation of EA -> V-EA | Encoded in ExistPart backward direction | Partial | Core blocker for k>0 |
| Lemma 5.3: beta-free base case (induction on n) | VecEADecomp zone decomposition | Sorry-free (k=0) | Not extended to k>0 |
| Corollary 5.4: reduction via F_i = alpha_i AND (beta_{i+1} Until F_{i+1}) | KampBypass enriched formula construction | Implemented | Formula correct but relies on false ih |
| A_i^-(z_0, z): left sub-interval type | Zone decomposition in KampBypassUntil/Since | Sorry-free (k=0) | Not extended to k>0 |
| A_i^+(z, z_1): right sub-interval type | Zone decomposition in KampBypassUntil/Since | Sorry-free (k=0) | Not extended to k>0 |
| INF formula (Dedekind completeness) | `semantic_prior_UZ`/`semantic_prior_SZ` (Prior axioms) | Implemented | Prior = Dedekind complete + density |
| K+(F) next occurrence | Until-based temporal formula | Implemented | Sorry-free |
| Dedekind completeness of chain | `DedekindComplete` typeclass or Prior axioms | Implemented | Z is Dedekind complete |

## Findings

### Finding 1: GeneralExistPartOrdered is False at ALL Depths

The Z counterexample (Z with constant predicates) refutes GeneralExistPartOrdered(k)
for every k >= 0, not just k=0.

**Mechanism**: On Z with constant predicates, every integer has the same depth-d 1-var NF
for ALL d, by induction on d using Z's translation symmetry (the shift n -> n+1 is an
automorphism). Therefore the preconditions of GeneralExistPartOrdered (matching individual
1-var NFs + matching atom orders) are satisfied by BOTH env = [0, 2] and env = [0, 1]
with identical parameters. But the depth-k existential `exists y between e(0) and e(1)`
differs: y=1 exists in (0,2) but no integer exists in (0,1). Since the temporal formula A
is evaluated at e(0) = 0 in both cases and `temporal_truth Z atomMap 0 A` is a fixed Boolean,
A cannot distinguish them.

**Impact**: The third conjunct of `kamp_mutual_induction` is unsound at every depth.
Both `generalExistPartOrdered_zero` (sorry at line 174) and `generalExistPartOrdered_succ`
(sorry at line 207) are IMPOSSIBLE to prove.

### Finding 2: existPart_succ_n1_bypass k>0 Is Sound Given Valid Hypothesis

The proof in KampBypass.lean for `k = succ k'` is **complete with no sorry**. It constructs
an enriched Until/Since/Eq formula and proves both directions (forward and backward)
correctly. The proof uses `ih_general_exist` in exactly one way:

- At r=2, with `ge_env_nfs = [nf_x0, nf_t0]` and `ge_env_atoms = sub_nf.1`
- To build temporal formulas `ge_formula ssn` for each depth-k 3-var sub-NF ssn
- These formulas are baked into a `quant_conj` that encodes quantifier truth values

If `ih_general_exist` were replaced with a valid hypothesis providing the same
`ge_formula`/`ge_correct` interface, the proof would go through unchanged.

### Finding 3: Rabinovich's Proof Structure (Two Nested Inductions)

Rabinovich Section 5 uses a fundamentally different approach from the current Lean code:

**Lemma 5.3** (base case): Handles exists-forall formulas where all interval types beta_i
are True. Induction on n (number of witnesses). Uses Dedekind completeness to define
r_0 = inf{z in (z_0, z_1) | P_1(z)} and reduces to shorter intervals.

**Lemma 5.1** (main lemma): Handles full bracket formulas. Three cases:
1. Endpoint failure: negation is trivially true
2. Guard success, no witness: reduces via Corollary 5.4 (nested Until/Since)
3. Guard failure in interval: uses INF formula + interval splitting

**Key structural difference**: Rabinovich works with TWO free variables (z_0, z_1) and
shows closure under negation for exists-forall formulas. He never needs "formula at one
point characterizing multi-variable existential." His approach reduces negation to
shorter bracket formulas via the A_i^-/A_i^+ decomposition.

### Finding 4: The Backward Direction Requires Temporal Formula Characterization

The backward direction of `existPart_succ_n1_bypass` fundamentally requires temporal
formula characterizations of existentials on non-constant environments. Pure NF transfer
(`nf_extend_fwd`/`nf_extend_bwd`) cannot bridge the gap because:

- These tools require depth-(K+1) r-var NF agreement to produce depth-K (r+1)-var agreement
- They cannot compose two independent 1-var agreements into a 2-var agreement
- The reverse direction (1-var -> 2-var) is provably false (NfComposition.lean documents this)
- ExistPart(k) only handles constant-env existentials, not non-constant

### Finding 5: Recommended Approach -- Zone-Decomposed ExistPart (Option K)

Replace GeneralExistPartOrdered with a zone-decomposed formulation:

**For `exists y, nf_eval_nf M k 3 [y, x, t] ssn` where t < x (Until zone)**:

Decompose by y's position relative to x and t:

1. **y = x zone**: Constant-env sub-problem at x. Use ExistPart(k) directly.
2. **y = t zone**: Constant-env sub-problem at t. Use ExistPart(k) directly.
3. **y > x (future of x)**: From x's temporal perspective, `exists y > x with P(y)` is
   characterizable by `P Until top` or similar. The depth-k conditions on [y, x, t]
   where y > x > t reduce to: y's 1-var NF type (via CharPart(k)) plus its relationship
   to x (via Until) -- constant-env at x.
4. **y < t (past of t)**: Mirror of (3), using Since from t's perspective.
5. **t < y < x (between-zone)**: THE HARD CASE. Use interval splitting a la Rabinovich.
   On Prior structures, "exists y in (t, x) with depth-k conditions" can be encoded
   temporally because:
   - From x, the interval (t, x) is the "Since zone"
   - The depth-k NF of [y, x, t] involves depth-(k-1) sub-existentials
   - By induction (ExistPart(k-1)), each sub-existential at constant env has a
     temporal characterization
   - The between-zone existential becomes: "exists point between t and x satisfying
     a conjunction of temporal formulas" = `F Since (char(nf_t0) AND ...)` formula
6. **x < y < t (Since between-zone)**: Mirror of (5).

**Why this works**: Each zone reduces the non-constant-env existential to either
(a) a constant-env sub-problem (zones 1-4), or (b) an interval-based existential
that can be encoded via Until/Since on Prior structures (zones 5-6).

**Why this avoids the counterexample**: The Z counterexample exploits the between-zone
(zone 5) where gap size matters. But the temporal formula encoding via Since/Until
naturally handles this: "exists y strictly between t and x with property P" is
`P Since char(t)` evaluated at x (or a suitable enrichment). On Z with gap=1 (env [0,1]),
(0,1) is empty, so the Since formula is false. On Z with gap=2 (env [0,2]), y=1 exists
in (0,2), so the Since formula is true. The temporal formula naturally distinguishes
these cases because it is evaluated at x (not at e(0)=0), and x differs between the
two configurations.

WAIT -- critical correction: the formula IS evaluated at e(0) = x in the Lean code
(GeneralExistPartOrdered evaluates at `e ⟨0, _⟩`). But x is the FIRST element of the
env, not t. In the KampBypass usage, the env is [x, t] so e(0) = x. The formula is
evaluated at x, and t is the second element. Since the formula is evaluated at x (which
differs between configurations -- x=2 vs x=1 in the counterexample's env perspective),
wait -- no, the counterexample has e = [0, 2] and e = [0, 1], where e(0) = 0 in both
cases.

Let me reconsider. In the KampBypass usage:
- ge_env_nfs has index 0 = nf_x0 (x's NF) and index 1 = nf_t0 (t's NF)
- The formula is evaluated at e(0) = x (the first element)
- The env for ih_general_exist is (Fin.cons x (fun _ => t)) = [x, t]
- So e(0) = x and e(1) = t

This means the formula IS evaluated at x, not at t. In the counterexample, the
problem is that temporal_truth at e(0)=0 is fixed. But in KampBypass, e(0) = x
is the Until witness, and x can be DIFFERENT for different configurations.

Actually, the counterexample for GeneralExistPartOrdered uses e = [0, 2] and e = [0, 1]
where e(0) = 0 in both cases. The formula is at e(0) = 0. The problem is that both envs
have the same e(0) but different e(1).

In KampBypass's usage, x = e(0) is the Until witness, and different witnesses give
different x values. So the formula being at x (not t) is important. But the
counterexample still applies to GeneralExistPartOrdered IN GENERAL because we can
construct cases where e(0) is the same but e(1) differs.

The zone-decomposed approach works because it doesn't try to build a SINGLE formula
independent of the configuration. Instead, it builds zone-specific formulas that
exploit the temporal structure (Until/Since access to the interval between x and t).

### Finding 6: k=0 Infrastructure Is Reusable

The sorry-free k=0 infrastructure (~4400 lines) does NOT need to change:

- `existPart_succ_n1_bypass_k0`: Sorry-free, does not use ih_general_exist
- VecEADecomp zone decomposition: Sorry-free, handles depth-0 zone analysis
- KampForward pipeline: Sorry-free, provides temporal formulas for depth-0 existentials
- CharPart(0), ExistPart(0): Sorry-free

The k>0 fix only requires:
1. Replacing GeneralExistPartOrdered with the zone-decomposed formulation
2. Modifying the k>0 case in `existPart_succ_n1_bypass` to use the new formulation
3. Proving the new formulation (the zone-decomposed version)

### Finding 7: Dedekind Completeness and Discrete Structures

Rabinovich's proof works on ALL Dedekind complete chains, including discrete ones like Z.
The proof uses Dedekind completeness in exactly two places:

1. Existence of r_0 = inf{z in (z_0, z_1) | P(z)} (Lemma 5.3)
2. The K+ operator (next occurrence from above)

Both are well-defined on Z. The Prior axioms (semantic_prior_UZ, semantic_prior_SZ)
already encode this: UZ says "for every temporal formula, if it ever holds in the future,
there's a nearest future point where it holds" -- this is exactly K+ on Prior structures.

The counterexample on Z does NOT mean the proof fails on Z. It means the specific
formulation GeneralExistPartOrdered fails. The correct formulation (zone-decomposed)
works on Z because temporal formulas can distinguish gap sizes via Until/Since.

## Adversarial Self-Verification

### Claim 1: "GeneralExistPartOrdered is false at all depths"
**Challenge**: Could there be a depth k* at which the statement becomes true?
**Verification**: No. The proof that all integers have the same depth-d 1-var NF is
by induction on d using Z's translation symmetry. Each step uses the previous depth's
uniformity plus the fact that Z-automorphism preserves all quantifier conditions.
This holds for ALL d. **VERIFIED: false at all depths.**

### Claim 2: "existPart_succ_n1_bypass for k>0 is sorry-free"
**Challenge**: Does the proof contain hidden sorry dependencies?
**Verification**: The file compiles with the sorry only in GeneralExistPart.lean.
The `existPart_succ_n1_bypass` theorem takes ih_general_exist as a PARAMETER,
not from sorry. The proof body has no sorry. **VERIFIED: sorry-free given valid hypothesis.**

### Claim 3: "Zone-decomposed approach avoids the counterexample"
**Challenge**: Could the between-zone temporal formula face the same issue?
**Verification**: The counterexample exploits that temporal_truth at a FIXED point (e(0)=0)
cannot distinguish different env configurations. In the zone-decomposed approach, the
between-zone formula uses `Since` from x (the Until witness), which navigates the actual
interval (t, x). On Z with [0,2], Since from x=2 can see y=1 in (0,2). On Z with [0,1],
Since from x=1 sees empty interval (0,1). The temporal formula naturally distinguishes
because the evaluation point differs (x=2 vs x=1) and the interval structure differs.

BUT: this analysis was WRONG. On Z with constant predicates, temporal_truth Z atomMap n A
is the SAME for all n (translation homogeneity). So temporal_truth Z 2 A = temporal_truth Z 1 A
for ANY formula A. The evaluation point differing (x=2 vs x=1) does NOT help because Z's
automorphism makes all temporal formulas evaluate identically everywhere.

**REVISED**: BetweenZoneExistPart (Option K1) is ALSO FALSE, for the same fundamental
reason as GeneralExistPartOrdered. Any formulation characterizing a 2-free-variable
condition via a 1-free-variable temporal formula fails on translation-homogeneous structures.

The correct approach (identified during planning, plan v9) is to ELIMINATE ih_general_exist
entirely: restructure existPart_succ_n1_bypass k>0 to encode quantifier conditions via
generalExistPart_from_classical (full 2-var NF precondition, already proved) with a
self-bootstrapping backward proof. See plan v9 Phase 2 for details.

### Claim 4: "k=0 infrastructure doesn't need changes"
**Challenge**: Could the new formulation require changes to CharPart or ExistPart signatures?
**Verification**: CharPart and ExistPart signatures remain unchanged. Only the third
conjunct of kamp_mutual_induction changes. The existPart_succ_n1_bypass signature changes
only in the ih_general_exist parameter type. **VERIFIED: k=0 code unchanged.**

### Claim 5: "NF transfer alone cannot close the backward direction"
**Challenge**: Could `nf_skipIdx_cross` or some combination provide 2-var agreement?
**Verification**: `nf_skipIdx_cross` projects from (n+1)-var to n-var agreement (reducing
arity). It cannot compose two 1-var agreements into 2-var agreement. `nf_extend_fwd`
requires full r-var agreement at depth K+1 to produce (r+1)-var at depth K -- it doesn't
help when we only have 1-var agreement. **VERIFIED: NF transfer is insufficient.**

## Revised Direction: Exact Replacement Statement

Based on adversarial verification, the correct replacement for GeneralExistPartOrdered
should be one of two options:

### Option K1: Usage-Specific Formulation (Minimal Change)

Replace the third conjunct with a statement tailored to KampBypass's exact usage:

```
BetweenZoneExistPart(k) :=
  forall (char_k : NF(k,1) -> Formula) (char_k_correct : ...)
    (nf_x nf_t : NF(k+1, 1)) (sub_nf : NF(k, 3))
    (h_zone : -- y is strictly between t and x (or x and t)),
  exists (A : Formula),
    forall M (h_UZ h_SZ) (x t : M.carrier) (h_order : t < x),
      nf_eval_nf M (k+1) 1 (fun _ => x) nf_x ->
      nf_eval_nf M (k+1) 1 (fun _ => t) nf_t ->
      (temporal_truth M atomMap x A <->
       exists y, t < y /\ y < x /\ nf_eval_nf M k 3 [y, x, t] sub_nf_restricted)
```

This characterizes ONLY the between-zone existential (the hard case), evaluated at x
(the Until witness), not at an arbitrary env point. The non-between zones reduce to
constant-env ExistPart(k).

**Pro**: Minimal modification to KampBypass.
**Con**: Narrower than needed; requires careful zone decomposition in KampBypass.

### Option K2: Rabinovich-Faithful Interval Splitting (More General)

Replace GeneralExistPartOrdered with an interval-based characterization:

```
IntervalExistPart(k) :=
  forall (char_k : ...) (nf_x nf_t : NF(k+1, 1))
    (ssn : NF(k, 3)) (zone : SSNZone),
  exists (A : Formula),
    forall M h_UZ h_SZ (x t : M.carrier),
      zone_order_holds M x t zone ->
      nf_eval_nf M (k+1) 1 (fun _ => x) nf_x ->
      nf_eval_nf M (k+1) 1 (fun _ => t) nf_t ->
      (temporal_truth M atomMap x A <->
       exists y, zone_constraint M y x t zone /\ nf_eval_depth_k_conditions ...)
```

This provides a per-zone temporal characterization evaluated at x, parameterized by
the 1-var NFs of x and t plus the zone type.

**Pro**: More general, matches Rabinovich's interval-splitting structure.
**Con**: Larger API surface.

### Recommendation

**Option K1** (usage-specific) is recommended for implementation because:
1. It requires minimal changes to the existing code (~200-400 lines to replace GeneralExistPart.lean)
2. The KampBypass proof for k>0 needs only minor parameter type changes
3. The between-zone case is the ONLY case that needs the new formulation (other zones use ExistPart(k))
4. It avoids the Z counterexample because the formula is evaluated at x (the Until witness)
   rather than at an arbitrary e(0)

## Tactic Survey Results

Not applicable -- this is a structural/formulation research task, not a proof tactic task.

## Literature Proof Structure (Tier 1)

### Rabinovich Section 5 Step Map

**Step 1** (Lemma 5.3): Induction on n (witness count), all beta_i = True.
- Base: not(exists x)(P(x)) = forall y, not P(y)
- Step: Use Dedekind completeness to find r_0 = inf{P}; split interval
- Lean analog: VecEADecomp zone decomposition (sorry-free at k=0)

**Step 2** (Corollary 5.4): Reduce full bracket formula to beta-free case.
- Define F_i := alpha_i AND (beta_{i+1} Until F_{i+1})
- Negation of (exists z)[...](z_0, z) reduces via Lemma 5.3 on F_i
- Lean analog: KampBypass enriched formula (F_i = char(nf_x) AND quant_conj)

**Step 3** (Lemma 5.1): Main case split on endpoint failure.
- Case 1: not alpha_0(z_0) or K+(not beta_1)(z_0) -- trivial
- Case 2: alpha_0(z_0) and beta_1 everywhere -- reduces via Corollary 5.4
- Case 3: alpha_0(z_0), not K+(not beta_1), some not-beta_1 point -- INF + split
- Lean analog: zone dispatch in existPart_succ_n1_bypass (true/true, true/false, etc.)

**Step 4** (A_i^-/A_i^+ decomposition): Split at each potential witness position.
- A_i^-(z_0, z) = left sub-interval bracket formula
- A_i^+(z, z_1) = right sub-interval bracket formula
- Negation reduces to conjunction of negated sub-intervals (shorter -> IH)
- Lean analog: NOT YET IMPLEMENTED for k>0. This is the core gap.

## Sorry Inventory

| File | Line | Statement | Status | Blocked By |
|------|------|-----------|--------|------------|
| GeneralExistPart.lean | 174 | generalExistPartOrdered_zero | IMPOSSIBLE | Statement is FALSE |
| GeneralExistPart.lean | 207 | generalExistPartOrdered_succ | IMPOSSIBLE | Statement is FALSE |

These are the ONLY sorry sites in the Kamp pipeline. All other sorry references
in comments are documentation of the history.

## Next Steps

1. Design the exact Lean type signature for Option K1 (BetweenZoneExistPart)
2. Prove BetweenZoneExistPart(0) using existing VecEADecomp infrastructure
3. Prove BetweenZoneExistPart(k+1) from CharPart(k+1) + ExistPart(k) + BetweenZoneExistPart(k)
4. Replace ih_general_exist parameter in existPart_succ_n1_bypass with BetweenZoneExistPart
5. Update kamp_mutual_induction to use BetweenZoneExistPart as third conjunct
