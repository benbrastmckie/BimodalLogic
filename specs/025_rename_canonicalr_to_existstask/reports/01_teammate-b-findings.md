# Teammate B: CanonicalTask-Centric Architecture Design

**Date**: 2026-03-22
**Task**: 25 - rename_canonicalr_to_existstask
**Focus**: Target architecture after shifting from CanonicalR to CanonicalTask/Succ as primary

---

## Current Infrastructure

### What Exists for CanonicalTask/Succ

The CanonicalTask/Succ infrastructure is fully implemented and more mature than the task description implies.

**SuccRelation.lean** defines the two-condition `Succ` relation:
```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```
- Condition 1 (G-persistence): `g_content u ⊆ v` — identical to CanonicalR
- Condition 2 (F-step): `f_content u ⊆ v ∪ f_content v` — F-obligations resolve or defer

Key theorems already proven:
- `Succ_implies_CanonicalR`: projects out condition 1
- `Succ_implies_h_content_reverse`: g/h duality for Succ pairs
- `single_step_forcing`: if Fφ ∈ u, FFφ ∉ u, and Succ u v, then φ ∈ v
- `single_step_forcing_past`: symmetric P-direction version (currently has `sorry`)
- `succ_propagates_F_not`, `succ_propagates_P_not`: F/P propagation across steps

**CanonicalTaskRelation.lean** defines the integer-indexed CanonicalTask:
```lean
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k    => CanonicalTask_forward u k v
  | Int.negSucc k  => CanonicalTask_backward u (k + 1) v
```

The forward and backward constructors are inductive relations over Succ chains.

Key theorems already proven (the three TaskFrame axioms):
- `CanonicalTask_nullity_identity`: `CanonicalTask u 0 v ↔ u = v`
- `CanonicalTask_forward_comp`: chain concatenation for forward chains
- `CanonicalTask_converse`: `CanonicalTask u n v ↔ CanonicalTask v (-n) u`

Advanced infrastructure:
- `CanonicalTask_forward_MCS`: enriched version carrying MCS proofs at each chain node
- `bounded_witness`: if F^n(φ) ∈ u, F^(n+1)(φ) ∉ u, and a forward MCS chain u→v in n steps, then φ ∈ v
- `CanonicalTask_backward_MCS_P`: backward version with P-step property

**ExistsTask alias** (CanonicalFrame.lean):
```lean
abbrev ExistsTask := CanonicalR
```
Currently just an abbreviation — not yet a theorem expressed in CanonicalTask terms.

### The ExistsTask ↔ CanonicalTask Connection

The critical connection (not yet formally stated as a theorem):
```
ExistsTask(M, N)  ↔  ∃ n ≥ 1, CanonicalTask(M, n, N)
```

This equivalence says CanonicalR is the positive reachability closure of Succ-chains. The left-to-right direction requires establishing that any CanonicalR step can be refined into a Succ-chain (not straightforward, since Succ adds the F-step condition that CanonicalR lacks). The right-to-left direction follows immediately from `Succ_implies_CanonicalR` and `canonicalR_transitive`.

**Important architectural distinction**: The stated equivalence is NOT currently provable without further infrastructure. CanonicalR (= g_content M ⊆ N) is weaker than Succ (which additionally requires f_content M ⊆ N ∪ f_content N). A single CanonicalR step does NOT imply a single Succ step. The correct relationship is:

- Succ ⊆ CanonicalR (the first condition of Succ IS CanonicalR)
- CanonicalR ≠ ExistsTask in general (unless we add the F-step wrapper)

This is a key architectural insight: renaming CanonicalR to ExistsTask should NOT assert it equals the existential of CanonicalTask. Instead, ExistsTask should remain the standalone definition `g_content M ⊆ N`, and CanonicalTask/Succ serves a different (deeper, more structured) role.

---

## Target Theorem Structure

### Theorems Currently Stated in CanonicalR Terms and Their Replacements

#### `canonicalR_transitive` → `CanonicalTask_forward_comp` (already exists)

