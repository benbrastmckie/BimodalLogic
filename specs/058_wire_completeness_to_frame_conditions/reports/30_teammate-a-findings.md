# Teammate A Findings: History-Unification Approach

**Task**: 58 - Wire Completeness to Frame Conditions
**Focus**: Option C - History-Unification for cross-family witness transfer
**Date**: 2026-03-26

---

## Key Findings

- **The Transfer Theorem as stated CANNOT be proven** from what `boxClassFamilies` guarantees.
- **Shared box-class does not imply shared temporal content**: families in the same box-class can disagree on G/H-formulas and on `phi ∈ fam.mcs(s)` for arbitrary formulas.
- **The G-agreement invariant is one-directional**: `temporal_theory_witness_exists` guarantees G(a) ∈ M → G(a) ∈ W (forward-only), not bidirectional synchronization between any two families.
- **The linearity axiom does not rescue the approach**: it constrains witnesses in a single family, not relationships across families with shared box-class.
- **A weaker unification IS possible but solves a different problem**: one can transfer G-formulas forward across any box-class-agreeing family — but not arbitrary phi.
- **No existing cross-family transfer lemmas exist** in UltrafilterChain.lean that go beyond modal (Box) formulas.

---

## Detailed Analysis

### 1. Shared Box-Class Structure

All families in `boxClassFamilies M0 h_mcs` (line 1553–1557) share a common property:

```lean
noncomputable def boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    f = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k }
```

The shared property is `box_class_agree M0 W` — both positive and negative Box-formulas are exactly those of M0.

More precisely, `box_class_agree M0 W` (line 265) means:
```lean
∀ phi : Formula, Formula.box phi ∈ M0 ↔ Formula.box phi ∈ W
```

This means all families share:
- The same S5-modal content at the base MCS W (at time k)
- The same Box content at ALL times (because Box is persistent by `succ_chain_box_persistent`, line 334)

So for fam, fam' both in `boxClassFamilies M0 h_mcs`, and any time t:
```
Formula.box phi ∈ fam.mcs(t) ↔ Formula.box phi ∈ fam'.mcs(t)
```

This is proven by `boxClassFamilies_modal_forward`/`modal_backward` (lines 1595–1670).

**What the shared box-class does NOT cover**: G-formulas, H-formulas, F-formulas, P-formulas, or propositional atoms. Two families can be in the same box-class but have completely different temporal content.

### 2. The Transfer Theorem — Analysis of Feasibility

The proposed Transfer Theorem:

```
forall fam fam' in boxClassFamilies,
forall phi s, phi ∈ fam'.mcs(s) →
  exists s' >= s, phi ∈ fam.mcs(s')
```

**This is FALSE in general.** Here is a counterexample construction:

Let M0 be an MCS containing `G(p)` (always p) and `neg(p)` at time 0 — wait, that's inconsistent. Let me construct the counterexample more carefully.

**Counterexample**: Let M0 be an arbitrary MCS. Consider:
- `fam = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS M0 h_M0)) 0` — the "canonical" family starting from M0
- `fam' = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) 0` where W is constructed via `box_theory_witness_exists` to contain some formula `phi` that is NOT in M0

Specifically: let M0 contain `diamond(p)` for atomic `p`. By `box_theory_witness_exists`, there exists W with `p ∈ W` and `box_class_agree M0 W`. Then `fam'` has `p ∈ fam'.mcs(0)`.

But can we guarantee `p ∈ fam.mcs(s')` for some `s' >= 0`? Only if the SuccChain from M0 eventually reaches an MCS containing `p`. This is the very thing that the `Z_chain_forward_F` sorry (line 2485) is trying to prove — and it's blocked.

**The Transfer Theorem would imply Z_chain_forward_F**: If we could transfer `phi ∈ fam'.mcs(0)` to `phi ∈ fam.mcs(s')`, then by setting fam to be the Z-chain family and fam' to be the witness family from `boxClassFamilies_bundle_forward_F`, we would have Z_chain_forward_F. So the Transfer Theorem is at least as hard as the blocked theorem.

**But the Transfer Theorem is actually STRONGER** (and likely FALSE for the same reasons):

Consider p = F_top (seriality), so p ∈ every MCS. Now consider a non-trivial phi. The issue is that after transitioning through the SuccChain from M0, we lose track of arbitrary phi-content. The chain from M0 at step n may contain `neg(phi)` while a chain from W contains `phi`.

### 3. G-Agreement Structure: What It Really Says

The `temporal_theory_witness_exists` (line 1153) gives for witness W of F(phi) from M:
```
∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W
```

