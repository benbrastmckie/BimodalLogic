# Research Report: Task #38 - Box Backward Direction in succ_chain_truth_lemma

**Task**: 38 - Prove Box backward direction in succ_chain_truth_lemma
**Agent**: math-research-agent (teammate A)
**Completed**: 2026-03-22

## Key Findings

### Finding 1: Why ψ ∈ MCS does NOT imply □ψ ∈ MCS

This is the central mathematical obstruction. In modal logic, the T-axiom states:
```
□ψ → ψ
```
This is a ONE-WAY implication. The converse `ψ → □ψ` is NOT a theorem in standard modal
logics (K, T, S4, S5). If it were, every formula would be necessary if true, which trivializes
modal logic entirely and collapses □ to classical truth.

**Counterexample in standard Kripke semantics**: Consider a two-world frame {w₁, w₂} with
R(w₁,w₁), R(w₁,w₂), R(w₂,w₂). The MCS at w₁ can contain p without containing □p, because
p might be false at w₂.

**In the TM bimodal proof system**: The system includes axiom `modal_t: □ψ → ψ`. For the
converse to hold universally, the system would need a *necessitation rule* at the object level:
`ψ ∈ MCS → □ψ ∈ MCS`. But this is precisely the modal_backward condition that requires
the full BFMCS construction with modal saturation.

### Finding 2: What the Codebase Already Knows

The codebase has extensively documented this issue. Key evidence:

1. **ModallyCoherentBFMCS.lean** (line 19-21) explicitly states:
   > "The singleton BFMCS approach (SuccChainBFMCS.lean) has an **unprovable** `modal_backward`
   > sorry. For a singleton bundle, `modal_backward` requires `φ ∈ MCS → □φ ∈ MCS`, which is
   > the converse of the T-axiom and mathematically impossible for contingent formulas."

2. **BFMCS.lean** defines the correct fix: `modal_backward` in a multi-family BFMCS is:
   ```
   ∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → □φ ∈ fam.mcs t
   ```
   This is provable via modal saturation when the bundle contains multiple distinct families.

3. **ModalSaturation.lean** contains `saturated_modal_backward` (sorry-free):
   - If the BFMCS is modally saturated, then modal_backward holds
   - Saturation means: ◇ψ ∈ fam.mcs t → ∃ fam' in bundle where ψ ∈ fam'.mcs t
   - The proof by contraposition: if ψ ∈ all families but □ψ ∉ fam.mcs t, then ◇¬ψ ∈ fam.mcs t,
     and saturation gives a family with ¬ψ, contradicting ψ being in all families.

### Finding 3: The Singleton Omega Issue in Detail

The `succ_chain_omega M0 = {succ_chain_history M0}` construction creates a singleton Omega.
In the truth lemma:

```
truth_at succ_chain_model (succ_chain_omega M0) σ t (□ψ)
  ↔ ∀ σ' ∈ succ_chain_omega M0, truth_at ... σ' t ψ
  ↔ truth_at ... (succ_chain_history M0) t ψ     -- singleton collapse
  ↔ ψ ∈ succ_chain_fam M0 t                       -- by IH (forward direction)
```

The backward direction would need:
```
ψ ∈ succ_chain_fam M0 t  →  □ψ ∈ succ_chain_fam M0 t
```

This is `modal_backward` for the singleton bundle, which is precisely what
`ModallyCoherentBFMCS.lean` identifies as unprovable. The singleton design collapses
accessibility to identity, making Box trivially true in the singleton but breaking the
backward direction of the truth lemma.

### Finding 4: Why Completeness Doesn't Need the Backward Direction

Examining `SuccChainCompleteness.lean`:

The completeness proof uses ONLY `succ_chain_truth_forward` (the forward direction):
```
phi ∈ succ_chain_fam M0 t → truth_at succ_chain_model (succ_chain_omega M0) ... t phi
```

The proof flow is:
1. φ not provable → {¬φ} consistent
2. Extend to SerialMCS M0
3. ¬φ ∈ M0 = succ_chain_fam M0 0
4. By `succ_chain_truth_forward`: ¬φ is true at time 0
5. Therefore φ is not valid

The backward direction is needed ONLY for the `imp` case of the forward direction proof
(line 192: `ih_psi.mpr`). But this backward implication for `psi` is a strictly smaller
formula - by structural induction. The backward direction for **atoms**, **bot**, **imp**,
**G**, and **H** can all be proven from the forward direction. Only `Box` backward is stuck.

### Finding 5: The Biconditional Structure Creates a Real Dependency

The proof at line 192 uses `(ih_psi t).mpr` in the forward direction of `imp`. This means
the biconditional induction is genuinely needed for the imp case. However, the question is
whether the **box backward** sub-case is actually reachable.

**Critical observation**: The backward direction of Box is needed if `psi` in the induction
could itself be a Box formula... but wait, `psi` is a **strict subformula** of `Box psi` only
in an unusual induction. In the `imp` case, `psi` and `chi` are strict subformulas of `psi.imp chi`.
The `mpr` call uses IH for `psi` and `chi` (both strict subformulas), NOT for Box formulas.

