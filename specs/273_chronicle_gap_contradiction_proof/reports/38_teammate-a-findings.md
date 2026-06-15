# Teammate A Findings: Nested Until Encoding Design and x-Sharing

**Role**: Primary Approach — Nested Until Encoding Design
**Focus**: The x-sharing question for multiple positive between_tx SSNs

---

## Key Findings

### 1. x IS Shared — VecEA2.holdsLeft Fixes x by Construction

The critical finding is that **x is guaranteed shared across all positive between_tx SSNs** in the current encoding. This is not a property that needs to be proved from the temporal formula structure — it is baked into the VecEA2 semantic framework.

The definition of `VecEA2.holdsLeft` (VecEATranslation.lean, line 250–256) is:

```lean
def VecEA2.holdsLeft {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA2 n) (t : M.carrier) : Prop :=
  vea.endpointLeft.eval_at M atomMap t ∧
  ∃ z1 : M.carrier, t < z1 ∧
    vea.endpointRight.eval_at M atomMap z1 ∧
    vea.bracket.holds M atomMap t z1
```

There is a **single existential `z1`** (called `x` in `enriched_vecEA2_until`). All conditions in `endpointRight` are required to hold at this same `z1`. In `enriched_vecEA2_until`, `endpointRight` is defined as:

```lean
let endRight : TemporalPred :=
  ⟨Formula.and (char_1 nf_x) (formula_conjList right_conjuncts)⟩
```

The `right_conjuncts` is a conjunction over **all** positive between_tx SSNs. Each SSN's condition `Formula.snce char_y Formula.top` is one conjunct in this conjunction, all evaluated at the **same point `z1`**. So there is no x-sharing problem at the semantic level — `VecEA2.holdsLeft` inherently binds a single endpoint.

### 2. Why the Forward Direction (forward_nf_eval_of_holdsLeft) Fails

The current sorry is at line 2205 in KampBypass.lean. The forward direction attempts to reconstruct `nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf` from `VecEA2.holdsLeft M atomMap vea.snd t`.

After destructuring `holdsLeft`, we have:
- `h_endLeft`: `pre_conditions_at_t_until` holds at `t`
- `x : M.carrier` with `h_t_lt_x : t < x`
- `h_endRight`: `char_1(nf_x) ∧ formula_conjList right_conjuncts` holds at `x`
- `h_bracket`: `(BracketFormula.trivial seg_guard).holds M atomMap t x`

The forward direction must produce `nf_eval_nf M 1 2 [x, t] sub_nf`. This requires:
1. **Atom reconstruction**: `∀ a, atom_eval M [x,t] a ↔ sub_nf.1 a = true`
2. **Quantifier reconstruction**: `∀ ssn, (∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ sub_nf.2 ssn = true`

The problem noted in the comment at line 2201–2204 is a **Lean definitional equality issue**: `h_eq : enriched_vecEA2_until ... = ⟨n, vea⟩` cannot be used directly to rewrite `h_holds` because the sigma type makes transport through `HEq` necessary. This is a purely mechanical Lean issue — not a logical gap.

**The real semantic blocker for the current encoding** is in the between_tx backward direction: the Since formula `Formula.snce char_y Formula.top` at `x` gives `∃ y' < x, char_y(y')`, but this does NOT establish `t < y'`. It only establishes `y' < x`. The witness `y'` could be anywhere before `x`, not necessarily in `(t, x)`.

### 3. The Paper's Construction (Rabinovich 2014, Proposition 3.5)

From the Rabinovich 2014 literature file, Proposition 3.5 describes the key translation:

> An exists-forall formula with one free variable at position z_k in a sequence x_0 < ... < x_n is equivalent to the conjunction of:
> - A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
> - A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND Overleftarrow-Box B_0)...)))