Current:
```lean
theorem canonicalR_transitive (M M' M'' : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_R1 : CanonicalR M M') (h_R2 : CanonicalR M' M'') : CanonicalR M M''
```

CanonicalTask equivalent (already proven):
```lean
theorem CanonicalTask_forward_comp (u w v : Set Formula) (m n : Nat) :
    CanonicalTask_forward u m w → CanonicalTask_forward w n v →
    CanonicalTask_forward u (m + n) v
```

**Migration note**: `canonicalR_transitive` uses the T4 axiom (G φ → GG φ) and works at the CanonicalR level. The CanonicalTask version composes chains without needing T4 — transitivity is structural in the chain definition. The CanonicalR version can be retained as a convenience lemma derived from CanonicalTask_forward_comp when chains have length 1.

#### `canonicalR_reflexive` → `CanonicalTask_nullity_identity` (already exists)

Under reflexive G/H semantics, `CanonicalR M M` holds (the T-axiom G(φ) → φ makes g_content M ⊆ M). This corresponds to:
```lean
theorem CanonicalTask_nullity_identity (u v : Set Formula) :
    CanonicalTask u 0 v ↔ u = v
```

The CanonicalTask framing is cleaner: "zero steps" is identity, not "self-accessibility." This avoids the philosophical confusion about reflexivity.

#### `canonicalR_irreflexive` → `CanonicalTask_strict_positive` (NEW, to be defined)

Current (proven theorem in CanonicalIrreflexivity.lean):
```lean
theorem canonicalR_irreflexive : ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M
```

In CanonicalTask terms, the replacement theorem is:
```lean
theorem CanonicalTask_strict_positive (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (n : Nat) (hn : n ≥ 1) (v : Set Formula) :
    CanonicalTask_forward_MCS M n v → v ≠ M
```

Or more precisely — the claim that positive-length Succ-chains are strictly progressive:
```lean
theorem Succ_step_changes_content (M N : Set Formula) (h_mcs_M : SetMaximalConsistent M)
    (h_mcs_N : SetMaximalConsistent N) (h : Succ M N) : M ≠ N
```

This is provable using the single_step_forcing theorem: given any F(φ) ∈ M with FF(φ) ∉ M, if Succ M N then φ ∈ N. If additionally φ ∉ M, then N ≠ M.

**The key insight**: Instead of the negative statement "CanonicalR M M is false," we get the positive statement "Succ-steps make progress." This is semantically richer and avoids dependence on the deprecated axiom.

#### `canonicalR_strict` → `CanonicalTask_anti_cycle` (NEW)

Current:
```lean
theorem canonicalR_strict (M N : Set Formula) (hM : SetMaximalConsistent M)
    (hN : SetMaximalConsistent N) (h_MN : CanonicalR M N) : ¬CanonicalR N M
```

In CanonicalTask terms, the replacement involves ruling out non-trivial cycles:
```lean
theorem CanonicalTask_no_positive_cycle (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (n : Nat) (hn : n ≥ 1) : ¬CanonicalTask_forward_MCS M n M
```

This would say: no positive-length Succ-chain can loop back to its starting point. This is stronger than the CanonicalR version and more directly useful for the quotient construction.

---

## Task 29 Blocker Resolution via CanonicalTask

### The Phase 5 Blocker Dissolves

The current Phase 5 blocker is stated as: `canonicalR_irreflexive_axiom` is FALSE under reflexive semantics. The Lean codebase has an inconsistency: there is both a proven `canonicalR_reflexive` theorem AND a deprecated-but-still-referenced `canonicalR_irreflexive_axiom`.

**The CanonicalTask reframing resolves this cleanly:**

1. **CanonicalTask(M, 0, M) is TRUE (identity)** — this is `CanonicalTask_nullity_identity`. Harmless. It corresponds to "zero steps reaches M from M." No forward motion occurs.

