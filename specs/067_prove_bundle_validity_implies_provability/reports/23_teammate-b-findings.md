# Teammate B Findings: Mathematical Completeness Approaches

## Summary

The fundamental gap in the completeness proof is the **family-level temporal coherence** requirement for the truth lemma. Currently, bundle-level temporal coherence (`boxClassFamilies_bundle_forward_F`) is proven sorry-free, but family-level coherence (`BFMCS.temporally_coherent`) requires proving that F(phi) in `fam.mcs(t)` implies there exists `s > t` with `phi` in `fam.mcs(s)` **within the same family** - not just somewhere in the bundle. This is needed because the backward truth lemma direction for G uses contraposition, which invokes `forward_F` on the family being evaluated, and a witness in a different family would be evaluated along a different history.

The problem is that the current SuccChain construction does not guarantee F-formula resolution within the same chain. The Lindenbaum extension process can "lose" F-formulas during dovetailing when formula enumeration causes some obligations to be indefinitely deferred. The mathematically false `f_nesting_is_bounded` theorem (now removed) previously papered over this gap.

## Key Findings

### Segerberg Bulldozing Analysis

The term "bulldozing" in modal/temporal logic refers to Segerberg's technique for handling tree-like models in dynamic logic completeness proofs. The technique involves systematically "flattening" branching structures while preserving logical properties.

**What it does:**
1. Start with a potentially branching canonical model
2. Use selective Henkin/Lindenbaum constructions with explicit tracking of diamond/eventuality obligations
3. Systematically resolve each obligation by "bulldozing through" - ensuring every existential requirement gets a witness

**Key insight:** The bulldozing approach is essentially about **fair scheduling** of witnesses. Rather than following a deterministic path (like the current SuccChain), it maintains a queue of pending obligations and processes them fairly.

**For our context:** The current construction uses `successor_from_deferral_seed` which deterministically picks the next MCS. This can cause starvation: F(phi) might be perpetually deferred if the enumeration keeps introducing "higher priority" formulas.

### Bundle vs Family Coherence

**Bundle-level coherence** (proven in `boxClassFamilies_bundle_forward_F`):
- `F(phi) in fam.mcs(t)` implies `exists fam' in bundle, exists s > t, phi in fam'.mcs(s)`
- The witness can be in ANY family
- This is sufficient for **modal** completeness (S5 semantics)
- PROVEN sorry-free via `temporal_theory_witness_exists`

**Family-level coherence** (required by `BFMCS.temporally_coherent`):
- `F(phi) in fam.mcs(t)` implies `exists s > t, phi in fam.mcs(s)`
- The witness must be in the SAME family
- This is required for **temporal** completeness (truth lemma backward G case)
- NOT proven - the SuccChain construction does not guarantee this

**Why family-level is needed:**

The truth lemma proves: `phi in fam.mcs(t) <-> truth_at model omega (to_history fam) t phi`

For the G backward direction (`forall s >= t, truth(psi) at s -> G(psi) in mcs t`), the proof proceeds by contraposition:
1. Assume `G(psi)` not in `fam.mcs(t)`
2. Then `neg(G(psi)) = F(neg psi)` is in `fam.mcs(t)`
3. **By family-level forward_F**: exists `s > t` with `neg(psi)` in `fam.mcs(s)`
4. By hypothesis: `truth(psi)` at `s`, so by IH, `psi` in `fam.mcs(s)`
5. Contradiction: `psi` and `neg(psi)` in same consistent MCS

Step 3 is the critical use. If we only have bundle-level coherence, the witness `neg(psi)` would be in some other family `fam'`, but the semantic hypothesis (step 4) only guarantees truth along `to_history(fam)`, not `to_history(fam')`.

**Could bundle-level suffice?**

If we could restructure the truth lemma to evaluate truth relative to the entire bundle simultaneously (rather than a single history), bundle-level might suffice. However:
- The task frame semantics requires a specific history for evaluation
- Box quantifies over histories, but G/H quantify over times within ONE history
- The temporal operators are fundamentally "intra-history" in their semantics

### Alternative Constructions

**1. Fair-Scheduling Chain (Dovetailed Resolution)**

Instead of deterministically choosing successors, maintain an explicit obligation set:
- `Obligations(n) = {phi | F(phi) in mcs(n) and phi not yet witnessed}`
- At each step, pick from obligations in round-robin fashion
- Construct witness MCS ensuring the selected obligation is satisfied
- Remove satisfied obligation, add any new F-formulas to the queue

This guarantees every F-obligation eventually gets a witness within finitely many steps.

**Complexity:** Requires significant restructuring of SuccChain, new data structure for obligation tracking, and proofs that the dovetailed construction maintains MCS consistency.

