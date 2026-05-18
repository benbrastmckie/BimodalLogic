# Teammate C (Critic) Findings: Task #157

**Task**: Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-18
**Artifact**: 09
**Confidence Level**: HIGH (based on cross-referencing GHR94 text with Lean code and 7+ handoff files)

## Key Findings

### 1. GHR94 Does NOT Use `all_past`/`all_future` — The Formalization's Language Is Wrong for This Proof

**This is the root cause of ALL failures.**

GHR94 Section 10.2 works exclusively in the language `{S, U}` with boolean connectives. The text says (p. 569): "Wffs of the language may contain nested occurrences of S and U." There is NO mention of `H` (all_past) or `G` (all_future) as primitive connectives in Section 10.2. The operators `H(¬A)` and `G(¬A)` appear only as *abbreviations* in the proof of Lemma 10.2.2 (negation lemma) and Lemma 10.2.3 Case 2, where they are immediately expanded:
- `G(¬A) = ¬U(A, ⊤)` (in the sense of the proof text)
- `H(¬A) = ¬S(A, ⊤)` (in the sense of the proof text)

**GHR94's "syntactically separated" (10.2, p. 571)**: "a boolean combination of atoms, wffs U(E, F) with E and F built without using S and wffs S(E, F) with E and F built without using U." No `all_past`/`all_future` appears here.

**Our formalization's `is_syntactically_separated`** (Defs.lean:143-151): Adds two extra cases:
```lean
| .all_past φ => is_U_free φ
| .all_future φ => is_S_free φ
```

This **widens** the definition beyond what GHR94 uses. The GHR94 separation procedure produces boolean combinations of atoms, `U(E,F)` with S-free `E,F`, and `S(E,F)` with U-free `E,F` — NEVER `all_past` or `all_future` as standalone terms.

**Why it matters**: Cases 1-2 in `Eliminations.lean` explicitly construct `all_past`/`all_future` in their separated witnesses (lines 372, 458, 515). These witnesses satisfy the wider `is_syntactically_separated` but are NOT what GHR94 produces. When the hierarchy theorem tries to substitute back into these separated forms, the `all_past`/`all_future` nodes create the callback circularity (report 10, handoff phase-3-callback-analysis).

### 2. The Prior Research Correctly Diagnosed the Problem but Proposed Wrong Fixes

The handoff `phase-3-callback-analysis-20260518.md` contains increasingly desperate attempts to handle `all_past`/`all_future` in the callback:
- Expand them first? Breaks `no_S_nested_in_U`.
- Lexicographic measure `(count_allpast_allfuture, count_U)`? Doesn't work because expanding `all_future` INCREASES count_U.
- Handle them case-by-case? Each path leads to needing the axioms being proved.

The correct fix is identified at line 85-86 of the handoff: "GHR94 proves 10.2.5-10.2.8 for formulas WITHOUT `all_past`/`all_future`." But the proposed resolution — "first expand temporal, then apply hierarchy" — runs into the problem that *the separated witnesses from Cases 1-2 reintroduce `all_past`/`all_future`*.

### 3. The ACTUAL Fix: Change Eliminations Cases 1-2 to Not Produce `all_past`/`all_future`

GHR94 Lemma 10.2.2 states:
```
¬U(A, B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)
¬S(A, B) ↔ H(¬A) ∨ S(¬A ∧ ¬B, ¬A)
```

In the integer case, GHR94 **expands** `G(¬A)` and `H(¬A)` because they are not primitive. So Case 2 (`S(a ∧ ¬U, q)`) should produce a separated witness using `¬S(A, ⊤)` (which equals `H(¬A)`) expanded as its S/U encoding, NOT using `.all_past`. Similarly, Case 1 should not use `.all_future`.

**Specifically**: The elimination cases should produce separated witnesses that are boolean combinations of atoms, `U(E,F)` with S-free E,F, and `S(E,F)` with U-free E,F — nothing else. The existing Cases 1-2 take a shortcut by using `.all_future (¬A)` and `.all_past (¬a)` instead of their S/U equivalents.

