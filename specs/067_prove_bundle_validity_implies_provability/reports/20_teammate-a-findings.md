# Research Findings: Semantic Root Cause Analysis

**Task**: 67 — prove_bundle_validity_implies_provability
**Focus**: Mathematical root cause of bfmcs_from_mcs_temporally_coherent blocker
**Date**: 2026-03-29

---

## Key Findings

### 1. Root Cause: The Z-chain Construction Only Resolves F_top, Not Arbitrary F-Obligations

The true mathematical root cause is a **design mismatch** between what the omega chain construction does and what family-level temporal coherence requires.

**What the construction does** (`omega_chain_forward_with_inv` at UltrafilterChain.lean:2027-2045):
- At each step n, the forward chain resolves exactly ONE F-obligation: `F_top` (i.e., `F(neg bot)`)
- The witness is obtained via `omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top`
- The witness MCS contains `neg bot` (trivially true) and preserves G-theory + box-class

**What family-level coherence requires** (`forward_F` in `temporally_coherent`):
- For ANY F(psi) in fam.mcs(t), there must exist s > t with psi in fam.mcs(s)
- The witness must be IN THE SAME CHAIN, not just somewhere in the bundle

**The gap**: The Z-chain advances by always resolving F_top. If F(phi) is in Z_chain(t) for some specific phi, the construction provides NO guarantee that phi will appear at any particular future position in the same chain.

### 2. Standard Textbook Approach: Henkin-Style Fair Scheduling

Standard completeness proofs for temporal logic (Blackburn, de Rijke, Venema "Modal Logic"; Goldblatt "Logics of Time and Computation") use different strategies:

**Strategy A: Flat Canonical Model (Standard Kripke)**
- Build the canonical model as a flat set of ALL maximal consistent sets
- Define temporal accessibility R_G as: M R_G N iff G-theory(M) ⊆ N
- The "Existence Lemma" provides witnesses: if F(phi) ∈ M, then {phi} ∪ G-theory(M) is consistent, so there exists an MCS N with phi ∈ N and M R_G N
- This works because witnesses can be ANY MCS, not constrained to a specific chain

**Strategy B: Henkin-Style Construction (for Linear Time)**
- Build the canonical model incrementally using fair scheduling
- Enumerate ALL F-obligations in a priority queue
- At each step, resolve the highest-priority pending obligation
- Fair scheduling guarantees every obligation is eventually resolved
- This is the "bulldozing" technique (Segerberg 1970)

**Why our construction fails**: We use a single-obligation resolution (F_top only), which is a degenerate case of fair scheduling that never resolves other F-obligations within the same chain.

### 3. The Fuel Exhaustion Is a Symptom, Not the Root Cause

The sorry in `restricted_bounded_witness_fueled` (SuccChainFMCS.lean:2797) occurs in the `fuel = 0` branch:
```lean
| 0 =>
  match d with
  | 0 => exact absurd h_d_ge (by omega : ¬0 ≥ 1)
  | _ + 1 =>
    -- Semantically unreachable case - fuel exhausted but witness must exist
    exact ⟨k + 1, by omega, by sorry⟩
```

**This branch is semantically unreachable** when:
- The caller provides fuel = B*B+1 where B = closure_F_bound(phi)
- Each recursive call decreases fuel by 1 and increases k by 1
- The total recursion depth is bounded by B^2 (F-nesting squared)

**However**: The fuel exhaustion sorry is NOT the blocking issue for `bfmcs_from_mcs_temporally_coherent`. The real blocker is that we need to CALL `restricted_bounded_witness_fueled` in the first place, which requires:
1. A `DeferralRestrictedSerialMCS phi` as the starting point
2. This structure requires `F_top ∈ deferralClosure(phi)` (via `has_F_top` field)
3. For general phi, `F_top ∉ deferralClosure(phi)` (proven at SubformulaClosure.lean:919)

### 4. The F_top ∉ deferralClosure(phi) Blocker Is Structural

The constraint `F_top ∈ deferralClosure(phi)` fails for any phi without `F(neg bot)` as a subformula:

- `deferralClosure(phi)` = `closureWithNeg(phi)` ∪ deferral disjunctions
- `closureWithNeg(phi)` contains only subformulas of phi and their negations
- For phi = `p` (atomic): `deferralClosure(p) = {p, neg p}`
- `F_top = some_future(neg bot)` is clearly not in this set

This is the **true structural blocker** documented in team research report 10.

---

## Standard Textbook Approach

### How Standard Proofs Ensure Temporal Witnesses Exist

**In Blackburn-de Rijke-Venema (2001, Ch. 4)**:
The canonical model for basic modal logic (including temporal operators) uses:
1. Worlds = ALL maximal consistent sets
2. Accessibility = G-preimage containment (M R_G N iff ∀a. G(a) ∈ M → a ∈ N)
3. Existence Lemma: F(phi) ∈ M → ∃N. M R_G N ∧ phi ∈ N

