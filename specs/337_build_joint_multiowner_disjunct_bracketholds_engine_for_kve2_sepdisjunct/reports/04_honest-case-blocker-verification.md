# Report 04 — Adversarial Verification: Is the Task-337 Phases 2-6 Blocker Genuine for the HONEST Coincident Case?

**Mode**: RESEARCH/VERIFY-ONLY (no Lean edits; only `lean_run_code` scratch experiments).
**Question**: Does the `_of_honest` qualifier + Phase-1's coincident-anchor membership witness
dissolve the block-vs-merged monotonicity contradiction the v3 implementer reported?

## Verdict

```json
{
  "blocker_genuine_for_honest_case": true,
  "feasible_additive_path": false,
  "path_sketch_or_contradiction": "The coincidence tag changes only which VALIDITY bit is read (CLOSED self-zone), NOT the geometry of anchors or base-type witnesses. Honest coincident inputs with >=2 interior owners whose realized-type regions INTERLEAVE still exist; for them the .holds builder must produce a GLOBALLY strictly-monotone witness sequence over a per-owner BLOCK concatenation, which forces total region segregation between owners. Interleaving honest models violate segregation for EVERY block order (rank-independent). Verified False by omega in 5 scratch experiments. A point-level cross-owner slot merge (task-338 carrier edit of kvE2_sepSlotsLOf/ROf) is genuinely required.",
  "key_evidence": "ExistsForallNF.lean:106-132 (global strict monotonicity); SharedWitness.lean:292-299 (per-owner block straddles anchor), :258-264/280-286 (lX1 point type pins the anchor), :869-876 (block flatMap slot list), :1548-1550 (coincident order = distinct zipIdx ranks + coincident TAG), :1566-1597 (per-owner SEPARATE anchor extraction), :1733 (Phase-1 uses coincidence only for MEMBERSHIP); lean_run_code experiments 1-5 all derive False for interleaving honest configs and for shared-anchor collapse."
}
```

**Bottom line**: The subtlety was worth testing, but it does not hold. The blocker is GENUINE for
the multi-owner honest coincident case — the case the "joint multi-owner disjunct bracket-holds
engine" deliverable actually needs. The v3 implementer's recommended task-338 carrier edit is
required. (A narrow additive path exists ONLY for the degenerate <=1-interior-owner sub-case,
which does not satisfy the joint multi-owner deliverable.)

## Why the coincidence subtlety does NOT dissolve the contradiction

The hypothesis under test (from the orchestrator): in the honest case the arrangement is
`kvE2_sepCoincidentOrder`, so maybe the two owners' anchors COINCIDE rather than interleave,
dissolving the `a<u, p<a, u<p ⊢ False` contradiction.

This is false for a precise, source-grounded reason: **"coincident" here is self-coincidence, not
cross-owner anchor sharing.**

1. `KvE2SepSpikeOrderType.coincident` (SW:684) documents "τ's χ-witness COINCIDENT at `x1_σ`" but
   is consumed by validity as a **placement tag** selecting which zone BIT is read — the CLOSED
   self-zone `zAtX1L/R` bit (`kvE2_sepClosedLeafStub`, SW:767-772) versus the OPEN `zXU`/`zUW`
   bits the strict tags read. It is F5 bit-selection, not a geometric constraint on anchors.

2. `kvE2_sepCoincidentOrder` (SW:1548-1550) maps `(kvE2_sepPos qnf).zipIdx` to
   `(σ, .coincident, rank)` with **DISTINCT** ranks `0,1,…,n-1`. Distinct ranks are literally the
   opposite of collapsed anchors.

3. The validity proof `kvE2_sepCoincidentOwner_valid_left` (SW:1566, esp. line 1577
   `obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb`) extracts a **SEPARATE** anchor `x1_σ` for EACH owner
   from the model. Nothing forces `x1_σ = x1_τ`. Different owners have different, generically
   interleaving anchors.

