# Teammate A: Primary Literature Analysis
## Techniques for Base TM and Chronicle Construction

**Date**: 2026-04-27
**Task**: 113 — Literature review: completeness techniques

---

## Executive Summary

Three papers were analyzed against the current BX completeness proof state (12 sorry sites across Chronicle and ChronicleToCountermodel). The most immediately actionable finding is that **Xu 1988 Section 2 directly supplies the missing g-construction** for the c2' sorry sites in `CounterexampleElimination.lean`. The key insight from Xu's proof of Lemma 2.4 is that when inserting a new point with its MCS, the g-function for new adjacent pairs can be **constructed via the DCS obtained during the bridging step** — specifically, the B' from Xu's 2.4 becomes g(x, new_z) and B'' becomes g(new_z, y). Reynolds 1992 confirms this approach applies to dense linear time and is equivalent to the BX completeness technique already in use. Caleiro et al. 2013 is not directly applicable to the critical path.

---

## Key Findings

### Finding 1: Xu 1988 Section 2 — The Missing g-Construction for c2' Sorrys

**Location**: Xu 1988, Lemma 2.4 (pp. 94–96) and Definitions 2.5–2.7.

The codebase has 6 `c2' := sorry` sites in `CounterexampleElimination.lean` (lines 786, 824, 864, 902, 938, 970) and 1 additional sorry at line 1086. All of these are in `eliminate_potential_counterexample` and require: when inserting a new point z into the chronicle domain, specifying what g(old_x, z) and g(z, old_y) should be for the new adjacent pairs.

**Xu's answer** (from Lemma 2.4 + the proof of Theorem 2.8):

When inserting a new point z between x and y to eliminate a counterexample:
1. Apply Lemma 2.4 to `A = f(x)`, `B = g(x,y)`, `C = f(y)` to obtain B', D, B'' satisfying:
   - `R(A, B', D)` (BurgessR3Maximal for the pair (x, z))
   - `R(D, B'', C)` (BurgessR3Maximal for the pair (z, y))
   - `B ∪ {¬β} ⊆ D` (the new MCS at z contains ¬γ)
2. Set `g(x, z) = B'` and `g(z, y) = B''`.

The codebase's `eliminate_C4_counterexample` already correctly finds D (the new MCS for z) via `dcs_neg_insert_consistent` + `set_lindenbaum`. The **missing step** is that the same Lemma 2.4 application also yields B' and B'' simultaneously — these become the new g-values. The current code extracts only D but discards B' and B''.

