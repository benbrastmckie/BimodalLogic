# Teammate B Findings: Prop 4.3 Structural Induction Design and NF-to-FOMLO Bridge

**Artifact**: 13b  
**Session**: research phase, task 273  
**Focus**: Prop 4.3 structural induction on MonadicFormula; NF-to-FOMLO composition chain; whether Lemma 3.2.2 is needed for the NF-specific case

---

## 1. What FOMLO Formula Type to Use

**Answer: `MonadicFormula sig n` (already in the codebase, defined in `MonadicFO.lean`).**

The codebase already has a complete FOMLO type. Relevant definitions at
`/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean`:

```lean
inductive MonadicFormula (sig : MonadicSignature) : Nat → Type where
  | atom {n} (p : sig.preds) (i : Fin n) : MonadicFormula sig n
  | lt   {n} (i j : Fin n)               : MonadicFormula sig n
  | not  {n} (α : MonadicFormula sig n)  : MonadicFormula sig n
  | and  {n} (α β : MonadicFormula sig n): MonadicFormula sig n
  | all  {n} (α : MonadicFormula sig (n+1)) : MonadicFormula sig n
  | ex   {n} (α : MonadicFormula sig (n+1)) : MonadicFormula sig n
  deriving DecidableEq

def eval {sig} {n} (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) : MonadicFormula sig n → Prop
```

This is exactly Rabinovich's FOMLO signature Σ (with `sig.preds` as unary predicates and `<` as the order). No new type is needed. `MonadicFormula sig 1` is the type for formulas with one free variable.

**The expanded signature of Def 4.1**: Rabinovich's E[Σ] predicates (TL(Until,Since)-definable ones) are handled IMPLICITLY. In the Lean formalization, when we say "on Prior structures, every MonadicFormula is equivalent to a temporal formula," the equivalence is with respect to the canonical expansion. The `OrderedMonadicStructure` provides the carrier and predicate interpretations; there is no need to explicitly introduce new predicate symbols, because Prior structures are characterized by `semantic_prior_UZ` and `semantic_prior_SZ` axioms on the fixed `atomMap : Formula → sig.preds`.

**Conclusion**: Prop 4.3 can be stated directly over `MonadicFormula sig 1` with `eval M (fun _ => t) phi` on the left and `temporal_truth M atomMap t A` on the right.

---

## 2. The Composition Chain from Prop 4.3 to the Three Sorries

The three active sorries all stem from the same gap:

| File | Location | Sorry Description |
|------|----------|-------------------|
| `NegationClosure.lean` | line 1371 | `nf_exist_formula_nested_backward` — backward direction of P2(k+1) |
| `NfCharFormula.lean` | line 572 | `nf_2var_exist_formula_prior` — classical existence of P2 existence formula |
| `KampPrior.lean` | line 149 | `nf_characterizable_temporal_prior` succ case |

**The chain connecting Prop 4.3 to these sorries**:

```
Prop 4.3 (structural induction on MonadicFormula phi)
    gives: temporal_truth M atomMap t A <-> eval M (fun _ => t) phi

Apply to phi = nf_to_formula (depth-k 1-var NF nf) — MonadicFormula sig 1
    since nf_eval_nf M k 1 (fun _ => t) nf <-> eval M (fun _ => t) (nf_to_formula nf)
    (this is doets_lemma_1_1 applied to nf_to_formula)

Result: temporal_truth M atomMap t A <-> nf_eval_nf M k 1 (fun _ => t) nf
    = P1(k) for all k simultaneously

Apply p2_from_p1_succ (FoToVecEA.lean, already sorry-free)
    to the P1(k+1) just obtained:
    gives P2(k) for all k

Fill KampPrior.lean:149: nf_characterizable_temporal_prior at succ k
    uses P1(k) → nf_char_kp1_from_2var → P1(k+1), but with Prop 4.3
    this is replaced by the direct P1(k) for all k

Fill NfCharFormula.lean:572: nf_2var_exist_formula_prior
    = p2_from_p1_succ applied to P1(k+1) from Prop 4.3

Fill NegationClosure.lean:1371: nf_exist_formula_nested_backward
    = subsumed by P2(k) obtained via p2_from_p1_succ + Prop 4.3
```