**2. Omega-Enumeration Chain (Task #55 approach)**

Enumerate all F-formulas: `{F(phi_0), F(phi_1), F(phi_2), ...}`

Build chain where at step `2n`, we handle the `n`-th F-formula:
- If `F(phi_n)` is in `mcs(2n)`, ensure `phi_n` is in `mcs(2n+1)`
- Otherwise, proceed with standard successor

This is mentioned in `UltrafilterChain.lean` as `omegaClassFamilies_temporally_coherent` (referenced but not implemented).

**3. Restricted MCS Approach**

For a specific formula `psi` being proven consistent, work with `RestrictedMCS(cl(psi))`:
- The closure `cl(psi)` is finite
- F-nesting within finite closure IS bounded
- `f_nesting_is_bounded_restricted` holds for restricted chains

This is the approach used by `succ_chain_completeness` and is currently sorry-free.

**Limitation:** Only proves completeness for individual formulas, not general validity. This is actually sufficient for weak completeness!

**4. Henkin-Style Witness Construction**

Standard approach from Henkin completeness:
- Enumerate all formulas
- For each F(phi), add a "witness constant" c_phi
- Ensure phi[c_phi] is satisfied at the appropriate time

This is essentially what fair-scheduling achieves but with explicit syntactic witnesses.

### Truth Lemma Structure

The truth lemma in `ParametricTruthLemma.lean` (lines 207-351) has this critical structure:

```lean
theorem parametric_canonical_truth_lemma
    (B : BFMCS D) (h_tc : B.temporally_coherent)  -- <-- REQUIRES FAMILY-LEVEL
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔ truth_at ... phi
```

The `h_tc : B.temporally_coherent` hypothesis is used ONLY in:
- Line 322-331: G backward case (calls `temporal_backward_G`, which uses `forward_F`)
- Line 342-351: H backward case (calls `temporal_backward_H`, which uses `backward_P`)

Both uses are via:
```lean
let tcf : TemporalCoherentFamily D := {
  toFMCS := fam
  forward_F := h_forward_F  -- extracted from h_tc
  backward_P := h_backward_P
}
exact temporal_backward_G tcf t ψ h_all_mcs
```

**Why the induction is bidirectional:**

The forward direction for `imp` requires the backward direction:
- Forward imp: `(psi -> chi) in MCS, truth(psi) |- truth(chi)`
- Step 1: `truth(psi) -> psi in MCS` [BACKWARD IH for psi]
- Step 2: MCS modus ponens
- Step 3: `chi in MCS -> truth(chi)` [FORWARD IH for chi]

This means the truth lemma cannot be proven forward-only. The backward direction for G/H needs `h_tc`. Therefore, proving the truth lemma requires family-level temporal coherence.

### Can the Induction Be Restructured?

**Option: Prove forward direction first, derive backward**

This fails because:
1. Forward imp case uses backward IH (as shown above)
2. The dependency is inherent to MCS modus ponens reasoning
3. No known reformulation avoids this

**Option: Define truth lemma without G backward requirement**

This would require changing the semantics:
- Make G truth only require forward propagation, not backward derivability
- This breaks the correspondence between MCS membership and semantic truth
- The whole point of the canonical model is that membership equals truth

**Option: Use bundle-level coherence in truth lemma**

This would require:
- Truth evaluation that considers ALL histories simultaneously
- Essentially moving to a bundle-global semantics
- But this conflicts with task frame semantics where evaluation is history-specific

## Recommended Approach

**Mathematically most correct: Fair-Scheduling Chain Construction**

This is the standard technique used in completeness proofs for temporal logic with eventually operators. The key insight is that the current SuccChain construction is "greedy" - it picks successors without regard for which F-obligations need witnesses. A fair-scheduling construction explicitly tracks obligations and ensures each gets satisfied.

**Implementation outline:**

1. Define `ObligationSet(M) = {phi | F(phi) in M, phi not yet witnessed}`

2. Define `FairSuccChain`:
   ```
   mcs(0) = M0
   mcs(n+1) =
     if ObligationSet(mcs(n)) is empty:
       standard successor from F_top
     else:
       pick phi from ObligationSet (round-robin by enumeration order)
       build successor MCS containing phi AND F_top
   ```

3. Prove coherence:
   - Each F(phi) at time t gets witnessed by some s > t (bounded by enumeration position)
   - The witness is in the SAME chain by construction

**Complexity estimate:** ~500-800 lines of new Lean code for:
- Obligation set definition and operations
- Modified chain construction
- Proofs that the construction maintains MCS properties
- Proofs that each obligation eventually gets a witness

**Alternative: Omega-Enumeration**

Simpler but less elegant:
1. Fix an enumeration of all formulas: `phi_0, phi_1, ...`
2. At step `2n`: if `F(phi_n)` is pending, construct witness for it
3. At step `2n+1`: standard forward step

This is what `omegaClassFamilies_temporally_coherent` appears to reference.

**Not Recommended: Sorry deferral**

The zero-debt policy prohibits adding sorries or "Option B" solutions. The proof must be complete or the task must be marked blocked pending a mathematical solution.

**Not Recommended: New axioms**

Introducing axioms to bridge the gap would compromise the mathematical integrity of the formalization.

## Confidence Level

**Medium-High**

**Justification:**
- The diagnosis of WHY family-level coherence is needed is definitive (truth lemma structure analysis)
- The diagnosis of WHY current SuccChain fails is definitive (deterministic construction can starve obligations)
- The fair-scheduling solution is a well-known technique in the literature
- The implementation complexity estimate is uncertain (could be simpler or harder)

**Remaining uncertainty:**
- Whether fair-scheduling can be elegantly integrated with existing infrastructure
- Whether there are Lean-specific proof engineering challenges
- The exact complexity of proving fair-scheduling maintains consistency
- Whether omega-enumeration is simpler than full fair-scheduling

## Sources

- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [A completeness theorem in the modal logic of programs](https://eudml.org/doc/209235)
- [Canonical Models for Normal Logics (Imperial College)](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)
