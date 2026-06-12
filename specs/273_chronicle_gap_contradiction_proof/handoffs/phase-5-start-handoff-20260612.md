# Phase 5 Start Handoff

## Completed in this session
- Phase 4f: Prop 4.2 negation closure for VecEA2/VVecEA2 (NegationClosureProp42.lean)
  - `neg_vecEA2`: single VecEA2 negation is VVecEA2
  - `neg_2var_vec_ea`: full VVecEA2 negation is VVecEA2
  - `VBracketFormula.toVVecEA2WithEndpoints`: lift V-bracket to VVecEA2
  - All sorry-free, lean_verify clean
- Phase 4 marked COMPLETED in plan v21
- Phase 5 started: FoToVecEA.lean created with infrastructure

## Phase 5 Current State
- FoToVecEA.lean: imports NegationClosureProp42 + NegationClosure, builds clean, 0 sorries
- Contains: nfCharPred, atomsPred helpers; detailed bridge strategy documentation
- No theorems proven yet (infrastructure only)

## Phase 5 Next Steps (for successor agent)

### Step 1: Construct VVecEA2 for NF existence (nf_exist_to_vvecEA2)

Signature:
```lean
theorem nf_exist_to_vvecEA2 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_kp1 : NormalForm sig (k+1) 1 → Formula)
    (char_kp1_correct : ∀ nf M h_UZ h_SZ t,
      temporal_truth M atomMap t (char_kp1 nf) ↔ nf_eval_nf M (k+1) 1 (fun _ => t) nf)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k+1) 2) :
    ∃ v : VVecEA2, ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
      (v.holdsLeft M atomMap t ↔ ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf)
```

### Step 2: Construction approach

For nf_order_dir sub_nf = some true (t < x):
- For each compatible nf_x, build VecEA2:
  - endpointLeft = atomsPred parent_atoms
  - endpointRight = nfCharPred (char_kp1 nf_x)
  - bracket = trivial (TemporalPred.top segments) with witnesses for positive ssn conditions
- The VVecEA2 disjuncts over all compatible nf_x

Forward: given x with nf_eval, determine nf_x = nf_characteristic, use char_kp1_correct
Backward: from VecEA2.holdsLeft, extract z1 = x and use char_kp1_correct inverse

### Step 3: The critical insight for backward direction

The FAILED approach (nf_exist_formula_nested_backward) tried to recover 3-var NFs
from 1-var NFs via composition. The VecEA2 approach encodes the 3-var NF conditions
DIRECTLY as TemporalPreds in the bracket formula. Specifically:

- For each ssn with sub_nf.2(ssn) = true, the bracket contains a witness y with
  pointType = conjunction of char_kp1(nf_y) conditions that force the full 3-var NF
- No composition lemma needed: the TemporalPred at y encodes ALL conditions

### Step 4: Wire into master_induction (Phase 6)

Replace P2(k+1) at NegationClosure.lean line 1448-1469:
```lean
have p2_kp1 : P2 atomMap (k + 1) := by
  intro parent_atoms sub_nf
  obtain ⟨v, hv⟩ := nf_exist_to_vvecEA2 atomMap h_surj k char_kp1 char_kp1_correct parent_atoms sub_nf
  exact ⟨v.translateLeft, fun M h_UZ h_SZ t h_atoms =>
    (v.translateLeft_correct M atomMap t).trans (hv M h_UZ h_SZ t h_atoms)⟩
```

## Files Modified
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean (NEW, 80 lines)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean (NEW, 120 lines)
- specs/273_chronicle_gap_contradiction_proof/plans/21_rabinovich-formula-level-plan.md (updated)