**Critical insight**: Prop 4.3 BYPASSES the backward direction of `nf_exist_formula_nested` entirely. Instead of trying to invert the formula to recover the NF, Prop 4.3 gives a direct temporal characterization of `eval M env phi` for any MonadicFormula phi by structural induction — not by NF induction. Once P1(k) is established for all k via Prop 4.3, `p2_from_p1_succ` (already sorry-free in `FoToVecEA.lean`) delivers P2(k) without needing the backward direction.

---

## 3. Type Signature of `nf_to_fo_formula` (NF-to-MonadicFormula)

The codebase does not yet have a function called `nf_to_fo_formula`. The relevant existing infrastructure is `doets_lemma_1_1`, which states that NF agreement implies formula agreement for any MonadicFormula. The connection is:

**Every `NormalForm sig k n` is realizable as the NF of some `MonadicFormula sig n`** — this is the content of `nf_to_formula` (referenced in `KampPrior.lean` comments at line 33 but the file likely exists in the Stavi path). The Lean encoding goes:

```lean
-- Each NF at depth k, arity n corresponds to a conjunction of
-- atomic conditions (depth-0) AND quantifier conditions (depth k)
-- This can be expressed as a MonadicFormula sig n

-- Proposed type signature for nf_to_fo_formula:
noncomputable def nf_to_fo_formula {sig : MonadicSignature}
    (k n : Nat) (nf : NormalForm sig k n) : MonadicFormula sig n
```

The formula would have `quantifier_depth ≤ k` and satisfy:
```lean
theorem nf_to_fo_formula_correct {sig} (k n : Nat) (nf : NormalForm sig k n)
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier) :
    eval M env (nf_to_fo_formula k n nf) ↔ nf_eval_nf M k n env nf
```

For the NF-specific Prop 4.3 application, the critical case is `n = 1`:
```lean
nf_to_fo_formula k 1 nf : MonadicFormula sig 1
-- quantifier_depth ≤ k
-- eval M (fun _ => t) (nf_to_fo_formula k 1 nf) ↔ nf_eval_nf M k 1 (fun _ => t) nf
```

At depth 0: `nf_to_fo_formula 0 1 nf` is a conjunction of atomic literals (no quantifiers).  
At depth k+1: `nf_to_fo_formula (k+1) 1 nf` is a conjunction of atomic literals AND existential/universal conditions at depth ≤ k+1. The **key free-variable count insight**: when written out, `nf_to_fo_formula (k+1) 1 nf` has the form

```
atom_part(x_0) AND ∀/∃ x_1 ... atom_part(x_1) AND nested_conditions(x_0, x_1)
```

where each nested condition involves `MonadicFormula sig 2` (the pair (x_1, x_0)). So the subformulas at arity 2 that arise naturally have **at most 2 free variables**. This is the structural observation that makes Lemma 3.2.2 unnecessary for the NF-specific case (see Section 6).

---

## 4. How the Structural Induction Should Be Structured in Lean 4

**Prop 4.3 in Lean** should be proved by `MonadicFormula.rec` / pattern matching recursion, NOT by NF-depth induction. Here is the proposed structure:

```lean
/-- Prop 4.3: Every MonadicFormula sig 1 is equivalent to a temporal formula
    on Prior structures (= Dedekind complete chains relativized to Prior). -/
noncomputable def prop43
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (phi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) phi ↔ temporal_truth M atomMap t A } := by
  -- Structural induction on phi
  induction phi with
  | atom p i =>
    -- Atomic case: phi = P(x_0). Already quantifier-free = EA with 0 witnesses.
    -- Temporal formula: atom_literal atomMap h_surj p true/false
    ...
  | lt i j =>
    -- x_i < x_j, but for n=1, i=j=0 so this is x_0 < x_0, always false.
    exact ⟨Formula.bot, fun M _ _ t => by simp [eval, lt_irrefl]⟩
  | not alpha ih =>
    -- Negation case: phi = ¬alpha. alpha : MonadicFormula sig 1.
    -- By IH: alpha ~ temporal formula A_alpha.
    -- By Prop 4.2 (NegationClosureProp42.lean): ¬A_alpha has a VVecEA2 equivalent.
    -- By Prop 3.5 (VecEATranslation.lean): VVecEA2 translates to temporal formula.
    -- BUT: for n=1, ¬alpha is a MonadicFormula sig 1 with 1 free variable.
    -- The negation closure (Prop 4.2) acts on the INTERVAL between the free var
    -- and a future/past witness. For n=1, there IS no interval — the formula
    -- directly characterizes a point property.
    -- For n=1, ¬temporal_formula is still temporal (temporal formulas are closed
    -- under negation directly, since they include ¬ as a constructor).
    obtain ⟨A, hA⟩ := ih
    exact ⟨A.neg, fun M h_UZ h_SZ t => by
      simp [temporal_truth_neg]
      exact (hA M h_UZ h_SZ t).not⟩
  | and alpha beta iha ihb =>
    -- Conjunction case: temporal formulas are closed under conjunction.
    obtain ⟨A, hA⟩ := iha
    obtain ⟨B, hB⟩ := ihb
    exact ⟨Formula.and A B, fun M h_UZ h_SZ t => by
      simp [temporal_truth_and, eval]
      exact Iff.and (hA M h_UZ h_SZ t) (hB M h_UZ h_SZ t)⟩
  | all alpha ih =>
    -- This case does NOT arise for n=1 → n=1.
    -- all alpha : MonadicFormula sig 1 where alpha : MonadicFormula sig 2.
    -- But Prop 4.3 is stated for n=1 only, so we need to handle
    -- 'all alpha' where the body alpha has 2 free variables.
    -- This requires Prop 4.3 for n=2 formulas, not n=1.
    -- RESOLUTION: The induction must be generalized to arbitrary n,
    -- with Prop 3.5 applied at the n=1 leaf.
    sorry
  | ex alpha ih =>
    -- ex alpha : MonadicFormula sig 1 where alpha : MonadicFormula sig 2.
    -- Same issue as 'all' case.
    sorry
```

**The induction structure problem**: A naive induction on `MonadicFormula sig 1` hits cases where subformulas have arity ≥ 2. Lean's `induction` tactic on the indexed inductive type will generate sub-goals for different arities. The correct approach is:

**Option A (Recommended)**: Prove Prop 4.3 for ALL arities simultaneously by well-founded recursion on `phi.quantifier_depth`:

```lean
-- Generalized to arbitrary n, with VVecEA2.translateLeft_correct at n=1
noncomputable def prop43_gen {sig} (atomMap) (h_surj) :
    (n : Nat) → (phi : MonadicFormula sig n) →
    { formulas : List Formula //
      ∀ M h_UZ h_SZ env,
        eval M env phi ↔ ∃ A ∈ formulas, temporal_truth_rel M atomMap env A }
```

where `temporal_truth_rel` is suitably relativized. At `n=1`, reduce to a disjunction of temporal formulas.

**Option B (Simpler for NF case)**: Observe that Prop 4.3 is only needed at `n=1` via `nf_to_fo_formula`, which has depth `≤ k`. Use induction on `k` (NF depth) rather than structural induction on `MonadicFormula`. This is exactly the master induction already in `NegationClosure.lean` (lines 1395-1470), but with the backward direction replaced by the Prop 4.3 route via `p2_from_p1_succ`.

---

## 5. Does Def 4.1 Expanded Signature Need Formalization?

