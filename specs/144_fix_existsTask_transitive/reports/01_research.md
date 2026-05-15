# Research Report: Fix existsTask_transitive (Task 144)

## Sorry Analysis

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`, line 259

**Theorem**: `existsTask_transitive`

**Statement**: If `ExistsTask M M'` and `ExistsTask M' M''`, then `ExistsTask M M''`, given `SetMaximalConsistent M`.

**The sorry** fills `h_T4`, a proof of:
```lean
[] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi))
```
i.e., the temporal 4 axiom `G phi → G(G phi)` as a `DerivationTree`.

The comment says `BX: derive temp_4 from BX1`, which is misleading — `temp_4` is a direct axiom constructor (`Axiom.temp_4`), not something that needs to be derived from BX1. The fix is trivial.

**Goal state at sorry site** (confirmed via lean_goal):
```
h_T4 : ⊢ phi.all_future.imp phi.all_future.all_future
⊢ phi ∈ M''
```
The `h_T4` hypothesis is exactly the type being filled by the sorry. Once `h_T4` is established, the rest of the proof (lines 261–265) is sorry-free and uses standard MCS closure reasoning.

---

## Proposed Fix (Verified)

**Fix**: Replace `sorry` with `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`

### Verification

**Axiom.temp_4 signature** (from `Theories/Bimodal/ProofSystem/Axioms.lean`, line 116–117):
```lean
| temp_4 (φ : Formula) :
    Axiom (φ.all_future.imp φ.all_future.all_future)
```
So `Axiom.temp_4 phi : Axiom (phi.all_future.imp phi.all_future.all_future)`.

**DerivationTree.axiom constructor** (from `Theories/Bimodal/ProofSystem/Derivation.lean`, line 75):
```lean
| axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : DerivationTree Γ φ
```
So `DerivationTree.axiom [] _ (Axiom.temp_4 phi) : DerivationTree [] (phi.all_future.imp phi.all_future.all_future)`.

This exactly matches `[] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi))` (the `⊢` notation is definitional equality for `DerivationTree []`).

### Identical Usage Already Compiled

The identical pattern appears and compiles in:
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean`, line 248:
  ```lean
  DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  ```
  (proves `SetMaximalConsistent.all_future_all_future`, which is sorry-free)
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean`, line 274:
  ```lean
  DerivationTree.axiom [] _ (Axiom.temp_4 ψ)
  ```
  (inside `temp_4_past`, sorry-free)

The `_` for the formula argument is inferred from the `Axiom.temp_4 phi` argument. No imports are needed — `DerivationTree`, `Axiom`, and `Formula.all_future` are all already in scope (the file already uses `theorem_in_mcs` and `SetMaximalConsistent.implication_property` which require the same imports).

**Confidence: 100%** — this is a direct axiom application, not a proof search.

### Complete Fixed Proof

```lean
theorem existsTask_transitive (M M' M'' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_R1 : ExistsTask M M') (h_R2 : ExistsTask M' M'') :
    ExistsTask M M'' := by
  intro phi h_G_phi
  have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  have h_GG : Formula.all_future (Formula.all_future phi) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_G_phi
  have h_G_in_M' : Formula.all_future phi ∈ M' := h_R1 h_GG
  exact h_R2 h_G_in_M'
```

---

## Critical Path Trace

`existsTask_transitive` reaches `bx_completeness` via two independent paths:

### Path 1: Dense case (Chronicle)

```
existsTask_transitive (CanonicalFrame.lean:251)
  -> abbrev canonicalR_transitive (CanonicalFrame.lean:268)
  -> parametric_task_rel_forward_comp (ParametricCanonical.lean:132)
     [x > 0, y > 0 branch: uses canonicalR_transitive]
  -> ParametricCanonicalTaskFrame.forward_comp (ParametricCanonical.lean:203)
  -> ParametricCanonicalTaskFrame Rat (ChronicleToCountermodel.lean:802)
  -> dd_countermodel_chronicle_dense (ChronicleToCountermodel.lean)
  -> bx_completeness dense case (Completeness.lean:153-154)
```

### Path 2: Discrete case (WeakCanonical/Doets)

```
existsTask_transitive
  -> canonicalR_transitive
  -> parametric_task_rel_forward_comp
  -> ParametricCanonicalTaskFrame Int (WeakCanonical/Transfer.lean, imports ParametricCanonical)
  -> doets_countermodel_discrete
  -> bx_completeness discrete case (Completeness.lean:160)
```

### Path 3: RootScopedChain (dead code, per Completeness.lean:218)

```
existsTask_transitive -> canonicalR_transitive -> ParametricCanonicalTaskFrame Int
  -> dd_countermodel (RootScopedChain.lean:202)
```
This path is explicitly marked dead code in Completeness.lean comment at line 218. The sorry sites in RootScopedChain.lean (lines 186, 193, 198) are separate sorries that are NOT on the critical path.

**Conclusion**: `existsTask_transitive` IS on the critical path via Paths 1 and 2. Both active branches of `bx_completeness` depend on `ParametricCanonicalTaskFrame.forward_comp`, which calls `canonicalR_transitive = existsTask_transitive`.

---

## Other Findings

### CanonicalFrame.lean: Only one sorry

`grep` confirms exactly one sorry in `CanonicalFrame.lean` (line 259). All other theorems in this file are sorry-free:
- `canonical_forward_F`: sorry-free (uses `set_lindenbaum` + seed consistency)
- `canonical_backward_P`: sorry-free
- `canonical_forward_U`: sorry-free
- `canonical_backward_S`: sorry-free
- `h_content_chain_transitive`: sorry-free (uses `temp_4_past` correctly)

### Analogous pattern already complete

`h_content_chain_transitive` (lines 281–293) is the past-direction analogue. It uses `temp_4_past phi` (a derived lemma) instead of the direct axiom. The future direction (`existsTask_transitive`) uses `Axiom.temp_4` directly, which is even simpler.

### MCSProperties.lean: SetMaximalConsistent.all_future_all_future is redundant

`SetMaximalConsistent.all_future_all_future` (MCSProperties.lean:243) proves essentially the same result as what `existsTask_transitive` needs internally. The sorry in CanonicalFrame.lean could alternatively be written:
```lean
DerivationTree.weakening [] _ _ (DerivationTree.axiom [] _ (Axiom.temp_4 phi)) (by intro; simp)
```
But the direct form `DerivationTree.axiom [] _ (Axiom.temp_4 phi)` is cleaner and works because the context is already `[]`.

### Note on sorry comment

The comment `BX: derive temp_4 from BX1` is incorrect. `temp_4` is a standalone axiom constructor in the BX system (Layer 3, line 116 of Axioms.lean). It does not need to be derived from BX1 (serial_future). The comment is a historical artifact from when the axiom system was being reorganized.

---

## Confidence Level

**Fix confidence: 100%**

Rationale:
1. `Axiom.temp_4 phi` is a well-typed constructor of `Axiom (phi.all_future.imp phi.all_future.all_future)`
2. `DerivationTree.axiom [] _ (Axiom.temp_4 phi)` produces exactly the required type
3. The identical call pattern compiles without issues at MCSProperties.lean:248 and :274
4. The file already imports everything needed (no new imports required)
5. The sorry is 1 line with a straightforward type; no universe issues, no implicit argument issues

**Implementation effort**: 1 line change — replace `sorry /- BX: derive temp_4 from BX1 -/` with `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`.
