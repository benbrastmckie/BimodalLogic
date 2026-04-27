# Teammate D Findings: Burgess-Faithful Long-Term Architecture

**Task**: 107 - Chain Design Diagnostics for Representation Theorem
**Focus**: Horizons -- Burgess-faithful r-relation and chronicle architecture
**Date**: 2026-04-26

---

## 1. Complete Map of Burgess Section 2 vs Codebase

### Lemma-by-Lemma Status

| Burgess | Description | Codebase Status | File | Notes |
|---------|-------------|-----------------|------|-------|
| **Def 2.1** (DCS) | Deductively closed sets | COMPLETE | `ChronicleTypes.lean` | `SetDeductivelyClosed`, `mcs_is_dcs`, `dcs_modus_ponens`, `dcs_conj_closed` |
| **Lemma 2.2** | If U(gamma, delta) in MCS A, then gamma is consistent | WITHDRAWN | `RRelation.lean` | FALSE under strict semantics for gamma=bot. Replaced by weaker `until_disjunction_in_mcs`: gamma or delta in A. Not needed downstream. |
| **Lemma 2.3** | r-relation equivalences (a) <-> (b) | PARTIALLY PRESENT | `RRelation.lean` + `ChronicleTypes.lean` | See Section 2 below for detailed analysis. |
| **Lemma 2.4** | Endpoint construction for C5 | PRESENT (adapted) | `PointInsertion.lean` | `lemma_2_4`: produces MCS C with beta in C, g_content(A) subset C, P(U(gamma,beta)) in C. Adapted for strict semantics (no gamma in C guarantee). |
| **Def 2.5** | R-maximality | PRESENT (two formulations) | `ChronicleTypes.lean` | `R3Maximal` (obligation propagation) AND `burgessR3` (content-based). Not unified. |
| **Lemma 2.5** | Interval absorption (B = B' intersect D intersect B'') | PRESENT (content version) | `RRelation.lean` | `burgessR3_absorption` proved. But `R3Maximal` version (that B = B' intersect D intersect B'' under R-maximality) is NOT proved. |
| **Lemma 2.6** | Interval splitting for C4 (insert D with neg-delta between A and C) | PARTIALLY PRESENT | `PointInsertion.lean` | `lemma_2_6_full` referenced but not proved. The `eliminate_C4_counterexample` handles easy cases; the hard case (G(gamma) in f(x) AND H(gamma) in f(y)) is `sorry`. |
| **Lemma 2.7** | Guard propagation for C5 (U(xi,eta) in A, eta not in B) | NOT PRESENT | -- | Neither the Burgess version nor a strict-semantics adaptation exists. |
| **Lemma 2.8** | Guard propagation for C5 (complement condition) | NOT PRESENT | -- | Depends on 2.7 |
| **Lemma 2.9** | C4 counterexample elimination | PARTIALLY PRESENT | `CounterexampleElimination.lean` | `eliminate_C4_counterexample` covers easy cases. Hard case (line 334) is `sorry`. |
| **Lemma 2.10** | C5 counterexample elimination | PARTIALLY PRESENT | `CounterexampleElimination.lean` | `eliminate_C5_counterexample` exists for the case n=0 (adding a new point after all existing points). The inductive case n=m+1 (inserting between existing points) is not implemented. |
| **Claim 2.11** | Truth lemma | STUB | `ChronicleConstruction.lean` | `truth_claim` exists as `Iff.rfl` placeholder. The real content needs C3 + full C5 with guard. |

### Chronicle Conditions Status

| Condition | Defined | Maintained in Omega Chain | Proved at Limit |
|-----------|---------|--------------------------|-----------------|
| C0 (MCS) | YES | YES | YES (`limit_c0`) |
| C0' (finite dom) | YES (implicit in Finset) | YES | N/A (limit is countable, not finite) |
| C1 (DCS intervals) | YES | NO (g not populated) | NO |
| C2 (r3Relation all pairs) | YES | NO | NO |
| C2' (R3Maximal adjacent) | YES | NO (g not populated) | NO |
| C3 (three-way decomp) | YES | NO (g not populated) | NO |
| C4/C4' (counterexample) | YES | YES (via elimination) | YES (`limit_satisfies_c4`) |
| C5/C5' (witnesses) | YES | YES (via elimination) | PARTIAL (`limit_satisfies_c5_weak` -- endpoint only, no guard) |