**Two paths to fix**:
- **(A) Refactor Cases 1-2** to produce witnesses using `¬U(A, ⊤)` for `G(¬A)` and `¬S(A, ⊤)` for `H(¬A)`. This is the cleanest approach: the separated witnesses stay in `{S, U, boolean}` and the `all_past`/`all_future` cases never arise.
- **(B) Narrow `is_syntactically_separated`** to disallow `all_past`/`all_future` entirely (remove the two cases from Defs.lean). Then Cases 1-2 must be updated. This is option (b) from report 10.
- **(C) Prove the hierarchy WITH `all_past`/`all_future` handling**. This is what 7+ attempts have tried and failed at. I assess this as possible but unnecessarily hard.

### 4. "Constituent" in GHR94 Means "Boolean Constituent"

GHR94 10.2.6 (line 169): "Note that U(Aₙ, Bₙ) does not appear in any Dⱼ." The Dⱼ are the "pure past wffs" that are boolean constituents of the separated form E'. In GHR94's language, E' is a boolean combination of:
- atoms (including fresh qi)
- U(An, Bn) (pure future)
- Dj = S(...) with no U inside (pure past)

"Substitute U(Ai, Bi) for each qi in each Dj" means: for each past constituent Dj, replace the atoms qi with the temporal formulas U(Ai, Bi). The key is that U(An, Bn) appears ONLY in future constituents, never in the Dj's.

**In the formalization**: `subst_in_separated_separable` handles `.snce` positions (past constituents) and `.untl` positions (future constituents) of a separated formula. The issue is that `.all_past` positions are ALSO past constituents in the widened definition, but GHR94 never has them.

### 5. `count_U_subformulas` as Used in the Callback Does Decrease (Clarification)

The handoff claims "Count-U of callback formulas is NOT bounded below the original." This needs nuance:

In GHR94 10.2.6, after abstracting n-1 U-types to atoms q1...q_{n-1}, the separated form E' has U appearing ONLY as U(An, Bn) in future positions. When we substitute U(Ai, Bi) back for qi in past constituents Dj, each Dj contains at most n-1 distinct U-types (just U(A1,B1)...U(A_{n-1},B_{n-1}), NOT U(An,Bn)). So count_distinct_U_types decreases.

However, `count_U_subformulas` (which counts total U-node occurrences, not distinct types) CAN increase: if qi appears 5 times in Dj, substituting U(Ai, Bi) gives 5 copies. But the INDUCTION in 10.2.6 is on the NUMBER OF DISTINCT U-TYPES n, not on count_U_subformulas.

The current Lean code uses `count_U_subformulas` (total count) as the induction measure, not n (distinct types). **This is a mismatch with GHR94.** The abstraction step removes all copies of U(An, Bn), which strictly decreases `count_U_subformulas`. But the substitution-back step can increase total count. GHR94's approach works because it uses distinct-type count as the measure, and the substitution-back is handled by 10.2.5 (single-type case) within each constituent.

### 6. Common Pattern in All 7+ Failed Attempts

Every failed attempt follows the same arc:
1. Start with the right idea (follow GHR94 hierarchy)
2. Hit `all_past`/`all_future` in separated formulas (from Cases 1-2)
3. Try to handle them (expand, case-split, lexicographic measure)
4. Each handling attempt either breaks `no_S_nested_in_U`, introduces circular dependencies, or requires the very axioms being proved
5. Write handoff documenting the dead end

The pattern repeats because the ROOT CAUSE (Cases 1-2 produce non-GHR94 separated witnesses) is never fixed.

## Gaps and Blind Spots

1. **Nobody has tried changing Cases 1-2.** All 7+ attempts accept the existing elimination cases as given and try to work around the `all_past`/`all_future` they produce. This is backwards — the cases are the problem.

2. **The `is_syntactically_separated` definition has never been questioned.** Report 10 mentions option (b) "refactor `is_syntactically_separated` to disallow `all_past`/`all_future`" but this is always deferred as too invasive. It's not — it's the correct fix.

3. **GHR94 10.2.3 Case 2** (Eliminations.lean) uses `H(¬A)` but the text says "noting that S(a ∧ G(¬A), q) is equivalent to S(a, ¬A ∧ q) ∧ (¬A) ∧ G(¬A)." In integer time, `G(¬A) = ¬U(A, ⊤)` which is just `¬(.untl A (.imp .bot .bot))`. This is a boolean negation of a future formula — perfectly separated without needing `.all_future`. Similarly `H(¬A) = ¬S(A, ⊤)` is a boolean negation of a past formula.