Here x is **fixed as a free variable** (it is z_k in the paper's notation). The paper does NOT generate independent per-witness nested Until chains that need to share an endpoint. Instead:

- The exists-forall formula has ONE sequence of existentially chosen points
- The translation to nested Until/Since follows the structure of this single sequence
- x (= z_k) is the free variable, not existentially quantified in this direction

When there are multiple positive between_tx SSNs in the Lean formalization (ssn_1, ssn_2, ...), each SSN says "there exists a y in (t,x) satisfying char_y". In the paper, these would all appear as separate existential witnesses x_i in the interval (z_0, z_k). The full nested Until chain encodes all of them together in one chain.

### 4. Analysis of the Nested Until Approach (Approach A)

Approach A proposes replacing the Since-at-endpoint encoding with a nested Until evaluated at `t` (endpointLeft):

```
Formula.untl seg_guard_f (char_y.and (Formula.untl seg_guard_f (char_1 nf_x)))
```

**For a SINGLE positive between_tx SSN**: This formula evaluated at `t` says:
- `seg_guard` holds from `t` to some `y` where `char_y ∧ (seg_guard Until char_1(nf_x))` holds
- i.e., `∃ y ∈ (t, ?)` where `char_y(y)` and then `∃ x' > y` where `char_1(nf_x)(x')` and `seg_guard` holds between `y` and `x'`
- This gives `t < y < x'` with `char_y(y)` and `char_1(nf_x)(x')`, where `seg_guard` guards both `(t,y)` and `(y,x')`

**For MULTIPLE positive between_tx SSNs**: Each SSN produces an independent nested Until chain with its own existential `x'_i` as the innermost endpoint. In the conjunction `chain_1 ∧ chain_2 ∧ ...`, we have:
- Chain 1: `∃ y_1 ∈ (t, x'_1)` with `char_y_1(y_1)` and `char_1(nf_x)(x'_1)`
- Chain 2: `∃ y_2 ∈ (t, x'_2)` with `char_y_2(y_2)` and `char_1(nf_x)(x'_2)`

**The x-sharing question**: Do we know `x'_1 = x'_2`? **No, not from a conjunction of independent chains.** Each chain independently witnesses its own "x". We need a SINGLE x.

### 5. Why the Disjunction over nf_x Does NOT Resolve This

The outer `enriched_bypass_until` disjuncts over `nf_x` values. Within a single disjunct (fixed `nf_x`), the `holdsLeft` semantics gives a SINGLE `z1` (the endpoint `x`). At the semantic level of `VecEA2.holdsLeft`, x is shared because it is the single existential quantified in the framework.

But if we implement "one independent nested Until chain per positive between_tx SSN" as separate conjuncts in `endpointLeft` (Approach A), we lose this sharing at the TEMPORAL FORMULA level: the temporal formula itself would existentially quantify independently for each chain, producing different `x'_i` values.

The VecEA2 framework solves this by design: it evaluates the ENTIRE `endpointRight` conjunction at the SAME `z1`. The framework's job is precisely to ensure this sharing.

### 6. The Actual Blocker: backward Direction for between_tx Zone

The current encoding uses `Formula.snce char_y Formula.top` in `endpointRight` (at x). The backward direction (backward_holdsLeft_of_nf_eval) works because given x as the concrete witness, `Since(char_y, top)` at x correctly witnesses `y < x` with `char_y(y)`. This is lines 2033–2047.

The **forward direction** (forward_nf_eval_of_holdsLeft) fails because:
1. The Lean mechanical issue: transporting through `h_eq` to access `endpointRight`
2. The semantic gap: from `Since(char_y, top)` at x, we extract `∃ y' < x, char_y(y')`, but we cannot reconstruct the LOWER BOUND `t < y'`

For `nf_eval_nf` reconstruction in the quantifier case, we need `∃ y, nf_eval_nf M 0 3 [y, x, t] ssn` where ssn is the between_tx SSN. This requires `t < y < x`. The Since formula only gives `y' < x`.

### 7. Recommended Fix: Bracket-Based Encoding for between_tx Witnesses

The correct fix is to move positive between_tx witnesses INTO the bracket (as point types), not keep them in endpointRight as Since formulas. This is Approach B (bracket-based) rather than Approach A (nested Until at t):

**Recommended encoding for n positive between_tx SSNs**:
- n bracket witnesses y_1, ..., y_n in (t, x)
- Each y_i has point type `char_y_i`  
- Segment types enforce seg_guard between witnesses
- endpointRight retains `char_1(nf_x)` only (plus eq_x and above_x conditions)

This gives `VecEA2 n` (not `VecEA2 0`) with:
- `endpointLeft(t)`: pre-conditions (y < t, y = t zones)
- `bracket(t, x)`: n witnesses with char_y_i at each, seg_guard between
- `endpointRight(x)`: `char_1(nf_x) ∧ eq_x conditions ∧ above_x conditions`

In this encoding, x IS definitionally shared by VecEA2.holdsLeft, and each y_i witness is IN (t, x) by the bracket semantics.

If Approach A (nested Until) is preferred over bracket witnesses, the nested Until formula must be placed as a SINGLE conjunction at endpointLeft using a SINGLE innermost Until with char_1(nf_x), not independent chains per SSN. The paper's construction (Prop 3.5) handles multiple witnesses by nesting them sequentially into ONE chain: ssn_1 at y_1, then ssn_2 at y_2, then ... then x at the end. But this requires ordering the SSNs, and it entangles the reconstruction.

---

## Recommended Approach

**For closing the forward_nf_eval_of_holdsLeft sorry**, use the bracket-based encoding:

1. Change `enriched_vecEA2_until` to use `VecEA2 n` where n = number of positive between_tx SSNs
2. Each positive between_tx SSN becomes a bracket point type (char_y_i at witness y_i)
3. Segment types are the seg_guard (neg char_y for negative between_tx SSNs)
4. endpointRight loses the Since conjuncts; x is only required to satisfy `char_1(nf_x)` and eq_x/above_x conditions

This makes the forward direction tractable:
- From bracket witnesses y_1, ..., y_n in (t, x), we directly extract the required existentials for `nf_eval_nf`
- No Since formula needs to be unwrapped — the witnesses are explicit in the bracket

The nested Until (Approach A) with a single chain works for ONE SSN at a time but requires sequential composition for multiple SSNs, which is more complex and harder to prove correct in Lean.

---

## Evidence from Codebase

### The x-sharing is semantic (VecEA2.holdsLeft), not syntactic

File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean`, lines 250–256

The single `∃ z1` in `holdsLeft` is the key. All conditions in `endpointRight` evaluate at this same `z1`. If we design the encoding so all between_tx conditions are in `endpointRight` as Since formulas, x is shared semantically. The problem is only in the forward direction — extracting `t < y` from `Since(char_y, top)` at x.

### The backward direction succeeds with Since (lines 2033–2047)

File: `KampBypass.lean`, lines 2033–2047. The backward direction succeeds because it has the concrete `x` witness and uses `between_tx_temporal_iff` to extract the existential y from nf_eval_quant, then wraps it into the Since formula. The forward direction cannot use `between_tx_temporal_iff` in reverse without knowing `t < y`.

### enriched_bypass_until disjuncts over nf_x (lines 495–509)

File: `KampBypass.lean`, lines 495–509. The outer disjunction over all compatible `nf_x` values means: within each disjunct, `nf_x` is fixed. The single VecEA2 for that disjunct has a single `z1` (= x). This DOES resolve x-sharing at the disjunct level — but only because `VecEA2.holdsLeft` semantically quantifies a single endpoint.

---

## Answers to Specific Questions

**Q1. Does the paper's construction handle multiple between-zone witnesses with a SINGLE nested Until, or with independent per-witness Untils?**

Answer: The paper (Prop 3.5) uses a SINGLE nested chain. Multiple witnesses are encoded sequentially: the chain goes through each witness point in order. There is no separate per-witness Until; they are nested inside each other.

**Q2. In the paper, is x (the right endpoint) FIXED by the outer formula structure, or does each witness chain independently determine its own x?**

Answer: x (= z_k, the free variable's position) is FIXED as the current time point being evaluated. The formula is evaluated AT x. The exists-forall formula describes what must hold relative to x. So x is not determined by the chain — it is given.

**Q3. Within a single disjunct (fixed nf_x), can we guarantee that all nested Until chains share the same x?**

Answer: YES — by the `VecEA2.holdsLeft` semantics, there is exactly ONE existential endpoint `z1`. All conditions in `endpointRight` must hold at this single `z1`. So x IS shared at the semantic level.

**Q4. If x IS shared, describe the exact encoding.**

The current encoding is architecturally correct for x-sharing (Since formulas in endpointRight all evaluate at the same z1). The problem is purely in the forward direction: unwrapping Since at x gives `∃ y' < x` but not `t < y'`. Fix: use bracket witnesses for between_tx SSNs instead of Since at endpointRight.

**Q5. If x is NOT shared, what modification resolves this?**

x IS shared (semantic answer). The modification needed is for the forward direction gap: use bracket-based between_tx witnesses rather than Since-at-x.

---

## Confidence Level

- **x IS shared by VecEA2.holdsLeft construction**: HIGH CONFIDENCE (definitional, not contingent)
- **Current Since-at-x encoding fails forward direction due to missing t < y lower bound**: HIGH CONFIDENCE (semantic analysis)
- **Bracket-based encoding fixes the forward direction**: HIGH CONFIDENCE (structural argument)
- **Nested Until (Approach A) at endpointLeft with single chain per SSN creates independent x endpoints**: HIGH CONFIDENCE (syntactic analysis of temporal semantics)
- **Paper (Prop 3.5) uses sequential nesting not independent chains**: HIGH CONFIDENCE (direct reading of Rabinovich 2014)