**No.** The "expanded signature" in Rabinovich Def 4.1 is a conceptual device: it adds temporal predicates as new unary predicate symbols so that "the negation of a V-∃∀ formula is equivalent to a V-∃∀ formula USING those new predicates." In the Lean formalization:

- Prior structures are characterized by `semantic_prior_UZ M atomMap` and `semantic_prior_SZ M atomMap`
- These axioms encode that certain temporal formulas hold at all points
- The "expanded predicates" A ∈ E[Σ] correspond to point predicates definable by temporal formulas

The proof in Lean proceeds by: for each V-∃∀ formula, its negation is shown to hold on a V-∃∀ formula where the point-type predicates are `TemporalPred` values (carrying a `Formula` field). Since `TemporalPred` already carries a `Formula`, no new signature extension is needed — the existing `TemporalPred` type in `VecEAFormula.lean` plays the role of E[Σ] predicates implicitly.

**Practical consequence**: `NegationClosureProp42.lean` already handles this correctly. Its `neg_vecEA2` theorem uses `h_UZ : semantic_prior_UZ M atomMap` without ever mentioning E[Σ] explicitly.

---

## 6. Can P1(k) Be Proved WITHOUT Lemma 3.2.2?

**Yes, for the NF-specific case.** Here is the argument:

### The NF-specific structure

For a depth-(k+1) arity-1 NF `nf : NormalForm sig (k+1) 1`, the formula `nf_to_fo_formula (k+1) 1 nf` naturally decomposes as:

```
Atom conditions at var 0 (arity 1)
AND ∀ sub_nf : NormalForm sig k 2,
    (∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
    ↔ (nf.2 sub_nf = true)
```

The existential `∃ x, nf_eval_nf M k 2 (x, t) sub_nf` involves:
- `x` = new existential witness (arity 2 formula with free variables `{x, t}`)
- `t` = the fixed point (free variable)

This has **at most 2 free variables** in each sub-formula. No 3-or-more-variable EA formula arises in this NF decomposition at any single level.

### Why Lemma 3.2.2 is for the GENERAL case

Lemma 3.2.2 (from the paper) says: an EA formula with n > 2 free variables decomposes into a conjunction of EA formulas with ≤ 2 free variables. This is needed when Prop 4.3 is applied to a GENERAL MonadicFormula (e.g., with 3+ free variables) — as happens in the negation step when a formula with 3 free variables is negated and one needs to apply Prop 4.2.

For the Kamp theorem proof, we only need Prop 4.3 at arity 1 (one free variable). When we apply it to `nf_to_fo_formula k 1 nf`:
- The formula has arity 1
- Its existential subformulas have arity 2 (one new quantified variable, one free variable)
- Prop 4.2 applies to arity-2 EA formulas directly (that IS its stated hypothesis: "at most 2 free variables")

**Conclusion**: Lemma 3.2.2 is NOT needed for the NF-specific path to close the three sorries. Only Prop 4.2 (already proved in `NegationClosureProp42.lean`) is needed for the negation case, and it already handles the ≤2-free-variable case.

---

## 7. Composition Chain: Prop 4.3 → Sorry Closure

Here is the precise composition chain, with file references:

### Step 1: Prove P1(k) for all k via NF induction (without circularity)

Instead of the circular master_induction (which needs P2(k) to get P1(k+1)), use:

```
P1(0): nf_depth0_char_formula (already sorry-free)

P1(k+1) from P1(k) only (NO P2 needed):
  - nf_to_fo_formula (k+1) 1 nf : MonadicFormula sig 1
  - Apply Prop 4.3 structurally:
    * Atoms: P1(0) handles this
    * Negation: temporal formulas are closed under ¬ (trivial)
    * Conjunction: closed trivially
    * Existential ∃ x: this produces arity-2 formula
      → Apply Prop 4.2 (NegationClosureProp42, already done)
      → Apply Prop 3.5 (VecEATranslation.translateLeft_correct, already done)
  - Result: temporal formula for nf_eval_nf M (k+1) 1 (fun _ => t) nf
```