2. **For n ≥ 1: Is CanonicalTask_forward_MCS M n M provable?** Under the current axioms:
   - Succ M N requires g_content M ⊆ N (G-persistence) AND f_content M ⊆ N ∪ f_content N (F-step)
   - If M has a formula Fφ ∈ M with FFφ ∉ M (and φ ∉ M), then any Succ-successor N must contain φ (by single_step_forcing), so N ≠ M
   - Under reflexive semantics with the T-axiom (G(φ) → φ), g_content M ⊆ M holds, but Succ M M additionally requires f_content M ⊆ M ∪ f_content M = M, which holds trivially. So **Succ M M could theoretically hold** (if M is G-persistent AND F-closed).
   - However, for MCSes arising in the canonical construction, the F-step condition forces progress. Specifically: if Fφ ∈ M and φ ∉ M, then f_content M ⊄ M (since φ ∈ f_content M but φ ∉ M). This means Succ M M fails whenever M has unresolved F-obligations.

3. **The practical replacement for the deprecated axiom**: Instead of asserting `¬CanonicalR M M` universally, the CanonicalTask approach gives us:
   ```
   ExistsTask_witnesses_have_Succ_progress:
     For any M, the seriality witnesses, density witnesses, and DF witnesses
     produced by the canonical construction satisfy Succ(M, W) with W ≠ M.
   ```
   This is provable per-witness (using the fresh G-atom approach from Task 029 reports) without needing universal CanonicalR irreflexivity.

### What Replaces the `canonicalR_strict` Call Sites?

There are 25+ call sites of `canonicalR_strict` in the codebase, all in the staged construction files. The pattern is always:
```lean
have h_strict : ¬CanonicalR q.mcs p.mcs :=
  canonicalR_strict p.mcs q.mcs p.is_mcs q.is_mcs hq_R
```

**CanonicalTask replacement pattern**: At each call site, the witness q was constructed by a specific procedure (seriality extension, density construction, DF-step). The replacement is:
```lean
have h_strict : q.mcs ≠ p.mcs := by
  -- q.mcs was constructed via Lindenbaum from seed S
  -- seed S contains G(p) for fresh atom p ∉ p.mcs (or equivalent fresh formula)
  -- therefore q.mcs contains G(p), hence p ∈ g_content(q.mcs)
  -- since p ∉ p.mcs, g_content(q.mcs) ⊄ p.mcs, i.e., ¬CanonicalR(q.mcs, p.mcs)
  exact canonicalR_strict_via_fresh_atom p.mcs q.mcs ... h_fresh
```

This per-witness approach eliminates the need for universal `canonicalR_irreflexive_axiom`.

---

## Quotient Construction via Succ-Chains

### Can Antisymmetrization Be Succ-Native?

Currently, `DovetailedTimelineQuot` and `CantorApplication.lean` define the antisymmetric quotient via:
```lean
-- Preorder: a ≤ b iff a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs
```

The quotient identifies `a ~ b` when `CanonicalR a.mcs b.mcs ∧ CanonicalR b.mcs a.mcs`.

**Can this be restated using CanonicalTask/Succ?**

The answer is: YES, with a different preorder definition.

**Succ-native preorder**:
```lean
def SuccChainLE (p q : DovetailedPoint) : Prop :=
  p.mcs = q.mcs ∨ ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward p.mcs n q.mcs
```

This is strictly weaker than the CanonicalR preorder because Succ ⊆ CanonicalR but not vice versa. However, for the canonical construction, every CanonicalR step was constructed as a Succ-chain step (via the seed construction), so in practice the two preorders may coincide on the built timeline.

**Important subtlety**: The DovetailedPoint preorder uses `DovetailedPoint.le`:
```
a ≤ b  iff  a.mcs = b.mcs  ∨  CanonicalR a.mcs b.mcs
```

If we replace CanonicalR with the positive CanonicalTask reachability, we get a preorder that:
- Is reflexive (zero steps, or same MCS)
- Is transitive (chain concatenation)
- Is total (from the linear order on the staged construction)

The antisymmetrization of this Succ-native preorder would identify points with the same MCS AND mutually Succ-reachable points. Under the CanonicalTask `no_positive_cycle` theorem (see above), the only points identified are those with the same MCS — giving a proper linear order with no spurious identifications.

