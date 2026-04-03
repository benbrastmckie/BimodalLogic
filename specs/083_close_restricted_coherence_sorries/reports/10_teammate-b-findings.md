# Teammate B Findings: Complete Axiom System and Completeness Strategy Under Fully Strict Semantics

**Task**: 83 - Close Restricted Coherence Sorries
**Focus**: Complete axiom analysis, Until/Since reformulation, completeness strategy for fully strict TM over Z
**Date**: 2026-04-03

## 1. Complete Axiom Analysis Under Fully Strict Semantics

### Target Semantics (Fully Strict)

Under the target fully strict semantics for TM over (Z, <):

- **G phi at t** := for all s > t, phi(s)
- **H phi at t** := for all s < t, phi(s)
- **phi U psi at t** := exists s > t, psi(s) and for all u in (t, s), phi(u)
- **phi S psi at t** := exists s < t, psi(s) and for all u in (s, t), phi(u)

Derived operators:
- **F phi** := neg G neg phi = exists s > t, phi(s)
- **P phi** := neg H neg phi = exists s < t, phi(s)
- **X phi** := bot U phi (on Z: phi(t+1), since (t, t+1) is empty)
- **Y phi** := bot S phi (on Z: phi(t-1), since (t-1, t) is empty)

### Per-Axiom Validity Table

| # | Current Axiom | Formula | Valid Under Strict? | Disposition |
|---|--------------|---------|-------------------|-------------|
| 1 | prop_k | (phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi)) | YES | Keep unchanged |
| 2 | prop_s | phi -> (psi -> phi) | YES | Keep unchanged |
| 3 | ex_falso | bot -> phi | YES | Keep unchanged |
| 4 | peirce | ((phi -> psi) -> phi) -> phi | YES | Keep unchanged |
| 5 | modal_t | Box phi -> phi | YES | Keep unchanged (S5 modal, not temporal) |
| 6 | modal_4 | Box phi -> Box Box phi | YES | Keep unchanged |
| 7 | modal_b | phi -> Box Diamond phi | YES | Keep unchanged |
| 8 | modal_5_collapse | Diamond Box phi -> Box phi | YES | Keep unchanged |
| 9 | modal_k_dist | Box(phi -> psi) -> (Box phi -> Box psi) | YES | Keep unchanged |
| 10 | temp_k_dist | G(phi -> psi) -> (G phi -> G psi) | YES | Keep unchanged (K-distribution valid for any normal modal operator) |
| 11 | temp_4 | G phi -> G G phi | YES | Keep unchanged (transitivity of < gives this) |
| 12 | temp_a | phi -> G P phi | YES on Z | Keep unchanged. Proof: if phi(t), for any s > t, need P phi at s, i.e., exists r < s with phi(r). Take r = t. Since t < s, phi(t) holds. Valid because Z has no right endpoint. |
| 13 | temp_l | always phi -> G(H phi) | YES | Keep unchanged. Under strict semantics, always phi = H phi AND phi AND G phi means phi at ALL times. So for any s > t, H phi at s means for all r < s, phi(r) -- trivially satisfied. |
| 14 | **temp_t_future** | **G phi -> phi** | **NO** | **REMOVE**. Counterexample: G phi at t means for all s > t, phi(s). This says nothing about phi(t). |
| 15 | **temp_t_past** | **H phi -> phi** | **NO** | **REMOVE**. Symmetric argument. |
| 16 | modal_future | Box phi -> Box(G phi) | YES | Keep unchanged. Proof uses time-shift invariance; shifting histories preserves Box truth, and G quantifies over future times. The shift argument works identically for strict G. |
| 17 | temp_future | Box phi -> G(Box phi) | YES | Keep unchanged. Same time-shift argument. |
| 18 | temp_linearity | F phi AND F psi -> F(phi AND psi) OR F(phi AND F psi) OR F(F phi AND psi) | YES | Keep unchanged. Under strict F (exists s > t), the trichotomy s1 < s2 / s1 = s2 / s1 > s2 still works. Witnesses are strictly future in all cases. |
| 19 | density | G G phi -> G phi | ONLY on dense orders | Keep as Dense extension (invalid on Z, valid on Q). Note: under strict semantics this is a genuine frame condition, not trivially valid like under reflexive semantics. |
| 20 | discreteness_forward | (F top AND phi AND H phi) -> F(H phi) | YES on Z | Keep as Discrete extension. Under strict semantics: H phi at t means phi at all s < t. If there is a future (F top), the immediate successor t+1 exists. We need F(H phi), i.e., exists s > t with H phi at s. Take s = t+1. Then H phi at t+1 means for all r < t+1, phi(r). We know phi at all r < t (from H phi at t) and phi at t (from the premise). On Z, r < t+1 iff r <= t. So H phi at t+1 holds. Valid. |
| 21 | seriality_future | G phi -> F phi | YES on Z | Keep as Discrete extension. Requires NoMaxOrder: there exists s > t, so universal implies existential. Under strict semantics this is a genuine axiom (not trivially from T-axiom). |
| 22 | seriality_past | H phi -> P phi | YES on Z | Keep as Discrete extension. Symmetric. |
| 23 | **until_unfold** | **(phi U psi) -> psi OR (phi AND G(phi U psi))** | **NO** | **REPLACE**. See Section 2 below. |
| 24 | **until_intro** | **psi OR (phi AND G(phi U psi)) -> (phi U psi)** | **NO** | **REPLACE**. See Section 2 below. |
| 25 | until_induction | G(psi -> chi) AND G(phi AND chi -> G chi) -> (phi U psi -> chi) | NEEDS ANALYSIS | See Section 2 below. |
| 26 | until_linearity | (phi U psi) AND (phi' U psi') -> ... | YES | Keep unchanged. The witness ordering argument works identically with strict witnesses. |
| 27 | **since_unfold** | **(phi S psi) -> psi OR (phi AND H(phi S psi))** | **NO** | **REPLACE**. Mirror of until_unfold. |
| 28 | **since_intro** | **psi OR (phi AND H(phi S psi)) -> (phi S psi)** | **NO** | **REPLACE**. Mirror of until_intro. |
| 29 | since_induction | H(psi -> chi) AND H(phi AND chi -> H chi) -> (phi S psi -> chi) | NEEDS ANALYSIS | Mirror of until_induction. |
| 30 | since_linearity | (phi S psi) AND (phi' S psi') -> ... | YES | Keep unchanged. |
| 31 | until_connectedness | phi AND (chi U psi) -> chi U (psi AND (chi S phi)) | YES | Keep unchanged. Semantic argument: the witnesses for U and S interact correctly regardless of strict/reflexive. |
| 32 | since_connectedness | phi AND (chi S psi) -> chi S (psi AND (chi U phi)) | YES | Keep unchanged. |
| 33 | **F_until_equiv** | **F psi -> top U psi** | **YES** | Keep unchanged. Under fully strict semantics, F psi = exists s > t, psi(s), and top U psi = exists s > t, psi(s) AND top at all u in (t,s). The top is vacuous. So F psi iff top U psi. |
| 34 | **P_since_equiv** | **P psi -> top S psi** | **YES** | Keep unchanged. Symmetric. |