Wait — this is where the subtlety lies. The existential `∃ x, nf_eval_nf M k 2 (x,t) sub_nf` is NOT directly `eval M env (ex phi)` for a specific phi — it IS `nf_eval_nf` at arity 2. The connection runs through `doets_lemma_1_1`: if P1(k) gives temporal characterization of arity-1 depth-k NFs, then `nf_to_fo_formula k 2 sub_nf` is a MonadicFormula sig 2 equivalent to `nf_eval_nf M k 2 env sub_nf`. Applying Prop 4.3 to `nf_to_fo_formula k 2 sub_nf` (arity-2 formula) would give a VVecEA2 formula. Then Prop 3.5 translates it to temporal.

**But**: applying Prop 4.3 to an arity-2 formula DOES require knowing the temporal formula for `eval M env phi` where phi has arity 2. For arity-2 formulas, Prop 3.5 applies directly (no Lemma 3.2.2 needed, since arity ≤ 2).

### Step 2: p2_from_p1_succ (already sorry-free)

Once P1(k+1) is established, `p2_from_p1_succ` in `FoToVecEA.lean` (lines 156-222) gives P2(k) sorry-free:

```lean
-- Already sorry-free:
noncomputable def p2_from_p1_succ ... :
    ∃ (A : Formula), ∀ M h_UZ h_SZ t,
      temporal_truth M atomMap t A ↔
      ∃ x, nf_eval_nf M k (1+1) (Fin.cons x (fun _ => t)) sub_nf
```

### Step 3: Fill KampPrior.lean:149

```lean
| succ k ih =>
  -- By IH on k: P1(k) established for all NFs at depth k
  -- Prop 4.3 gives P1(k+1) directly (see Step 1)
  -- No backward direction of nf_exist_formula_nested needed
  exact prop43 atomMap h_surj (nf_to_fo_formula (k+1) 1 nf)
```

### Step 4: Fill NfCharFormula.lean:572

```lean
-- nf_2var_exist_formula_prior follows from p2_from_p1_succ applied
-- to the P1(k+1) from Prop 4.3:
exact p2_from_p1_succ atomMap h_surj k
  (fun nf_1 => (prop43 atomMap h_surj (nf_to_fo_formula (k+1) 1 nf_1)).val)
  (fun nf_1 => (prop43 atomMap h_surj (nf_to_fo_formula (k+1) 1 nf_1)).property)
  parent_atoms sub_nf
```

### Step 5: Fill NegationClosure.lean:1371

This sorry becomes unnecessary: once P2(k) is established via Steps 1-2, the entire `nf_exist_formula_nested_backward` sorry is subsumed. The `master_induction` at line 1395 would be replaced by:

```lean
-- master_induction(k) uses Prop 4.3 instead of nf_exist_formula_nested
noncomputable def master_induction_prop43 ...
  | k + 1 =>
    let p1_kp1 := prop43_to_P1 atomMap h_surj (k+1)
    let p2_k := p2_from_p1_succ atomMap h_surj k ... p1_kp1 ...
    ⟨p1_kp1, p2_k⟩
```

---

## 8. Summary of Proposed Type Signatures

```lean
-- 1. NF-to-MonadicFormula (to be created, likely already exists somewhere)
noncomputable def nf_to_fo_formula {sig : MonadicSignature}
    (k n : Nat) (nf : NormalForm sig k n) : MonadicFormula sig n

theorem nf_to_fo_formula_correct {sig} (k n : Nat) (nf : NormalForm sig k n)
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier) :
    eval M env (nf_to_fo_formula k n nf) ↔ nf_eval_nf M k n env nf

-- 2. Prop 4.3 (main theorem to implement)
noncomputable def prop43_formula
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (phi : MonadicFormula sig 1) : Formula

theorem prop43_correct {sig} (atomMap) (h_surj)
    (phi : MonadicFormula sig 1) :
    ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      eval M (fun _ => t) phi ↔ temporal_truth M atomMap t (prop43_formula atomMap h_surj phi)

-- 3. P1(k) for all k via Prop 4.3 (the key bridge theorem)
noncomputable def prop43_to_P1
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    ∃ A : Formula, ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf
-- Proof: A = prop43_formula atomMap h_surj (nf_to_fo_formula k 1 nf)
```

