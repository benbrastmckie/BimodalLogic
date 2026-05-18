# Teammate C (Critic) Findings: Task #157 Round 8

**Date**: 2026-05-18
**Angle**: Failure pattern analysis and blind spot identification
**Confidence**: HIGH

## Key Findings: What Has Gone Wrong and Why

### 1. The Fundamental Circularity Is a Formalization Artifact, Not a Mathematical Problem

The GHR94 proof (Lemmas 10.2.4-10.2.8) works by iteratively rewriting a formula, tracking that a well-founded measure decreases at each step. The proof never needs to assert "S(C,F) is separable" as a standalone lemma — it produces the separated formula directly by construction.

The Lean formalization chose to represent separability existentially:
```lean
def is_separable (φ : Formula) : Prop :=
  ∃ ψ, is_syntactically_separated ψ = true ∧ int_equiv φ ψ
```

This is an opaque existential. When GHR94 says "substitute back into past constituents of the separated form," the mathematical proof has a *concrete* formula `ψ` built by the construction. In Lean, after `obtain ⟨ψ, hsep, hequiv⟩ := is_separable_of_something`, you only know `ψ` exists — you cannot pattern-match on its structure to find "past constituents."

**This is the root cause of ALL 7+ failed approaches.** Every approach eventually needs to:
1. Take a separated formula ψ (existential witness)
2. Substitute a temporal operator into specific positions of ψ
3. Argue the result is still separable

Step 2 is impossible with an opaque existential. You don't know WHERE in ψ the relevant atoms ended up. The abstract_untl/abstract_snce infrastructure tries to work around this but produces a model-modification equivalence (M vs M'), not a global int_equiv.

**Root fix**: The hierarchy theorem must be proved by CONSTRUCTING the separated equivalent directly at each step, never passing through an opaque existential. Every intermediate result must return the concrete formula, not just existence.

### 2. Self-Contradicting Research Across Rounds

Rounds 6 and 7 give contradictory assessments of the same mathematical approach:

- **Round 6** (report 06): "The Dedekind formula approach (GHR94 Lemma 10.3.11) is for Dedekind-complete time, NOT for integer time Z. Using it for Z is a category error."

- **Round 7** (report 07): "GHR94 Section 10.3 (Dedekind-complete time) provides Case 5-8 formulas that, when specialized to integers, yield correct intermediate equivalences." Teammate B verified this against the counterexample.

**Who is right?** Round 7. The Dedekind formulas from Section 10.3 are MORE GENERAL than the integer formulas from Section 10.2. They apply to ALL Dedekind-complete time structures, which includes the integers. The integers are Dedekind-complete (trivially — every bounded subset has a sup, namely its maximum, since discrete).

Round 6's "category error" claim was itself wrong. The error was confusing "designed for dense time" with "only valid on dense time." The formulas work on Z; they just have extra terms (K±, Γ±) that collapse to ⊥ on Z, making them simpler than on the reals.

**Critical lesson**: This self-contradiction wasted significant effort. Round 6 dismissed the Dedekind approach, Round 7 rediscovered it. The code now implements the Dedekind approach (case3_equiv_Z_general, Q-lemma, etc.), confirming Round 7 was right.

### 3. Case 7 Is Not Fundamentally Harder — The Tooling Gap Is the Issue

Current state: Cases 5, 6, 8 proved without all_separable. Case 7 uses `all_separable _`.

**Why Case 7 is "harder"**: S(a∧U, q∨¬U). Expanding ¬U via `neg_until_equiv` gives guard `q ∨ G(¬A) ∨ U'` where `U' = U(¬A∧¬B, ¬A)`. Applying case3_equiv_Z_general for U' splits into formulas with both U and U' in event position. The existing `untl_under_bool_only` / `replace_untl_with_top` machinery handles ONE U-type at a time.