This is a **one-way implication from M to W**. It says:
- W inherits all G-formulas of M
- BUT W can have additional G-formulas not in M
- AND M can have G-formulas that happen to NOT be in W's negation-closure
- Most importantly: this is only about G-formulas, not arbitrary phi

The construction in `omega_chain_forward_with_inv` (line 2027) builds a chain where:
- Each step W_{n+1} is constructed from W_n by taking a witness for F_top
- G-formulas from M0 propagate: `G(a) ∈ M0 → G(a) ∈ W_n` for all n (line 2080)
- Box-formulas from M0 are preserved: `box_class_agree M0 W_n` for all n

So within a single omega-chain, we have G-propagation from the base. But across TWO DIFFERENT chains from box-class-agreeing bases, we have only box-class agreement — NOT G-formula agreement.

**Concretely**: Let M0 contain `G(p)`. Let W be in the box class of M0 but containing `neg(G(p))`. This W exists as long as `G(p)` is not in the box theory of M0 (i.e., not provable from box-formulas alone). The family from W will NOT satisfy `p ∈ fam_W.mcs(s)` for all s, while the family from M0 will.

This shows: knowing phi ∈ fam'.mcs(s) gives no information about phi ∈ fam.mcs(s') when fam and fam' are merely box-class-equivalent.

### 4. Modal Equivalence and Temporal Formulas

The question asks: "If fam and fam' are modally equivalent (same Box/Diamond theorems), what can we infer about temporal formulas?"

**Answer**: Very little that is directly useful for the transfer theorem.

Formal content of box-class equivalence between two MCSes M, W:
- Same Box-formulas → same modal T-consequences (since Box(phi) → phi by modal_t)
- Same positive/negative Box formulas → same S5-modal theory (by S5 completeness)
- By axiom `temp_future`: Box(phi) → G(Box(phi)), so same Box-formulas imply same G(Box(phi)) formulas
- By axiom `modal_future`: Box(phi) → phi, so same Box-formulas imply same modal facts

But this covers only modally-generated G-formulas. An arbitrary formula phi can be in G-theory(M) without being a modal consequence of Box(phi).

**The linearity axiom** (line 344):
```
F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)
```

This says: witnesses for F(phi) and F(psi) in the SAME family are temporally ordered (one comes before or after the other). This constrains witnesses WITHIN a single family but gives NO information about witnesses across different families. The linearity axiom is about the linear order of a single history, not about relationships between histories.

### 5. Existing Lemmas About Cross-Family Relationships

Searching UltrafilterChain.lean, the only cross-family relationship theorem is `boxClassFamilies_modal_forward` (line 1595):
```lean
theorem boxClassFamilies_modal_forward (M0 : Set Formula) ...
    (phi : Formula) (t : Int) (h_box : Formula.box phi ∈ fam.mcs t)
    (fam' : FMCS Int) (hfam' : fam' ∈ boxClassFamilies M0 h_mcs) :
    phi ∈ fam'.mcs t
```

This transfers `phi` from fam to fam' at the SAME time t — but ONLY when `Box(phi) ∈ fam.mcs(t)`, i.e., only for modal witnesses.

**No lemma exists** that transfers arbitrary phi across families in boxClassFamilies. This confirms that the infrastructure for History-Unification is absent.

### 6. Why the Transfer Theorem Would Need to Be FALSE

For the TM logic completeness proof to use bundle semantics, we need the semantic model to be a **bundle** in the sense of Burgess/Zanardo — a set of histories that is "locally like R" and satisfies branching-time properties. The families in `boxClassFamilies` form a bundle, but they are INDEPENDENT histories.

If we could transfer phi from any history to any other history in the bundle, we would be collapsing the bundle into a single history — which would trivialize the semantics. The point of having multiple families is precisely that they can disagree on temporal content.

**More precisely**: the Transfer Theorem `phi ∈ fam'.mcs(s) → exists s' >= s, phi ∈ fam.mcs(s')` would imply that all families are "cofinal in each other" — each formula that holds somewhere in one family holds somewhere in every other family. This is a very strong commutativity condition that does NOT follow from box-class agreement alone.

In fact, consider the TM model with two parallel histories that agree on Box-formulas but where phi is in history 1 at time 0 and NOT in history 2 at any time. This is a valid TM model (satisfying all axioms) and shows that the Transfer Theorem fails semantically.

### 7. Potential Partial Results

Even if the full Transfer Theorem fails, there is a restricted version that works:

**Lemma (G-formula transfer)**: For any `a` with `G(a) ∈ M0`:
```
∀ fam ∈ boxClassFamilies M0 h_mcs, ∀ s : Int, a ∈ fam.mcs(s)
```

