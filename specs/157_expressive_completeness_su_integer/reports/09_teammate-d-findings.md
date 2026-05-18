# Teammate D Findings: Strategic Horizons

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-18
**Angle**: Strategic direction, minimum viable path, unconventional approaches

## Key Findings

### 1. Cost-Benefit Analysis: Axiom Elimination IS Worth Doing — But Not at Any Cost

**What axiom elimination buys:**
- **Roadmap Phase 2** ("Frame hierarchy + axiom cleanup") explicitly lists axiom cleanup. The 9 axioms in SeparationThm.lean are the largest axiom cluster in the entire codebase — more than any other module.
- **Task 155** (Reynolds pipeline) does NOT need axiom-free separability to proceed. It needs sorry-free `US_expressively_complete_over_Z`, which is ALREADY achieved. The dependency in state.json is about the theorem existing, not about its axiom footprint.
- **Publication quality** (Roadmap Phase 5): Axioms are semantically sound but epistemically weaker than proved theorems. For a formal verification paper, having 9 unproved axioms in the separation layer is a meaningful limitation.
- **Primitives reduction**: Roadmap Phase 2 plans to "redefine G/H/F/P via U/S" (task 116), which is exactly `expand_temporal`. Eliminating axioms before that simplification would be cleaner, but is not a hard dependency.

**Verdict**: Valuable but not blocking anything. Task 155 can proceed NOW. Axiom elimination should be bounded: if it's not achievable within ~1 more focused attempt (4-6 hours), descope.

### 2. The Root Cause: `all_past`/`all_future` in `is_syntactically_separated`

Every failed attempt ultimately traces to the same issue: `is_syntactically_separated` (Defs.lean:143-151) accepts `.all_past φ` (when U-free) and `.all_future φ` (when S-free). This means:
- Cases 1-2 (Eliminations.lean:372, 458, 515) produce separated witnesses WITH `all_past`/`all_future`
- The callback in `subst_in_separated_separable` receives formulas that may contain `all_past`/`all_future`
- These can't be expanded without breaking `no_S_nested_in_U` or inflating `count_U`

**GHR94 works in {S, U, ¬, ∧} only.** It has no `all_past`/`all_future` primitives. The formalization's richer language is the SOLE source of all circularity.

### 3. The Nuclear Option DOES Work (HIGH CONFIDENCE)

**Question 6 from the directive**: Can we prove `all_past_separable` directly from `is_separable (¬S(¬φ, ⊤))`?

**Yes, but it's circular in the current setup.** Here's why:
- `all_past φ ≡ ¬S(¬φ, ⊤)` (semantic equivalence, proved as `all_past_equiv_neg_snce`)
- If we had `all_formulas_separable`, then `is_separable (¬S(¬φ, ⊤))` follows trivially
- `all_past_separable` becomes `is_separable_of_equiv (all_past_equiv_neg_snce φ) (all_formulas_separable _)`

The nuclear option IS the endgame — once `all_formulas_separable` eliminates the need for the axioms. The question is proving `all_formulas_separable` non-circularly.

### 4. The SMALLEST Change That Unblocks Everything (HIGH CONFIDENCE)

**Redefine `is_syntactically_separated` to exclude `all_past`/`all_future`:**

```lean
def is_syntactically_separated : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_syntactically_separated φ && is_syntactically_separated ψ
  | .box _ => true
  | .all_past _ => false    -- CHANGED: was `is_U_free φ`
  | .all_future _ => false  -- CHANGED: was `is_S_free φ`
  | .untl φ ψ => is_S_free φ && is_S_free ψ
  | .snce φ ψ => is_U_free φ && is_U_free ψ
```

**Why this works:**
1. `expand_temporal` already produces formulas with `has_no_allpast_allfuture = true`
2. The hierarchy (10.2.5-10.2.8) works ONLY for expanded formulas — which have no `all_past`/`all_future`
3. The callback formulas from `subst_in_separated_separable` would NEVER receive `all_past`/`all_future` because separated formulas can't contain them
4. The circularity disappears entirely — `no_S_nested_in_U_separable_param`'s callback gets formulas that are guaranteed `has_no_allpast_allfuture`

**Blast radius:**
- Cases 1-2 in Eliminations.lean need to produce expanded witnesses (use `¬S(¬φ, ⊤)` instead of `all_past φ`)
- All proofs that construct separated formulas with `all_past`/`all_future` break
- `is_properly_separated` already excludes these (uses `is_past_only`/`is_future_only` which include them), so it's unaffected
- Downstream consumers of `is_separable` are unaffected (existential quantification over witnesses)

**Estimated effort**: 2-4 hours. Mostly updating Cases 1-2 elimination witnesses.

### 5. Alternative: Two-Predicate Approach (MEDIUM CONFIDENCE)

Instead of changing `is_syntactically_separated`, define:

```lean
def is_base_separated : Formula → Bool  -- {S, U, ¬, ∧} only
  | .all_past _ => false
  | .all_future _ => false
  | -- ... same as is_syntactically_separated for other cases

def is_base_separable (φ : Formula) : Prop :=
  ∃ ψ : Formula, is_base_separated ψ = true ∧ int_equiv φ ψ
```