**Why Cases 5, 6, 8 succeed**: 
- Case 5: Only U(A,B) appears; ¬U never enters a guard.
- Case 6: ¬U appears but the contradiction U∧U'=⊥ allows event-splitting into sub-cases with at most one U-type each.
- Case 8: Decomposes to `S(a∧¬U, ⊤) ∧ ¬S(¬q∧U, ¬a∨U)` which isolates each half to a single U-type.

**For Case 7**: The guard `q∨¬U` means ¬U persists in the guard position. After case3_equiv for U' (treating the ¬U as providing U'), the RHS formula has U(A,B) in event positions AND U' in various places. The contradiction U∧U'=⊥ still applies, but the resulting sub-cases have S-terms with U' inside S-arguments (not just under booleans), which breaks `untl_under_bool_only`.

**The real fix for Case 7**: Use the GHR94 Section 10.2 Case 7 formula DIRECTLY (from the integer case, not Dedekind):

```
S(a∧U, q∨¬U) ↔ S(a, B∧q) ∧ (A ∨ (B∧U(A,B)))
             ∨ S(S(a, B∧q) ∧ A ∧ (q∨¬U(A,B)), q∨¬U(A,B))
```

The first disjunct: S(a,B∧q) is U-free and S-free atoms → syntactically separated. (A∨B∧U) is separated. AND of separated = separable.

