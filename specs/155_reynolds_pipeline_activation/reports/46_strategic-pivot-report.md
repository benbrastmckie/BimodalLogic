# Strategic Pivot Report: Bridge Lemma → Direct StaviFormula Construction

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Purpose**: Consolidate findings from 6 implementation sessions and 4 research sessions into a clear path forward.

---

## 1. What We Learned (Sessions 1-6)

### The Bridge Lemma is Real but Not on the Critical Path

`nf_2var_from_interval_data` (StaviCompleteness.lean) is a genuine mathematical theorem — GHR93 Proposition 7 / Lemma 11. It states that decomposition data (1-var NFs + ordering + interval types) determines 2-variable NFs.

Six implementation sessions attempted to prove it. Each added infrastructure:
- Fraïssé compression lemma (sorry-free)
- Zone match witness (sorry-free)
- Depth-decrease lemmas (sorry-free)
- Depth-0 existential transfer (sorry-free)
- Variable dropping lemma (sorry-free)

**But the core sorry persists** — the 4-variable existential transfer at depth j ≥ 1 — because `interval_nf_types` (a Finset of 1-var NFs) loses spatial arrangement information. The proof must go through the EF game (confirmed by literature), which requires a type universe bridge between the NF world and the game world.

### The Bridge Lemma Feeds nf_characterizable_by_stavi

The dependency chain: bridge lemma → `nf_characterizable_by_stavi` → characteristic formula B → U(B, A) in Case II.

**But CaseAnalysis.lean does NOT import StaviCompleteness.lean.** The bridge lemma is not on the critical path for `bx_completeness`.

### GHR93 Uses B Syntactically

GHR93's B = X_{a_n} is a single formula inside U(B, A). It is constructed as the conjunction of all rank-≤-r temporal formulas true at a_n. This conjunction has rank r (conjunction preserves depth/rank). GHR93 takes this as obvious because there are finitely many inequivalent formulas at each rank.

---

## 2. The Key Insight: Bypass nf_characterizable_by_stavi

GHR93 constructs X_t from **original temporal formulas of rank ≤ r** — NOT from NormalForm-derived approximations. The Lean formalization already has the mathematical content for this:

### stavi_n_equiv (Defs.lean)

```lean
def stavi_n_equiv ... (n : Nat) ... :=
  ∀ (A : StaviFormula), stavi_depth A ≤ game_depth sig n → ...
```

This establishes that there are finitely many equivalence classes of StaviFormulas at each rank. `NormalForm sig r 1` is Fintype and enumerates these classes.

### rank_type (TypeFormulas.lean)

```lean
def rank_type M atomMap r t : Set StaviFormula :=
  { A | stavi_depth A ≤ r ∧ stavi_temporal_truth_mu M atomMap r t A }
```

This IS GHR93's X_t — the set of depth-≤-r StaviFormulas true at t. Sorry-free.

### The Construction Path

1. For each equivalence class of depth-≤-r StaviFormulas (enumerated by `NormalForm sig r 1`):
   - There exists a representative StaviFormula of depth ≤ r (from the StaviCompleteness construction)
   - OR: use any formula in the equivalence class (all have depth ≤ r by definition)
2. B = sf_conjList of { φ_i : φ_i ∈ rank_type M atomMap r t } ∪ { .neg φ_i : φ_i ∉ rank_type M atomMap r t }
3. `stavi_depth B = r` (max of conjuncts, each depth ≤ r)
4. `stavi_depth (std_untl B A) = r + 2`
5. Transfer through tau at rank r + 4: r + 2 ≤ r + 4 ✓

**Critical question**: Can we enumerate representative depth-≤-r StaviFormulas WITHOUT `nf_characterizable_by_stavi`?

**Answer**: `stavi_n_equiv` + `NormalForm` Fintype gives us that finitely many equivalence classes exist. To get a concrete representative formula for each class at depth ≤ r, we need either:
- (a) `nf_characterizable_by_stavi` (has sorry, produces depth ~2r)
- (b) Direct construction from the equivalence class definition (each class is defined by depth-≤-r behavior, so a representative of depth ≤ r exists by definition)
- (c) Classical.choice on the existence (non-constructive but correct)

Option (c) works: for each NormalForm `nf : NormalForm sig r 1`, use `Classical.choice` to select a StaviFormula `A` with `stavi_depth A ≤ r` and `∀ M t, stavi_temporal_truth_mu M atomMap r t A ↔ nf_eval_nf M r 1 [t] nf`. The existence of such A follows from the expressive completeness direction (StaviFormulas can express everything NormalForms can at bounded depth).