4. What Phase-1's `kvE2_sepCoincidentOrder_mem_arr'` (SW:1733) actually delivers is **MEMBERSHIP**
   (`kvE2_sepCoincidentOrder qnf ∈ kvE2_sepArr' qnf`) via the CLOSED-bit validity route. Membership
   is orthogonal to the `.holds` witness-construction obligation. Phase 1 being green (axiom-clean)
   says nothing about the realizability of the block-order witness sequence.

So the honest coincident arrangement still presents `kvE2_sepBody_holds_iff.mpr` (SW:970-988) with
a per-owner **block** slot list whose owners can interleave — exactly the strict-case geometry.

## The `.holds` obligation demands GLOBAL strict monotonicity

`kvE2_sepDisjunct` (SW:613-624) builds a bracket of length `|lL| + 1 + |lR|`; its `.2.holds`
reduces through `IntervalPattern.holds` (ExistsForallNF.lean:106-132, and the computed-length form
`holds_eq_succ` :188-204). At `n+1` witnesses this requires **one** witness function
`witnesses : Fin (n+1) → M.carrier` with

```
∀ i j, i < j → witnesses i < witnesses j          -- ExistsForallNF.lean:117 (GLOBAL, over ALL slots)
∀ i,   (alpha i).eval_at M atomMap (witnesses i)   -- each slot's point type realized at its witness
```

The witness index order is the concatenated slot-list order. For the coincident disjunct the LEFT
slot list is `kvE2_sepSlotsLOf wo = (kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor`
(SW:869-871) — a per-owner BLOCK concatenation. Each left-interior owner block (SW:292-299) is

```
[lXU σ … in (x,x1_σ)] ++ [lX1 σ @ x1_σ] ++ [lUW σ … in (x1_σ,w)]
```

and `lX1 σ`'s point type `kvE2_sepPtX1L` (SW:258-264, dispatched at :281) is the `charK` E[Σ]-atom
that self-types σ's own anchor, pinning that witness to `x1_σ`. So each owner block straddles its
own anchor, and global monotonicity forces: **all of owner_i's block < all of owner_{i+1}'s block**,
i.e. owner_i's above-anchor `lUW` points < owner_{i+1}'s below-anchor `lXU` points — **total region
segregation between owners.**

## Scratch experiments (`lean_run_code`, all returned success = False derived)

| # | Config | Result |
|---|--------|--------|
| 1 | Interleaving honest model, block order σ,τ: `a<u`, `p<b`, `u>b`, `p<a`, monotone `u<p` | `omega` ⊢ False |
| 2 | Shared/coincident anchor collapse: `lX1 σ = lX1 τ = c` needs strict `c < c` | `omega` ⊢ False |
| 3 | Shared anchor, ignore anchor clash: σ `lUW` `c<u`, τ `lXU` `p<c`, monotone `u<p` | `omega` ⊢ False |
| 4 | RANK-INDEPENDENCE: interleaving model kills BOTH block orders σ,τ AND τ,σ | `omega` ⊢ False (both) |
| 5 | Sanity: only totally-segregated regions `x<a<c<b<w` are block-realizable | constructible (no contradiction) |

Experiment 4 is the decisive one: `kvE2_sepBody_holds_iff.mpr` may pick ANY `wo ∈ kvE2_sepArr'`,
and `wo`'s rank permutes whole owner blocks (`kvE2_sepOrderOwners` mergeSort, SW:861-863). Because
BOTH orders derive False on the same interleaving honest model, **no rank permutation rescues the
build**. Experiment 5 confirms the block interface is realizable exactly when owner regions are
totally segregated — which interleaving honest models are not.

The interleaving model is a legitimate honest coincident input: two left-interior owners σ, τ with
self-coincident anchors `x1_σ = a`, `x1_τ = b` (`x<a<b<w`); σ's fold requires a `zUW` base type
realized in `(a,w)` and τ's fold requires a `zXU` base type realized in `(x,b)` (the fold bits
force these witnesses to EXIST for honesty), but the model may realize them only at `u>b` and `p<a`
respectively. The `_of_honest` universal quantifier must cover this input; one bad input defeats
any block-order builder.