**Design recommendation**: The quotient construction can remain CanonicalR-based for now (since `ExistsTask = CanonicalR` is the current alias), and transition to Succ-chain preorder once `CanonicalTask_no_positive_cycle` is proven. The transition is low-risk since the two coincide on constructed timelines.

---

## Truth Lemma Restatement

### How ParametricTruthLemma.lean Uses CanonicalR

Examining `ParametricTruthLemma.lean`, the truth lemma works over the `FMCS D` abstraction:
```lean
theorem parametric_canonical_truth_lemma (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔ truth_at (ParametricCanonicalTaskModel D) ...
```

The `FMCS D` (family of maximal consistent sets indexed by D) uses `forward_G` and `backward_H` properties directly:
```lean
fam.forward_G t s psi hts h_G  -- extracts psi from G(psi) via monotone index
fam.backward_H t s psi hst h_H  -- extracts psi from H(psi) via monotone index
```

**The critical observation**: The truth lemma does NOT directly mention CanonicalR. It works through the abstract `FMCS D` interface. The G/H cases use:
- `temporal_backward_G tcf t psi h_all_mcs` for the backward direction of G
- `temporal_backward_H tcf t psi h_all_mcs` for the backward direction of H

These are properties of `TemporalCoherentFamily`, which requires `forward_F` and `backward_P`. These ARE properties that connect back to CanonicalR (via the witness seed construction).

### CanonicalTask-Native Truth Lemma

The truth lemma CAN be restated in CanonicalTask terms for the discrete (integer-indexed) case. The `D = ℤ` case is the natural home for CanonicalTask:

```lean
theorem discreteCanonicalTask_truth_lemma
    (fam : SuccChainFamily)  -- family indexed by ℤ via Succ-chains
    (t : ℤ) (phi : Formula) :
    phi ∈ fam.mcs t ↔ truth_at discreteCanonicalTaskModel ... t phi
```

where `SuccChainFamily` encodes:
- `fam.mcs : ℤ → Set Formula` giving MCSes at each integer time
- `Succ (fam.mcs t) (fam.mcs (t+1))` for all t (adjacent positions are Succ-related)
- MCS property at each time point

The G-case in this truth lemma would use `bounded_witness` directly:
```
G(phi) ∈ fam.mcs t
 → for all n ≥ 0, phi ∈ fam.mcs (t + n)
```

The F-case would use the CanonicalTask forward chain:
```
F(phi) ∈ fam.mcs t
 → ∃ n ≥ 1, CanonicalTask(fam.mcs t, n, W) ∧ phi ∈ W
```

**The challenge**: The parametric truth lemma works for arbitrary ordered groups D. The CanonicalTask version is specific to ℤ (or ℕ for the forward-only fragment). The two-level architecture (parametric for dense case D = ℚ, discrete for D = ℤ) is the right design.

**Current status**: The parametric truth lemma does not mention CanonicalR directly. The CanonicalTask infrastructure is used in the discrete staged construction (SuccRelation, CanonicalTaskRelation), which feeds into the dense construction via the FMCS interface. The truth lemma itself is already "CanonicalTask-agnostic" — it's the construction machinery that connects to Succ-chains.

---

## Migration Path

### Phase 1: Formalize the ExistsTask-CanonicalTask Connection (low urgency)

The `ExistsTask = CanonicalR` alias exists. What needs to be added:

```lean
-- State the characterization (requires proof infrastructure)
theorem ExistsTask_characterization (M N : Set Formula)
    (h_mcs_M : SetMaximalConsistent M) (h_mcs_N : SetMaximalConsistent N) :
    ExistsTask M N ↔ ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward M n N := ...
```

**Blocker**: The right-to-left direction is easy (`Succ_implies_CanonicalR` + `canonicalR_transitive`). The left-to-right direction requires constructing a Succ-chain from a bare CanonicalR step — this needs the forward_F property and Lindenbaum construction. It may not be provable in full generality (CanonicalR does not carry F-step information). This theorem may be false for arbitrary CanonicalR pairs and only hold for constructed witnesses.