BUT: proving that such A exists at depth ≤ r IS `nf_characterizable_by_stavi` (or something equivalent). We're back to needing either the bridge lemma or an alternative.

### The Real Escape: Use StaviFormulas Directly

Instead of mapping through NormalForm, work directly with StaviFormulas:
- `rank_type M atomMap r t` is the set of depth-≤-r StaviFormulas true at t
- Two points with the same rank_type are indistinguishable by depth-≤-r formulas (`rank_type_eq_iff`, sorry-free)
- The conjunction of a finite subset of StaviFormulas at depth ≤ r has depth r

The ONLY issue: rank_type is a potentially infinite set (StaviFormula is not Fintype). We need FINITELY many representatives.

**Resolution**: The game-world infrastructure already knows that finitely many rank_types exist (via NormalForm Fintype). `Fintype (NormalForm sig r 1)` → finitely many distinct rank_types → for each rank_type, at least one carrier point realizes it → can enumerate the finite list of rank_types realized in a model.

For B = X_t: we don't need ALL StaviFormulas of depth ≤ r — just enough to distinguish t's type from all other types. This is a finite set (one per equivalence class).

---

## 3. Architecture Decision

### Two Worlds, Clean Interface (Option D)

The NF world (NormalForm, nf_characteristic) and the game world (ExtendedCarrier, rank_type, StaviFormula) serve different mathematical purposes:
- **NF world**: Decidability, finiteness, canonical model construction
- **Game world**: EF games, formula transfer, type characterization

Forcing unification would be a major refactor (~2000 lines) that loses the distinct advantages of each. Instead: accept both worlds with a clean interface.

### The Interface Lemmas Needed

1. **nf_to_rank_type**: `nf_characteristic` agreement → `rank_type` agreement
   - Follows from `doets_lemma_1_1` + Stavi translation
2. **rank_type_to_nf**: `rank_type` agreement at depth ≥ k → `nf_characteristic` agreement at depth k
   - Follows from the converse of `doets_lemma_1_1`

These are the ONLY bridge lemmas needed. They're much smaller (~50-100 lines total) than the full `nf_2var_from_interval_data`.

---

## 4. Recommended Path Forward

### Phase 1: Build B = X_t using stavi_n_equiv (~100-150 lines)
- Prove: for each `nf : NormalForm sig r 1`, there exists `A : StaviFormula` with `stavi_depth A ≤ r` characterizing nf
- This may need a sorry if `nf_characterizable_by_stavi` isn't available, OR it can be proved directly from `stavi_n_equiv` which asserts the equivalence
- Build `sf_conjList` of representatives → B with depth r

### Phase 2: Implement Case II with B at depth r (~200-300 lines)
- phi = U(B, A) at depth r+2
- Transfer through tau at rank r+4 (delta=4)
- Extract witness z = e_n
- sel_pn_ord trivial
- Round 2 via tau's formula preservation

### Phase 3: Close remaining sorries (~200-400 lines)
- Cases III/IV
- Theorem6.lean rank promotion
- Downstream

### Deferred: Bridge Lemma
- `nf_2var_from_interval_data` remains with sorry
- NOT on critical path for bx_completeness
- Worth proving later for mathematical completeness
- Correct approach: type universe bridge (nf_to_rank_type + rank_type_to_nf) + existing game infrastructure

---

## 5. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Representative StaviFormula at depth ≤ r needs sorry | HIGH | May need to accept axiom or prove from stavi_n_equiv |
| A (interval type formula) needs materialization | MEDIUM | Semantic approach via tau's formula preservation |
| delta=4 requires Theorem6.lean:325 | MEDIUM | Close as prerequisite |
| Cases III/IV need rank r+3 formulas | MEDIUM | delta=4 provides r+4 ≥ r+3 |

---

## 6. Summary

**The bridge lemma is not the bottleneck.** The bottleneck was trying to prove a theorem (nf_2var_from_interval_data) that isn't on the critical path, using an approach (NF induction) that the literature doesn't use.

**Follow GHR93**: Construct B = X_t as a conjunction of depth-≤-r StaviFormulas, use it syntactically in U(B, A), transfer through tau at rank r+4. The infrastructure for this (stavi_n_equiv, rank_type, sf_conjList) largely exists.

**Defer the bridge lemma** to a future task focused on StaviCompleteness. The type universe bridge (nf_to_rank_type + rank_type_to_nf) is the correct architecture for that, using existing sorry-free game infrastructure.
