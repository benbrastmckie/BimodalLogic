# Critic Findings: Task 107 — Burgess Chronicle Construction

**Date**: 2026-05-05
**Role**: Teammate C (Critic)
**Focus**: Gaps, misalignments, stale assumptions, blind spots

---

## Finding 1: STALE COMMENT — Case B Sorry (PointInsertion.lean:1969-1976) Is Now Closable

**What**: The sorry at PointInsertion.lean:1977 (Case B of `burgess_D0_finite_subset_consistent_incons`) has a stale comment claiming "BurgessR3Maximal_extension_fails requires consistent extensions, so no neg-until witness can be extracted." This was true BEFORE the ClosedUnderDerivation cascade but is **FALSE now**.

**Why it matters**: This sorry may be closable without any new infrastructure. The ClosedUnderDerivation strengthening (completed in the recent cascade) was precisely designed to fix this case, but the proof wasn't updated to use it.

**Evidence**:
- `BurgessR3Maximal` (ChronicleTypes.lean:326-329) now uses `∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C`
- `BurgessR3Maximal_extension_fails` (PointInsertion.lean:631-644) uses `deductiveClosure_closed_under_derivation` which doesn't require consistency
- When B is MCS and β ∉ B: `{β}∪B` is inconsistent → `DC({β}∪B) = Set.univ` → `Set.univ` is `ClosedUnderDerivation` → `B ⊂ Set.univ` (B consistent) → maximality gives `¬burgessR3(A, Set.univ, C)`

**The resolution path**: `BurgessR3Maximal_extension_fails` with δ=β already gives `¬burgessR3(A, DC({β}∪B), C)`. By `dc_delta_B_burgessR3` contrapositive, we get `∃ β₀ ∈ B, ∃ γ₀ ∈ C, untl(β₀∧β, γ₀) ∉ A` (or the Since direction fails). Combined with `h_pos : untl(b∧β, γ_hat) ∈ A` and `b∧β` being derivably inconsistent (b has β.neg as a conjunct), the contradiction should follow via left_mono_until.

**Key mathematical argument**: Since ⊢ (b∧β) → (β₀∧β) (b is a conjunction containing β₀), left_mono gives `untl(b∧β, γ_hat) ∈ A → untl(β₀∧β, γ_hat) ∈ A`. But we also need γ_hat to be related to γ₀ — this requires γ₀ to participate in c_list. The existing code uses a fixed c_list without the witness γ₀. **A restructuring is needed**: extract the maximality witness BEFORE constructing c_list, then include γ₀ in c_list. This is the same approach used successfully in Case A.

**Severity**: Critical — this is the most impactful finding. If correct, it eliminates one sorry with no new axioms or infrastructure.

**Confidence**: High (verified definitions and proof states via lean_goal)

---

## Finding 2: Plan v60 Is Significantly Stale

**What**: Plan v60 (plans/60_implementation-plan.md) was written before the NoUnivBurgessR3 cascade and contains multiple outdated assumptions.

**Why it matters**: Following the plan literally would waste effort on already-completed work or pursue approaches that are no longer blocked.

**Specific stale items**:

| Plan Claim | Reality |
|------------|---------|
| "12 remaining sorries" | 8 sorries remain (3 PointInsertion, 2 CounterexampleElimination, 2 ChronicleToCountermodel, 1 Completeness) |
| Phase 1 "Fix Build Error" | COMPLETED — build passes |
| Phase 2 "Add linear_until_mcs" | COMPLETED — infrastructure exists |
| Phase 3 Task 3.3 "BLOCKED: BurgessR3Maximal only considers SetDeductivelyClosed" | FALSE — BurgessR3Maximal now uses ClosedUnderDerivation |
| Phase 6 "7 sorries in CounterexampleElimination" | Only 2 remain (lines 413, 511) |
| Testing line 371 "BurgessR3Maximal uses SetDeductivelyClosed D" | WRONG — uses ClosedUnderDerivation D |
| "Total sorry count: 12 -> 0" | Start is 8, not 12 |

**Severity**: Important — the plan needs revision before implementation continues.

**Confidence**: High (verified sorry counts and definition inspection)

---

## Finding 3: Convention Alignment Is Correct (No Remaining Misalignments)