4. **The `.untl`/`.snce` cases of `all_formulas_separable_aux`** (Hierarchy.lean:1687-1698) currently use `all_separable` (axiom-dependent). Nobody has tried the approach of doing junction-depth induction AFTER eliminating `all_past`/`all_future` from the separated witnesses. With GHR94-conformant separated forms (no `all_past`/`all_future`), the hierarchy theorem becomes straightforward.

5. **No attempt has been made to verify the fix in isolation.** Before building the full hierarchy, one could modify Case 1 to use `¬(.untl A (.imp .bot .bot))` instead of `.all_future (Formula.neg A)` and verify it compiles. This would be a 10-line change that validates the approach.

## Invalid Assumptions Found

| Assumption | Status | Evidence |
|------------|--------|----------|
| "Cases 1-8 are correctly proved and should not be changed" | **INVALID** | Cases 1-2 use `.all_future`/`.all_past` which are not part of GHR94's separated language |
| "`is_syntactically_separated` is correct" | **PARTIALLY INVALID** | Correct as a definition, but the `.all_past`/`.all_future` cases widen it beyond GHR94 and cause the callback circularity |
| "Expanding temporal before hierarchy solves the problem" | **INVALID** | Expansion removes `all_past`/`all_future` from the INPUT formula, but Cases 1-2 REINTRODUCE them in separated witnesses |
| "`count_U_subformulas` is the right induction measure for 10.2.6" | **INVALID** | GHR94 uses count of DISTINCT U-types, not total U-node count |
| "The callback formulas have fewer U-subformulas" | **SOMETIMES INVALID** | Depends on measure: distinct types YES, total count NO |
| "We need a combined lexicographic measure" | **MISGUIDED** | The real fix is preventing `all_past`/`all_future` from appearing in separated witnesses |

## Recommendations

### Priority 1: Modify Cases 1-2 to Use S/U Encodings (HIGH CONFIDENCE)

Replace `.all_future (¬A)` with `¬(.untl A .top)` and `.all_past (¬a)` with `¬(.snce a .top)` in the separated witnesses of Cases 1-2.

**Verification**: These replacements are semantically equivalent by the already-proved `all_future_equiv_neg_untl` and `all_past_equiv_neg_snce`. The resulting formulas are `is_syntactically_separated` because:
- `¬(.untl A .top)` = `.imp (.untl A .top) .bot` where `.untl A .top` has S-free args
- `¬(.snce a .top)` = `.imp (.snce a .top) .bot` where `.snce a .top` has U-free args

Both are boolean combinations of separated subformulas.

**Estimated effort**: 50-100 LOC (modify the witnesses and their separation proofs in Cases 1-2).

### Priority 2: Optionally Narrow `is_syntactically_separated`

After fixing Cases 1-2, the `all_past`/`all_future` cases in `is_syntactically_separated` become dead code (no elimination case produces them). They can be removed for cleanliness:

```lean
| .all_past _ => false
| .all_future _ => false
```

This may break some existing lemmas that depend on `all_past`/`all_future` being separated, but those lemmas become unnecessary once the hierarchy works without them.

### Priority 3: Implement Hierarchy Without `all_past`/`all_future` Complications

With GHR94-conformant separated witnesses:
1. `subst_in_separated_separable` callback never encounters `.all_past`/`.all_future`
2. `no_S_nested_in_U_separable_param` needs only `has_no_allpast_allfuture` (guaranteed by `expand_temporal`)
3. The full chain 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8 follows GHR94 with no extra complications

### Priority 4: Fix the Induction Measure for 10.2.6

Change from `count_U_subformulas` (total occurrences) to a measure that counts distinct U-types. Or, as GHR94 does it: abstract ALL but one U-type, apply 10.2.5, then substitute back. The count of remaining distinct U-types strictly decreases.

## What Has Each Failed Attempt Gotten Wrong

**All 7+ attempts made the same structural error**: they accepted the separated witnesses from Cases 1-2 as given and tried to build the hierarchy around them. The correct approach is to fix the witnesses to conform to GHR94's separated language, then the hierarchy follows the textbook proof.

This is a classic case of "working around a symptom instead of fixing the cause." The symptom (`all_past`/`all_future` in callbacks) appeared in every attempt. The cause (Cases 1-2 produce non-standard separated witnesses) was identified in report 10 but marked as "too invasive" and never attempted.