The second disjunct: S(event, q∨¬U) where event = S(a,B∧q) ∧ A ∧ (q∨¬U). The INNER S(a,B∧q) is separated (atomic args). A is an atom. q∨¬U is ¬U under boolean. So event = separated ∧ atom ∧ (atom ∨ ¬U). This is a Case 8 form: S(a'∧¬U, q∨¬U) where a' = S(a,B∧q)∧A∧q (under event-split on ¬U at the event). Actually: need to handle the ¬U in both event and guard.

Wait — the second disjunct IS Case 8: S(event∧(q∨¬U), q∨¬U). But the event contains q∨¬U too. Let me re-read: S(S(a,B∧q)∧A∧(q∨¬U(A,B)), q∨¬U(A,B)). The event has ¬U(A,B) and the guard has ¬U(A,B). GHR94 says "use the eighth and fourth eliminations." Case 8 handles S(a'∧¬U, q'∨¬U) and Case 4 handles S(a', q'∨¬U).

This avoids introducing a second U-type entirely! The key is: DON'T use neg_until_equiv on ¬U. Instead, use the GHR94 Case 7 equivalence directly and reduce to Cases 4 and 8 (already proved).

### 4. The "Replace U with ⊤/⊥" Approach Was SOUND for the Cases It Was Used

Round 3 claimed `replace_untl_with_top` was unsound. Round 4 reverted. But Rounds 7-8 BROUGHT IT BACK and it's working for Cases 5, 6, 8.

The confusion: `replace_untl_with_top` IS valid when:
- The formula is under a conjunct with U(A,B) (i.e., U holds at the SAME time point)
- AND the formula's U(A,B) appears only under boolean connectives (not temporal operators)

The second condition is captured by `untl_under_bool_only`. Round 3 missed this condition, applied the replacement under temporal operators, got unsoundness. Rounds 7-8 added the `untl_under_bool_only` guard and the approach is now sound and proven correct (`replace_correct_bool`).

### 5. The Plan (07_dedekind-specialization-plan.md) Is Partially Obsolete

The plan describes 6 phases:
- **Phase 1** [COMPLETED]: K/Gamma triviality, Q-lemma ✓
- **Phase 2** [COMPLETED]: case3_equiv_Z_general, Case 5 ✓
- **Phase 3** [PARTIAL]: Cases 6-8. Plan says "Case 8 first, Case 7 via Cases 4+8, Case 6 via Cases 2+3+5." But actual implementation went: Case 5 → Case 6 → Case 8, with Case 7 blocked. Case 6 was proved via neg_until_equiv + U∧U' contradiction (a different approach than the plan specified).
- **Phase 4** [NOT STARTED]: Hierarchy theorem. The plan's strategy (nested Nat.strongRecOn on JD + count_U) has NEVER been attempted in code. The analysis handoff says it fails at JD=1, but this analysis assumed opaque existentials.
- **Phase 5** [NOT STARTED]: Replace 9 axioms.
- **Phase 6** [NOT STARTED]: Final verification.

**The plan needs revision**: Phase 3 needs a new strategy for Case 7 (use GHR94 10.2.3 Case 7 formula directly, reduce to Cases 4+8). Phase 4 needs fundamental rethinking (constructive separated equivalents, not opaque existentials).

## Gaps and Shortcomings

### A. Nobody Has Re-Read GHR94 Section 10.2.3 Case 7 Recently

The handoffs discuss Case 7 in terms of "multi-U-type barriers" from neg_until_equiv expansion. But GHR94 10.2.3 gives an EXPLICIT formula for Case 7 that reduces to Cases 8 and 4 WITHOUT introducing a second U-type. This is on lines 95-101 of the literature file:

```
S(a∧U, q∨¬U) ↔ S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U) ∨ S(a,B∧q)∧A ∨ S(a,B∧q)∧B∧U(A,B)
```

Then "eliminations (8) and (4)" finish it. This has been sitting in the literature file the entire time. Nobody in rounds 5-8 checked whether Case 7's GHR94 integer formula would work directly without neg_until_equiv.

### B. The Hierarchy Theorem Strategy Needs Constructive Witnesses

ALL 7 failed approaches to the hierarchy share one defect: they try to prove `is_separable φ` by composing existential witnesses. This is fundamentally wrong for GHR94's proof structure.

GHR94 works by CONSTRUCTING the separated equivalent step by step. The Lean proof must do the same: track the concrete formula through each transformation, not just assert existence. This means:

The hierarchy theorem should have signature:
```lean
theorem all_formulas_separable_aux (φ : Formula) 
    (hexp : has_no_allpast_allfuture φ = true) :
    { ψ : Formula // is_syntactically_separated ψ = true ∧ int_equiv φ ψ }
```

or equivalently, return a `Subtype`. With a concrete witness, you CAN substitute into specific positions and argue the result is separated.

However, this requires refactoring all 8 case eliminations to return concrete formulas rather than existential proofs. Cases 1-4 in Eliminations.lean already partially do this (they construct explicit `elim_case_N_formula`). But the infrastructure for composing these is missing.

### C. The `expand_temporal` Step May Be Unnecessary

The current plan calls for `expand_temporal` to eliminate `all_past`/`all_future` before the hierarchy theorem. This adds complexity. GHR94's Lemma 10.2.8 works directly on formulas with S and U — it doesn't require elimination of H (all_past) and G (all_future) first. The junction_depth definition treats these as transparent (they don't count toward junction depth).

The real question: can the hierarchy theorem work directly on the unexpanded formula? If H(φ) = ¬S(⊤,¬φ) is used, then H(φ) has the same junction depth as S(⊤,¬φ). But `expand_temporal` is currently done BEFORE the hierarchy, which means `has_no_allpast_allfuture` is a precondition. This seems unnecessary and adds a composition step.

### D. Case 6 May Have a Hidden Bug

The case6_separable_Z proof at line 1628 uses `neg_untl_event_equiv` and `since_distrib_or_left` and then delegates Branch B to `case6_branchB_separable`. But the handoff from earlier (case6-handoff-20260518.md) says D3 of Branch B had "two sorry." The current code at line 1659 shows only Case 7 using `all_separable _`. So either D3 was resolved, or the sorry was replaced without proper verification.

Let me verify: `grep` shows only one `all_separable` use in DedekindZ.lean (line 1659, Case 7). The Case 6 code compiles without sorry. So D3 was indeed resolved — likely in the round that added `d21_sep` and `replace_untl_with_bot` infrastructure. This appears correct.

## Specific Concerns

### Concern 1: The GHR94 "K⁺q = K⁻q = ⊤" Error (Line 249 of Literature File)

The literature file at line 249 says: "In integer time, these connectives are not very interesting for K⁺q = K⁻q = ⊤."

Round 7 research correctly identifies this as a textbook error: K⁺q = ⊥, not ⊤. The code correctly proves K_plus_bot_on_Z and K_minus_bot_on_Z. BUT: this means Section 10.3 formulas specialized to Z have K⁺ = K⁻ = ⊥ (NOT ⊤ as the text claims). The implementation accounts for this, but it means anyone reading GHR94 must mentally correct line 249.

Risk: If ANY future lemma relies on K⁺ = ⊤ (as GHR94 text suggests), it will be wrong. The code is safe, but the documentation should flag this prominently.

### Concern 2: case3_equiv_Z_general Requires U-free AND S-free Guards

The theorem signature:
```lean
theorem case3_equiv_Z_general (a q A B : Formula)
    (hq : is_U_free q = true) (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hq' : is_S_free q = true) (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    int_equiv (.snce a (Formula.or q (.untl A B))) (case3_rhs a q A B)
```

Note: `a` has NO freeness constraints. This matches GHR94 ("a, q, A, B being atoms" — but the proof generalizes a to arbitrary event). This is correct and important.

BUT: the plan's Phase 4 (hierarchy theorem) calls case3_equiv_Z_general inside an induction where q, A, B may NOT be S-free or U-free (they could be arbitrary subformulas after abstraction). This is a real problem if the hierarchy tries to use case3_equiv at JD > 1 where the subformulas have been partially processed.

### Concern 3: No Vacuous Definitions Found

I checked for `def X := True` patterns:
```
grep -n "def.*:= True\|def.*:= trivial\|def.*:= Unit" DedekindZ.lean
```
None found. All definitions appear substantive.

### Concern 4: `is_U_free` Accepts `all_future` 

As noted in Round 7 research: `is_U_free` returns true for `all_future φ` when φ is U-free. Mathematically, G(φ) = ¬U(¬φ, ⊤), so `all_future` contains U implicitly. But since `expand_temporal` is applied first (replacing `all_future` with `¬U(¬φ, ⊤)`), this doesn't cause problems in practice. The `has_no_allpast_allfuture` precondition ensures the issue can't arise.

## Questions Not Being Asked

### Q1: Could Case 7 Be Proved Using the GHR94 Integer Formula Directly?

GHR94 10.2.3 Case 7 gives:
```
S(a∧U, q∨¬U) ↔ [S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U)] ∨ [S(a,B∧q)∧A] ∨ [S(a,B∧q)∧B∧U]
```

- Disjunct 2: S(a,B∧q) is Case 0 (no U at all). A is an atom. Their AND is separable.
- Disjunct 3: S(a,B∧q) is Case 0. B∧U is separated. Their AND is separable.
- Disjunct 1: S(event∧¬U, q∨¬U) where event = A∧S(a,B∧q)∧q. Wait — the event is A∧(q∨¬U)∧S(a,B∧q). After expanding: this is `A∧q∧S(a,B∧q) ∨ A∧¬U∧S(a,B∧q)` (distributing over q∨¬U). This is NOT simply Case 8 because the event has mixed U-type content.

Actually: the first disjunct of GHR94 has full event `A∧(q∨¬U(A,B))∧S(a,B∧q)` and guard `q∨¬U(A,B)`. The event contains ¬U, the guard contains ¬U. This IS Case 8 form (after noting that the event has a factor of ¬U from q∨¬U when the event point satisfies ¬q). Actually, no — the event doesn't necessarily have ¬U as a conjunct. It has q∨¬U as a factor.

Let me reconsider: S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U). Event-split on U at the event point:
- U holds: event = A∧(q∨¬U)∧S(a,B∧q) with U holding. q∨¬U simplifies via q∨False = q. So event ↔ A∧q∧S(a,B∧q)∧U. Guard still has ¬U. This is Case 1 for U (U in event, not in guard after simplification? No — guard has ¬U). Actually guard q∨¬U. When U holds, ¬U is false, so guard must be satisfied by q alone at each guard point. But we can't simplify the guard that way since U may differ at guard points. So the guard is q∨¬U as-is.

This IS Case 5 form: S(a'∧U, q∨U'') where a' = A∧q∧S(a,B∧q) and the guard has ¬U. Wait, no. Case 5 has S(a'∧U, q'∨U). Here we have S(a'∧U, q∨¬U) which is Case 7 again — circular.

So GHR94 says "use eliminations (8) and (4)" on the first disjunct. Let me re-read exactly:

The first disjunct is: `S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U)`.

This has ¬U in both event and guard. If we factor out: event can be written as `e∧(q∨¬U)` where e = A∧S(a,B∧q). So S(e∧(q∨¬U), q∨¬U).

Hmm. Event-split on guard's ¬U satisfaction: this is S(e∧(q∨¬U), q∨¬U) = Case 4 form S(e, q∨¬U) when e doesn't have U... but e doesn't have U (A is an atom, S(a,B∧q) has no U since a,B,q are atoms/U-free). Wait — e is U-free if A and S(a,B∧q) are U-free. They are (a,B,q are all atoms in the original lemma, or U-free in the generalized version). So this IS Case 4: S(U-free-event, q∨¬U). Wait, but (q∨¬U) is a factor of the event too.

Let's simplify: S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U). The event is A∧(q∨¬U)∧S(a,B∧q). Since A, S(a,B∧q) are U-free, the only non-U-free part of the event is (q∨¬U) which contains ¬U. So the event has ¬U under boolean. But the overall form is S(stuff∧¬U-under-boolean, q∨¬U). This doesn't fit Cases 1-8 directly because the event isn't simply a'∧±U.

GHR94 says "use eliminations (8) and (4)." The procedure must be:
1. Use Lemma 10.2.1 (since_distrib) to decompose S(A∧(q∨¬U)∧σ, q∨¬U) into:
   - S(A∧q∧σ, q∨¬U): This has U-free event → Case 4
   - S(A∧¬U∧σ, q∨¬U): This has ¬U in event → Case 8

Both are already proved! This IS the way forward for Case 7.

### Q2: Why Isn't the Hierarchy Theorem Being Attempted With Constructive Witnesses?

Nobody has attempted a version of the hierarchy where each lemma returns the concrete separated formula, not an existential. This would solve the "substitute into past constituents" problem. It's more engineering work (threading concrete formulas), but it's the ONLY approach consistent with GHR94's proof structure.

### Q3: Is There a Simpler Way to Eliminate the 9 Axioms?

If Case 7 can be proved (see Q1 above), then ALL 8 cases are non-circular. The remaining question is: can `all_separable` be proved by structural induction using only Cases 1-8 + boolean closure, WITHOUT the hierarchy?

Answer: No. The structural induction step for `.snce C F` gives IH on C and F, producing separated C' and F'. But `.snce C' F'` is a NEW formula whose separability requires temporal closure (exactly the axiom `snce_separable`). The hierarchy is needed to handle this step.

BUT: if ALL 8 cases return concrete formulas (not existentials), and the hierarchy tracks concrete formulas through abstraction+resubstitution, then the temporal closure axioms become THEOREMS derivable from the construction.

## Confidence Level

**HIGH** on the diagnostic (why things failed, what the root cause is).

**MEDIUM-HIGH** on the Case 7 fix (GHR94 10.2.3 formula → Case 4 + Case 8 via since_distrib). This needs verification against the actual Lean signatures but the mathematical logic is sound.

**MEDIUM** on the hierarchy fix (constructive witnesses). This is the correct approach but the engineering effort is substantial — refactoring all case eliminations to return concrete formulas rather than existentials.