**What**: After extensive checking of all key definitions against Burgess 1982, the convention mapping is consistent throughout.

**Evidence verified**:
- `burgessR A β C` = ∀γ∈C, untl(β,γ)∈A = ∀γ∈C, U(γ,β)∈A ✓ (matches Burgess r(A,β,C) criterion 2.3a)
- `burgessR3 A B C` forward: ∀β∈B, ∀γ∈C, U(γ,β)∈A ✓
- `burgessR3 A B C` backward: ∀β∈B, ∀α∈A, S(α,β)∈C ✓ (matches 2.3b)
- `BurgessR3Maximal` maximality: over ClosedUnderDerivation ✓ (matches Burgess DCS = no consistency req)
- `burgess_D0_seed`: B ∪ {~δ} ∪ {U(γ,β):β∈B,γ∈C} ∪ {S(α,β):β∈B,α∈A} ✓ (matches Burgess 2.6 D₀)
- `lemma_2_7_seed`: Contains S(α,β∧xi) matching Burgess S(α,β∧η) ✓
- `lemma_2_7` conclusion: eta∈D (event), xi∈B' (guard) ✓ (matches Burgess ξ∈D, η∈B')

**Severity**: Minor (positive finding — no action needed)

**Confidence**: High

---

## Finding 4: ClosedUnderDerivation vs DCS — Definition Is Correct But Has a Subtle Consequence

**What**: `ClosedUnderDerivation` (ChronicleTypes.lean:69) matches Burgess's definition of "deductively closed" exactly: contains all consequences, no consistency requirement. `SetDeductivelyClosed` = `SetConsistent ∧ ClosedUnderDerivation`. The strengthened `BurgessR3Maximal` uses `ClosedUnderDerivation` for maximality, matching Burgess.

**Subtle consequence**: Burgess's r(A, B, C) implicitly requires B to be a DCS (deductively closed). In our code, `burgessR3` does NOT require B to be ClosedUnderDerivation — it only requires the content condition (∀β∈B, ∀γ∈C, untl(β,γ)∈A and the Since dual). The DCS requirement is in the FIRST conjunct of `BurgessR3Maximal`: `SetDeductivelyClosed B`. So `burgessR3(A, Set.univ, C)` is well-defined even though Set.univ is not SetDeductivelyClosed.

**Why it matters**: The `NoUnivBurgessR3` condition rules out `burgessR3(A, Set.univ, C)` which is the content condition only. This is correct because `BurgessR3Maximal` requires `SetDeductivelyClosed B` (consistent), and the maximality extends to ClosedUnderDerivation extensions. The architecture is sound.

**Severity**: Minor (no bug, but worth documenting for future maintainers)

**Confidence**: High

---

## Finding 5: NoUnivBurgessR3 — A Formalization Artifact Not in Burgess

**What**: `NoUnivBurgessR3` (ChronicleTypes.lean:348-350) is not a condition in Burgess's paper. Burgess doesn't mention it because his maximality is implicit over all DCS including Set.univ. In our formalization, it's needed because the Zorn construction works over `SetDeductivelyClosed` (consistent) extensions, and the upgrade to ClosedUnderDerivation maximality requires a separate argument for the inconsistent case.

**Why it matters**: The sorry at Completeness.lean:152 needs `NoUnivBurgessR3` to be PROVED, not assumed. The comment says "This holds because Set.univ contains bot... violating the consistency requirement implicit in burgessR3's definition." But `burgessR3` does NOT require consistency — it's a pure content condition. The comment is wrong.

**The real question**: Is `burgessR3(A, Set.univ, C)` actually false for all MCS A, C? It means ∀φ (any formula), ∀γ∈C, untl(φ, γ)∈A. Taking φ=⊥: untl(⊥, γ)∈A for all γ∈C. Under Burgess semantics, untl(⊥,γ) = U(γ,⊥) = {x : ∃y>x, y∈V(γ) ∧ ∀z(x<z<y → z∈V(⊥))}. On any linear order with NO intermediate points between some x and y (discrete orders), this can hold. So U(γ,⊥) is NOT provably ⊥ in J₀.