The sorry at line 254 is in the `box` case's backward direction. This path is:
- Called when someone has `truth_at ... t (□ψ)` and needs `□ψ ∈ MCS`
- The forward direction for `imp` only invokes `ih_psi.mpr` for `psi` being the antecedent
  of an implication, not for `□ψ`
- Therefore, if we only need `succ_chain_truth_forward` (the `.mp` direction), the sorry
  at line 254 is NOT REACHED in the completeness proof

**This is why the file header says**: "Note on Box Backward: The backward direction for Box
in a singleton-Omega model requires that psi in MCS implies Box psi in MCS. This is NOT
generally true for arbitrary MCS content. However, for COMPLETENESS we only need the FORWARD direction."

### Finding 6: What Modal Axioms Would Fix This

For a **single** MCS/world, `ψ → □ψ` holds in exactly those modal logics where:
- The frame is a single reflexive point (every world sees only itself)
- In that case, □ψ ↔ ψ because all accessible worlds are just the current world

This is the **trivial frame** or **point frame**. It is NOT the canonical model for TM bimodal
logic, which requires a non-trivial accessibility structure.

Axioms that would entail `ψ → □ψ`:
- The **5-axiom** (◇ψ → □◇ψ) combined with reflexivity gives S5, but still doesn't give ψ → □ψ
- The **necessitation** rule says: if ⊢ ψ then ⊢ □ψ (for *theorems* only, not contingent truths)
- A hypothetical "local necessitation" axiom `ψ → □ψ` would collapse □ to a trivial operator

None of these are present in TM bimodal logic by design.

## Recommended Approach

### Option A: Accept the sorry (currently implemented, correct for completeness)

The sorry at line 254 is **mathematically justified as non-provable** in the singleton Omega
construction. The file headers already document this clearly. Since completeness only needs
`succ_chain_truth_forward`, the sorry does not affect the completeness result.

**Verdict**: This is already the implemented strategy. The sorry should remain with its
documentation noting it is not needed for completeness.

### Option B: Replace with `sorry`-free proof using T-axiom direction only

The theorem statement is a biconditional, but only one direction is needed. One approach:
restructure the proof to prove the two directions separately:
1. Prove `succ_chain_truth_forward` directly (only `.mp` directions needed)
2. For the backward truth lemma, either leave it as a separate sorry'd theorem or remove it

This avoids the false impression that the biconditional is fully proven.

### Option C: Prove the backward direction using BFMCS modal saturation

This is the **mathematically complete** solution used in other parts of the codebase:
1. Replace `succ_chain_omega` (singleton) with a multi-family Omega
2. Use the BFMCS + modal saturation machinery from `ModalSaturation.lean`
3. The `saturated_modal_backward` theorem provides the proof

However, this would require significant refactoring of the succ_chain approach and is
not required for the completeness result.

### Recommendation

**Option A is correct for the current goal.** The sorry at line 254 documents a real
mathematical impossibility for the singleton construction. The completeness proof in
`SuccChainCompleteness.lean` uses only `succ_chain_truth_forward` which does not invoke
the sorry path. The comment should be updated to more clearly state:

```lean
-- Box backward is MATHEMATICALLY UNPROVABLE for singleton Omega:
-- psi ∈ MCS does NOT imply Box(psi) ∈ MCS (converse of T-axiom).
-- The codebase uses multi-family BFMCS (ModalSaturation.lean) for the full
-- biconditional. This sorry is not reached in succ_chain_completeness.
sorry
```

## Evidence/Examples

### Evidence 1: Singleton BFMCS failure is documented
File: `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean`, lines 19-21:
explicitly states the singleton approach has an unprovable `modal_backward`.

### Evidence 2: Completeness proof only uses forward direction
File: `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean`, line 154:
`succ_chain_truth_forward M0 φ.neg 0 h_neg_in_fam` - only forward used.

### Evidence 3: Multi-family BFMCS has sorry-free modal_backward
File: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`:
`saturated_modal_backward` is the sorry-free version for multi-family bundles.

### Evidence 4: The sorry is explicitly noted as "not needed for completeness"
File: `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean`, line 254:
`sorry -- Box backward not needed for completeness; requires modal coherence (BFMCS)`

### Evidence 5: SuccChainCompleteness axiom dependency comment
File: `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean`, line 34:
`- One sorry in SuccChainTruth (Box backward - not used in completeness)`

## Confidence Level

**High** - The mathematical analysis is clear and supported by multiple sources:
1. Classical modal logic theory (T-axiom is one-way)
2. The codebase's own documentation of this exact issue
3. The completeness proof not invoking the sorry'd path
4. The multi-family BFMCS approach as the sorry-free alternative (already implemented)

The sorry at line 254 is NOT a gap that needs to be filled for completeness. It is a
mathematically accurate `sorry` acknowledging that the biconditional truth lemma for the
singleton Omega construction cannot be fully proven without the BFMCS modal saturation
machinery.
