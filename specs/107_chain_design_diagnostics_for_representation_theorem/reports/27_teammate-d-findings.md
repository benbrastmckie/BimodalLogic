# Teammate D Findings: Venema 1993 and Alternative Completeness Approaches

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Artifact**: 27_teammate-d-findings.md
**Focus**: Alternative approaches, long-term architecture assessment
**Date**: 2026-04-25

---

## 1. Venema 1993 Analysis

### What Venema Does

Venema 1993 proves completeness of the axiom system **BW** (Burgess + well-ordering axiom W) with respect to well-orderings, and **BN** (BW + discreteness D) with respect to (omega, <). The key technique is "completeness via completeness" -- using expressive completeness of the SU language (Kamp's theorem) to bridge from a "definably well-ordered" model to an actual well-ordered model.

### The Core Technique

1. Start with a BW-consistent formula phi
2. Extend to a maximal BW-consistent set Phi (standard Lindenbaum)
3. By Burgess's completeness theorem for **B** (the base Since/Until logic over all linear orders): Phi is satisfiable in some linear model M
4. Because M satisfies BW, M is "definably well-ordered" (every first-order definable subset has a smallest element)
5. By Doets's theorem: definably well-ordered models have n-equivalents for all n
6. So M has a well-ordered n-equivalent M', which satisfies phi

### Does Venema Address the Non-Domain Extension Problem?

**No.** Venema's approach is fundamentally different from Burgess's chronicle construction. Venema takes Burgess's completeness for linear orders (B) as a BLACK BOX and then uses model-theoretic transfer (n-equivalence) to move from linear models to well-ordered models. He never builds a chronicle or does any step-by-step construction. The non-domain extension problem is specific to the chronicle approach; Venema avoids it entirely because he never constructs a partial domain.

### Could Venema's Technique Help Us?

**Not directly for the current goal.** Venema's approach requires:
- Expressive completeness of SU over the target frame class (Kamp's theorem for complete orders, Stavi for all linear orders)
- A base completeness result to start from (Burgess's B over all linear orders)
- The Doets transfer theorem for definable well-orderings

The project's goal is completeness of BX over strict linear orders with the Until/Since operators. Venema's technique would require first having completeness over ALL strict linear orders (which is what Burgess gives us -- and what we are trying to formalize), then transferring to a specific subclass. It is a technique for SPECIALIZING completeness to subclasses, not for establishing the base completeness in the first place.

### The Irreflexivity Rule

Venema explicitly discusses the irreflexivity rule (IR) and its disadvantages. His contribution is avoiding IR for well-orderings and omega. The BX system already avoids IR (using orthodox rules: MP, TG, SUB). This is consistent with our approach and confirms that an orthodox axiomatization for strict linear orders exists.

---

## 2. Verbrugge 2004 Step-by-Step Method

### What It Does

Verbrugge (de Jongh, Veltman, Verbrugge) proves completeness of various tense logics (Lin, P, Q, R, D, Z, Z x n) using a step-by-step construction that builds the model incrementally.

### How It Handles Domain Extension

The step-by-step method builds the temporal order T in stages:
- **Stage 0**: Single point t* with MCS Gamma_{t*}
- **Stage n+1**: For each unwitnessed formula neg(G phi_n) at some point t, insert a new witness point

For **Q** (rationals / dense orders), the construction adds density points at odd stages: between every two adjacent points in T_n, insert a new point v with Gamma_t prec Gamma_v prec Gamma_u. After omega stages, the resulting countable dense order is isomorphic to Q by Cantor's theorem.

**Key insight**: The domain IS the model. There is no "non-domain" -- every point in the temporal order is a point that was explicitly inserted during construction. The domain naturally grows to be countable and dense, and Cantor's theorem identifies it with Q at the very end.

### Comparison with Burgess Chronicle

The Burgess chronicle is essentially the same idea but with more structure: chronicles track additional invariants (C0-C5) for the Until/Since operators, which the basic Verbrugge G/H construction does not need. The non-domain extension problem arises because the chronicle builds limit_dom as a subset of Q (using rational coordinates for inserted points) rather than building an abstract order that IS the domain.

---

## 3. The Architectural Question: Does FMCS Require D = Rat?

### Current FMCS Structure

```lean
structure FMCS where
  mcs : D -> Set Formula          -- total function on ALL of D
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> G(phi) in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' < t -> H(phi) in mcs t -> phi in mcs t'
```

The FMCS requires `mcs` to be a **total function** on D. This is the source of the non-domain extension problem: the chronicle produces `limit_f` defined on `limit_dom` (a countable subset of Q), but the FMCS needs a function on ALL of Q.

### What D Requires

The `dd_countermodel_chronicle` output signature quantifies existentially:
```lean
exists (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] ...
```

Currently, D is instantiated as `Rat`. But the existential quantification means **any** type satisfying these constraints works. The completeness theorem `bx_completeness` only needs `valid phi -> Nonempty (DerivationTree [] phi)`, so the specific D in the countermodel is irrelevant.

### The Three Options

**Option A: Cantor isomorphism (current plan)**
- Build chronicle on limit_dom subset of Q
- Prove limit_dom is countable, dense, no min/max, nonempty
- Use `Order.iso_of_countable_dense` to get `limit_dom ≃o Q`
- Define `cantor_f(q) = limit_f(iso.symm(q))` -- now total on Q
- forward_G/backward_H reduce to limit_forward_G/limit_backward_H (sorry-free)

**Option B: Use limit_dom as the domain directly**
- Subtype `{x : Rat // x ∈ limit_dom}` as D
- Avoids extension entirely: mcs is limit_f, naturally total on the subtype
- Problem: Subtype of Rat does NOT have `AddCommGroup` -- addition can leave limit_dom
- This was investigated by Teammate C (round 23) and confirmed to fail

**Option C: Generalize FMCS to work on partial domains**
- Replace `mcs : D -> Set Formula` with `mcs : {x : D // x ∈ dom} -> Set Formula`
- Every downstream consumer (truth lemma, representation theorem, BFMCS) must be updated
- Estimated effort: 15-25 hours of refactoring across 10+ files
- This would be a major architectural change

### Verdict on Options

Option A (Cantor isomorphism) is clearly the right choice:
- `Order.iso_of_countable_dense` is AVAILABLE in Mathlib (`Mathlib.Order.CountableDenseLinearOrder`)
- The prerequisites (Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty) for limit_dom are straightforward to prove
- It requires ~8-10 hours of work vs 15-25 for Option C
- It does not change any existing infrastructure

Option B is dead (confirmed by round 23 Teammate C).

Option C is architecturally cleaner in theory but would require touching nearly every file in the algebraic representation layer. It is not worth the effort given that Option A works.

---

## 4. Burgess's Model Domain

Burgess 1982 Section 2.8 defines his model on X = limit_dom, NOT on all of Q. The truth lemma works on X. Burgess does not need to extend to Q because he works directly with the constructed domain as the temporal frame.

The reason our formalization needs the extension is that the `FMCS` structure requires a total function `D -> Set Formula`, and D is fixed as `Rat`. If we could use `limit_dom` as D, we would match Burgess exactly. But the `AddCommGroup` requirement on D prevents this (Option B above).

The Cantor isomorphism resolves this mismatch: after the isomorphism, every rational IS a domain point, so the function is naturally total. The isomorphism transports all the chronicle properties (C0-C5, forward_G, backward_H) from limit_dom to Q.

---

## 5. Could We Restructure the Endgame?

### The Proposed Alternative

Instead of:
```
chronicle on limit_dom -> extend to Q via Cantor -> FMCS on Q -> representation theorem
```
Could we do:
```
chronicle on limit_dom -> truth lemma on limit_dom -> countermodel on limit_dom -> representation theorem
```

### Analysis

This would require the parametric framework to accept limit_dom as D. The parametric representation theorem (`ParametricRepresentation.lean`) has:
```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

limit_dom is a `Set Rat` (i.e., a subset). As a subtype, it has `LinearOrder` (inherited) but NOT `AddCommGroup` (not closed under addition). So this path fails for the same reason as Option B.

However, one could imagine a more radical restructuring:
1. Define a custom type `ChronicleDomain` that wraps limit_dom
2. Give it a group structure by extending limit_dom to be closed under addition (Lindenbaum at each new point)
3. Define the FMCS on this extended domain

This is essentially reinventing the Cantor isomorphism but with more work. The Cantor isomorphism is strictly simpler.

### Verdict

The endgame restructuring does NOT save effort. The Cantor isomorphism path is optimal.

---

## 6. ROADMAP Goal Analysis

The ROADMAP states:
> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

This is the representation theorem goal. The chronicle construction achieves this:
1. For any non-provable phi, build a chronicle with phi.neg in the root MCS
2. Cantor-iso limit_dom to Q
3. Build BFMCS on Q (totally ordered abelian group)
4. Parametric representation gives a TaskFrame countermodel over Q

The ROADMAP also mentions:
- **Path B** (D=Rat completeness, task 107 Phase 4): representation theorem over Q
- **General completeness** (all strict linear orders): stretch goal

The sorry-free `dd_countermodel_chronicle` is the milestone. The current plan achieves this.

---

## 7. Effort Comparison

| Approach | Estimated Hours | Risk | Notes |
|----------|----------------|------|-------|
| **A: Cantor iso + current FMCS** | 8-10h | Low | `Order.iso_of_countable_dense` available. Prerequisites straightforward. |
| **B: Subtype limit_dom as D** | Dead | N/A | No AddCommGroup on subtype. Confirmed dead by round 23. |
| **C: Generalize FMCS to partial domains** | 15-25h | High | Touches 10+ files. Changes fundamental abstractions. No clear benefit over A. |
| **D: Venema-style model-theoretic transfer** | 40-60h | Very High | Requires formalizing Kamp's theorem, Doets's theorem, Stavi connectives. NOT applicable to base completeness. |
| **E: Verbrugge step-by-step from scratch** | 30-50h | High | Would replace the entire chronicle construction. Same end result. No advantage over current approach + Cantor iso. |

### Recommendation

**Stay with the current plan: Cantor isomorphism (Option A).** It is the lowest-effort, lowest-risk path to sorry-free `dd_countermodel_chronicle`. The existing infrastructure (limit_forward_G, limit_backward_H, limit_c5, etc.) is all sorry-free and ready to be transported through the isomorphism.

---

## 8. Summary of Key Findings

1. **Venema 1993 does NOT address the non-domain extension** -- it uses a completely different technique (model-theoretic transfer via n-equivalence) that takes base completeness as input rather than constructing it.

2. **Verbrugge 2004 avoids the non-domain problem** by building the domain incrementally (every model point was explicitly inserted). But this is exactly what the chronicle does -- the mismatch arises from our FMCS requiring a total function on a fixed D, not from the construction itself.

3. **The Cantor isomorphism is the right fix.** `Order.iso_of_countable_dense` exists in Mathlib. Prerequisites for limit_dom are provable. Estimated 8-10 hours.

4. **Generalizing FMCS to partial domains is NOT worth the effort** (15-25h, high risk, touches 10+ files).

5. **The ROADMAP goal ("completeness over totally ordered abelian groups") aligns perfectly** with the current plan: chronicle + Cantor iso + BFMCS on Q.

6. **No alternative approach offers a faster path** than completing the remaining 11 sorry sites via the current plan. The infrastructure is 90% built.

7. **The current architecture is the right long-term architecture.** The parametric representation theorem is clean and general. The chronicle construction is mathematically sound. The only gap is the mechanical Cantor isomorphism wiring, which is routine.