**Recommendation**: Do NOT attempt this theorem in full generality. Instead, state a weaker version:
```lean
theorem CanonicalTask_forward_implies_ExistsTask (M N : Set Formula) (n : Nat) (hn : n ≥ 1) :
    CanonicalTask_forward M n N → ExistsTask M N := ...
```
This is straightforwardly provable from `Succ_implies_CanonicalR` and `canonicalR_transitive`.

### Phase 2: Prove CanonicalTask_no_positive_cycle (medium priority)

This is the CanonicalTask analog of `canonicalR_irreflexive`. The proof strategy:
- Use `single_step_forcing` and `bounded_witness` to show that a cycle of length n would force a formula φ to be in M at position 0 AND outside M at the same position — contradiction.
- Alternatively, use the fresh G-atom approach: any constructed Succ-step uses a seed that includes a fresh formula, so the successor MCS differs from the source.

### Phase 3: Replace `canonicalR_strict` Call Sites (high priority for Task 29)

At each of the 25+ call sites, replace with the per-witness fresh-atom construction:
1. `CantorApplication.lean` NoMaxOrder, NoMinOrder, DenselyOrdered (3 call sites)
2. `DovetailedTimelineQuot.lean` (similar pattern, 3 call sites)
3. Other staged construction files

The pattern is uniform: each call site constructs a witness W from a seed. Modifying the seed to include a fresh formula (G(p) for fresh p) gives `¬CanonicalR W M` directly without needing `canonicalR_irreflexive_axiom`.

### Phase 4: Remove the Deprecated Axiom (deferred until Phase 3 complete)

Once all call sites are updated, remove `canonicalR_irreflexive_axiom` from `CanonicalIrreflexivity.lean`. The theorem `canonicalR_irreflexive` (proven via Gabbay IRR + T-axiom) remains; only the axiom declaration is removed.

### Phase 5: Rename CanonicalR to ExistsTask (cosmetic, deferred)

After the above phases, perform the rename:
- `CanonicalR` → `ExistsTask` throughout (63 files)
- `CanonicalR_past` → `ExistsPastTask` (or leave as is)
- Update `CanonicalFrame.lean` to define `ExistsTask` as the primary definition (not an alias)

This is purely cosmetic and can be done as a large-scale search-and-replace once the logical infrastructure is stable.

---

## Key Architectural Insights

### The Two-Level Architecture Is Sound

1. **CanonicalTask/Succ** (integer-indexed, discrete): Used in the staged construction to build MCS chains with F-step guarantees. Provides rich distinctness proofs via `bounded_witness` and `single_step_forcing`.

2. **ExistsTask/CanonicalR** (binary, dense): Used in the quotient construction (Antisymmetrization) and in the parametric truth lemma. A derived/coarser view.

The migration does NOT require collapsing these two levels. The target architecture keeps both, with CanonicalTask as primary and ExistsTask as a derived convenience.

### The Irreflexivity Problem Is a Red Herring

The Task 29 blocker about `canonicalR_irreflexive_axiom` is not an irreflexivity problem — it is a **strictness problem**. We need witnesses to be STRICTLY greater than their sources in the quotient. This does not require universal irreflexivity of CanonicalR; it requires local distinctness at each construction site. CanonicalTask/Succ provides exactly the right tools for this via the F-step condition.

---

## Confidence Level

**High** for the structural analysis of what CanonicalTask/Succ does and does not provide.

**High** for the claim that `CanonicalTask_forward_implies_ExistsTask` is provable and useful.

**Medium** for the claim that `ExistsTask ↔ ∃ n ≥ 1, CanonicalTask_forward M n N` holds in full generality (the left-to-right direction may require additional infrastructure or be false for arbitrary CanonicalR pairs).

**High** for the recommended Phase 3 migration path (replace deprecated axiom call sites with per-witness fresh-atom arguments).

**Medium** for the Succ-native quotient construction (it requires `CanonicalTask_no_positive_cycle` which is not yet proven).

**High** that the two-level architecture (CanonicalTask for discrete, ExistsTask for dense) is the correct design and that the parametric truth lemma does not need significant changes.