**Root diagnosis**: The omega chain currently maintains only C0 and eliminates C4/C5 counterexamples. It does NOT populate g-values, does NOT maintain C1/C2'/C3, and consequently cannot provide the guard at intermediate points for the full C5.

---

## 2. The Two r-Relations: Detailed Analysis

The codebase contains TWO fundamentally different r-relations. Understanding which Burgess uses where is critical.

### Codebase r-Relation (Obligation Propagation)

```
rRelation(A, B) := forall gamma delta,
  untl(gamma, delta) in A ->
  delta in B OR (gamma in B AND untl(gamma, delta) in B)
```

**Direction**: A -> B. Until obligations FROM A propagate INTO B.
**Meaning**: B is a valid next state after A. Either the eventuality is resolved (delta in B) or the guard continues with the obligation persisting (gamma and U(gamma,delta) in B).
**Used by**: BX9 (until_elim) and BX5 (self_accum_until).

### Burgess r-Relation (Content/Guard)

```
burgessR(A, beta, C) := forall gamma in C, untl(beta, gamma) in A
```

**Direction**: B x C -> A. Elements of C and guards from B combine to form Until formulas IN A.
**Meaning**: beta is a valid guard for the interval between A and C.

Extended to sets:
```
burgessRSet(A, B, C) := forall beta in B, burgessR(A, beta, C)
```

### Equivalence Under MCS Conditions

**Claim**: Burgess Lemma 2.3 states that for MCS A, C:

- (a) forall gamma in C, untl(gamma, beta) in A   [Burgess notation: U_B(gamma, beta)]
- (b) forall alpha in A, snce(alpha, beta) in C    [Burgess notation: S_B(alpha, beta)]

are equivalent. The codebase's `rRelation` is NEITHER (a) NOR (b). It is a third property derived from BX9 applied to the Until formulas in A.

**Critical question**: Is codebase `r3Relation(A, B, C)` equivalent to `burgessR3(A, B, C)` when A, B, C are all MCS?

**Answer: NO, not in general.** Here is why:

- `burgessR3(A, B, C)` says: for all beta in B and gamma in C, `untl(beta, gamma) in A`. This is a statement ABOUT A given B and C.
- `r3Relation(A, B, C)` says: (1) for all gamma, delta with `untl(gamma, delta) in A`, either delta in B or (gamma in B and untl(gamma,delta) in B); AND (2) the mirror for Since from C. This is a statement about B given A (and C).

The Burgess relation `burgessR3` is strictly stronger: it says that B contains ALL formulas that could serve as guards between A and C. The codebase's `r3Relation` only says that B resolves or continues the Until obligations that happen to be in A.

**However**: When B is R3-maximal (in the Burgess sense), the two are related. The key insight is that Burgess's R-maximality is defined relative to `burgessR`, not `rRelation`. The codebase's `R3Maximal` is defined relative to `r3Relation`, which is the wrong maximality condition for the Burgess argument.

### Which Direction Does Burgess Use Where?

| Lemma | Uses | Direction | Property |
|-------|------|-----------|----------|
| 2.3 proof (a)->(b) | Burgess r | B x C -> A | beta guards from C into A |
| 2.4 (endpoint) | Burgess r(a) direction | builds C from {gamma} union {S(alpha,beta) : alpha in A} | Constructs endpoint |
| 2.5 (absorption) | Burgess r | B x C -> A + BX6 | **Key**: beta in B, burgessR(A,beta,D), burgessR(D,beta,C) implies burgessR(A,beta,C) |
| 2.6 (splitting) | R-maximality + burgessR | When delta not in B and R(A,B,C), find B', D, B'' | Uses maximality to find witness of non-membership |
| 2.7 (guard prop) | burgessR + BX5 + BX7 | U(xi,eta) in A, eta not in B | Splits interval to propagate guard |
| 2.8 (guard prop) | burgessR + BX7 | complement condition at C | Variant of 2.7 |
| 2.9 (C4 elim) | Calls 2.6 (case n=0) or reduces (case n>0) | R(f(x), g(x,y), f(y)) | Needs R-maximality for adjacent pairs |
| 2.10 (C5 elim) | Calls 2.4 (case n=0) or 2.7/2.8 (case n>0) | Multiple | Needs burgessR for guard extraction |
| 2.11 (truth) | C3 + C5 | g(x,y) subset f(z) for intermediate z | Uses C3 three-way decomposition |

