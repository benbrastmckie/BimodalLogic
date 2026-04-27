# Research Report: Task #107

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1777310875_e31997

## Summary

Four teammates unanimously identified the root cause of all 9 remaining sorry sites: the elimination functions do not construct g-values per Burgess's paper. Every elimination function passes `g = χ.g` unchanged, leaving new adjacent pairs with undefined g-values. The density elimination compounds this by setting `f(z) = f(x)` (creating an unsatisfiable "self-pair"), whereas Burgess uses Lemma 2.6 to construct a fresh MCS D. The missing piece is a proper formalization of Burgess Lemma 2.6 for the content-based `BurgessR3Maximal` relation — the existing `lemma_2_6_full` (which uses the obligation-based `R3Maximal`) trivially returns D = B and is useless for splitting. Cross-referencing with task 113's literature review (Xu 1988) confirms: these are engineering tasks following Burgess/Xu directly, with no alternative approach in the literature.

## Key Findings

### 1. Root Cause: Elimination Functions Don't Construct g-Values (4/4 unanimous)

Every elimination function (`eliminate_C5_counterexample`, `eliminate_C4_counterexample`, `eliminate_g_prop_counterexample`, `eliminate_h_prop_counterexample`) returns the input chronicle's g-function unchanged:

- C5: `refine ⟨⟨fun q => if q = y then C else χ.f q, χ.g, insert y χ.dom⟩, ...⟩`
- C4: `refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩, ...⟩`
- Return types include `∀ a b, χ'.g a b = χ.g a b` (proved by `rfl`)

When a new point z is inserted between x and y, the pairs (x,z) and (z,y) inherit `χ.g x z` and `χ.g z y` — arbitrary garbage since z was never in the domain. The singleton chronicle starts with `g = fun _ _ => ∅`, so after C5 inserts point y beyond x, `g(x,y) = ∅`. Since ∅ is not deductively closed, `c2'` (which requires `SetDeductivelyClosed (g x y)`) must fail.

**In Burgess's construction**: Lemma 2.10 (C5, case n=0) applies Lemma 2.4 to get B, C with R(f(x), B, C), then sets `g'(x,y) = B`. Lemma 2.9 (C4, case n=0) applies Lemma 2.6 to get B', D, B'' with R(f(x), B', D), R(D, B'', f(y)), then sets `g'(x,z) = B'`, `g'(z,y) = B''`. Both say "let C3 determine the other values of g'."

### 2. Density Elimination Is Architecturally Wrong (4/4 unanimous)

The density elimination (CounterexampleElimination.lean line 1002) sets:
```lean
val := ⟨fun q => if q = z then χ.f pc.x else χ.f q, g', insert z χ.dom⟩
```

This sets `f(z) = f(x)`, creating the "self-pair" blocker at line 1086: `burgessR3(f(x), g(x,y), f(x))` is needed but only `burgessR3(f(x), g(x,y), f(y))` is available. Teammate B proved this is genuinely unsatisfiable: if G(p) ∈ A, then burgessR3(A, B, A) requires F(¬p) ∈ A, contradicting G(p) ∈ A.

**Burgess never sets f(z) = f(x)**. In Lemma 2.9 (case n=0), he applies Lemma 2.6 to R(f(x), g(x,y), f(y)) with δ ∉ g(x,y), producing a FRESH MCS D. Setting f'(z) = D eliminates the self-pair problem entirely — both R(f(x), B', D) and R(D, B'', f(y)) come from the lemma construction.

### 3. Missing Lemma 2.6 for Content-Based Relation Is THE Blocker (4/4 unanimous)

The codebase has two versions of "Lemma 2.6":

1. **`lemma_2_6`** (PointInsertion.lean:343): Takes `g_content(A) ⊆ C` and `δ ∉ C`, produces D with `¬δ ∈ D` and `g_content(A) ⊆ D`. This is a weak version — it gives a new MCS but NOT the B', B'' splitting needed for c2'.

