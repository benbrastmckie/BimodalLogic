# Research Report: Task #116 — Team Research (Round 2)

**Task**: 116 — Redefine G, H, F, P in terms of U and S following Burgess 1982
**Date**: 2026-05-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1779145651_81f10a
**Prior Research**: specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md

## Summary

The original Round 1 research significantly undercounted the scope of this refactoring: **83 files with 1891 references** in Theories (not 70/1416), plus **20 test files with 507 references**, totaling **103 files and 2398 references**. Pattern-match arms are **~400** (not 122 as originally estimated). The entire WeakCanonical/Separation subtree (15 files, 492 references) was missed completely. The original 20-hour estimate should be revised to **30-40 hours**.

The good news: approximately **54 of 83 Theories files need NO code changes** because they use `all_future`/`all_past` only as function applications (not pattern matches), which work transparently when these become `def`s. The actual implementation work concentrates on ~29 files with pattern matches plus the axiom removal cascade.

Key new findings include: `@[match_pattern]` may reduce refactoring surface dramatically (needs prototyping), the ConservativeExtension/ExtFormula module is structurally incompatible (has `all_past`/`all_future` but no `untl`/`snce`), the Separation module's syntactic predicates semantically change (correctly), and the task should proceed immediately because it unblocks task 157.

## Key Findings

### 1. Corrected Scope — 40% Larger Than Original Research

| Metric | Round 1 Estimate | Round 2 Actual | Delta |
|--------|-----------------|----------------|-------|
| Theories files | ~70 | **83** | +13 |
| Theories references | ~1416 | **1891** | +475 |
| Pattern-match arms | ~122 | **~400** | +278 (3.2x) |
| Test files | (unmentioned) | **20** | new |
| Test references | (unmentioned) | **507** | new |
| **Total files** | ~70 | **103** | +33 |
| **Total references** | ~1416 | **2398** | +982 |

**Root cause of undercount**: The entire `WeakCanonical/` subtree (15 files, 492 references including 260 pattern-match arms) was omitted. The test suite (20 files, 507 references) was unmentioned. `UltrafilterFrame.lean` (82 refs, untracked new file) was unknown.

### 2. Three-Tier Difficulty Classification

**Tier 1 — HARD (5 files, ~200 pattern arms, 2+ hours each)**:
- `Syntax/Formula.lean` (64 refs, 34 arms): Core type change + beq/complexity/atoms/swap
- `WeakCanonical/Separation/Hierarchy.lean` (115 refs, 82 arms): Massive structural inductions
- `WeakCanonical/Separation/TemporalClosure.lean` (111 refs, 58 arms): But has `expand_temporal` proof asset
- `WeakCanonical/Separation/Defs.lean` (45 refs, 36 arms): 9+ recursive functions lose arms
- `ConservativeExtension/ExtFormula.lean` (39 refs, 30 arms): Parallel type must match

**Tier 2 — MEDIUM (~24 files, ~200 pattern arms, 30-60 min each)**:
Including `Duality.lean`, `DedekindZ.lean`, `Lifting.lean`, `Substitution.lean`, `ProofSearch.lean`, `SignedFormula.lean`, `SubformulaClosure.lean`, `SoundnessLemmas.lean`, and others.

**Tier 3 — EASY (~54 files, 0 pattern arms, most need NO changes)**:
These use `all_future`/`all_past` only as function applications (`φ.all_future`, `Formula.all_future φ`). Since `all_future` becomes a `def` with the same signature `Formula → Formula`, these compile unchanged. Includes high-reference files like WitnessSeed (88 refs), ReflexiveCanonical (84 refs), PointInsertion (74 refs), Bridge (57 refs).

### 3. WeakCanonical/Separation — The Missing Module

**15 files, 492 references, 260 pattern-match arms** — entirely absent from the original plan.

| File | Refs | Arms | Risk |
|------|------|------|------|
| Separation/Hierarchy.lean | 115 | 82 | CRITICAL |
| Separation/TemporalClosure.lean | 111 | 58 | HIGH (but has proof assets) |
| ReflexiveCanonical.lean | 84 | 0 | MEDIUM (constructor apps + axiom refs) |
| Separation/Defs.lean | 45 | 36 | CRITICAL (syntactic predicates change) |
| ExpressiveCompleteness.lean | 25 | 20 | MEDIUM |
| Separation/Duality.lean | 24 | 20 | MEDIUM |
| Separation/DedekindZ.lean | 24 | 20 | MEDIUM |
| Separation/SeparationThm.lean | 24 | 4 | LOW |
| Table.lean | 12 | 10 | MEDIUM |
| TruthLemma.lean | 10 | 2 | LOW |
| Others (5 files) | 18 | 8 | LOW |