**Summary**: Burgess uses `burgessR` (the content-based relation) EVERYWHERE. The obligation propagation `rRelation` is a derived consequence, not the primary definition.

---

## 3. Architectural Recommendation

### The Core Problem

The codebase built the entire chronicle infrastructure on `rRelation` (obligation propagation) instead of `burgessR` (content/guard). This leads to:

1. **R3Maximal is wrong**: Maximizing over `r3Relation` instead of `burgessR3` gives a set B that is maximal in the wrong sense. Burgess needs: "delta not in B implies there exist gamma in C with untl(beta, delta) not in A for some beta in B". The codebase's maximality gives: "there exists a proper extension B' where rRelation A B' fails", which is a completely different failure mode.

2. **C4 hard case is stuck**: The sorry at line 334 of `CounterexampleElimination.lean` needs "gamma not in g(x,y)" to invoke Lemma 2.6. Under Burgess maximality, delta not in B means there exist gamma in C with `untl(beta, delta) not in A` for some beta in B. This is precisely the tool for the C4 hard case. Under the codebase's maximality, no such tool exists.

3. **g-values are never populated**: The omega chain construction currently only maintains f-values (MCS at points). The g-values (interval DCS) are never constructed, meaning C1, C2', and C3 are never established.

### Recommended Refactoring: Adopt Burgess's r-Relation Verbatim

**Option 2 from the handoff is correct**: Replace `r3Relation` with `burgessR3` as the primary definition.

The refactoring plan:

**Step 1: Redefine the primary r-relation**

Keep `burgessR`, `burgessRSet`, `burgessR3` as they already exist in `RRelation.lean`. Make them the PRIMARY definitions for the chronicle conditions.

Redefine:
```lean
def r_primary (A : Set Formula) (β : Formula) (C : Set Formula) : Prop :=
  burgessR A β C  -- forall gamma in C, untl(beta, gamma) in A

def r_set (A B C : Set Formula) : Prop :=
  burgessRSet A B C  -- forall beta in B, r_primary(A, beta, C)

def R_maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  r_set A B C ∧ r_set_since C B A ∧  -- burgessR3
  ∀ (D : Set Formula), SetDeductivelyClosed D → B ⊂ D →
    ¬(r_set A D C ∧ r_set_since C D A)
```

**Step 2: Prove the codebase's rRelation is derivable from burgessR3**

Under MCS conditions, if `burgessR3(A, B, C)` and B is an MCS, then `r3Relation(A, B, C)` follows. This means every existing lemma that uses `r3Relation` still works after the switch.

Proof sketch: Given `untl(gamma, delta) in A` and B is MCS with `burgessR3(A, B, C)`:
- By BX9 in A: `gamma or delta in A`.
- If we know gamma in B: then `untl(gamma, delta) in B` (since B is MCS and contains the right formulas)... Actually this direction is not immediate. Let me reconsider.

Actually, `rRelation(A, B)` and `burgessRSet(A, B, C)` are INDEPENDENT properties. The codebase's `rRelation` says "obligations from A propagate to B"; `burgessRSet` says "B-formulas guard from A to C". For the chronicle, Burgess needs `burgessRSet`, not `rRelation`.

The correct approach is: **do not prove equivalence**. Instead, replace all uses of `rRelation`-based maximality with `burgessR3`-based maximality, and rederive the downstream lemmas.

**Step 3: Prove R_maximal existence via Zorn**

The existing `r3Maximal_extension_exists` proof structure works. Replace the ordering condition with `burgessR3`:

```lean
def burgessR3DCSExtensions (A S C : Set Formula) : Set (Set Formula) :=
  {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ burgessR3 A B C}
```

Chain unions preserve `burgessR3` because: if beta in union(chain) and gamma in C, then beta in some chain element T, and `burgessRSet(A, T, C)` gives `untl(beta, gamma) in A`. Same for the Since direction.

