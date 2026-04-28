# Teammate B Findings: Xu 3.2.1 Proof Mechanics & Maximality Analysis

## Key Findings

### 1. Xu's 3.2.1 Requires Forward-Only Maximality; Our BurgessR3Maximal Is Bidirectional

**Xu's definitions (Xu 1988, §2)**:
- `r(A, β, C)` := ∀γ∈C, U(γ,β) ∈ A — **forward (Until) direction only**
- `R(A, B, C)` := B is maximal DCS with r(A, B, C) — **forward-only maximality**
- Xu's 2.0(iii): R(A,B,C) ∧ δ∉B → ∃β'∈B such that r(A, β'∧δ, C) fails, i.e., ∃γ'∈C with U(γ', β'∧δ) ∉ A

**Our definition (ChronicleTypes.lean:315)**:
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```
where `burgessR3 = burgessRSet ∧ burgessRSetSince` — **bidirectional maximality**.

**The gap**: From bidirectional maximality, when δ∉B, we get `¬burgessR3(A, DC(B∪{δ}), C)`. But `burgessR3 = burgessRSet ∧ burgessRSetSince`, so the failure is in EITHER direction. Xu's proof requires the failure to be specifically in the forward (burgessRSet) direction.

### 2. Forward Direction Holds for Extensions — Proved Sorry-Free

The helper `burgessR3_untl_conj_in_A` (RRelation.lean:1283-1365) is sorry-free and proves:
```
burgessR3(A, B, C), β∈B, γ∈C, β'∈B, δ∈C ⊢ untl(β'∧untl(β,γ), δ) ∈ A
```

Combined with BX2 (left_mono_until, guard weakening: if φ→χ then untl(φ,ψ)→untl(χ,ψ)), this gives: for ANY ψ ∈ DC(B∪{untl(β,γ)}) and δ∈C, `untl(ψ, δ) ∈ A`.

**Therefore `burgessRSet(A, DC(B∪{untl(β,γ)}), C)` holds unconditionally.**

### 3. Bidirectional Maximality Forces Backward-Direction Failure

Since burgessRSet holds for the extension but burgessR3 fails (by maximality), it MUST be that `burgessRSetSince(C, DC(B∪{untl(β,γ)}), A)` fails. This means:

∃ψ ∈ DC(B∪{untl(β,γ)}), ∃α∈A: `snce(ψ, α) �� C`

where ψ involves the Until formula `untl(β,γ)`. We have `snce(β₀, α) ∈ C` for all β₀∈B and α∈A (from burgessRSetSince(C,B,A)), but NOT for ψ containing `untl(β,γ)`. To derive `snce(ψ, α) ∈ C` would require enriching a Since guard with an Until sub-formula — exactly what Burgess's A3a axiom does, and which is absent from our system.

### 4. Xu's Proof Works Because His R Is Forward-Only

In Xu's proof of 3.2.1(i):
1. Assume U(γ,β) ∉ B for β∈B, γ∈C
2. By 2.0(iii) [forward maximality]: ∃β'∈B, γ'∈C with ¬U(γ', β'∧U(γ,β)) ∈ A
3. By BX5 + BX2 + BX3: U(γ'', β''∧U(γ'',β'')) → U(γ', β'∧U(γ,β)) is a theorem
4. By BX5: U(γ'',β'') → U(��'', β''∧U(γ'',β'')) 
5. So U(γ'',β'') → U(γ', β'∧U(γ,β)) is a theorem
6. ¬U(γ', β'∧U(γ,β)) ∈ A forces ¬U(γ'',β'') ∈ A
7. But U(γ'',β'') ∈ A from r(A,B,C). Contradiction. ✓

Step 2 extracts a **forward-specific failure witness**. Our maximality does not provide this.

### 5. The Since Mirror (3.2.1(ii)) Requires Backward-Only Maximality

Xu's 3.2.1(ii): R(A,B,C) → S(α,β) ∈ B for β∈B, α∈A.

The proof is the exact mirror using:
- Backward maximality: δ∉B → ∃β'∈B with ¬S(α', β'∧δ) ∈ C for some α'∈A
- BX5' (self_accum_since) + BX2' + BX3'

So 3.2.1(i) needs forward maximality and 3.2.1(ii) needs backward maximality.

### 6. `burgessR3Maximal_exists_from_seed` Requires Both Directions

The current seed constructor (RRelation.lean:1131) requires:
- `h_burgessR : burgessR A η C` (forward)
- `h_burgessRSince : burgessRSince C η A` (backward)

And it produces `BurgessR3Maximal A B C` (bidirectional). This is the output of a Zorn's lemma argument over `{B | S⊆B ∧ DCS(B) ∧ burgessR3(A,B,C)}`.

To produce forward-only maximal sets, we would Zorn over `{B | S⊆B ∧ DCS(B) ∧ burgessRSet(A,B,C)}` instead — this only needs `h_burgessR`, not `h_burgessRSince`.

## Recommended Approach

### Option (a): Forward-Only Maximality — **RECOMMENDED**

Define a new type matching Xu's R exactly:

```lean
def BurgessRSetMaximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessRSet A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessRSet A D C
```

And its backward mirror:
```lean
def BurgessRSetSinceMaximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessRSetSince A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessRSetSince A D C
```

**Existence**: Zorn over DCS extensions preserving burgessRSet (resp. burgessRSetSince). The chain union argument is identical to the existing one — just drop the other direction.

**3.2.1 proof**: Xu's argument goes through verbatim:
- (i) uses BurgessRSetMaximal + BX5 → untl(β,γ) ∈ B
- (ii) uses BurgessRSetSinceMaximal + BX5' → snce(β,α) ∈ B

**Key question**: Does the C2' condition need both directions? 

### Cascade Analysis for Option (a)

**ChronicleTypes.lean c2'**: Currently requires `BurgessR3Maximal`. Must change to require BOTH `BurgessRSetMaximal(f(x), g(x,y), f(y))` AND `BurgessRSetSinceMaximal(f(y), g(x,y), f(x))`. This is logically WEAKER than BurgessR3Maximal (bidirectional maximality in a single set is STRONGER than separate maximalizations).

Wait — this is problematic. Forward-maximal B and backward-maximal B could be DIFFERENT sets. BurgessR3Maximal gives ONE set maximal for both. With separate maximalizations, we'd need two different sets, but c2' assigns ONE g(x,y) per pair.

**Resolution**: We need to show that a single set B can be both forward-maximal and backward-maximal. This would require Burgess Lemma 2.3 (forward ↔ backward), which we don't have.

**Alternative**: Use the EXISTING BurgessR3Maximal but extract a 2.0(iii)-equivalent that works.

### Option (d): Direct Maximality Extraction — **MOST PROMISING**

The bidirectional maximality gives us: if δ∉B, then DC(B∪{δ}) does not satisfy burgessR3. But we proved burgessRSet holds. So burgessRSetSince FAILS.

Instead of Xu's direct contradiction (which needs forward failure), use this structure:

1. Assume untl(β,γ) ∉ B.
2. burgessRSet(A, DC(B∪{untl(β,γ)}), C) holds (sorry-free).
3. burgessRSetSince(C, DC(B∪{untl(β,γ)}), A) fails (by maximality + step 2).
4. So ∃ψ ∈ DC(B∪{untl(β,γ)}), ∃α∈A: snce(ψ,α) ∉ C, i.e., ¬snce(ψ,α) ∈ C.
5. ψ is a consequence of β₀ ∧ untl(β,γ) for some β₀∈B.

Now we need a contradiction. We have ¬snce(ψ,α) ∈ C where β₀∧untl(β,γ)→ψ. From burgessRSetSince(C,B,A): snce(β₀,α) ∈ C. We need snce(ψ,α) ∈ C.

By BX2' (left_mono_since): if φ→χ (as a theorem), then snce(φ,ψ)→snce(χ,ψ). So snce(β₀,α) → snce(ψ',α) when β₀→ψ'. But ψ is a consequence of β₀∧untl(β,γ), not of β₀ alone. So β₀ alone doesn't imply ψ.

**We need**: snce(β₀∧untl(β,γ), α) ∈ C. This requires showing that for β₀∈B and α∈A, snce(β₀∧untl(β,γ), α) ∈ C. This is exactly a Since-mirror of `burgessR3_untl_conj_in_A`, but with mixed Until/Since — it requires:
- From burgessRSetSince(C,B,A): snce(β₀,α) ∈ C for β₀∈B, α∈A
- BX5' (self_accum_since): enrich the guard with Since formulas
- But we need to enrich the guard with untl(β,γ), an **Until** formula

**BX5' gives**: snce(β₀, α) → snce(β₀ ∧ snce(β₀,α), α). The enrichment is a **Since** formula, not an Until formula. We cannot get untl(β,γ) into the Since guard using BX5' alone.

**This is the A3a wall.** A3a allows enriching Until guards with Since information (and by mirror, Since guards with Until information). Without it, we cannot mix Until and Since in guard enrichment.

### Summary of Options

| Option | Viability | Why |
|--------|-----------|-----|
| (a) Forward-only maximality | Blocked | Need single B maximal for both; requires Lemma 2.3 |
| (b) Separate forward/backward maximality | Problematic | c2' needs ONE g(x,y), not two |
| (c) Bidirectional implies forward maximality | False | Forward-maximal set can be strictly larger |
| (d) Direct extraction from bidirectional | Blocked | Backward failure needs A3a to derive contradiction |
| (e) Add A3a as axiom | **Viable if sound** | Need to verify A3a is valid under our guard semantics |

## Evidence

### Line References

- BurgessR3Maximal definition: `ChronicleTypes.lean:315-318`
- burgessR3 = burgessRSet ∧ burgessRSetSince: `ChronicleTypes.lean:305-306`
- c2' uses BurgessR3Maximal: `ChronicleTypes.lean:367-369`
- `burgessR3_untl_conj_in_A` (sorry-free): `RRelation.lean:1283-1365`
- `burgessR3Maximal_exists_from_seed`: `RRelation.lean:1131-1154`
- `burgessR3Maximal_extension_exists` (Zorn): `RRelation.lean:724-763`
- Xu's 3.2.1 proof: `Xu_1988_On_some_US_tense_logics.md:221-230`
- Xu's r-relation (forward only): `Xu_1988_On_some_US_tense_logics.md:77`

### The Core Mathematical Obstacle

All paths to proving 3.2.1 under bidirectional maximality require the ability to derive `snce(ψ, α) ∈ C` where ψ contains an Until sub-formula `untl(β,γ)`. This requires an axiom connecting Until and Since guard enrichment — precisely Burgess's A3a (= Xu's axiom (3)). Our BX4 (connect_future: φ→G(P(φ))) is strictly weaker: it gives P(φ) = snce(⊤, φ) with trivial guard ⊤, not the required guard β.

## Confidence Level

**HIGH** that the analysis is correct: the bidirectional maximality / forward-only maximality distinction is mathematically sharp and explains exactly why the sorry exists.

**MEDIUM** on the best fix: Option (e) (adding A3a) requires verifying soundness under our specific guard semantics (half-open [t,s) vs open (t,s)). This is a critical question that determines the entire approach. If A3a is sound, it should be added and all blockers dissolve. If not, a deeper architectural change is needed.