**Is NoUnivBurgessR3 provable from J₀?**: The comment at ChronicleTypes.lean:344 says "This condition is NOT derivable from J₀ axioms alone (since J₀ is also complete for discrete orders where untl(⊥, gamma) can hold vacuously)." This is CORRECT. NoUnivBurgessR3 is a semantic property specific to the dense-order construction, NOT a J₀ theorem.

**Approaches to resolve**:
1. **Accept as an axiom specific to the construction** — the completeness theorem says "consistent → satisfiable over K₀ (all linear orders)." The construction builds a model over Q (dense). NoUnivBurgessR3 is a property of the Q-based construction, not a general logical truth. It can be proved by exhibiting a specific formula and showing untl(⊥, γ) ∉ A for that γ, using properties of the construction.
2. **Prove semantically**: On the Q model being constructed, U(γ,⊥) is always ∅ (dense, so always intermediate points). By soundness of J₀ for Q, if U(γ,⊥) is always ∅ then ¬U(γ,⊥) is valid on Q, hence ¬untl(⊥,γ) is in every MCS... wait, this doesn't work because we need it for ALL MCS, not just those realized on Q.
3. **Restructure**: Instead of requiring NoUnivBurgessR3 globally, prove it case-by-case at each call site. Each call site has specific MCS with specific Until formulas; show that untl(⊥, γ) ∉ A for the specific A and C in context.

**Severity**: Important — the NoUnivBurgessR3 sorry is the last remaining sorry that isn't a pure Burgess lemma. Its resolution requires careful mathematical analysis.

**Confidence**: High (verified the definition and its non-derivability from J₀)

---

## Finding 6: lemma_2_7_seed_consistent Sorry — Burgess's Proof Strategy Is Clear

**What**: The sorry at PointInsertion.lean:2744 needs the consistency of `lemma_2_7_seed A B C xi eta`. Plan v60 Phase 4 outlines a 10-step BX5+BX7 chain, which is Burgess's proof of Lemma 2.7 (p.372).

**Why it matters**: This is the mathematically hardest sorry. The proof requires:
1. Extract witness (β₀, γ₀) from maximality with ¬untl(β₀∧xi, γ₀) ∈ A
2. BX5 self-accumulation on both Until formulas
3. BX7 three-way disjunction
4. Eliminate 2 of 3 disjuncts using the witness
5. Use surviving disjunct + BX3 (A3a) to get untl(xi, β∧eta) ∈ A
6. Show ζ is consistent via Lemma 2.2

**Potential blind spot**: The D2 elimination (step 6 in the plan) is non-trivial. The plan notes "beta0 AND untl(beta0, gamma0) -> gamma0 is NOT derivable" and proposes an alternative path via BX14 separation. This alternative hasn't been verified at the Lean level and could contain additional complications.

**Severity**: Important — this is the key mathematical content

**Confidence**: Medium (the mathematical argument is from Burgess, but Lean-level implementation may surface additional type-matching issues)

---

## Finding 7: CounterexampleElimination Sorries (lines 413, 511) — C2' Dependency

**What**: The C4/C4' hard case sorries need `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))` for adjacent pairs. The comments say "Phase 8: Restore this proof once c2' is re-established." These are the only 2 CounterexampleElimination sorries (not 7 as plan v60 claims).

**Why it matters**: The c2' property was removed from the omega_chain invariant at some point. These sorries cannot be closed until c2' (BurgessR3Maximal for adjacent pairs) is restored in the omega chain construction.

**The dependency chain**: lemma_2_6_splitting → omega_chain c2' → C4 hard cases → FUC/FSC → completeness

**Severity**: Important — blocking downstream work

**Confidence**: High (verified proof states show the needed hypothesis is absent)

---

## Finding 8: FUC/FSC Sorries — The Deepest Dependency

**What**: The 2 sorries at ChronicleToCountermodel.lean:621,625 need the full C5 truth lemma with guard at intermediate points. The proof state shows:
```
h_until : φ.untl ψ ∈ (rooted_cantor_fmcs N h_N h_no_univ s).mcs t
⊢ ∃ s₁, t < s₁ ∧ ψ ∈ mcs(s₁) ∧ ∀ r, t < r → r < s₁ → φ ∈ mcs(r)
```