2. **`lemma_2_6_full`** (PointInsertion.lean:838): Takes `R3Maximal(A, B, C)` (obligation-based maximality), but trivially returns D = B because `R3Maximal` forces B to be MCS. Completely useless for splitting.

**What's needed**: Burgess Lemma 2.6 for `BurgessR3Maximal(A, B, C)` (content-based maximality):
```
Given BurgessR3Maximal(A, B, C) and δ ∉ B, produce:
- MCS D with ¬δ ∈ D
- DCS B' with BurgessR3Maximal(A, B', D)
- DCS B'' with BurgessR3Maximal(D, B'', C)
- B = B' ∩ D ∩ B''
```

The proof requires showing D₀ = {S(α,β) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ∈C, β∈B} is consistent. Burgess's proof uses A5a, A4a, A3a. Under strict semantics:
- A3a and A4a are NOT valid (documented in PointInsertion.lean:16 and TemporalDerived.lean:517)
- BX5+BX6+BX7 subsume A4a's role (documented in PointInsertion.lean:21-22)
- BX4+BX5 subsume A3a's role (documented in PointInsertion.lean:19-20)
- The existing `lemma_2_4` uses similar BX-axiom techniques and works sorry-free

**Risk assessment**: MEDIUM. The BX axiom adaptation path is documented and `lemma_2_4` (which uses analogous techniques) is already formalized. However, the consistency argument in Lemma 2.6 is more complex than in 2.4 (it requires chaining BX5→BX7→BX5→A3a-equivalent). Estimated effort: 20-40 hours for the lemma alone.

### 4. "burgessR3_absorption" Is a Misnomer (4/4 unanimous)

Plan v20 references "burgessR3_absorption" for splitting g-values. This conflates two different lemmas:

- **Lemma 2.5** (existing as `burgessR3_absorption`): Goes parts→whole. Given burgessR3(A, B₁, D) and burgessR3(D, B₂, C) and B₁₂ ⊆ B₁∩D∩B₂, concludes burgessR3(A, B₁₂, C). This is a COMPOSITION result.

- **Lemma 2.6**: Goes whole→parts. Given BurgessR3Maximal(A, B, C) and δ∉B, CONSTRUCTS D, B', B'' with the splitting. This is a CONSTRUCTION result.

The plan's Phase 3 assumed we could "split g via burgessR3_absorption" — but absorption goes the wrong direction. The actual splitting requires Lemma 2.6.

### 5. g_prop/h_prop Eliminations Are Workarounds, Not Burgess (3/4 — A, C, D)

Burgess only eliminates C4a, C4b, C5a, C5b counterexamples. The codebase adds `g_prop_forward/backward` and `density` as separate elimination kinds. Teammate D proved g_prop is subsumed by C4:

- G(α) = ¬(⊤ U ¬α). If G(α) ∈ f(x) and α ∉ f(y) with x < y, then (⊤ U ¬α).neg ∈ f(x) and ¬α ∈ f(y) — this is a C4 counterexample.

**g_prop/h_prop exist because g-values are empty**. With proper g-values, G-propagation follows from C3: G(α) ∈ f(x) puts α in g_content(f(x)), and with burgessR3(f(x), g(x,y), f(y)), α propagates to g(x,y) and thence to intermediate f(z) via C3. **Once g-values are properly constructed, g_prop/h_prop can be removed.**

Density elimination IS genuinely needed (to ensure the limit domain is dense), but should use Lemma 2.6 rather than f(z) = f(x).

### 6. Intersection-Based limit_g Is Correct (3/4 — B, C, D; A revised)

Report 33 claimed the intersection-based limit_g is "tautological for FUC." **This is wrong.** The definition:
```
limit_g(x,z) = {φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f(y)}
```
is mathematically the correct limit g-function for a dense domain. C3 is satisfied definitionally. The FUC argument works once finite-stage g-values are non-empty:

1. U(φ,ψ) ∈ f(t) → by C5 at stage n, ∃s with ψ ∈ f_n(s) and η ∈ g_n(t,s)
2. By C3 at stage n: g_n(t,s) ⊆ f_n(r) for any r between t and s in dom_n
3. By f-immutability (already proved): η ∈ limit_f(r) for those r
4. For NEW points r added after stage n: by g-immutability, g_m(t,s) = g_n(t,s) for m ≥ n. By C3 at stage m, g_m(t,s) ⊆ f_m(r).
5. Therefore η ∈ limit_f(r) for ALL r between t and s → η ∈ limit_g(t,s) by definition

The intersection and stage-based definitions coincide for the dense limit (Teammate B proved this). **No change to limit_g is needed.** The real blocker was empty finite-stage g-values.

### 7. The Existing `lemma_2_4` Output Needs Enrichment for C5 (from task 113 + A)

The existing `lemma_2_4` (PointInsertion.lean) returns:
- MCS C with ξ ∈ C and g_content(A) ⊆ C

But for C5 elimination, Burgess gets R(f(x), B, C) — i.e., a BurgessR3Maximal B. The current code discards this: it uses `lemma_2_4` to get C but never constructs B. Task 113 (Xu 1988 analysis) confirms: "the code already finds D via set_lindenbaum but discards the B' and B'' that Xu's Lemma 2.4 produces simultaneously."

The fix: after `lemma_2_4` gives C with g_content(A) ⊆ C, apply `burgessR3Maximal_exists_from_seed` to construct B with BurgessR3Maximal(A, B, C). The seed comes from the r-relation that g_content(A) ⊆ C establishes. This is already available infrastructure.

## Synthesis

### Conflicts Resolved

**Conflict 1 — limit_g definition**: Teammate A initially favored stage-based limit_g but revised after analysis. Teammates B, C, D all recommend keeping intersection-based. **Resolution**: Keep intersection-based limit_g (no code change needed). The FUC proof works via finite-stage C3 + f-immutability + intersection definition, once g-values are non-empty.

**Conflict 2 — Effort estimate**: A estimates 20-30h, D estimates 78-102h (40-60h for Lemma 2.6 alone), C says plan's 700-800 lines is 2-3x too low. **Resolution**: The realistic estimate depends on the BX axiom adaptation of Lemma 2.6's consistency argument. Given that `lemma_2_4` (which uses analogous BX techniques) is already formalized, the Lemma 2.6 adaptation is probably 20-40h, not 40-60h. Total estimate: **40-60h** for all 9 sorries.

**Conflict 3 — Report 33 "tautological" claim**: Teammates B, C, D agree report 33 was wrong about intersection limit_g being tautological. A revised to agree. **Resolution**: Unanimous — intersection limit_g is correct; the problem is empty g-values, not the definition.

### Gaps Identified

1. **Lemma 2.6 for BurgessR3Maximal is completely missing** — this is a substantial formalization (~300-600 lines). The consistency proof needs adaptation from A3a/A4a to BX axioms.

2. **Individual elimination functions need new return types** — changing from `∀ a b, χ'.g a b = χ.g a b` to carrying new g-values + c2' proofs for new pairs.

3. **g-immutability must be proved** — after elimination functions construct proper g-values, need to show old-pair g-values persist across stages. This should follow from the construction (old pairs get `χ.g` preserved).

4. **C5 n>0 case may need Lemma 2.7/2.8** — when there are domain points after x, C5 elimination may need to insert between x and x' (not just append). This requires Lemma 2.7/2.8, which are currently withdrawn. The adaptation to BX axioms needs study.

5. **No alternative approach exists** (confirmed by task 113 literature review) — this is genuinely novel territory for S5+U/S+strict semantics.

### Recommendations

#### Phase 1: Formalize Burgess Lemma 2.6 for BurgessR3Maximal (~20-40h)