**Step 4: Populate g-values in the omega chain**

This is the critical missing piece. At each step of the omega chain, when inserting a new point z between x and y:

1. Construct g(x,z), g(z,y) as R_maximal DCS using the new `R_maximal` definition
2. Define g(w,z) and g(z,w) for non-adjacent w via C3: `g(w,z) = g(w,x) intersect f(x) intersect g(x,z)` etc.
3. Prove the invariant `ChronicleInvariant` is preserved

**Step 5: Prove C5 with guard via C3**

Once g-values are populated and C3 holds, the guard at intermediate points follows:

Given `untl(xi, eta) in f(x)` and witness y with `eta in f(y)`, for any z with `x < z < y`:
- C3: `g(x,y) subset f(z)`
- C5 elimination: `eta in g(x,y)` (from the seed construction)
- Therefore `eta in f(z)` -- wait, that gives the event not the guard.

Actually, Burgess's C5 says: `U(xi,eta) in f(x)` implies there exists y with `xi in f(y)` and `eta in g(x,y)`. The guard eta is in the INTERVAL set g(x,y), and by C3, `g(x,y) subset f(z)` for intermediate z, giving `eta in f(z)`.

**Notation clarification**: In Burgess, `U(gamma, beta)` where gamma=event, beta=guard. The codebase writes `untl(guard, event)`. So Burgess's C5a says: `U(xi, eta) in f(x)` [Burgess notation] = `untl(eta, xi) in f(x)` [codebase notation: guard=eta, event=xi]. Wait, let me recheck.

Burgess semantics: `V(U(alpha, beta)) = {x : exists y, x < y, y in V(alpha), forall z, x < z < y -> z in V(beta)}`. So alpha = event (holds at witness), beta = guard (holds on interval).

Codebase: `Formula.untl phi psi` where `phi` = guard, `psi` = event. Semantics: `untl(phi, psi)` at t means exists s > t, psi(s) and forall u in [t,s), phi(u).

Translation: Burgess `U(alpha, beta)` = codebase `untl(beta, alpha)` (guard=beta, event=alpha).

Burgess C5a: if `U(xi, eta) in f(x)` [event=xi, guard=eta], then exists y with `xi in f(y)` [event at witness] and `eta in g(x,y)` [guard in interval].

In codebase notation: if `untl(eta, xi) in f(x)`, then exists y with `xi in f(y)` and `eta in g(x,y)`.

The codebase's C5 says:
```
untl xi eta in f(x) -> exists y, x < y, eta in f(y),
  forall z in [x,y), xi in f(z) AND untl(xi, eta) in f(z)
```
Here `xi` = guard, `eta` = event. So `eta in f(y)` = event at witness, `xi in f(z)` = guard at intermediate. This matches Burgess with the translation: `xi` = Burgess's beta (guard), `eta` = Burgess's alpha (event). And the codebase wants `xi in f(z)` (guard at intermediate), which under C3 comes from `xi in g(x,y)`.

So the architecture is: C5 elimination produces y with `eta in f(y)` AND `xi in g(x,y)`. Then C3 gives `g(x,y) subset f(z)` for intermediate z, giving `xi in f(z)`.

**This is exactly right.** The missing piece is: the g-values must be populated during C5 elimination, with `xi in g(x,y)` as part of the seed.

---

## 4. Guard Convention Adaptation: Reflexive vs Irreflexive Until

### Burgess's Convention (Reflexive Guard)

Burgess uses `U(alpha, beta)` where the guard beta holds on the OPEN interval (x, y):
- `V(U(alpha, beta)) = {x : exists y > x, y in V(alpha), forall z (x < z < y -> z in V(beta))}`

The guard does NOT cover the current point x or the witness point y. This is a fully open interval (x, y).

### Codebase Convention (Half-Open Guard)

The codebase uses `untl(phi, psi)` where the guard phi holds on [t, s):
- `untl(phi, psi)` at t: exists s > t, psi(s), forall u in [t, s), phi(u)

The guard COVERS the current point t but NOT the witness s.

### Impact on the r-Relation

**Burgess r(A, beta, C)**: forall gamma in C, `U_Burgess(gamma, beta)` in A.