**Proof**: G(a) ∈ M0 → G(a) ∈ W (by `omega_chain_forward_G_theory` applied to every step) → ... but this only works for the specific chain from M0, not arbitrary families in the box-class.

Actually this also fails: the family from W may have `neg(G(a))` if W was not built from M0's chain but independently (which is what `boxClassFamilies` allows — ANY W with box_class_agree M0 W).

**The only safe transfer**: Box(phi) → phi at the same time, via `boxClassFamilies_modal_forward`.

---

## Recommended Approach (If History-Unification)

History-Unification in the strong form (Transfer Theorem) is not viable. However, there is a modified formulation:

**Option C' — Weak History-Unification**: Instead of transferring phi to the SAME family, transfer G-formulas from the BASE MCS.

The key observation is that `temporal_theory_witness_exists` gives a witness W for F(phi) from M that inherits ALL G-formulas of M:
```
G_theory(M) ⊆ G_theory(W)
```

This means: if we are working with the Z-chain (omega-enumeration), and F(phi) ∈ Z_chain(t), then the witness W has the same G-obligations as Z_chain(t). Building a chain from W would give a family where:
1. phi ∈ new_fam.mcs(t+1)
2. G(a) ∈ new_fam.mcs(s) for all G(a) ∈ M0 (by G-propagation transitivity)

**This is exactly what `boxClassFamilies_bundle_forward_F` already proves** — it gives phi in a NEW family at time t+1. The problem is that this new family is not the ORIGINAL family fam.

The only way this helps is if we can show that the truth lemma only needs SOME family where phi appears, not the SAME family — which leads to Option B (Bundle-Modified Semantics), not Option C.

---

## Evidence and Examples

### Evidence That Cross-Family Transfer Fails

The `boxClassFamilies_modal_backward` theorem (line 1643) shows the CORRECT scope of cross-family reasoning:
```lean
theorem boxClassFamilies_modal_backward (M0 : Set Formula) ...
    (phi : Formula) (t : Int)
    (h_all : ∀ fam' ∈ boxClassFamilies M0 h_mcs, phi ∈ fam'.mcs t)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs) :
    Formula.box phi ∈ fam.mcs t
```

This shows: if phi is in ALL families at time t, THEN Box(phi) is in any family at time t. The transfer works for Box-strengthened formulas, not for plain phi.

### Code Citations

| Location | What It Shows |
|----------|---------------|
| Line 265 | `box_class_agree` = same Box-formulas only |
| Line 1153–1186 | `temporal_theory_witness_exists` gives G-agreement (one-way) |
| Line 1595–1670 | Only cross-family transfer is for Box(phi) |
| Line 1784–1822 | `boxClassFamilies_temporally_coherent` — SORRY/BLOCKED (family-level) |
| Line 2424–2485 | `Z_chain_forward_F` — SORRY/BLOCKED (same root cause) |
| Line 2536–2555 | Bundle-level coherence uses different families (the actual gap) |

---

## Confidence Level

**HIGH confidence that the strong Transfer Theorem FAILS** and History-Unification (Option C as stated) cannot be proven.

**Reasoning**:
1. The `boxClassFamilies` construction explicitly allows arbitrary W with `box_class_agree M0 W` — no temporal content is constrained
2. The only cross-family lemmas in the codebase transfer modal content (Box(phi))
3. The Transfer Theorem would imply `Z_chain_forward_F` which is a known-blocked sorry
4. Semantically, two linear histories can agree on all Box-formulas while disagreeing on any specific temporal formula phi

---

## Gaps and Open Questions

1. **Can the Transfer Theorem be proven under additional constraints?** For example, if we add the constraint that both fam and fam' share the same G-theory (not just box-class), would transfer work? This might give a weaker completeness result.

2. **Is there a version of the truth lemma that avoids the need for same-family witnesses?** This leads to Option B (bundle semantics), which was identified as requiring "new infrastructure" in report 19. The infrastructure might be a different truth predicate that quantifies over all families simultaneously.

3. **Could the linearity axiom be used to ORDER the witness families**, so that the witness in fam' is "accessible" from fam through a chain of family-transitions? This seems unlikely to work formally but deserves exploration.

4. **The omega-enumeration Z-chain approach**: The real question is whether the Z-chain construction (using dovetailed enumeration) can be shown to resolve ALL F/P-obligations, not just F_top. The sorry at line 2485 (`Z_chain_forward_F`) represents this gap. Proving this would give family-level coherence for the Z-chain, and would be the most direct route to completeness.