**C4/C4' hard case specifically** (Xu Lemma 2.4 with the b ∉ B* branch):
- The code finds w_max (the rightmost point with neg_until) and w_next (its successor).
- It calls `h_c2' w w_next h_adj` to get `h_r3_wn : burgessR3 (f w) (g w w_next) (f w_next)`.
- It constructs D with ¬γ via `set_lindenbaum`.
- **What is missing**: D was obtained by extending B* = g(w, w_next), so `g(w, w_next) ⊆ D`. Xu's 2.3(i) guarantees `S(α, ⊤) ∈ B'` for every α ∈ A — i.e., r(A, B', D) holds. The code can define `g(x_new_left, z) := g(w, w_next)` extended appropriately, and `g(z, y) := B*`  (the DCS from the Lindenbaum extension step).

**For C5/C5' sorrys** (lines 786, 824): The C5 insertion adds a new rightmost or leftmost point with an MCS witnessing the U/S eventuality. In this case, the new adjacent pair is `(last_dom_point, new_z)` (for C5) or `(new_z, first_dom_point)` (for C5'). The g-value for this pair can be constructed directly: by Xu's Lemma 2.2 (the Burgess construction for U(γ,β) ∈ A), the construction yields B and C such that R(A, B, C), γ ∈ C and β ∈ B. Set `g(x, new_z) := B` and `f(new_z) := C`.

### Finding 2: Xu 1988 — Base Case (Phase 1) G/H Propagation

**Location**: Xu 1988, Section 2, Lemma 2.3 and C1–C4 of Definition 2.5.

Xu handles G/H propagation through the `r3Relation` (his `r(A, B, C)`) structure:
- His C3 (p. 103): `∀t,t' ∈ T with t < t', g(t, t') ⊆ f(t'')` for every t'' in dom strictly between t and t'. This is exactly the codebase's `c3` condition.
- His Lemma 2.3: `R(A, B, C)` implies `S(α, ⊤) ∈ B` for every α ∈ A (and dually U(γ,⊤) ∈ B for every γ ∈ C). These ensure that the interval function B "sees" both its endpoints, supporting G-propagation.
- G-propagation in the TM base case (G over boolean operators): if G(α) ∈ f(x) and x < y, then α ∈ g(x,y) (by r-relation: U(γ,α) ∈ A implies β ∈ B), and by c3, g(x,y) ⊆ f(y). This gives α ∈ f(y). This argument is **already proven sorry-free** in the codebase (`limit_forward_G`).

**Assessment**: No new work needed for Phase 1 base case. The codebase's approach matches Xu Section 2 exactly, and the sorry-free `limit_forward_G` already handles G/H propagation.

### Finding 3: Reynolds 1992 — Structure of the Forward Until Coherence Sorry

**Location**: Reynolds 1992, Section 4 (Burgess-Xu result outline) and Section 5–6 (Prior and density).

**Critical finding for the 2 sorry sites in `cantor_bfmcs_restricted_fuc`**:

Reynolds (Section 4, pp. 193–195) gives the clearest articulation of why the guard at intermediate points requires C3:

> "if we define a valuation on the order of sets by M ⊨ p(Γ) iff p ∈ Γ, then the flow of time consisting of those sets becomes a structure M satisfying, for all Γ ∈ M, for all A ∈ Γ, M ⊨ A(Γ) iff A ∈ Γ"

The "for all A" includes the guard formula φ in U(φ,ψ). In Reynolds's construction, the guard holds at all intermediate points **by the definition of the r-relation and the C3 property**: g(x,z) ⊆ f(y) for x < y < z, so if φ ∈ g(x,z), then φ ∈ f(y) for all y strictly between x and z.

**Direct implication for `cantor_bfmcs_restricted_fuc`**: The blocker comment (line 611–614) says "C5_weak gives the endpoint ψ ∈ f(y), but the guard φ ∈ f(r) for intermediate r requires the real interval function g with C3." Reynolds confirms: this C3-based argument is the **standard approach** and is not avoidable with canonical-model techniques. The `cantor_bfmcs_restricted_fuc` sorry is correctly identified as requiring limit_g with C3 property.

However, Reynolds's proof (Theorem 1 + Corollary 1) suggests an alternative: construct the rational-flowed model first (using Burgess-Xu completeness for linear frames), verify it satisfies all Prior/Sep axioms, **then apply Doets' theorem** to get a real-flowed model. In the context of the BX proof (not the reals proof), this reduces to: once C4/C4'/C5/C5' conditions all hold at the limit (in the ω-construction), the Truth Lemma holds — including for U with guard — **at the limit** rather than at each finite stage. The key point: `limit_satisfies_c5_full` (mentioned in the blocker comment) would follow from C5 being verified in the limit chronicle, which is established by the elimination process.

**Actionable path**: The `cantor_bfmcs_restricted_fuc` sorry requires showing that the limit chronicle's C5 condition (with guard) is preserved when applying the Cantor isomorphism. The code currently only uses C5_weak (endpoint). The full C5 with guard follows from limit_c3 (which is sorry-free, `ChronicleConstruction.lean` line 860) together with limit_satisfies_c5. The argument: if U(φ,ψ) ∈ f(t) in the limit, then by C5 there exists s > t with ψ ∈ f(s) and φ ∈ f(r) for all r strictly between t and s — and this φ ∈ f(r) follows from C3: g(t,s) ⊆ f(r), and φ ∈ g(t,s) by the r-relation.

### Finding 4: Reynolds 1992 — IRR-Free Technique

**Location**: Reynolds 1992, Section 3 (IRR discussion), pp. 187–188.

Reynolds explicitly notes that IRR is not needed when using the Burgess-Xu construction for the base (linear frames) case. The IRR rule was used in Gabbay-Hodkinson to give unique names to points (for U/S expressibility). Reynolds avoids this by using Prior-U and Prior-S axioms instead of names.

**Relevance to BX proof**: The BX proof already uses an IRR-free approach (orthodox rules only). Reynolds confirms this is the right choice. No new technique here, but strong confirmation that the current approach is principled.

### Finding 5: Caleiro-Viganò-Volpe 2013 — Mosaic Method Assessment

**Location**: Caleiro et al., Section 4.1 (Completeness of Hilbert-style axiomatization).

The mosaic method provides a **completely different completeness architecture**: instead of Henkin-style MCS construction + point insertion, it defines mosaics (pairs of consistent formula sets) satisfying coherence conditions, builds a saturated set of mosaics, then constructs a model by composing mosaics.

**For the base TM case (S5 + linear tense without interactions)**:
The relevant case is their `L(C, ())` — linear tense + S5 modal with no interaction — handled in Section 3.2 (Theorem 3.13) and Section 4.1. The Hilbert-style completeness proof in Section 4.1 reduces to: Γ is unsatisfiable iff there is no C-D-structure of mosaics for Γ.

The mosaic method handles S5+temporal by maintaining **separate** vertical mosaics (temporal, V1–V4) and horizontal mosaics (modal, H1). State formulas (including ∀A) provide the linking condition. This cleanly separates the S5 reasoning (horizontal) from the temporal reasoning (vertical).

**Assessment for applicability**: The mosaic method is architecturally incompatible with the current chronicle-based proof. Integrating it would require a complete redesign. However, one specific technique from Caleiro et al. could be extracted: their **coherence condition V3** (`GA ∈ Γ → GA ∈ Δ` for vertical mosaic (Γ,Δ)) is exactly the G-propagation preservation. This matches the codebase's `forward_G` condition in FMCS and is confirmed as the correct formulation.

**For the Box (S5) part**: Caleiro et al.'s horizontal saturation condition SH1 (`∃A ∈ Ω → ∃Γ ∈ Points(S), (Ω,Γ) ∈ SH and A ∈ Γ`) corresponds to what the BFMCS construction achieves via modal coherence. The current BFMCS approach (sorry-free) already handles this correctly.

**Confidence**: Medium. The mosaic method confirms the correctness of the current architecture but offers no shortcuts to the specific sorry sites.

---

## Recommended Approach

### Priority 1: Close the 6 c2' sorry sites in CounterexampleElimination.lean

**Action**: Modify `eliminate_potential_counterexample` to extract B' and B'' from the Lindenbaum extension step (following Xu's Lemma 2.4) and use them as the g-values for new adjacent pairs.