Then:
1. Prove `all_formulas_base_separable` via the hierarchy (no circularity)
2. Prove `is_base_separable → is_separable` (trivially, since `is_base_separated → is_syntactically_separated`)
3. Therefore `all_formulas_separable`

**Advantage**: Zero changes to existing code. Additive only.
**Disadvantage**: Another definition to maintain. Conceptual overhead.

### 6. Task Scoping Recommendation

**Immediate**: Mark task 157 as PARTIAL/COMPLETED for its PRIMARY goal (sorry-free `US_expressively_complete_over_Z`). Unblock task 155.

**New task**: Create a focused task (e.g., "Eliminate 9 axioms in SeparationThm.lean via base-separated hierarchy") with the two-predicate approach (Finding 5) or the redefinition approach (Finding 4). This task is pure proof engineering with no mathematical uncertainty — the path is known, only the Lean encoding needs work.

**Do NOT continue hammering on Phase 3 in the current setup.** 7+ attempts spanning 2 days prove the current `is_syntactically_separated` definition creates unfixable circularity. Any approach that leaves `all_past`/`all_future` in the separated witness space will hit the same wall.

## Strategic Assessment

### Downstream Impact on Task 155

Task 155 description: "Replace the chronicle fallback in Transfer.lean with the full Reynolds Theorem 15 pipeline." It needs `US_expressively_complete_over_Z` — which is sorry-free. It does NOT mention axiom-free. **Task 155 can proceed immediately.**

### Long-Term Alignment

The roadmap's Phase 2 plans to "redefine G/H/F/P via U/S" (task 116). This literally IS `expand_temporal` — making `all_past`/`all_future` derived operators rather than primitives. Once that happens:
- `is_syntactically_separated` naturally loses its `all_past`/`all_future` cases
- The hierarchy becomes straightforward
- The axiom elimination falls out

**Implication**: If task 116 is planned anyway, axiom elimination NOW is premature optimization. The cleanest path is: (1) complete task 116 first (redefine G/H/F/P), (2) then axiom elimination is trivial because `is_syntactically_separated` naturally has no `all_past`/`all_future` cases.

However, task 116 is in Phase 2, which is after sorry-free completeness. If axiom elimination is desired sooner, the two-predicate approach (Finding 5) avoids touching existing code.

## Recommended Approach

**Option A (Fastest, lowest risk)**: Two-predicate approach.
1. Define `is_base_separated` excluding `all_past`/`all_future` (~10 LOC)
2. Prove hierarchy for `is_base_separable` — zero circularity, the existing infrastructure (`no_S_nested_in_U_separable_param`, `subst_in_separated_separable`) works directly (~300 LOC)
3. Bridge `is_base_separable → is_separable` (~5 LOC)
4. Prove `all_formulas_separable` non-circularly (~10 LOC)
5. Replace 9 axioms (~30 LOC)

Total: ~350 LOC, 4-6 hours, zero changes to existing code.

**Option B (Cleanest long-term)**: Redefine `is_syntactically_separated`.
- Higher blast radius but conceptually cleaner
- Better done alongside task 116 (redefine G/H/F/P)
- Estimated 2-4 hours but with risk of cascade breakage

**Option C (Defer)**: Complete task 157 as-is (sorry-free main theorem achieved), create new task for axiom elimination, proceed to task 155.

## Evidence/Examples

### The Callback Type Under Two-Predicate Approach

With `is_base_separated` excluding `all_past`/`all_future`:

```lean
-- subst_in_base_separated_separable callback receives ONLY:
-- .snce c' d' where c', d' = subst_formula c p (.untl A B)
-- NO .all_past cases because base_separated forbids them
-- Therefore callback = (fun χ hns => no_S_nested_in_U_base_separable_param χ hns hexp IH)
-- The IH on count_U works because c', d' have strictly fewer U-types
```

This is the EXACT same structure as the current `no_S_nested_in_U_separable_param` but without the `all_past`/`all_future` escape hatch that causes circularity.

### Why 7+ Attempts Failed (Pattern)

| Attempt | Approach | Failure Point |
|---------|----------|---------------|
| 1-3 | Opaque existentials | Can't access separated structure |
| 4-5 | Constructive + expand_temporal | Breaks no_S_nested_in_U or count_U |
| 6 | Lexicographic (count_ap_af, count_U) | all_future expansion breaks S-free |
| 7 | Parameterized callback | Callback gets all_past from separated witness |

All trace to the same root: separated witnesses contain `all_past`/`all_future`.

## Confidence Level

- Finding 1 (cost-benefit): **HIGH** — task 155 clearly doesn't need axiom-free
- Finding 2 (root cause): **HIGH** — unanimous across 8 research rounds
- Finding 3 (nuclear option): **HIGH** — trivial once all_formulas_separable exists
- Finding 4 (redefine is_syntactically_separated): **HIGH** mathematically, **MEDIUM** on effort estimate
- Finding 5 (two-predicate approach): **HIGH** — additive, zero-risk to existing code
- Finding 6 (scoping): **HIGH** — clear separation of achieved vs remaining goals