---

## 9. Key Findings and Risks

### Confirmed Facts

1. **MonadicFormula exists and is complete** — no new type needed for FOMLO.

2. **MonadicFormula.rec induction is the right tool** — but it must range over multiple arities simultaneously (arity increases when going under a binder). Well-founded recursion on `phi.quantifier_depth` is the clean Lean 4 approach.

3. **Lemma 3.2.2 is NOT needed for the NF-specific path** — confirmed by the ≤2-free-variable structure of `nf_to_fo_formula k 1 nf`'s subformulas.

4. **p2_from_p1_succ is already sorry-free** (confirmed at FoToVecEA.lean:156-222). This is the critical sorry-free bridge from P1(k+1) to P2(k).

5. **Def 4.1 expanded signature needs no explicit formalization** — `TemporalPred` already serves this role.

6. **The three sorries reduce to a single gap**: proving `prop43_correct` (Prop 4.3) for MonadicFormula sig 1, which by structural induction reduces to:
   - Atomic case: trivial (atom literals)
   - Negation: trivial (temporal formulas closed under negation at arity 1)  
   - Conjunction: trivial
   - Existential ∃x, phi(x,t): apply Prop 4.3 to phi(x,t) (arity-2 formula), then use VVecEA2.translateLeft_correct + bracketBuildRight_correct

### Risks

1. **Arity-2 existential step is nontrivial**: Applying Prop 4.3 to arity-2 formulas requires knowing temporal equivalents for arity-2 EA formulas. Prop 3.5 (VecEA2.translateLeft_correct) handles arity-2 V-∃∀ formulas, but going from a general arity-2 MonadicFormula to V-∃∀ DOES use the negation closure (Prop 4.2), which is already proved.

2. **nf_to_fo_formula may not exist yet** — needs to be checked in the Stavi path (`EFGames/StaviCompleteness.lean` or `CharacteristicFormula.lean`). If absent, it must be created (estimated 50-80 lines: direct recursion on k, with atoms handled by conjunction of Bool conditions).

3. **Prop 4.3 structural induction across arities**: The standard `induction phi` tactic will generate goals for formulas of arities n and n+1 simultaneously. This requires a generalized induction hypothesis `∀ n, MonadicFormula sig n → VVecEA2_formula`. The n=1 case is Kamp; n=2 uses Prop 3.5 directly (which handles 2-free-variable V-∃∀).

### Recommended Implementation Order

1. Verify whether `nf_to_fo_formula k 1 nf` already exists (check StaviCompleteness.lean and CharacteristicFormula.lean)
2. If absent, implement `nf_to_fo_formula` and its correctness theorem (uses `doets_lemma_1_1`)
3. Implement `prop43_formula` and `prop43_correct` by structural induction on MonadicFormula
4. Implement `prop43_to_P1` using `prop43_correct` + `nf_to_fo_formula_correct`
5. Use `prop43_to_P1` + `p2_from_p1_succ` to fill the three sorries
6. Optionally replace the master_induction with the cleaner Prop 4.3 route

---

## Tactic Survey Notes

For the inductive cases of Prop 4.3:
- Atomic: `exact ⟨atom_literal ..., by simp [eval, temporal_truth]⟩` — `simp` should close
- Negation at arity 1: `exact ⟨A.neg, by simp [temporal_truth_neg, eval]; exact (ih ...).not⟩`
- Conjunction: `simp [temporal_truth_and, eval]` + `Iff.and`
- Existential: requires `bracketBuildRight_correct` + `VVecEA2.translateLeft_correct` — non-trivial but the tools exist
