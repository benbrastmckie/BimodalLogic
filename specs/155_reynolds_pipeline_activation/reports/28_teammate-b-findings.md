# Teammate B Findings: Alternative Approaches to Breaking the Formula C Circularity

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Role**: Teammate B — Alternative Approaches
**Focus**: Formula C construction, induction structure, NF-to-StaviFormula bridge, and alternatives to cont_holds

---

## Key Findings

### 1. The Circularity Is Real But Narrow — and There Is a Non-Circular Path

The circularity identified across reports 38, 39, and 29 is real but does not block ALL routes to constructing C. The precise scope:

**What IS circular**: Converting `NormalForm (muSig sig) (2*r) 1` back to `StaviFormula` of depth `r`. This conversion is `stavi_table_mu` inversion, which is literally the theorem being proved (expressive completeness).

**What is NOT circular**: Enumerating `StaviFormula` terms of depth `<= r` directly by structural recursion on the inductive type, then filtering by truth at mu-points of the interval. This does not require the theorem being proved — it only requires the type `StaviFormula` to be finite up to a given depth, which is a combinatorial fact about the inductive type's structure.

The formalization chose `cont_holds` (a Prop-level universal quantification over all StaviFormulas of depth `<= r`) as a proxy for the formula C. This choice is semantically faithful but syntactically opaque: it captures what C means without making C a concrete `StaviFormula` object.

### 2. The Induction Does NOT Require C at the Inductive Step — C Is Pre-Proof Infrastructure

GHR93's proof of `(**)_{n+1}` does not use the induction hypothesis to construct C. The construction order is:

1. **Before any induction argument**: Enumerate temporal L-formulas of rank `<= r` (finitely many, since L is finite and rank bounds the formula depth).
2. **For each mu-point v in (a_n, y')**: Form X_v = conjunction of all rank-r formulas holding at v.
3. **C = X_{(a_n, y')}** = disjunction of all distinct X_v (finitely many distinct types).
4. **Then** use the game-theoretic induction hypothesis for Claims 1 and 2.

The induction hypothesis `(**)_n` is used only for:
- **Claim 2** (strategy restriction to sub-intervals): "We will use this argument repeatedly" (GHR93 p.116)
- **The four-case analysis** (Case I splitting, Cases II-IV for the actual backward response)

The formula C is fully constructed from the finite set of rank-r StaviFormulas — a set that exists in Lean as the range of the inductive type `StaviFormula` bounded by `stavi_depth`. No circularity.

### 3. The `nf_characterizable_by_stavi` IH Cannot Close the Gap — But the Infrastructure Is Almost There

The current code attempts `nf_characterizable_by_stavi` by induction on `k` (NF depth). The base case (k=0) is proved via `nf_base_sf`. The inductive step (k+1) is the central sorry (EFGames.lean:10086).

However, the formalization has an important asymmetry: `nf_characterizable_by_stavi` produces a StaviFormula for each NF at depth k, but the inductive step for depth k+1 NFs requires handling 2-variable NFs (`NormalForm sig k 2`) — characterizing the joint type of a pair (x, t). Temporal connectives alone cannot capture this for k >= 1.

This is NOT the same as the Claim 1 circularity. The NF inductive step is a genuine gap in the GHR93 proof as formalized: both routes (GHR93's rank-type partition approach and the Lean NF induction approach) require the game-theoretic Theorem 6 argument applied to 2-variable structures.

**The existing infrastructure that IS close**:
- `stavi_expressive_completeness` (EFGames.lean:10089) is complete EXCEPT for `nf_characterizable_by_stavi` inductive step
- `nf_base_sf` + `nf_base_sf_correct`: base case for k=0 is done
- `sf_conjList`, `sf_disjList`, `sf_disj`, `sf_atom_literal`, `sf_verum`: combinators all exist
- `gap_char_formula`, `sf_K_plus`, `sf_K_minus`: gap-detection formulas exist
- `nf_determines_stavi_truth_depth`: NF at depth 2r determines StaviFormula truth of depth <= r

### 4. The `cont_holds` Predicate Can Be Replaced — Here Is the Non-Circular Construction

GHR93's formula C as a `StaviFormula` can be built directly using the existing infrastructure:

```lean
-- Step 1: Enumerate StaviFormulas up to depth r
-- (This needs a Fintype instance for { A : StaviFormula // stavi_depth A <= r })
-- The inductive type StaviFormula is finitely generated at each depth level.

-- Step 2: For each depth-r StaviFormula, check if it holds at ALL mu-points of (a_n, y')
-- "A holds on interval (a_n, y')" is a Prop, decidable classically.

-- Step 3: Take the conjunction of all such A.
-- X_{(a_n, y')} = sf_conjList (all depth-r StaviFormulas holding on (a_n, y'))

-- Step 4: stavi_depth(sf_conjList ...) <= r (conjunction preserves depth)
```

The key missing piece is `Fintype { A : StaviFormula // stavi_depth A <= r }`. This is NOT circular — it is a structural fact about the inductive type.

**Why this works**: StaviFormula is defined as an inductive type with 8 constructors. Formulas of depth <= r are exactly those whose construction tree has height <= r. The number of such trees is finite (for finite atom sets). A `Fintype` instance can be built by structural recursion: depth-0 formulas are exactly `{.base(.bot), .base(.top), .base(.atom a) for a in atoms, negations thereof}` — a finite set. Depth-(k+1) formulas are finite products of depth-k formulas connected by the 5 binary constructors.

### 5. The Current Sorry Landscape: 12 in ExpressivenessGeneral.lean, 1 in EFGames.lean

From the Forward Inventory (report 30) and Session Audit (report 30b), the sorry sites fall into groups:

**Group A — Claim 1 gap/boundary edge cases (S1, S2: lines 3901, 3935)**:
- S1 (3901): r2_resp = rank_embed(y') boundary case. Formula materialization or dedicated boundary lemma needed.
- S2 (3935): r2_resp is a gap. This is where the circularity report (39) identified the formula materialization block. BUT: report 29 shows this case can be handled with the case-split approach (if `cont_holds` fails at the infimum directly, no pigeonhole/materialization needed).

**Group B — Multi-round mechanical adaptations (S3-S5: lines 4412, 4424, 4468)**:
- S3 (4412): Mechanical copy of h_cont_transfer with multi-round indices. Report 30_mechanical-strategy.md maps this exactly to ~65 lines of direct adaptation.
- S4 (4424): Multi-round K^-(negD) argument. Inherits S1/S2 but is otherwise mechanical.
- S5 (4468): Multi-round gap sub-case. Mirror of existing gap proof with adapted indices.

**Group C — Position constraint after rank_down (S6, S7: lines 4483, 4508)**:
- The sorry is specifically: `a'_rd(position) = d`. After rank_down projects the rank-(r+2) game to rank r, the position tracking is lost.
- **Alternative approach**: Instead of using rank_down as a black box, inline the projection. The projection maps `rank_embed(d)` to `d` by definition (rank_embed is injective). If `mr_resp = rank_embed(d)` (proved in Step 6), then the projection of mr_resp is d.

**Group D — Case II ordering (S8-S10: lines 5945, 6045, 6098)**:
- Cross-boundary ordering goals requiring sigma strategy instantiation.

**Group E — Cases III-IV gap detection (S11: line 7028)**:
- Entire gap-case proof pending Lemma 9 correctness.

**Group F — Lemma 10 strategy restriction (S12: line 7390)**:
- Sub-interval strategy restriction for ghr93_forward_to_backward_rank_varying.

**Group G — NF characterization inductive step (S13: EFGames.lean:10086)**:
- The keystone sorry: the full GHR93 proof.

### 6. What `nf_determines_stavi_truth` Provides — and What It Cannot Do

The lemma `nf_determines_stavi_truth_depth` (ExpressivenessGeneral.lean:614) shows:

```
If p and q have the same NF at depth 2r (in the mu-extended structure),
then they agree on all StaviFormulas of depth <= r.
```

This bridges NF-level properties to formula-level properties. It cannot produce a StaviFormula from a NF — it only transfers truth between points with the same NF.

**However**, `stavi_expressive_completeness` (EFGames.lean:10089) IS complete in its proof structure: it uses `nf_characterizable_by_stavi` as a black box, and the rest of the proof (building the disjunction over good NFs, proving correctness via `doets_lemma_1_1`) is fully proved. The only sorry is in the `nf_characterizable_by_stavi` inductive step.

---

## Recommended Approach

### Tier 1: Immediate (Mechanical, Low Risk)

**Sorry S3 (line 4412 — h_cont_transfer_mr)**: Mechanical adaptation of h_cont_transfer. Report 30_mechanical-strategy.md provides the complete index translation table. ~65 lines. No conceptual blockers.

**Sorry S6/S7 (lines 4483, 4508 — position constraint)**: Instead of the rank_down black-box approach, use the already-established `h_mr_eq : mr_resp = rank_embed(by omega : r <= r+2) d` to directly extract the position constraint. The projection is: rank_embed maps d (at rank r) to an element at rank r+2, and when the response at rank r+2 equals rank_embed(d), the rank-r projection is d. This requires a lemma `rank_embed_project_eq` (rank_embed h d projected back gives d), which should follow from rank_embed being a section of the projection map.

### Tier 2: Moderate Effort

**Sorry S5 (line 4468 — multi-round gap case)**: Mirror of h_r2_resp_ge_d gap case with adapted indices. Report 30_mechanical-strategy.md gives the adaptation guide.

**Sorry S4 (line 4424 — h_mr_resp_le_d)**: Full adaptation of h_r2_resp_le_d for multi-round. Inherits S1/S2 edge cases but those are bounded failures (they produce `False` goals in narrow sub-cases).

**Sorries S9/S10 (lines 6045, 6098 — Case II ordering)**: The `same_order_type` goals require `x' < d <-> x < c`. This comes from the sigma strategy's order preservation. May be extractable from the existing `hgp_cd`/`hcd_boundary` hypotheses without full sigma instantiation.

### Tier 3: Architectural (High Impact)

**Replace `cont_holds` with formula C (affects S1, S2, S4)**:
The non-circular construction is: build a `Fintype` instance for StaviFormulas of depth `<= r`, then construct C directly as `sf_conjList` of all depth-r StaviFormulas holding on the interval. This:
- Eliminates the need for pigeonhole
- Makes C' = neg(C) or K^-(neg(C)) directly constructible as a StaviFormula of depth r+2
- Aligns the proof with GHR93's 5-line Claim 1 argument
- Estimated: ~200-300 lines for Fintype infrastructure + ~100 lines for C' proof = ~400 lines total, eliminates ~360 lines of pigeonhole code

**Alternative to full formula materialization (Case-Split)**: The case-split approach from reports 38/39 remains viable:
- If `cont_holds` holds at c_inf: pigeonhole witnesses are strictly below c_inf (strict inequality holds), closing S1/S2's edge cases
- If `cont_holds` fails at c_inf: the witnessing formula A is immediately available, no pigeonhole needed
- Estimated: ~240 lines, closes S1/S2/S4 boundary sub-cases

### Tier 4: Deferred (Major Infrastructure)

**NF characterizable inductive step (S13 — EFGames.lean:10086)**: This is the keystone sorry. It requires the complete GHR93 Theorem 6 + Proposition 7 + four cases + Lemma 9. This is the central theorem of the entire formalization. Address after Tiers 1-3 are complete.

**Cases III-IV (S11)** and **Lemma 10 strategy restriction (S12)**: Both require new major lemmas. Address after Tier 1-2.

---

## Evidence and Examples

### The Non-Circular Fintype Construction (Key Evidence)

The formula C = X_{(a_n, y')} in GHR93 is built using:
1. L (the atom set) is finite
2. Formulas of rank <= r are finitely many up to equivalence
3. Take one representative per equivalence class

In Lean, the `StaviFormula` inductive type has finite instances at each depth. The existing combinators (`sf_conjList`, `sf_disjList`) already build compound formulas from lists. The pattern for C would be:

```lean
-- Existing helper (EFGames.lean:9796)
private def sf_disjList : List StaviFormula → StaviFormula

-- Needed: Fintype instance
-- Fintype { A : StaviFormula // stavi_depth A <= r }
-- Build: enumerate all StaviFormulas by structural recursion on depth

-- Construct X_v for each mu-point v in (a_n, y')
-- X_v = sf_conjList [A | stavi_depth A <= r, stavi_temporal_truth_mu N atomMap r v A]

-- Construct C = X_{(a_n, y')}
-- C = sf_disjList [X_v | v is a mu-point in (a_n, y')]
-- (finitely many distinct X_v, since finitely many NF types)
```

The `nf_determines_stavi_truth_depth` lemma guarantees that distinct NF types at depth 2r correspond to distinct X_v formulas. Since `NormalForm (muSig sig) (2*r) 1` is `Fintype` (already established), there are finitely many X_v.

### The Rank Arithmetic Evidence

Report 28_claim1-formula-materialization.md correctly identifies:
- GHR93 rank r+1 for C' corresponds to Lean stavi_depth r+2 (the +2 per temporal connective convention)
- The forward game hypothesis `h_fwd_r1` uses rank r+2 (already updated from an earlier r+1 version)
- `K^-(neg D)` = `sf_K_minus (neg D)` has `stavi_depth = stavi_depth(D) + 2 <= r + 2` when `stavi_depth D <= r`

This means: if D is extracted from the interval (as a StaviFormula of depth <= r), then K^-(neg D) fits within the rank-(r+2) forward game budget. The rank arithmetic is already correct in the current code.

### The Case-Split Evidence

Report 39 (remove-pigeonhole-design.md) Section 4 maps the case-split approach:

```lean
-- At h_d_unique (or the sorry sites within h_r2_resp_le_d):
by_cases h_cont_d : cont_holds (a_bwd n) y' d

-- Case B (cont_holds fails at d):
-- ¬cont_holds a_bwd(n) y' d
-- unwraps to: ∃ A with stavi_depth A <= r, A holds on (a_bwd(n), y'), ¬A(d)
-- This A is the formula D directly — no pigeonhole needed.

-- Case A (cont_holds holds at d):
-- All failure witnesses u satisfy u < d strictly
-- The existing pigeonhole works with strict bounds
```

This is directly applicable to sorries S1 (c_inf boundary case) and S2 (gap r2_resp case): both require extracting a formula D, which the case-split provides directly in Case B.

---

## Confidence Level

**High confidence**:
- The circularity is real but narrow (only NF -> StaviFormula inversion)
- The C construction via StaviFormula enumeration is not circular
- The rank arithmetic (r+2 convention) is correct as currently implemented
- Sorries S3, S6, S7 are mechanical and have clear closure paths
- The case-split approach (Approach C) correctly resolves S1, S2 edge cases

**Medium confidence**:
- The Fintype StaviFormula construction (~200-300 lines) would close S1/S2 definitively but is untested
- The position constraint sorries (S6/S7) can be closed by inlining rank_down projection, but the lemma `rank_embed_project_eq` needs verification
- Case II ordering goals (S8-S10) have the right structure but full closure depends on sigma strategy instantiation

**Low confidence**:
- NF characterizable inductive step (S13) — the full GHR93 proof still needed; no alternative approach bypasses this
- Cases III-IV (S11) — architecturally sound but requires implementing Lemma 9 correctness fully
- Timeline for Tiers 3-4 given the mechanical work in Tiers 1-2 still outstanding

---

## Summary

The primary alternative approach that breaks the circularity without building massive new infrastructure is the **case-split on cont_holds at c_inf** (Approach C from reports 38/39). This closes the S1 and S2 sorry sites that are currently annotated as "formula materialization is circular" by bypassing the materialization entirely: when `cont_holds` fails directly at the boundary, the witnessing formula is immediately available.

The **full formula materialization** (Approach A from report 29) would be the mathematically cleanest solution and aligns with GHR93 exactly, but requires ~200-300 lines of `Fintype StaviFormula_bounded` infrastructure. This infrastructure is not circular and would also be useful independently for `nf_characterizable_by_stavi` work.

The mechanical adaptations (S3, S5, position constraints S6/S7) do not depend on resolving the formula C question and should be addressed immediately.