The single most important piece of missing infrastructure. Prove:
```
theorem burgess_lemma_2_6_content (A B C : Set Formula)
    (h_A : SetMaximalConsistent A) (h_C : SetMaximalConsistent C)
    (h_R : BurgessR3Maximal A B C) (δ : Formula) (h_notin : δ ∉ B) :
    ∃ D B' B'', SetMaximalConsistent D ∧ δ.neg ∈ D ∧
      BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
      B = B' ∩ D ∩ B''
```

Use BX5+BX6+BX7 (documented as subsuming A4a) and BX4+BX5 (subsuming A3a). Follow `lemma_2_4`'s pattern for BX axiom adaptation.

#### Phase 2: Modify Elimination Functions to Construct g-Values (~10-15h)

For each elimination type:
- **C5/C5'**: After `lemma_2_4` gives C, construct B via `burgessR3Maximal_exists_from_seed`. Set g'(x,y) = B. c2' immediate.
- **C4/C4'**: Apply new Lemma 2.6 to the adjacent pair's BurgessR3Maximal. Set g'(x,z) = B', g'(z,y) = B'', f'(z) = D. c2' immediate.
- **Density**: Same as C4 — apply Lemma 2.6 with any δ ∉ g(x,y). Fix f(z) from f(x) to D.
- **g_prop/h_prop**: Either use Lemma 2.6 (same pattern) or remove entirely (subsumed by C4).

Change return types from `g = χ.g` to carrying new g-values. Preserve g for old pairs.

#### Phase 3: Close 7 c2' Sorry Sites (~5h)

Once elimination functions construct proper g-values, c2' for new adjacent pairs comes from the BurgessR3Maximal output of Lemma 2.4/2.6. Each sorry site becomes a direct application of the construction.

#### Phase 4: Prove g-Immutability and Close 2 FUC Sorry Sites (~10-15h)

- Prove g-immutability: for old pairs (a,b), g at stage n+1 = g at stage n. Follows from elimination functions preserving g for old pairs.
- Close FUC (lines 615, 619): Given U(φ,ψ) ∈ limit_f(t), C5 gives s with guard η ∈ g_n(t,s). By g-immutability + C3, η ∈ limit_f(r) for all intermediate r. Transfer through Cantor isomorphism.

#### Phase 5: Cleanup (~5h)

- Consider removing g_prop/h_prop elimination kinds (subsumed by C4)
- Remove dead `lemma_2_6_full` (trivial D=B version)
- Update Completeness.lean sorry audit comments
- Final `lake build` and `#print axioms` verification

### What NOT to Do

- Do NOT patch `burgessR3Maximal_exists_general` — it is FALSE
- Do NOT use "burgessR3_absorption" for splitting — it goes the wrong direction
- Do NOT change limit_g to stage-based — intersection is correct
- Do NOT set f(z) = f(x) in any elimination — always construct fresh MCS via lemma
- Do NOT keep g_prop/h_prop long-term — they mask the real construction

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary audit | completed | high | Exhaustive sorry audit, limit_g analysis (revised), closure dependency chain |
| B | Literature | completed | high | Confirmed f(z)=f(x) is wrong per Burgess, "absorption" misnomer, limit_g coincidence |
| C | Critic | completed | high | g_prop as workaround, C2' only needed for C4, Lemma 2.6 adaptation risk |
| D | Horizons | completed | high | Two maximality concepts, lemma_2_6_full useless (D=B), minimal-change path |

## References

- Burgess 1982: "Axioms for tense logic I: Since and Until", Lemmas 2.4-2.10, Claim 2.11
- Xu 1988: "On some U,S-tense logics", Lemma 2.4 (confirms c2' sorries are engineering tasks)
- Task 113 literature review: No alternative approach exists for S5+U/S+strict chronicle
- PointInsertion.lean header: BX axiom substitutions for A3a/A4a documented
- TemporalDerived.lean:517: A3a/A4a invalidity proof + BX substitution table