## Why the point-level merge (task-338 carrier edit) is truly required

Faithful realization (Rabinovich Def 3.1: a single merged ascending chain) requires ordering ALL
slots — across owners — by actual model position, interleaving individual base points. A per-owner
block `flatMap` (SW:871/876) structurally cannot express that: it can only sequence WHOLE blocks.
The engine `k1v_sorted_realizationK` (SubBracket2V.lean:633, per v3 summary) confirms the intended
interface is a boundary-linked merged-anchor region list whose `interleaveK` output is in merged
order — incompatible with the block list. Therefore `kvE2_sepSlotsLOf/ROf` (SW:869-876) must be
redesigned into a genuine cross-owner slot MERGE keyed by each slot's merged-chain position, and
the dependent task-338 lemmas re-proven (`kvE2_sepBody_holds_iff`, `_extract`,
`kvE2_sepDisjunct_extract` index reads). This is exactly the v3 implementer's recommendation and it
is a carrier edit, not an additive one.

## Adversarial Self-Verification

I challenged the "genuine" conclusion by hunting for any additive escape:

| Claim | Source / Counterexample | Verification Method | Confidence |
|-------|--------------------------|---------------------|------------|
| Coincidence tag ≠ anchor coincidence (anchors stay distinct) | SW:1548-1550 (distinct zipIdx ranks), :1577 (separate `x1` per owner), :684 (tag = bit selector) | source read of committed Phase-1 lemma | High |
| `.holds` needs GLOBAL strict monotonicity over full concatenation | ExistsForallNF.lean:117, :188-204 | direct read of `IntervalPattern.holds` / `holds_eq_succ` | High |
| Each left-interior owner block straddles its pinned anchor | SW:292-299 (block shape), :258-264/281 (lX1 pinned by E[Σ]-atom) | source read | High |
| Block order forces total owner-region segregation; interleaving honest model violates it | Experiments 1,3 | `lean_run_code` omega ⊢ False | High |
| Blocker is RANK-independent (no `wo` rescues it) | Experiment 4 (both block orders False) | `lean_run_code` omega ⊢ False | High |
| Interleaving is a realizable HONEST coincident input | fold bits force zUW/zXU witnesses to exist; positions model-free; both owners left-interior self-coincident | analytic (grounded in kvE2_sepGate/nf_eval honesty semantics, SW:657-665, 1576-1597) | Medium-High |
| Escape via ≤1-interior-owner restriction | single block ⇒ no cross-owner segregation ⇒ additive `.holds` IS buildable there | analytic | Medium |
| Escape by adding a new valid `wo` with matching block order | Experiment 4/5: interleaving unrealizable for ALL block orders | `lean_run_code` | High |
| Escape by re-choosing witness points (point types are region-free) | list POSITION still pins lXU<anchor<lUW; cross-owner segregation still required | analytic + Exp 1 | High |

**Contradiction log**: none unresolved. The one nuance surfaced (Medium-confidence): an additive
`.holds` builder IS constructible for the degenerate honest sub-case with at most one interior
owner (single block, no cross-owner segregation). This is a genuine but strictly PARTIAL path; it
does not deliver the "joint multi-owner disjunct bracket-holds engine" the task is titled and
scoped for, so it does not overturn the verdict.

**Recommendations modified after verification**: I initially suspected the coincidence framing
might dissolve the contradiction (the hypothesis I was asked to test). Adversarial experiments 2-4
falsified that: coincident-anchor collapse fails even harder (`c<c`), and rank-independence kills
the "pick a better wo" escape. Verdict settled to blocker-genuine.

## Recommendation

Uphold the v3 implementer's blocker. Task 337 Phases 2-6 cannot proceed additively for the joint
multi-owner deliverable. Spawn/authorize a task-338 carrier edit: redesign
`kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` (SW:869-876) into a point-level cross-owner merge keyed by
merged-chain position, then re-prove the dependent 338 lemmas; Phase-1's
`kvE2_sepCoincidentOrder_mem_arr'` (SW:1733) then feeds the membership half unchanged.