### New Axioms Needed

| # | Name | Formula | Justification |
|---|------|---------|---------------|
| N1 | temp_a_dual | phi -> H F phi | Present recoverable from future-of-past. On Z: if phi(t), for s < t, need F phi at s, exists r > s with phi(r). Take r = t. Valid. This axiom is the H-direction analog of temp_a. Currently NOT in the axiom system. |
| N2 | until_unfold_strict | (phi U psi) -> X(psi OR (phi AND (phi U psi))) | Discrete unfolding. See Section 2. |
| N3 | until_intro_strict | X(psi OR (phi AND (phi U psi))) -> (phi U psi) | Discrete introduction. See Section 2. |
| N4 | since_unfold_strict | (phi S psi) -> Y(psi OR (phi AND (phi S psi))) | Mirror of N2. |
| N5 | since_intro_strict | Y(psi OR (phi AND (phi S psi))) -> (phi S psi) | Mirror of N3. |
| N6 | disc_next | F top -> X top | Existence of next step. Equivalent to F top -> bot U top (Venema's discreteness axiom). On Z: if there is any future, there is an immediate successor. |
| N7 | disc_prev | P top -> Y top | Mirror: existence of previous step. Equivalent to P top -> bot S top. |

**Note on temp_a_dual**: The current system lacks `phi -> H F phi` because under reflexive semantics it is derivable from `temp_a` plus temporal duality. Under strict semantics, it is an independent axiom needed for past-direction completeness. On Z (no left endpoint), it is valid.

**Note on N6/N7 vs discreteness_forward**: Venema's discreteness axioms `F top -> bot U top` and `P top -> bot S top` are simpler and more standard than the current `discreteness_forward`. Under strict semantics with the X definability, N6 subsumes the need for `discreteness_forward`. However, `discreteness_forward` remains valid and could be kept for backward compatibility.

**Confidence**: HIGH for the validity analysis. MEDIUM for whether the exact set {N1-N7} is both sufficient and non-redundant.

## 2. Until/Since Reformulation Under Fully Strict Semantics

### The Core Problem

Under fully strict Until (`phi U psi at t := exists s > t, psi(s) AND for all u in (t,s), phi(u)`):

1. **`psi -> phi U psi` is INVALID**: phi U psi requires a witness s > t, but psi holding at t does not provide a strictly future witness. Counterexample: psi holds only at t, not at any s > t.

2. **`(phi U psi) -> psi OR (phi AND G(phi U psi))` is INVALID**: Under strict G, `G(phi U psi)` means phi U psi at ALL s > t. But having a witness s0 > t only gives phi U psi at times in [t, s0), not at times > s0.

3. **`psi OR (phi AND G(phi U psi)) -> phi U psi` is INVALID**: Even the introduction direction fails. The first disjunct `psi` does not give phi U psi (no strictly future witness). The second disjunct has G(phi U psi) = for all s > t, phi U psi at s, but this does NOT include phi U psi at t itself (strict G excludes the present).

### The Resolution: X-Based Discrete Unfolding

On discrete orders (Z), the standard approach from the LTL tradition (and implicitly from Venema's discreteness extension) is:

**Discrete Unfold Equivalence**:
```
phi U psi  <->  X(psi) OR X(phi AND (phi U psi))
```

Wait -- this is not quite right either. Let me derive the correct unfolding carefully.

Under strict Until on Z, `phi U psi` at t means: exists s > t with psi(s) and phi at all u in (t, s). The minimal case is s = t+1 (immediate successor). So:

- If s = t+1: psi(t+1) and (t, t+1) is empty, so guard is vacuous.
- If s > t+1: psi(s) and phi at all u with t < u < s. In particular phi(t+1), and phi U psi at t+1 (with same witness s).

This gives the equivalence:
```
phi U psi at t  <->  psi(t+1) OR (phi(t+1) AND (phi U psi)(t+1))
```

Which, using X phi = phi(t+1), is:
```
phi U psi  <->  X psi OR (X phi AND X(phi U psi))
```

Simplifying with X distributing over conjunction (X is a normal modal operator on discrete orders with functional accessibility):
```
phi U psi  <->  X(psi OR (phi AND (phi U psi)))
```

**Semantic verification**:
- Forward: phi U psi at t. Exists s > t with psi(s), phi on (t,s). If s = t+1: psi(t+1), so X(psi OR ...) via psi. If s > t+1: phi(t+1) (from guard) and phi U psi at t+1 (same witness), so X(phi AND phi U psi), hence X(psi OR (phi AND phi U psi)).
- Backward: X(psi OR (phi AND phi U psi)) at t. So at t+1, either psi(t+1) or (phi(t+1) AND phi U psi at t+1). Case 1: psi(t+1), take witness s = t+1, guard (t, t+1) empty. Case 2: phi(t+1) and exists s' > t+1 with psi(s'), phi on (t+1, s'). Take witness s = s'. Guard (t, s) = {t+1} union (t+1, s'). phi(t+1) from premise, phi on (t+1, s') from inner Until. So phi U psi at t. VALID.

**This is the key axiom pair that replaces until_unfold and until_intro.**

### The Circularity Question

Report 09 raised the concern: if X = bot U phi, then writing `phi U psi <-> X(psi OR (phi AND (phi U psi)))` involves `(bot U (psi OR (phi AND (phi U psi))))`, which mentions Until in the "expansion" of Until. Is this circular?

**Answer: No, it is not circular.** The discrete unfold equivalence is a FIXED-POINT CHARACTERIZATION, not a definition. Until is already defined semantically. The axiom states a property that Until satisfies. In the axiom system, Until is a primitive connective with its own semantic clause; the axiom constrains its behavior. This is standard in temporal logic axiomatics -- the Burgess-Xu system similarly has Until appearing on both sides of its axioms.

Furthermore, in the completeness proof, the truth lemma proceeds by structural induction on formula complexity. `phi U psi` has complexity 1 + max(|phi|, |psi|). The subformula `psi OR (phi AND (phi U psi))` in the axiom is not structurally simpler, but the X-based formulation gives a TEMPORAL induction handle: truth at t reduces to truth at t+1, enabling backward induction along the integer chain.

### Induction Axiom for Until

The current `until_induction` axiom is:
```
G(psi -> chi) AND G(phi AND chi -> G chi) -> (phi U psi -> chi)
```

Under strict G, this becomes: for all s > t, (psi(s) -> chi(s)) and for all s > t, (phi(s) AND chi(s) -> for all r > s, chi(r)). This means: (1) wherever psi holds (strictly future), chi holds; (2) if phi AND chi hold at a strictly future time, then chi propagates to all further future times.

**Validity check**: Suppose phi U psi at t with witness s0 > t. We need chi at t. But the premises only give information about strictly future times s > t. At t itself, we have no information. The premises do NOT imply chi(t).

Wait -- the axiom says `phi U psi -> chi`, meaning chi at t. But the premises are about strictly future times. Under strict semantics, there is a gap: we know chi propagates from the witness backward (via the second premise), but only down to times strictly after t, not to t itself.

**Under strict G, the induction axiom as stated is INVALID.**

Counterexample: Let phi = top, psi = p (some atom), chi = p. G(p -> p) is trivially valid. G(top AND p -> G p) requires that wherever p holds in the strict future, p continues to hold. Now consider: p holds only at t+1. Then top U p holds at t (witness t+1). But chi = p does not hold at t. The premises are satisfied (vacuously for the second one since p AND G p never holds). Yet top U p at t does not imply p at t. So the axiom is invalid.

**Reformulated induction axiom for strict discrete semantics**:

The standard LTL induction axiom is:
```
If |- (psi OR (phi AND X theta)) -> theta, then |- phi U psi -> theta
```

As a Hilbert-style axiom schema:
```
G((psi OR (phi AND theta)) -> theta) -> (phi U psi -> G theta)
```

Alternatively, the proper induction principle for strict Until over Z uses X:

```
(psi -> chi) AND (phi AND chi -> X chi) -> (X(phi U psi) -> chi)
```

This says: if psi implies chi, and phi AND chi implies chi at the next step, then from (phi U psi) holding at t+1, chi holds at t+1 (... actually this needs more careful formulation).

The cleanest approach from the literature is the **least fixed point** characterization:

```
phi U psi is the LEAST formula theta satisfying: X(psi OR (phi AND theta)) -> theta
```

As an axiom:
```
G(X(psi OR (phi AND chi)) -> chi) -> (phi U psi -> chi)
```

**Semantic verification**: Suppose phi U psi at t. We have G(X(psi OR (phi AND chi)) -> chi), meaning for all s > t, if at s+1 either psi or (phi AND chi), then chi at s. Actually this is getting complicated.

Let me step back and use the standard approach. The proper axiom system for strict discrete Until uses:

1. **Expansion**: `phi U psi <-> X(psi OR (phi AND (phi U psi)))` (axiom pair N2+N3)
2. **Induction**: `phi U psi -> chi` is derivable whenever `psi -> chi` and `phi AND chi -> X chi` are derivable (as a derivation rule, not an axiom schema)

As an axiom schema, the induction becomes:
```
G(psi -> chi) AND G(phi AND X chi -> chi) -> G(phi U psi -> chi)
```

But this quantifies everything under G (strictly future). For the version that includes the present, one adds the present case explicitly. On Z with strict semantics, the proper formulation is:

```
(psi -> chi) AND (phi AND X chi -> chi) -> (phi U psi -> chi)
```

**This needs to be the POINTWISE version**: at any time t, if the two premises hold at t, and phi U psi holds at t, then chi holds at t. But Under strict Until, phi U psi at t gives a witness s > t, and we need to propagate chi backward from s to t. The first premise gives chi at s (since psi at s). The second premise at s-1: if phi(s-1) AND X chi at s-1 = chi(s), then chi(s-1). But we need the second premise to hold at s-1, which requires it to be globally true.

The correct axiom is:
```
always(psi -> chi) AND always(phi AND X chi -> chi) -> always(phi U psi -> chi)
```

Where `always` = H AND id AND G. But this is overly strong. The standard approach:

```
G(psi -> chi) AND G(phi AND X chi -> chi) -> G(phi U psi -> chi)
```

combined with

```
H(psi -> chi) AND H(phi AND X chi -> chi) -> H(phi U psi -> chi)
```

**My best assessment**: The current `until_induction` axiom needs reformulation for strict semantics. The X-based version replaces the inner G with X:

**Strict Until Induction (proposed)**:
```
(psi -> chi) AND (phi AND X(chi) -> chi) -> (phi U psi -> chi)
```

**Validity**: phi U psi at t, witness s > t. psi(s) implies chi(s) by first premise. For r from s-1 down to t+1: phi(r) (from guard) and X(chi)(r) = chi(r+1). By second premise, chi(r). At t+1: phi(t+1) (from guard, since t+1 in (t,s) when s > t+1; or s = t+1 in which case we already have chi(s) = chi(t+1)).

Wait, what happens at t itself? phi U psi says nothing about phi(t) or chi(t). The witness is strictly future. So chi propagates back to t+1 but NOT to t.

So the axiom should be: `phi U psi -> X chi`, not `phi U psi -> chi`.

Hmm, but the Burgess-Xu induction says `phi U psi -> chi` where chi holds AT THE PRESENT TIME. Under strict Until, the information is about the future, not the present.

**Resolution**: Under strict semantics, the induction axiom for Until provides information about the FUTURE, not the present. The correct statement is:

```
G(psi -> chi) AND G(phi AND X chi -> chi) -> (phi U psi -> X chi)
```

This says: if at all future times psi implies chi, and at all future times phi AND (chi at next step) implies chi, then phi U psi implies chi at the next step (t+1). The backward propagation from witness to t+1 works as above.

**Alternative**: Keep the Burgess-Xu form but understand that under strict Until, `phi U psi -> chi` tells us about chi relative to the Until's witness structure:

Actually, I think the simplest correct formulation for the fully strict case on Z is:

```
G(psi -> chi) AND G(phi AND chi -> X chi) -> (phi U psi -> X chi)
```

But I have low confidence in the exact formulation. The literature (Venema 1993, Burgess 1982) gives the definitive answer. The key point is:

**The induction axiom MUST be reformulated for strict semantics.** The G-based formulation from Burgess-Xu uses reflexive G. For strict G on discrete orders, the X-based approach is cleaner and standard in the LTL tradition.

**Confidence**: HIGH that reformulation is needed. MEDIUM on the exact statement.

## 3. Completeness Strategy Under Fully Strict Semantics

### Overview of Required Changes

The completeness proof for TM over Z currently follows this architecture:

1. **Start with target formula phi_0 unprovable**
2. **Build MCS M_0 containing neg phi_0** (Lindenbaum)
3. **Extend M_0 to a dovetailed chain of MCS indexed by Z** (DovetailedChain.lean)
4. **Build bundle of FMCS** (CanonicalConstruction.lean)
5. **Prove truth lemma**: phi in mcs(t) iff phi true at t in canonical model
6. **Extract model where phi_0 fails** (completeness)

### Changes to FMCS Structure

Currently, FMCS requires:
```
forward_G : forall t t' phi, t <= t' -> G phi in mcs(t) -> phi in mcs(t')
backward_H : forall t t' phi, t' <= t -> H phi in mcs(t) -> phi in mcs(t')
```

Under strict semantics, these become:
```
forward_G : forall t t' phi, t < t' -> G phi in mcs(t) -> phi in mcs(t')
backward_H : forall t t' phi, t' < t -> H phi in mcs(t) -> phi in mcs(t')
```

**Key difference**: The reflexive case (t = t') is NO LONGER required. This means `G phi in mcs(t)` does NOT imply `phi in mcs(t)`. The T-axiom base case vanishes.

### Changes to Dovetailed Chain Construction

The DovetailedChain uses `temporal_theory_witness_exists` to extend MCS chains. The key change:

- **forward_G propagation**: Currently uses `le_trans` (reflexive). Under strict, uses `lt_trans`. The step from M_n to M_{n+1} gives `g_content(M_n) subset M_{n+1}`, which means for all phi, G phi in M_n implies phi in M_{n+1}. For t' > t+1, chain forward via transitivity of <.

- **The T-axiom usage in forward_G**: Currently the chain proves `forward_G t t phi (le_refl t)` using the T-axiom in MCS. This case VANISHES under strict semantics (we never need t < t for strict forward_G). This is a SIMPLIFICATION.

- **F-obligation resolution**: The dovetailed chain resolves F(phi) in M_n by ensuring phi appears in some M_{n+k}. Under strict F = neg G neg, this means exists s > t with phi in mcs(s). The current mechanism works unchanged for strict semantics.

### Changes to Truth Lemma

The truth lemma is the heart of completeness. Under strict semantics:

#### G/H Cases (EASIER)

**Forward direction (G phi in mcs(t) implies G phi true at t)**:
- Need: for all s > t, phi true at s.
- By forward_G: G phi in mcs(t) implies phi in mcs(s) for s > t.
- By IH: phi in mcs(s) implies phi true at s.
- Done. NO base case needed (no t = t case).

**Backward direction (G phi true at t implies G phi in mcs(t))**:
- Contrapositive: neg G phi in mcs(t), i.e., F(neg phi) in mcs(t).
- By forward_F coherence: exists s > t with neg phi in mcs(s).
- By IH: neg phi true at s, so phi false at s.
- So exists s > t where phi is false, hence G phi is false at t. Done.

This is SIMPLER than the reflexive case, which required additionally proving the t = t base case using the T-axiom.

#### Until/Since Cases (THE KEY IMPROVEMENT)

Under strict semantics with the discrete unfold axiom `phi U psi <-> X(psi OR (phi AND (phi U psi)))`:

**Forward direction (phi U psi in mcs(t) implies phi U psi true at t)**:
- phi U psi in mcs(t).
- By unfold axiom in MCS: X(psi OR (phi AND (phi U psi))) in mcs(t).
- X is definable: bot U (psi OR (phi AND (phi U psi))) in mcs(t).
- On Z-indexed chain: this means at t+1, either psi or (phi AND phi U psi).
- Case 1: psi in mcs(t+1). By IH, psi true at t+1. Witness s = t+1, guard (t, t+1) empty. Done.
- Case 2: phi AND phi U psi in mcs(t+1). By IH, phi true at t+1 and phi U psi true at t+1. Semantic unfolding of phi U psi true at t+1: exists s > t+1, psi(s), phi on (t+1, s). Then phi U psi at t: witness s, psi(s), phi on (t, s) = phi at t+1 (from IH on phi) plus phi on (t+1, s) (from inner semantic Until). Done.

**Backward direction (phi U psi true at t implies phi U psi in mcs(t))**:
- phi U psi true at t: exists s > t with psi(s), phi on (t, s).
- Need phi U psi in mcs(t).
- On Z, s = t + k for some k >= 1. Proceed by induction on k.
  - Base case k = 1: psi true at t+1, guard (t, t+1) empty. By IH, psi in mcs(t+1). So mcs(t+1) contains psi, hence psi OR (phi AND phi U psi). By X-properties of the chain, X(psi OR ...) in mcs(t), i.e., phi U psi in mcs(t) by intro axiom.
  - Induction step k > 1: psi true at t+k, phi on (t, t+k). In particular, phi true at t+1 and phi U psi true at t+1 (with witness t+k). By IH (on k-1), phi U psi in mcs(t+1). By IH (structural, on phi), phi in mcs(t+1). So phi AND phi U psi in mcs(t+1), hence psi OR (phi AND phi U psi) in mcs(t+1). By X-intro, phi U psi in mcs(t).

**This is the backward truth lemma that was previously blocked!** The X-based axiom converts the infinite-quantifier problem (G-based) into a finite single-step induction (X-based). The induction on k = s - t is well-founded on Nat.

### The Canonical Frame Irreflexivity Issue

Under reflexive semantics, `ExistsTask M M` (the canonical accessibility is reflexive) follows from the T-axiom. Under strict semantics, the canonical frame's temporal relation is IRREFLEXIVE: M at time t relates to M' at time t' only when t < t' (or t > t' for the backward direction). There is no self-relation.

This is NOT a problem for the completeness proof because:
1. The FMCS construction indexes MCS by Z, and Z with < is irreflexive.
2. The truth lemma never needs the t = t case for strict temporal operators.
3. The canonical accessibility for the MODAL operator (Box) remains reflexive (S5 modal part is unchanged).

The previous concern about irreflexivity was about the INTERPLAY between temporal irreflexivity and modal reflexivity. In the TM framework:
- **Temporal relation**: indexed by Z with <, irreflexive by construction.
- **Modal relation**: full accessibility within the Omega set (shift-closed histories), reflexive by construction.
- These are ORTHOGONAL. The temporal irreflexivity does not affect modal reflexivity.

### The IRR Rule Question

The project previously used an IRR (Irreflexivity) rule in `Derivation.lean`. Under strict semantics, the IRR rule becomes more naturally motivated: it enforces that the temporal relation excludes self-loops.

However, the Venema approach avoids the IRR rule for discrete orders entirely. The discreteness axioms (F top -> X top, P top -> Y top) combined with seriality (F top, P top) give the necessary structural properties. The canonical model construction on Z inherently has irreflexive temporal order.

**The IRR rule may still be needed for the dense case (completeness over Q)**, but for discrete completeness over Z, the axiom system N1-N7 plus the Burgess-Xu core should suffice WITHOUT the IRR rule.

**Confidence**: HIGH.

## 4. Always Operator Analysis Under Strict Semantics

### Current Definition

```lean
def always (phi : Formula) : Formula := phi.all_past.and (phi.and phi.all_future)
-- Encoding: H phi AND phi AND G phi
```

### Behavior Under Strict Semantics

Under strict G and H:
- `G phi at t` := for all s > t, phi(s) -- does NOT include t
- `H phi at t` := for all s < t, phi(s) -- does NOT include t
- `always phi at t` = H phi at t AND phi at t AND G phi at t
  = for all s < t, phi(s) AND phi(t) AND for all s > t, phi(s)
  = phi at ALL times (past, present, and future)

**Key point**: Under strict semantics, `H phi AND G phi` does NOT imply phi. You could have phi at all times except t, and H phi AND G phi would still hold at t. The three-part conjunction `H phi AND phi AND G phi` is ESSENTIAL.

### Impact on temp_l Axiom

The axiom `temp_l`: `always phi -> G(H phi)`.

Under strict semantics:
- Premise: H phi AND phi AND G phi at t = phi at all times.
- Conclusion: G(H phi) at t = for all s > t, for all r < s, phi(r).
- Since phi holds at all times, for any s > t and r < s, phi(r). VALID.

The proof is unchanged (it uses only the fact that the premise gives phi everywhere).

### Impact on Proof System

Theorems about `always` need to account for the three-part structure. Under reflexive semantics, `always phi <-> H phi AND G phi` (the middle conjunct is redundant because G phi implies phi via T-axiom). Under strict semantics, `always phi` genuinely requires all three parts.

In the proof system:
- `G phi AND H phi -> always phi` is INVALID under strict semantics (missing the present).
- `always phi -> G phi AND H phi AND phi` is VALID.
- `G phi AND H phi AND phi -> always phi` is VALID.

Derived theorems in `Perpetuity/` may need updates if they relied on `G phi -> phi` to extract the present from `always`.

**Confidence**: HIGH.

## 5. Literature Completeness Results for S5 + Strict Temporal over Z

### Known Results

1. **Temporal logic of (Z, <) with Since and Until**: Complete axiomatization exists (Burgess 1982, Xu 1988, Venema 1993). The base Burgess-Xu system axiomatizes all reflexive linear orders. Venema's extension adds `F top -> bot U top` and `P top -> bot S top` for discrete orders, plus `F top` for the natural numbers. For Z (integers), one adds `F top` AND `P top` (seriality in both directions).

2. **S5 modal logic**: Complete axiomatization is well-known (K + T + 4 + B, or K + T + 5).

3. **Combining S5 with temporal logic**: The combination is known as a FUSION of two modal logics. For fusions, the Transfer Theorem (Fine-Schurz, Kracht-Wolter) guarantees: if L1 and L2 are complete modal logics, then their fusion L1 * L2 is complete with respect to the product of their frame classes, PROVIDED certain technical conditions are met.

### Applicability to TM

TM is NOT a simple fusion: the modal and temporal operators interact via the bridge axioms MF (`Box phi -> Box G phi`) and TF (`Box phi -> G Box phi`). These express that the S5 accessibility relation is "uniform across time" (time-shift invariance).

**The combination with bridge axioms requires additional care.** The transfer theorem for fusions applies to NON-INTERACTING logics. With MF and TF, we have interaction.

However, the TM logic is designed for a specific semantic setting: task frames where the S5 worlds are time-shift-invariant histories over Z. The completeness proof builds canonical models from MCS by:
1. Building temporal chains (FMCS) for each S5 world.
2. Linking S5 worlds via the Box/Diamond accessibility (BFMCS).
3. Ensuring MF and TF hold in the canonical model via the shift-closure property.

The bridge axioms MF and TF are sound because of time-shift invariance. In the canonical model, the Omega set (shift-closed set of histories) provides the modal accessibility, and time-shift closure ensures MF and TF hold.

**This completeness strategy is NOT affected by the strict/reflexive choice for temporal operators.** The S5 modal part is orthogonal. The bridge axioms MF and TF hold under both strict and reflexive temporal semantics (the soundness proofs use time-shift invariance, which works identically).

### Is S5 + Strict Temporal over Z Known to Be Complete?

**Yes, essentially.** The general framework of Gabbay-Hodkinson-Reynolds (1994) covers temporal logics with Since/Until over Z. Adding S5 modality with bridge axioms is a standard extension. The key requirement is that the combined axiom system is:
1. Complete for the temporal fragment (Burgess-Xu + Venema for Z).
2. Complete for the modal fragment (S5).
3. The bridge axioms are sound and canonical (they hold in the canonical model construction).

The specific combination in TM has not been published as a theorem in the literature (it is specific to this project's "perpetuity calculus" framework). But the general methodology is well-established and each component is known to work.

**Confidence**: HIGH that the combined system is complete. MEDIUM that all axioms are exactly right (the bridge axioms and their interaction with strict Until may have subtle issues not caught by the above analysis).

## 6. Summary of Proposed Axiom System for Fully Strict TM over Z

### Propositional Logic (4 axioms, unchanged)
1. prop_k: `(phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))`
2. prop_s: `phi -> (psi -> phi)`
3. ex_falso: `bot -> phi`
4. peirce: `((phi -> psi) -> phi) -> phi`

### S5 Modal Logic (5 axioms, unchanged)
5. modal_t: `Box phi -> phi`
6. modal_4: `Box phi -> Box Box phi`
7. modal_b: `phi -> Box Diamond phi`
8. modal_5_collapse: `Diamond Box phi -> Box phi`
9. modal_k_dist: `Box(phi -> psi) -> (Box phi -> Box psi)`

### Strict Temporal Base (6 axioms)
10. temp_k_dist: `G(phi -> psi) -> (G phi -> G psi)`
11. temp_4: `G phi -> G G phi`
12. temp_a: `phi -> G P phi` (present recoverable from past-of-future)
13. **temp_a_dual**: `phi -> H F phi` (present recoverable from future-of-past) -- NEW
14. temp_l: `always phi -> G(H phi)`
15. temp_linearity: `F phi AND F psi -> F(phi AND psi) OR F(phi AND F psi) OR F(F phi AND psi)`

### Modal-Temporal Interaction (2 axioms, unchanged)
16. modal_future: `Box phi -> Box(G phi)`
17. temp_future: `Box phi -> G(Box phi)`

### Discrete Temporal Axioms (2 axioms, revised)
18. seriality_future: `G phi -> F phi` (equivalently: `F top`)
19. seriality_past: `H phi -> P phi` (equivalently: `P top`)

### Since/Until Core (revised, 10 axioms)
20. **until_unfold_strict**: `phi U psi -> X(psi OR (phi AND (phi U psi)))` -- NEW (replaces until_unfold)
21. **until_intro_strict**: `X(psi OR (phi AND (phi U psi))) -> phi U psi` -- NEW (replaces until_intro)
22. **until_induction_strict**: reformulated with X (see Section 2) -- REPLACES until_induction
23. until_linearity: `(phi U psi) AND (phi' U psi') -> ...` (unchanged)
24. **since_unfold_strict**: `phi S psi -> Y(psi OR (phi AND (phi S psi)))` -- NEW
25. **since_intro_strict**: `Y(psi OR (phi AND (phi S psi))) -> phi S psi` -- NEW
26. **since_induction_strict**: reformulated with Y -- REPLACES since_induction
27. since_linearity: unchanged
28. until_connectedness: unchanged
29. since_connectedness: unchanged

### F/P-Until/Since Bridges (2 axioms, unchanged)
30. F_until_equiv: `F psi -> top U psi`
31. P_since_equiv: `P psi -> top S psi`

### Discreteness (2 axioms, Venema's extension)
32. **disc_next**: `F top -> bot U top` (X top on Z) -- NEW or subsumes discreteness_forward
33. **disc_prev**: `P top -> bot S top` (Y top on Z) -- NEW

### Inference Rules (4 rules)
- Modus Ponens
- Necessitation (Box): from phi, derive Box phi
- Temporal Necessitation (G): from phi, derive G phi
- Temporal Duality: from phi, derive swap_temporal(phi) (gives H-necessitation)

### Axioms REMOVED (from current system)
- temp_t_future (`G phi -> phi`) -- invalid under strict G
- temp_t_past (`H phi -> phi`) -- invalid under strict H
- until_unfold (old G-based version) -- invalid under strict G
- until_intro (old G-based version) -- invalid (psi does not imply phi U psi under strict)
- until_induction (old G-based version) -- invalid under strict G
- since_unfold, since_intro, since_induction (old versions) -- mirrors of above
- density -- kept only as Dense extension, irrelevant for Z

### Total Count
- Current system: ~34 axioms (base + discrete)
- Proposed system: ~33 axioms (base + discrete, minus T-axioms, plus temp_a_dual and disc axioms)

## 7. Confidence Levels

| Finding | Confidence |
|---------|------------|
| T-axioms (temp_t_future, temp_t_past) invalid under strict | HIGH (trivial counterexample) |
| Propositional + S5 modal axioms unchanged | HIGH |
| temp_k_dist, temp_4, temp_a valid under strict | HIGH |
| temp_a_dual needed as new axiom | HIGH |
| temp_l, modal_future, temp_future valid under strict | HIGH |
| temp_linearity valid under strict | HIGH |
| until_unfold/until_intro invalid under strict G | HIGH |
| X-based discrete unfold correct replacement | HIGH (verified semantically) |
| until_induction needs reformulation | HIGH |
| Exact formulation of strict until_induction | MEDIUM (needs literature verification) |
| Linearity and connectedness axioms valid under strict | HIGH |
| Discreteness axioms (Venema's F top -> bot U top) correct | HIGH (standard in literature) |
| Seriality axioms correct for Z | HIGH |
| Backward truth lemma solvable via discrete induction on k | HIGH (the key insight) |
| Forward truth lemma for G/H simpler under strict | HIGH |
| No IRR rule needed for discrete completeness | HIGH |
| S5 + strict temporal over Z complete | HIGH (general methodology established) |
| Exact axiom set sufficient and non-redundant | MEDIUM |

## 8. Key References

### Primary Sources
- Burgess, J.P. (1982). "Axioms for tense logic I: Since and Until." Notre Dame Journal of Formal Logic 23(4), pp. 367-374.
- Xu, M. (1988). Simplification of Burgess's axiomatization.
- Venema, Y. (1993). "Completeness via Completeness: Since and Until." In Diamonds and Defaults, Synthese Library vol. 229.
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). Temporal Logic: Mathematical Foundations and Computational Aspects. Vol. 1. Oxford University Press.

### Secondary Sources
- [SEP Supplement: Burgess-Xu Axiomatic System](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html)
- [SEP: Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Venema, Y. "Temporal Logic" (chapter)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- Blackburn, P., de Rijke, M., Venema, Y. (2001). Modal Logic. Cambridge University Press. Chapter 7 (Since and Until).
- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Lecture Notes.

### Codebase References
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- current axiom system (34 axioms)
- `Theories/Bimodal/Semantics/Truth.lean:118-129` -- current semantics (reflexive G/H, half-open U/S)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- current soundness proofs
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- dovetailed chain construction
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean:99-119` -- FMCS structure with forward_G/backward_H
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` -- T-axiom-based reflexivity (would be removed)