The Existence Lemma is proved by showing `{phi} ∪ g_content(M)` is consistent (our `temporal_theory_witness_exists` at UltrafilterChain.lean:1153 does this), then extending via Lindenbaum's lemma.

**Critical difference**: In the flat canonical model, the witness N can be ANY MCS. There is no requirement that N be part of a pre-constructed chain containing M.

### Why Bundle Semantics Makes This Harder

TM uses bundle semantics where:
- G quantifies along a SINGLE history (chain), not across all accessible worlds
- The truth of G(phi) at world w in history h requires phi true at ALL future positions IN THE SAME HISTORY h
- This forces witnesses for F-obligations to be in the same chain

The flat canonical model approach fails because:
- F(phi) at position t in chain C needs witness at position s > t IN CHAIN C
- But Lindenbaum gives us a witness MCS W that may not be = C(s) for any s

---

## Recommended Approach

### Option 1: Extend deferralClosure to Include Seriality Formulas (Recommended)

This is the approach identified in team research report 10:

```lean
def extendedDeferralClosure (phi : Formula) : Set Formula :=
  deferralClosure phi ∪ {F_top, P_top, Formula.neg Formula.bot}
```

**Why correct**:
1. F_top and P_top are theorems (hold in every consistent set)
2. Standard textbook closures ALWAYS include seriality axioms
3. F-nesting bound increases by at most 1 (F_top has depth 1)
4. The restricted chain construction remains valid

**Implementation**: 14 call sites in SuccChainFMCS.lean need updating to handle F_top specially.

### Option 2: Fair-Scheduling Omega Chain (Alternative)

Redesign `omega_chain_forward` to use fair scheduling:
1. Maintain a priority queue of pending F-obligations
2. At each step, resolve the LOWEST-priority pending obligation
3. New obligations added to queue with priority = current step
4. This guarantees every F(phi) is eventually resolved

**Pros**: Mathematically cleaner, follows textbook approach
**Cons**: Major refactoring of UltrafilterChain.lean

### Option 3: Use Bundle-Level Coherence + Different Truth Lemma (Not Recommended)

The `construct_bfmcs_bundle` provides bundle-level coherence (witnesses in potentially different families). A modified truth lemma could use this.

**Why not recommended**: The current truth lemma (`shifted_truth_lemma`) requires SAME-family witnesses. Changing this would require restructuring the entire completeness proof.

---

## Evidence/Examples

### Evidence for Root Cause Analysis

1. **UltrafilterChain.lean:2477-2478** (comment in `Z_chain_forward_F`):
   > "The real issue: the current omega_chain_forward always resolves F_top, not arbitrary F-obligations."

2. **UltrafilterChain.lean:2038** (witness construction):
   ```lean
   let h_F_top : Bimodal.Syntax.F_top ∈ M_n := SetMaximalConsistent.contains_F_top inv_n.is_mcs
   ```
   Shows the witness is ALWAYS for F_top.

3. **SuccChainFMCS.lean:2300** (`F_top_in_restricted_successor`):
   Uses `h_drm.1.1 h_F_top` which requires `F_top ∈ deferralClosure phi` — the exact failure point.

### Evidence for Recommended Approach

1. **Team research report 10** (reports/10_team-research.md) concludes:
   > "The mathematically correct solution is to define an extended deferral closure"

2. **SuccChainFMCS.lean:2887** (`restricted_forward_chain_forward_F`) is sorry-free, proving the restricted chain CAN resolve F-obligations — the missing piece is getting F_top into the closure.

---

## Confidence Level

**HIGH** — with the following justification:

1. **Root cause identified with precision**: The mismatch between single-obligation resolution (F_top) and the requirement for arbitrary F-obligation resolution within the same chain is clearly visible in the code (UltrafilterChain.lean:2038 vs 2477).

2. **Standard textbook approach confirmed**: The Existence Lemma approach in flat canonical models versus the per-chain requirement in bundle semantics explains why standard proofs work but ours doesn't directly apply.

3. **Multiple independent analyses converge**: Team research reports 09 and 10 both identify the same structural blocker (F_top ∉ deferralClosure for general phi) and recommend the same solution (extend deferralClosure).

4. **Sorry-free infrastructure confirms viability**: The existence of `restricted_forward_chain_forward_F` (sorry-free) shows that once the closure is extended, the proof goes through.

The only uncertainty is the exact set of formulas to add to the extended closure (whether `neg bot` alone suffices or whether `neg F_top`, `neg P_top` are also needed), but this is an implementation detail, not a conceptual gap.