**Critical finding**: `TemporalClosure.lean` (lines 588-629) already defines `Formula.top`, `expand_temporal`, and proves `all_past_equiv_neg_snce` and `all_future_equiv_neg_untl` — the EXACT semantic equivalences this refactoring relies on. This is a valuable proof asset that validates the semantic correctness.

### 4. Syntactic Predicate Semantic Changes (Correct but Significant)

After the refactor, `all_future φ` expands to contain `untl`. This means:

| Predicate | Before | After | Correct? |
|-----------|--------|-------|----------|
| `is_U_free (all_future φ)` | `is_U_free φ` | `false` (contains untl) | **Yes** — G is now defined via U |
| `is_S_free (all_past φ)` | `is_S_free φ` | `false` (contains snce) | **Yes** — H is now defined via S |
| `is_future_only (all_future φ)` | `is_future_only φ` | `true` (no snce) | **Yes** |
| `is_future_only (all_past φ)` | `false` | `false` (contains snce) | **Yes** |
| `is_syntactically_separated (all_future φ)` | `is_S_free φ` | `is_S_free φ` | **Yes** (verified by tracing) |

These changes are all **mathematically correct** — after the refactoring, G/H ARE defined via U/S, so predicates about U/S-freeness should reflect this. However, the Separation theory proofs that relied on the old behavior (e.g., Hierarchy theorem) must be updated.

### 5. `swap_temporal` — Works Algebraically, Proof Breaks

Tracing the expansion:
```
swap_temporal(all_future φ)
= swap_temporal((untl φ.neg top).neg)
= swap_temporal(imp (untl (imp φ bot) (imp bot bot)) bot)
= imp (snce (imp (swap_temporal φ) bot) (imp bot bot)) bot
= (snce (swap_temporal φ).neg top).neg
= all_past (swap_temporal φ) ✓
```

The algebra is correct — swapping `untl ↔ snce` automatically swaps G ↔ H. But the `swap_temporal_involution` proof uses `| all_past _ ih =>` and `| all_future _ ih =>` induction cases that no longer exist. The involution proof must be completely rewritten using 6-constructor induction, with G/H cases proven as separate lemmas.

### 6. `temp_k_dist` / `temp_4` Removal Cascade

Removing these axioms impacts ~100 direct references across 36+ files:

| Category | Count | Examples |
|----------|-------|---------|
| Axiom invocations (building derivation trees) | ~45 | MCSProperties, PointInsertion, ReflexiveCanonical |
| Soundness proof arms | ~20 | Soundness.lean, SoundnessLemmas.lean, DiscreteSoundness.lean |
| Substitution/Lifting arms | ~14 | Substitution.lean, ConservativeExtension/*.lean |
| Automation references | ~12 | ProofSearch.lean (pattern detection), Tactics.lean (`temp_4_tactic`), AesopRules.lean |
| Other (definitions, comments) | ~9 | Various |

**Key risk**: The plan allocates zero dedicated time for deriving `temp_k_dist` and `temp_4` as theorems from BX axioms. This derivation is non-trivial and should be done BEFORE removing the axiom constructors.

### 7. SubformulaClosure — Deeper Issues Than Originally Identified

Beyond pattern-match arm removal, SubformulaClosure has:
- **Structural F/P detection patterns**: `f_nesting_depth` and `extractFInner` pattern-match on `imp (all_future (imp inner bot)) bot` to detect F formulas. After the refactor, F formulas are `untl φ top`, a completely different pattern.
- **`Formula.noConfusion` proofs**: Used to distinguish `all_future` from `all_past` in membership proofs (e.g., `G_neg_neg_bot ≠ H_neg_neg_bot`). After the change, both are `imp` at the top level, so `noConfusion` cannot distinguish them — these proofs need entirely different strategies.
- **Deferral closure constants**: `G_neg_neg_bot`, `H_neg_neg_bot` etc. are defined as `Formula.all_future neg_neg_bot` — these compile but the distinction proofs break.

### 8. Semantic Equivalence Proof — Multi-Step Unfolding Required

The `truth_at` equivalence for `all_future φ` requires:
```
truth_at(all_future φ, t)
= truth_at((untl (φ.imp bot) (bot.imp bot)).imp bot, t)
= (∃ s, t < s ∧ ¬truth_at(φ, s) ∧ ∀ r ∈ (t,s), truth_at(bot.imp bot, r)) → False
= (∃ s, t < s ∧ ¬truth_at(φ, s) ∧ ∀ r ∈ (t,s), True) → False   [key: bot→bot is True]
= ¬(∃ s, t < s ∧ ¬truth_at(φ, s))
= ∀ s, t < s → truth_at(φ, s) ✓
```

The critical step is proving `truth_at(bot.imp bot, r) ↔ True`, which requires two `truth_at` unfoldings (imp then bot). This is straightforward but not a single simp step — every downstream proof that relied on direct `truth_at` unfolding for G/H must use the bridge lemmas.

### 9. ConservativeExtension/ExtFormula — Structural Incompatibility

`ExtFormula` is a separate inductive type with 6 constructors: `{atom, bot, imp, box, all_past, all_future}`. It does **NOT** have `untl` or `snce`. After task 116:
- `Formula` constructors: `{atom, bot, imp, box, untl, snce}` + `def` abbreviations
- `ExtFormula` constructors: `{atom, bot, imp, box, all_past, all_future}` — unchanged

`embedFormula` cannot translate `untl`/`snce` formulas. Additionally, `embedFormula` only handles 6/8 current Formula constructors (missing `untl`/`snce`) and uses `String` atoms vs `Atom` struct — it's already broken.

**Recommendation**: Scope ConservativeExtension out of task 116. It's effectively dead code (not imported by any barrel file). Create a follow-up task to either repair or archive it.

### 10. `@[match_pattern]` — Potential 50% Surface Reduction (Needs Prototyping)

Lean 4 supports `@[match_pattern]` on `def`s, allowing them to be used in pattern positions. If applied to `all_future`/`all_past`:
```lean
@[match_pattern] def all_future (φ : Formula) := (some_future φ.neg).neg
```

Then existing `| .all_future ψ =>` pattern matches **might still compile**. This is used in Mathlib (e.g., `Lists.atom`). However, the expansion pattern `(untl (φ.imp bot) (bot.imp bot)).imp bot` is complex, and Lean may not be able to discriminate during pattern matching (since it overlaps with general `imp` patterns).

**Verdict**: Prototype on a branch before committing. If it works, ~200 pattern-match arms could survive unchanged. If not, proceed with the full mechanical refactor.

### 11. `top` Consolidation Needed

Four inconsistent local `top` definitions exist:
1. `LindenbaumQuotient.lean:330` — `def top_quot := toQuot (Formula.bot.imp Formula.bot)`
2. `ChronicleToCountermodel.lean:171` — `def top_formula := Formula.bot.imp Formula.bot`
3. `TemporalClosure.lean:588` — `abbrev Formula.top := .imp .bot .bot`
4. `TemporalDerived.lean:61` — `private abbrev top := Formula.neg Formula.bot`

All semantically equivalent. A canonical `def Formula.top` should be added to `Formula.lean` and the local definitions replaced.

### 12. Derived Property Changes

| Property | G(p) Before | G(p) After | Change? |
|----------|------------|------------|---------|
| `complexity` | 2 | 5 | **Yes** — counts structural constructors |
| `modalDepth` | 0 | 0 | No |
| `temporalDepth` | 1 + td(p) | 1 + td(p) | No — correct |
| `countImplications` | 0 | 3 | **Yes** — counts structural imps |
| `needsPositiveHypotheses` | true | false | **Yes** — top-level imp now |
| `atoms` | atoms(p) | atoms(p) | No — correct |

`complexity` and `countImplications` changes are inherent to the structural representation change and are mathematically correct. `needsPositiveHypotheses` changing may affect heuristic proof search but is logically correct (G(φ) = ¬F(¬φ) is an implication).

### 13. Task Should Proceed Immediately

- Tasks 115, 124 (from the Phase 2 roadmap sequence) are already completed/archived
- Task 126 is ABANDONED
- Task 116's only dependency (107) is completed
- Task 157 (expressive completeness of {S,U}) is explicitly blocked by task 116's `all_future`/`all_past` constructors — documented across 10 research reports and 8 plan versions
- The refactoring improves publishability by aligning with standard presentations (Burgess 1982, GHR94)

## Synthesis

### Conflicts Resolved

1. **Effort estimate**: Teammate C says 35-50h, Teammate B says 28-35h. **Resolution: ~35 hours** — the Tier 3 files (54 files, 0 code changes) dramatically reduce the hands-on work, but the Separation module and axiom cascade add significant complexity beyond the original estimate.

2. **`is_U_free` semantic change — correct vs incorrect?**: Teammate A says "correct" (G now contains U), Teammate B says "breaks predicates." **Resolution: A is right mathematically** — after the refactoring, G IS defined via U, so `is_U_free(G(φ)) = false` is the correct semantics. The Separation theory treats G/H as abbreviations for U/S combinations, matching Burgess 1982 and GHR94. The Separation proofs need updating to reflect this correct new semantics, but the predicates themselves are right.

3. **ConservativeExtension handling**: Teammate B says "scope out" (dead code), Teammate D says "add untl/snce." **Resolution: Scope out** — `embedFormula` is already broken (missing untl/snce cases, wrong atom type). A separate task should repair or archive it.

4. **`@[match_pattern]` viability**: Teammate D proposes it could reduce work by 50%. **Resolution: Prototype first** — the complex expansion pattern may not work with Lean's pattern discriminator, but the potential payoff justifies a 1-hour prototype.

### Gaps Identified

1. **No plan phase for WeakCanonical** (15 files, 492 refs, 260 arms) — must be added
2. **No plan phase for tests** (20 files, 507 refs) — must be added
3. **No time allocated for deriving temp_k_dist/temp_4 from BX axioms** — should be a prereq
4. **SubformulaClosure `Formula.noConfusion` proofs** — not mentioned in any plan
5. **`@[match_pattern]` prototyping** — not considered in any plan
6. **Automation has dedicated `temp_4_tactic`** — must be rewritten or removed

### Recommendations

1. **Use `def` (not `abbrev`)** for all four abbreviations. Add both unfolding and re-folding `@[simp]` lemmas.

2. **Add `@[match_pattern]` and prototype** before committing to full refactor. If it works, many pattern-match sites survive unchanged.

3. **Consolidate `top`** as a canonical `def Formula.top` in Formula.lean (Phase 0/prereq).

4. **Derive `temp_k_dist`/`temp_4` as theorems BEFORE removing from Axiom** — replace all ~45 invocations with derived versions, then remove constructors.

5. **Add dedicated phases**: WeakCanonical/Separation (Phase 7.5) and Tests (Phase 10.5).

6. **Scope out ConservativeExtension** — it's broken independently. Create follow-up task.

7. **Revise time estimates**: 30-40 hours (not 20). The 54 Tier 3 files need no changes, concentrating work on ~29 pattern-match files + axiom cascade.

8. **Leverage existing proof assets**: `TemporalClosure.lean` already has `expand_temporal` and the semantic equivalence proofs. Build on these.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary Approach | completed | high | File-by-file tier classification (54 files need no changes); complete simp lemma inventory; derived property change analysis |
| B | Alternatives | completed | high | `def` vs `abbrev` decision; `top` consolidation; ConservativeExtension dead-code finding; test suite scope (507 refs); revised total count (2398 refs/103 files) |
| C | Critic | completed | high | Pattern-match recount (400 vs 122); `swap_temporal` proof breakage analysis; SubformulaClosure `noConfusion` issue; time estimate revision (35-50h); temp_k_dist/temp_4 blast radius (~100 refs) |
| D | Horizons | completed | high | Task ordering (proceed now, unblocks 157); `@[match_pattern]` proposal; ConservativeExtension structural incompatibility; publication alignment; re-folding simp lemma enhancement |

## References

- Burgess, J.P. (1982). "Axioms for tense logic I: Since and Until." *Notre Dame Journal of Formal Logic* 23(4).
- Gabbay, Hodkinson, Reynolds (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol 1. Chapter 10 (Separation theorem).
- specs/157_expressive_completeness_su_integer/reports/10_task116-dependency-analysis.md
- Teammate A findings: specs/116_redefine_ghfp_via_until_since/reports/02_teammate-a-findings.md
- Teammate B findings: specs/116_redefine_ghfp_via_until_since/reports/02_teammate-b-findings.md
- Teammate C findings: specs/116_redefine_ghfp_via_until_since/reports/02_teammate-c-findings.md
- Teammate D findings: specs/116_redefine_ghfp_via_until_since/reports/02_teammate-d-findings.md