In Burgess's semantics, this means: at the state described by A, there will be a future point (described by C) where gamma holds, with beta holding on the open interval between.

**Codebase burgessR(A, beta, C)**: forall gamma in C, `untl(beta, gamma)` in A.

In the codebase's semantics, this means: at A, there will be a future point where gamma holds, with beta holding on [t, s). The guard beta covers the current point.

### Consequence: `until_guard` Axiom

The BX axiom `until_guard: (phi U psi) -> phi` is VALID under half-open [t,s) semantics and INVALID under open (t,s) semantics. This is the key difference.

**Effect on the construction**:

1. **Lemma 2.4 (endpoint)**: Burgess gets `{gamma} union {S(alpha, beta) : alpha in A}` consistent using A3a. The codebase cannot use A3a (invalid under strict semantics). Instead, it uses BX4 (`connect_future`) and BX10 (`until_F`). The codebase's `lemma_2_4` produces `beta in C` and `g_content(A) subset C` and `P(U(gamma,beta)) in C`, but NOT `gamma in C` (because the guard does not cover the witness under half-open semantics). This is correct.

2. **Lemma 2.6 (splitting)**: Burgess uses A4a (`U(p,q) AND neg(U(p,r)) -> U(q AND neg(r), q)`) and A3a. Under strict semantics, A4a is NOT valid. The codebase needs BX5, BX6, BX7 as replacements. The handoff notes that `lemma_2_6_strong` was withdrawn as FALSE.

3. **C5 guard propagation**: Under Burgess, the guard covers (x,y) open. Under codebase, the guard covers [t,s) half-open. The `until_guard` axiom means `untl(xi, eta) in f(x)` implies `xi in f(x)` (guard at current point). This is STRONGER than Burgess at x but the same for intermediate z (where we need `xi in f(z)` from `xi in g(x,y) subset f(z)` via C3).

### Does `until_guard` Bridge the Gap?

Partially. The `until_guard` axiom gives us `xi in f(x)` for free (guard at current point), which Burgess does NOT have. But for intermediate points, both constructions need `xi in g(x,y)` via C3. The fundamental architecture is the same.

The key adaptation is in Lemma 2.6/2.7/2.8, where A3a and A4a are replaced by BX-specific axioms. These lemmas need to be RE-PROVED under the BX axiom system, not adapted from Burgess by simple substitution.

---

## 5. Target Architecture: Final ChronicleInvariant

### ChronicleInvariant (Finite Stage)

```lean
structure ChronicleInvariant (chi : Chronicle) : Prop where
  -- C0: Every domain point maps to an MCS
  hc0 : chi.c0
  -- C1: Every pair x < y maps to a DCS
  hc1 : chi.c1
  -- C2': Burgess R-maximality for adjacent pairs
  -- NOTE: Uses burgessR3-based maximality, NOT r3Relation-based
  hc2' : forall x y, Adjacent chi.dom x y ->
    BurgessR3Maximal (chi.f x) (chi.g x y) (chi.f y)
  -- C3: Three-way interval decomposition
  hc3 : chi.c3
```

where:
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  forall (D : Set Formula), SetDeductivelyClosed D -> B subset_strict D ->
    neg (burgessR3 A D C)
```

### BurgessR3Maximal Properties Needed

The following properties of `BurgessR3Maximal` are needed by the elimination lemmas:

1. **Non-membership witness**: If `R(A, B, C)` and `delta not in B`, then there exist `beta in B` and `gamma in C` such that `untl(beta, delta) not in A` (or the Since mirror). This follows from maximality: if all such Until formulas were in A, we could extend B with delta.

2. **DCS property**: B is deductively closed (already in the definition).

3. **MCS upgrade**: Under appropriate conditions, B is actually an MCS. Proof: if B is not MCS, there exists delta with neither delta nor neg(delta) in B. By non-membership witness applied to delta, ... Actually, this requires more work. Burgess doesn't claim R-maximal sets are MCS in general; he only uses them as DCS.

### EliminationResult

```lean
structure EliminationResult (chi : Chronicle) where
  chi' : Chronicle
  -- Domain extension
  dom_ext : chi.dom subset chi'.dom
  dom_strict : chi.dom subset_strict chi'.dom
  -- Agreement on old points
  f_agree : forall x in chi.dom, chi'.f x = chi.f x
  -- Agreement on old intervals
  g_agree : forall x y, x in chi.dom -> y in chi.dom -> chi'.g x y = chi.g x y
  -- Invariant preserved
  invariant : ChronicleInvariant chi'