This requires the full C5a property (not just "weak" C5 which gives the witness without the guard).

**Why it matters**: This is the ultimate goal — the truth lemma. It needs:
1. C5 weak: ∃y, ψ∈f(y) (already proved)
2. Guard propagation: φ∈g(x,y) → ∀z(x<z<y → φ∈f(z)) via C3
3. The connection between g-values and the Cantor isomorphism

**The g-value gap**: The current `limit_g` function may not actually carry the BurgessR3Maximal information needed. Check whether `limit_g` is defined by C3 (as Burgess prescribes) or by some placeholder.

**Severity**: Important — this is the final step

**Confidence**: Medium

---

## Finding 9: bot_until_bot_absurd and bot_since_bot_absurd Are Also Sorries

**What**: `bot_until_bot_absurd` (TemporalDerived.lean:183-186) and `bot_since_bot_absurd` (lines 191-193) are sorry stubs. They were proved using BX9 (until_elim) which was removed under open-guard semantics (task 113).

**Why it matters**: These ARE provable without BX9 under open-guard semantics, using BX10 instead:
- untl(⊥, ⊥) → F(⊥) (by BX10)
- F(⊥) = untl(⊥, ⊤) → F(⊤) (by BX10 again... wait, F(⊥) means ∃y>x, ⊥∈V(y) which is empty)
- Actually: F(⊥) = ∃y>x, y∈V(⊥) = ∅. So ¬F(⊥) is a thesis. Then untl(⊥,⊥) → F(⊥) → ⊥.

**Proof sketch**: ⊢ G(¬⊥) (by TG on ¬⊥ = ⊤.imp ⊥... hmm, ¬⊥ = ⊤). Actually ⊢ ⊤ (tautology). ⊢ G(⊤) (by TG). G(⊤) = ¬F(¬⊤) = ¬F(⊥). So F(⊥) ∉ any MCS. Then untl(⊥,⊥) → F(⊥) (by BX10 applied to event argument... wait).

BX10: untl(φ,ψ) → F(ψ). Our convention: φ=guard, ψ=event. So untl(⊥,⊥) → F(⊥). And ¬F(⊥) is a thesis (from ⊢ ⊤ → G⊤ → ¬F⊥). So untl(⊥,⊥) → ⊥. ✓

These sorries are NOT on the critical path for task 107 (verified: not used in Chronicle directory). But they should be closed as low-hanging fruit.

**Severity**: Minor (not on critical path)

**Confidence**: High

---

## Summary of Findings by Priority

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | Case B sorry (PI:1977) closable after ClosedUnderDerivation cascade | Critical | Restructure proof to extract maximality witness before c_list construction |
| 2 | Plan v60 significantly stale | Important | Revise plan before continuing implementation |
| 5 | NoUnivBurgessR3 not provable from J₀ | Important | Analyze whether it can be proved semantically or needs restructuring |
| 6 | lemma_2_7_seed_consistent needs careful D2 elimination | Important | Follow Burgess exactly; verify D2 path at Lean level |
| 7 | C4 hard cases blocked on c2' restoration | Important | Restore c2' in omega_chain first |
| 8 | FUC/FSC need full C5 with guard propagation | Important | Verify limit_g carries BurgessR3Maximal |
| 3 | Convention alignment correct | Minor | No action |
| 4 | ClosedUnderDerivation definition correct | Minor | Document for maintainers |
| 9 | bot_until_bot_absurd closable via BX10 | Minor | Close as low-hanging fruit |

---

## Recommended Resolution Order

1. **Close Case B sorry (Finding 1)** — likely the easiest remaining sorry, unblocked by the cascade
2. **Prove lemma_2_7_seed_consistent (Finding 6)** — the core Burgess argument
3. **Close lemma_2_7 inconsistent case (line 2875)** — may be closable after Finding 1 approach works
4. **Restore c2' in omega_chain (Finding 7)** — unblocks C4 hard cases
5. **Close C4/C4' hard cases** — now unblocked
6. **Close FUC/FSC (Finding 8)** — full truth lemma
7. **Resolve NoUnivBurgessR3 (Finding 5)** — can be done in parallel with 4-6
8. **Close bot_until_bot_absurd (Finding 9)** — low priority cleanup