Concretely:
- In the C5 case (line 786): `eliminate_C5_counterexample` returns a new MCS C (as `f(z_new)`). By Xu's Lemma 2.2, the same application that produced C also produced B satisfying `R(f(x), B, C)`. The `c2'` condition for the new pair `(x, z_new)` requires `SetDeductivelyClosed (g(x, z_new)) ∧ burgessR3 (f x) (g x z_new) (f z_new)`. Setting `g(x, z_new) := B` satisfies this. **The current code does not store B** — the fix is to change `eliminate_C5_counterexample` to also return the B satisfying the BurgessR3 condition.
- In the C4 case (line 864): After finding D (new MCS at z), D was constructed as a superset of B* = g(w, w_next). Set `g(w, z) := g(w, w_next)` (the original DCS) and `g(z, w_next) := g(w, w_next)` (same DCS, since B* ⊆ D satisfies the needed condition). Alternatively, use Xu's Lemma 2.4: B' from the application satisfies `R(f(w), B', D)` and B'' satisfies `R(D, B'', f(w_next))`.

### Priority 2: Close cantor_bfmcs_restricted_fuc (2 sorry sites)

**Action**: Show that the limit chronicle's C5 with guard follows from `limit_c3` + the limit C5 (endpoint) already established.

The path:
1. From `limit_satisfies_c5_weak` (sorry-free): U(φ,ψ) ∈ f(t) → ∃ s > t, ψ ∈ f(s).
2. From `limit_c3` (sorry-free): ∀ x < y < z in dom, g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z).
3. By the r-relation: r(f(t), g(t,s), f(s)) holds (from limit_c2 or limit_c2').
4. By Xu's Lemma 2.3(i): S(α,⊤) ∈ g(t,s) for every α ∈ f(t). This implies φ ∈ g(t,s) when U(φ,ψ) ∈ f(t) by the U/S interaction axiom.
5. By C3: for any r strictly between t and s, g(t,s) ⊆ f(r), so φ ∈ f(r).

The critical question is whether step 4 holds via `burgessR3`. Looking at the codebase's `burgessR3` definition: `r3Relation A B C` means `∀ β ∈ B, ∀ γ ∈ C, U(γ,β) ∈ A` — this is the converse of what we need. The needed direction is: from `U(φ,ψ) ∈ f(t)`, conclude φ ∈ g(t,s). This requires `limit_c2` (the full r-relation), not just `limit_c2'` (adjacent only). The `limit_c2` theorem needs to be verified as sorry-free.

---

## Evidence / Examples

### Xu's Lemma 2.4 → c2' construction

From Xu 1988, p. 95:
> "We apply 2.4 to A = f(t₁), B = g(t₁,t₂) and C = f(t₂) to obtain B', D, B'', and then fix t₃ ∈ T* − T and set: (c) f' = f ∪ {(t₃, D)}, (d) g' = g ∪ {((t₁,t₃), B'), ((t₃,t₂), B'')}"

This is exactly the pattern needed for `c2' := sorry` sites. The code already computes D (via Lindenbaum); it needs to also compute B' and B'' from the same application.

### Reynolds Section 4 → Forward Until guard

Reynolds confirms (p. 193):
> "the flow of time consisting of those sets becomes a structure M satisfying, for all Γ ∈ M, for all A ∈ Γ, M ⊨ A(Γ) iff A ∈ Γ"

The inductive proof of this truth lemma for U(φ,ψ) requires: if U(φ,ψ) ∈ Γ and Γ is placed at t, then ∃ Δ at s > t with ψ ∈ Δ and for all Ξ at r ∈ (t,s), φ ∈ Ξ. The "φ ∈ Ξ" part follows from C3: Ξ = f(r) contains g(t,s) ∩ f(r) (from C3), and φ ∈ g(t,s) by the r-relation.

### Caleiro et al. Section 4.1 → G-propagation confirmation

Their vertical coherence conditions V3 and V4 (p. 407):
> "(V3) if GA ∈ Γ then GA ∈ Δ; (V4) if HB ∈ Δ then HB ∈ Γ"

This exactly matches the codebase's FMCS `forward_G` condition and confirms the formulation is standard and correct.

---

## Confidence Level

| Finding | Confidence | Rationale |
|---------|-----------|-----------|
| Xu 2.4 → c2' construction | **High** | Xu's proof directly describes constructing g-values for new pairs via B', D, B'' |
| Xu base case G/H propagation | **High** | Matches codebase exactly; already proven |
| Reynolds → fuc sorry path | **Medium** | C3 + r-relation argument is correct but requires verifying limit_c2 is sorry-free |
| Reynolds IRR-free confirmation | **High** | Strong methodological confirmation, no action needed |
| Caleiro mosaic method | **Medium** | Confirms current architecture; no direct shortcut |

---

## Cross-Reference: Sorry Sites and Techniques

| Sorry Site | File | Applicable Technique |
|-----------|------|---------------------|
| `c2' := sorry` (C5 insertion, line 786) | CounterexampleElimination.lean | Xu 2.2: B and C from R(A,B,C) give g(x, z_new) := B |
| `c2' := sorry` (C5' insertion, line 824) | CounterexampleElimination.lean | Xu 2.2 dual: mirror for Since |
| `c2' := sorry` (C4 adjacent pair, line 864) | CounterexampleElimination.lean | Xu 2.4: B' and B'' from the Lindenbaum step |
| `c2' := sorry` (C4' adjacent pair, line 902) | CounterexampleElimination.lean | Xu 2.4 dual: mirror for Since |
| `c2' := sorry` (g from absorption, line 938) | CounterexampleElimination.lean | Xu 2.4 with B ⊆ g(x,x_next): direct DCS inheritance |
| `c2' := sorry` (g from absorption, line 970) | CounterexampleElimination.lean | Xu 2.4 dual: mirror |
| `sorry` line 1086 | CounterexampleElimination.lean | Requires separate analysis |
| Forward Until coherence (line 615) | ChronicleToCountermodel.lean | Reynolds Section 4 + C3: limit_c2 + limit_c3 path |
| Forward Since coherence (line 619) | ChronicleToCountermodel.lean | Mirror of Until |

---

## Notes on Scope Limitations

1. **Xu 1988 focuses on the minimal tense logic** (no S5). The S5 dimension of TM is handled by the BFMCS construction which is already sorry-free. No interaction technique from Xu is needed for the S5 part.

2. **Reynolds 1992 addresses dense linear time over reals**, which is more specific than the BX case (dense linear time over rationals is intermediate). The Burgess-Xu construction Reynolds uses is the same one in the codebase.

3. **The c2' condition in the codebase uses Adjacent pairs** (Definition 2.5 of `Chronicle.c2'`), which is weaker than full c2 (all pairs). This is by design: at the limit, the domain is dense (no adjacent pairs), so c2' is vacuously satisfied. This design matches Xu's approach of building conditions at finite stages then passing to the limit.