```

### Omega Chain Limit

The limit should provide:

```lean
structure LimitChronicle where
  -- Domain: countable dense subset of Q
  dom : Set Rat
  dom_countable : Set.Countable dom
  dom_dense : DenselyOrdered {q : Rat // q in dom}
  -- Point function
  f : Rat -> Set Formula
  -- Interval function
  g : Rat -> Rat -> Set Formula
  -- C0: all points map to MCS
  hc0 : forall x in dom, SetMaximalConsistent (f x)
  -- C1: all pairs map to DCS
  hc1 : forall x y in dom, x < y -> SetDeductivelyClosed (g x y)
  -- C2: burgessR3 for ALL pairs (derived from C2' + C3 + density)
  hc2 : forall x y in dom, x < y -> burgessR3 (f x) (g x y) (f y)
  -- C3: three-way decomposition
  hc3 : forall x y z in dom, x < y -> y < z ->
    g x z = g x y intersect f y intersect g y z
  -- C4/C4': counterexample conditions
  hc4 : Chronicle.c4 (limit as Chronicle)
  hc4' : Chronicle.c4' (limit as Chronicle)
  -- C5/C5': with FULL guard (via C3)
  hc5 : forall x in dom, forall xi eta,
    untl(xi, eta) in f(x) ->
    exists y in dom, x < y AND eta in f(y) AND xi in g(x, y)
  hc5' : (mirror for Since)
  -- Root containment
  zero_mem : 0 in dom
  root_mcs : f 0 = A0
```

The truth lemma (Claim 2.11) then follows:

- **Atom case**: Immediate from definition V(p) = {x : p in f(x)}.
- **Negation**: By MCS negation completeness (C0).
- **Conjunction**: By MCS conjunction property (C0).
- **Until**: Forward: `untl(xi, eta) in f(x)` -> C5 gives y with `eta in f(y)` and `xi in g(x,y)`. For intermediate z, C3 gives `g(x,y) subset f(z)`, so `xi in f(z)`. By induction, y in V(eta) and z in V(xi) for all z in (x,y). So x in V(untl(xi, eta)).
  Backward: `neg(untl(xi, eta)) in f(x)` and y > x with y in V(eta). By induction, `eta in f(y)`. By C4, exists z in (x,y) with `xi.neg in f(z)`. By induction, z not in V(xi). So x not in V(untl(xi, eta)).
- **Box**: Standard S5 modal argument (orthogonal to temporal construction).

---

## 6. Minimal Correct Refactoring Plan

### Phase A: Define BurgessR3Maximal (small, surgical)

1. Add `BurgessR3Maximal` to `ChronicleTypes.lean` using `burgessR3` from `RRelation.lean`
2. Prove `BurgessR3Maximal_extension_exists` via Zorn (parallel structure to existing `r3Maximal_extension_exists`)
3. Prove non-membership witness lemma for `BurgessR3Maximal`

### Phase B: Populate g-values in omega chain (major)

This is the hardest phase. For each point insertion step:

1. **C5 elimination (Lemma 2.10, case n=0)**: When adding endpoint y after all existing points:
   - Construct g(x, y) as BurgessR3Maximal DCS with seed containing xi (guard)
   - For all w < x in dom, define g(w, y) = g(w, x) intersect f(x) intersect g(x, y) (C3)

2. **C5 elimination (Lemma 2.10, case n>0)**: When adding point z between x and x' (x' = immediate successor):
   - This requires Lemmas 2.7/2.8 adapted for strict semantics
   - Construct g(x, z) and g(z, x') as BurgessR3Maximal DCS
   - Verify C3 for all triples involving z

3. **C4 elimination (Lemma 2.9)**: When adding counterexample point z between x and y:
   - Case n=0: Use Lemma 2.6 (needs BurgessR3Maximal of g(x,y))
   - Case n>0: Reduce as Burgess describes

4. **Invariant preservation**: At each step, verify ChronicleInvariant for the extended chronicle.

### Phase C: Derive full C5 at limit

1. Show limit g-values are well-defined (consistency of omega chain)
2. Show C3 holds at limit (by construction)
3. Derive C2 for all pairs from C2' + C3 using `burgessR3_absorption` (already proved)
4. Derive full C5 with guard from C5 elimination + C3

### Phase D: Wire into truth lemma

1. Prove Claim 2.11 using C0 + C3 + C4 + full C5
2. Wire into `ChronicleToCountermodel.lean` to replace sorry sites

### Estimated Effort

| Phase | Difficulty | New Definitions | New Theorems | Sorry Sites Addressed |
|-------|-----------|----------------|--------------|----------------------|
| A | Medium | 2-3 | 3-5 | 0 (foundation) |
| B | Hard | 5-10 | 15-25 | 2 (C4 hard cases) |
| C | Medium | 2-3 | 5-10 | 0 (limit properties) |
| D | Medium | 1-2 | 3-5 | 2 (restricted_fuc) |

**Total**: ~30-40 new theorems, addressing all 4 active sorry sites.

---

## 7. Risk Assessment

### Risk 1: Lemmas 2.7/2.8 Under Strict Semantics

Burgess's Lemmas 2.7 and 2.8 use A3a (`p AND U(q,r) -> U(q AND S(p,r), r)`) and A7a (linearity). A3a is INVALID under strict semantics. The handoff notes that `lemma_2_7` was withdrawn as FALSE.

**Mitigation**: The C5 elimination for case n>0 may need a different argument under strict semantics. One approach: since the codebase has `until_guard` (phi U psi -> phi), the guard covers the current point. This may provide enough structure to bypass A3a in the consistency argument. Alternatively, the BX axiom system may be strong enough to derive a strict-semantics analog of A3a's role in the consistency proof.

**Severity**: HIGH. If Lemmas 2.7/2.8 have no strict-semantics analog, the C5 elimination for case n>0 (inserting between existing points) is blocked. However, the C5 elimination for case n=0 (adding after all points) works, and the omega chain construction may be restructured to only use case n=0 by adding points in the right order.

### Risk 2: BurgessR3 Seed Construction

Constructing the initial seed for BurgessR3Maximal DCS extension requires showing that `{xi} union g_content(f(x))` is consistent AND satisfies burgessR3 as a seed. The existing `until_witness_seed_consistent` only shows consistency, not the burgessR3 property.

**Mitigation**: The seed for g(x,y) should include all formulas beta such that forall gamma in C, `untl(beta, gamma) in A`. This is well-defined given A and C. The consistency of this seed follows from the consistency of A.

### Risk 3: Omega Chain g-value Coherence

When extending the domain at step n+1, the new g-values must be consistent with all previously defined g-values. The C3 condition forces: `g(w, y_new) = g(w, x) intersect f(x) intersect g(x, y_new)`. This is well-defined but the DCS property of the intersection must be verified.

**Mitigation**: `dcs_inter_mcs_inter_dcs` already exists in `ChronicleTypes.lean` and handles exactly this case.

---

## 8. Summary of Recommendations

1. **Adopt Burgess's content-based r-relation (`burgessR3`) as the primary definition for chronicle conditions C2/C2'.** The obligation-propagation `rRelation` is useful as a derived property but is not the right foundation for R-maximality.

2. **Define `BurgessR3Maximal` and prove its existence via Zorn.** The existing proof structure for `r3Maximal_extension_exists` can be reused with minimal changes.

3. **Populate g-values in the omega chain construction.** This is the critical missing piece. Each point insertion step must construct BurgessR3Maximal DCS for the new intervals and verify C3 for all triples involving the new point.

4. **Investigate strict-semantics analogs of Lemmas 2.7/2.8.** If these are not available, restructure the C5 elimination to avoid the n>0 case, or find BX-specific replacements for A3a's role.

5. **Do NOT attempt to prove equivalence between `rRelation` and `burgessR3`.** They are different properties. Use `burgessR3` for the chronicle construction and derive `rRelation` when needed as a consequence.

6. **The `burgessR3_absorption` theorem (already proved) is the cornerstone** for deriving C2 from C2' + C3 at the limit. This is one of the few pieces that is already correct and complete.
