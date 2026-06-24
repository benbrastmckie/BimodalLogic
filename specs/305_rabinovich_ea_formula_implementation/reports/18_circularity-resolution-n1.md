# Circularity Resolution for the n=1 Critical-Path Sorry (KampPrior.lean:406)

- **Task**: 305 — rabinovich_ea_formula_implementation
- **Type**: lean4
- **Session**: sess_1782318374_f18952
- **Agent**: lean-research-hard-agent (H2+H3+H4+H5)
- **Tier**: 1 (literature-backed: Rabinovich 2014, lean4 strict)
- **Artifact**: 18

---

## 0. Executive Summary

The sorry at `KampPrior.lean:406` (n=1 case of `nf_nvar_exist_all_depths` at depth k+1)
is the SOLE critical-path blocker for `kamp_prior_expressive_completeness`. The handoff
(v33-phase-3-dispatch-2) frames it as a **fixed-point circularity**: building the formula for
`exist(k+1,1)` requires `char(k+2)`, which requires `exist(k+1,1)`.

**The central finding of this research: the circularity is an ARTIFACT of one particular
construction strategy (NF-disjunction at depth k+2), NOT a mathematical necessity.** The
arity-tower resolution that was already proved sound and implemented for the depth-0 base case
(`nf_nvar_exist_depth0_tl`, NfDepth0Generalized.lean:1267) and recommended in report 19 applies
directly to the n=1 case. The structural recursion `nf_nvar_exist_all_depths` is defined by the
equation compiler on `k` (arms `| 0` and `| k+1`), so its induction hypothesis is available at
**depth k for ALL arities**. The existing code at line 313 only ever invokes the IH at arity 2
(`... k 1 sub_nf'`); it never invokes it at arity 3 (`... k 2 _`), which is exactly what the
quantifier layer of an arity-2 NF needs. There is no call to `char(k+2)` anywhere in the correct
construction.

**RECOMMENDATION: A hybrid of Approach 5 and Approach 2 — concretely, "generalize
`nf_succ_char_formula` to arity 2" (call it `nf_succ_char_formula2`) and feed it the IH at depth
k arity 3.** This is Approach 5's content (build the pair-(x,t) characteristic formula directly,
then existentially bind x) realized through the existing NF + VecEA_m machinery. Approach 2
(mutual `char`/`exist` definition) is **NOT recommended**: as analyzed below, the naive mutual
def does not strictly decrease, and the staggered version that does decrease is exactly the
single-recursion-on-k structure we already have.

- Approach 5 (direct, via arity-2 char + existClosure): **HIGH confidence**, ~250-400 lines, MEDIUM risk.
- Approach 2 (mutual def): **does not close the loop as stated**; the only well-founded form
  collapses to the existing single recursion. LOW confidence as a distinct approach.

---

## 1. Sorry Inventory (Verified)

| # | File:Line | Critical? | Statement | Verification |
|---|-----------|:---------:|-----------|--------------|
| 1 | KampPrior.lean:406 | **YES** | `nf_nvar_exist_all_depths` k+1, n=1 arm | Confirmed via def return type + match arm |
| 2 | KampPrior.lean:409 | No | `nf_nvar_exist_all_depths` k+1, n≥2 arm | Off critical path (main theorem needs n=0,1 only) |

**Verification method**: `lean_goal` at lines 405/406 returns `null` goals (term-mode `match`
arm sorry; the warning told us this would happen). The goal is established from the def
signature (lines 257-263) instantiated at the n=1 arm plus the n=0 template (lines 379-386):

```
-- n = 1 goal:
∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig)
  (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
  (t : M.carrier),
  temporal_truth M atomMap t A ↔
  ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k + 1) 2 (insertEnv env t) sub_nf
```

`lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds (992 jobs); the only
non-lint warning is `declaration uses 'sorry'` at line 252. **Green baseline confirmed.**
**Confidence: HIGH.**

### Verified return-type unfolding (the semantic content of the n=1 goal)

`nf_eval_nf M (k+1) 2 (x,t) sub_nf` unfolds (NormalForm.lean:198-207, `k+1` arm) to:

```
(∀ a : AtomKind sig 2, atom_eval M (x,t) a ↔ sub_nf.1 a = true)         -- atom layer, arity 2
∧
(∀ qnf : NormalForm sig k 3,                                            -- quantifier layer
   (∃ y, nf_eval_nf M k 3 (Fin.cons y (x,t)) qnf) ↔ sub_nf.2 qnf = true)
```

Both layers reference **only depth k** (the quantifier layer's existentials are depth-k arity-3).
Nothing here requires depth k+2.

---

## 2. Dependency-Chain Diagrams (the proof of whether circularity is broken)

### 2.1 The claimed circularity (handoff's NF-disjunction-at-k+2 strategy)

```
exist(k+1, 1, sub_nf)                                  [arity-2 NF, depth k+1, bind 1 var]
  := ⋁ { nf' : NF(k+2,1) | nf'.2 sub_nf } of char(k+2, nf')
                       │
                       ▼
char(k+2, nf') = nf_succ_char_formula(exist_1var_fn, nf')   [arity-1 NF, depth k+2]
                       │  needs exist_tl_fn : NF(k+1, 2) → Formula
                       ▼
exist_1var_fn = exist(k+1, 1, ·)        ◄────── SAME function, SAME (depth k+1, arity 2)  ✗ CYCLE
```

This cycle is real **for this strategy**: it climbs to depth k+2 and then must come back down to
`exist(k+1,1)`. Measure `2k+n` is constant (2(k+1)+1 = 2k+3 at both ends). **The strategy is the
problem, not the theorem.**

### 2.2 Approach 5 (recommended): direct arity-2 characteristic + existClosure

```
exist(k+1, 1, sub_nf)                                  [GOAL: ∃ x, NF(k+1,2)(x,t)]
  = ∃ x, [ atomLayer2(x,t)  ∧  quantLayer2(x,t) ]
                 │                      │
   (depth-0 arity-2 atoms)   (∀ qnf:NF(k,3). (∃ y, NF(k,3)(y,x,t) qnf) ↔ sub_nf.2 qnf)
                 │                      │
                 ▼                      ▼
   nf_depth0_char (sorry-free)   IH: nf_nvar_exist_all_depths atomMap h_surj  k  2  qnf
                                         └──────── depth k, arity 3, bind 2 vars (y AND x)
                                                   STRICTLY SMALLER depth than k+1  ✓
                       │
   Build pair-char formula char2(sub_nf) : 1-free-var-in-(x,t) characterisation
                       │  (this is "nf_succ_char_formula generalised to arity 2")
                       ▼
   Bind x:  exist(k+1,1,sub_nf) := existClosure / translateEF1 over char2(sub_nf)
                       │  (VecEA_m.existClosure  OR  the Until/Since pair construction)
                       ▼
                   Formula      ◄────── depends ONLY on depth-k IH.  NO depth k+2.  ✓ ACYCLIC
```

The recursion measure is **depth k alone**, strictly decreasing k+1 → k. Arity rises 2 → 3 but
the IH (the equation-compiler IH of `nf_nvar_exist_all_depths` on the k+1 arm) covers **all
arities at depth k**, including arity 3. This is precisely the arity-tower argument (report 19
§2, "THIS IS THE ARITY TOWER RESOLUTION") and it is already validated at depth 0.

**Decisive code evidence**: line 313 calls `nf_nvar_exist_all_depths atomMap h_surj k 1 sub_nf'`
(arity 2 only). The fix is to ALSO call it at `k 2` for the quantifier layer of the arity-2 char.
The IH is in scope — it is the function being defined recursing on a strictly smaller k.

### 2.3 Approach 2 (mutual def): does it close the loop?

Proposed: `combined(k) := (char_{k+1} : NF(k+1,1)→Formula, exist_{k+1}_1 : NF(k+1,2)→Formula)`
by `Nat.rec` on k.

```
combined(k+1).exist  needs  char(k+2, ·)  =  combined(k+1).char  ... no, char_{k+2} = combined(k+1)?
```

The indexing is the trap. To build `exist_{k+1}_1` via the NF-disjunction-at-k+2 strategy you
need `char_{k+2}`, but `combined(k)` only produces `char_{k+1}`. So you would need
`combined(k+1).char` to be `char_{k+2}` — off by one — and `combined(k+1).exist` to be
`exist_{k+1}_1`. Then `combined(k+1).exist` calls `combined(k+1).char` (same recursion step):
**a self-reference WITHIN one `Nat.rec` step, which the equation compiler rejects unless one
component is defined strictly before the other.** Within a single step neither is "earlier", so
the measure does not decrease. To make it decrease you must define `char` purely from the
PREVIOUS step's `exist` (depth k) — but that is exactly Approach 5's single recursion on k, with
`char` and `exist` not actually mutual. **Conclusion: the only well-founded "mutual" def
degenerates to Approach 5.** Approach 2 adds no power and significant encoding pain
(`noncomputable mutual` with dependent `NormalForm sig k n` indices). See §3 for the skeleton
and the refutation of termination.

---

## 3. Approach 2 Concrete Skeleton + Termination Verdict

Mutual-def skeleton (the form the handoff proposes):

```lean
mutual
  noncomputable def charM (atomMap) (h_surj) :
      (k : Nat) → NormalForm sig (k + 1) 1 → Formula
    | k, nf => nf_succ_char_formula atomMap h_surj (existM atomMap h_surj k) nf
    --                                              └── needs exist at depth k, arity 2  (NF(k,2))

  noncomputable def existM (atomMap) (h_surj) :
      (k : Nat) → NormalForm sig k 2 → Formula
    | 0,     sub => nf_2var_exist_depth0_tl_fn atomMap h_surj sub          -- base, depth 0
    | k + 1, sub => /- needs char at depth k+2 OR exist at depth k arity 3 -/
        ⋁ { nf' : NF (k+2) 1 | nf'.2 sub } of charM atomMap h_surj (k+1) nf'
        --                                    └── charM at depth k+2 (index k+1 ⇒ NF(k+2,1))
end
termination_by
  charM k _ => (k, 1)
  existM k _ => (k, 0)
```

**Termination check (decreasing measure on lexicographic `(k, tag)` with tag char>exist):**

- `charM (k) nf  →  existM (k) sub`: measure `(k,1) → (k,0)`. Strictly decreases (tag). ✓
- `existM (k+1) sub  →  charM (k+1) nf'`: measure `(k+1,0) → (k+1,1)`. **INCREASES** (tag goes
  0→1 at the same k). ✗ **NON-DECREASING — the equation compiler will reject this.**

There is no tag assignment that makes both edges decrease, because the strategy creates a
char→exist edge AND an exist→char edge at the **same k**. A 2-cycle in the call graph at constant
k cannot be ranked by any well-founded measure. **Termination REFUTED for the
NF-disjunction-at-k+2 mutual form.**

The only repair is to make `existM (k+1)` call `charM` at a strictly smaller k, or call `existM`
at a strictly smaller k. The latter is Approach 5 (call `existM`/the all-depths function at depth
k, arity 3). At that point `char` and `exist` are no longer mutually recursive — `char` is
derivable, not primitive. **Verdict: Approach 2 as a distinct mechanism is unsound; it must be
demoted to Approach 5.**

---

## 4. Approach 5 Concrete Construction (recommended)

### 4.1 What must be built

The arity-1 helper `nf_succ_char_formula` (KampPrior.lean:107-118) characterises an arity-1 NF
at depth k+1 given `exist_tl_fn : NF(k,2)→Formula`. **We need its arity-2 analogue**, because
the n=1 case must characterise an arity-2 NF (the pair (x,t)), then bind x.

**New definition** `nf_succ_char_formula2` — characteristic of an arity-2 NF at depth k+1:

```lean
noncomputable def nf_succ_char_formula2
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p, ∃ a, atomMap (.atom a) = p)
    {k : Nat}
    (exist_tl_fn3 : NormalForm sig k 3 → Formula)   -- ← IH at depth k, arity 3
    (nf : NormalForm sig (k + 1) 2) : Formula
```

with target correctness (the pair (x,t) is characterised; x is the bound slot, t the free slot):

```
temporal_truth M atomMap t (nf_succ_char_formula2 … nf)  -- AFTER binding x via existClosure
  ↔  ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) nf
```

The decomposition mirrors `nf_succ_char_formula_correct` (lines 143-146) but at arity 2:

```
nf_eval_nf M (k+1) 2 (x,t) nf
  = (atom layer: ∀ a:AtomKind sig 2, atom_eval M (x,t) a ↔ nf.1 a)          -- depth-0 arity-2
  ∧ (quant layer: ∀ qnf:NF(k,3), (∃ y, nf_eval_nf M k 3 (y,x,t) qnf) ↔ nf.2 qnf)
```

`exist_tl_fn3 qnf` characterises `∃ y, nf_eval_nf M k 3 (y,x,t) qnf` as a formula in the pair
(x,t) — supplied by the IH `nf_nvar_exist_all_depths atomMap h_surj k 2 qnf` (depth k, n=2, binds
y AND x, leaving t free)... see §4.3 for the precise bridge. The atom layer uses `nfPredAtPos`
(NfDepth0Generalized.lean:62) + order literals between the two positions.

### 4.2 Binding x: the three y-zones inside, and the x-binding outside

There are TWO existential bindings in the n=1 case: the outer `∃ x`, and the inner `∃ y` of each
quantifier clause. The literature (Rabinovich Prop 3.5, §3 of the paper) maps each existential
witness in an interval decomposition directly to nested Until/Since. Our machinery already
encodes Prop 3.5 as `translateEF1` (Translation.lean:243, `translateEF1_correct`, sorry-free) and
its disjunctive lift `translateVEF1`, plus `VecEA_m.existClosure` (VecEA_m.lean:208) with BOTH
directions proved (`existClosure_correct` :251, `existClosure_correct_rev` :314).

**Inner `∃ y` (depth-k arity-3 → pair (x,t)).** This is delegated wholesale to the IH; we do NOT
re-derive the y-zone split by hand. `nf_nvar_exist_all_depths atomMap h_surj k 2 qnf` already
performs the y-zone decomposition (y<x, x<y, etc. and relative to t) internally — at depth 0 via
`nf_nvar_exist_depth0_tl` (which IS the all-zone arity decomposition, NfDepth0Generalized.lean),
and at depth k recursively. The three y-zones the handoff worries about (y<x, x<y<t, y>t) are
**already handled by the existing all-arity converter**; their decomposition is the content of
`nf_nvar_exist_depth0_tl_succ` (the merge/zone machinery, lines 390-585). This is the key point:
**we reuse, not rebuild, the bounded-interval-existential machinery.**

**Outer `∃ x`.** Once `char2(sub_nf)` characterises the pair (x,t) as a formula `B(x,t)` with one
free variable convention (x bound, t free), bind x with the existing 1-variable existential
binder. Two equivalent vehicles:
- (a) `VecEA_m.existClosure` + `VVecEA_m` translation (VecEA_m.lean), or
- (b) the same path the depth-0 arity-2 case uses: `nf_2var_exist_depth0_tl`'s pattern
  (`translateEF1` future/past chains).

### 4.3 The cleanest realization (minimizes new code)

Rather than write `nf_succ_char_formula2` from scratch, observe: **the n=1 case is structurally
identical to `nf_characterizable_temporal_prior`'s succ case (lines 470-519), one arity up.**
That existing (sorry-free) proof builds `exist_tl_fn = nf_nvar_exist_all_depths_fn k 1` and feeds
it to `nf_succ_char_formula`. The n=1 case should build `exist_tl_fn3 = nf_nvar_exist_all_depths_fn k 2`
and feed it to the new `nf_succ_char_formula2`, then existentially bind the extra variable. The
Fin.cons / insertEnv bridge needed is exactly the one already proved twice in this file (lines
317-331 and 497-513): `insertEnv env t = Fin.cons (env 0) (fun _ => t)` for `env : Fin 1`,
generalized to `Fin 2`.

**Only genuinely new artifact**: `nf_succ_char_formula2` + its correctness (the arity-2
generalization of lines 107-177) and the arity-2 existential binder. Everything else is reuse.

### 4.4 Verification that Approach 5 depends only on the depth-k IH

Dependency closure of the construction:
- `nf_depth0_char_formula`, `nfPredAtPos` — depth 0, sorry-free. ✓
- `nf_nvar_exist_all_depths atomMap h_surj k 2` — depth k, the in-scope structural IH. ✓
- `nf_succ_char_formula2` — new, references only the above + Fin/insertEnv lemmas. ✓
- `VecEA_m.existClosure` / `translateEF1` — sorry-free, depth-agnostic. ✓
- **No reference to `nf_*` at depth k+2 anywhere.** ✓

The recursion terminates because the equation compiler's `k+1 → k` step is structural; the IH is
the def itself at depth k, available at every arity. **Confidence: HIGH** that the cycle is
broken (it was never a real cycle — only the k+2 strategy created one).

---

## 5. H3 Reference-Grounding: 5-Column Lemma-Mapping Table

| Rabinovich concept | Paper location | Lean identifier | Type signature (verified) | Status |
|---|---|---|---|---|
| Exists-forall normal form | Def 3.1 (lit §3) | `NormalForm sig k n` | `NormalForm : Nat→Nat→Type`; `0,n ↦ AtomKind→Bool`; `k+1,n ↦ (AtomKind→Bool)×(NF k (n+1)→Bool)` | Exists, sorry-free (NormalForm.lean:134) |
| NF satisfaction (interval decomposition holds) | Def 3.1 semantics | `nf_eval_nf` | `(M)→(k n:Nat)→(Fin n→carrier)→NF sig k n→Prop` | Exists, sorry-free (NormalForm.lean:198) |
| Each (M,env) satisfies exactly one EF type | Lemma (uniqueness, used by Prop 4.3) | `nf_exists_unique` | `∀ M k n env, ∃! nf, nf_eval_nf M k n env nf` | Exists, sorry-free (NormalForm.lean:277) |
| Prop 3.5: V-EA(1 free var) ⇒ TL(U,S) | Prop 3.5 (lit §3, lines 87-94) | `translateEF1` / `translateEF1_correct` | `temporal_truth t (translateEF1 n k α β) ↔ α_k(t) ∧ rightChain ∧ leftChain` | Exists, sorry-free (Translation.lean:243) |
| Interval ⇒ nested Until/Since (right) | Prop 3.5 future chain | `buildRight` / `buildRight_correct` | `temporal_truth t (buildRight pairs rm) ↔ buildRight_spec …` | Exists, sorry-free (Translation.lean) |
| Interval ⇒ nested Since (left) | Prop 3.5 past chain | `buildLeft` / `buildLeft_correct` | `temporal_truth t (buildLeft pairs lm) ↔ buildLeft_spec …` | Exists, sorry-free (Translation.lean:199) |
| Lemma 3.4: ∃-closure of V-EA | Lemma 3.4 (lit §3, line 85) | `VecEA_m.existClosure` (+ `_correct`, `_correct_rev`) | `VecEA_m (m+1) → VecEA_m m`; both directions proved | Exists, sorry-free (VecEA_m.lean:208/251/314) |
| Char formula for arity-1 NF at depth k+1 | (construction layer) | `nf_succ_char_formula` / `_correct` | `(exist_tl_fn:NF k 2→Formula)→NF (k+1) 1→Formula`; `temporal_truth t (…) ↔ nf_eval_nf M (k+1) 1 (fun_⇒t) nf` | Exists, sorry-free (KampPrior.lean:107/121) |
| Char formula for arity-2 NF at depth k+1 | (construction layer, NEW) | `nf_succ_char_formula2` (TO BUILD) | `(exist_tl_fn3:NF k 3→Formula)→NF (k+1) 2→Formula` | **MISSING — primary new artifact** |
| Depth-0 all-arity ∃ converter (base case) | (infrastructure) | `nf_nvar_exist_depth0_tl` / `_fn_correct` | `NF 0 (n+1) → ∃A, temporal_truth t A ↔ ∃env:Fin n, nf_eval_nf M 0 (n+1) (insertEnv env t) sub_nf` | Exists, sorry-free (NfDepth0Generalized.lean:1267) |
| All-depth all-arity ∃ converter | Prop 4.3/4.4 analog | `nf_nvar_exist_all_depths` (the IH) | `(k n)→NF k (n+1)→∃A, temporal_truth t A ↔ ∃env:Fin n, nf_eval_nf M k (n+1) (insertEnv env t) sub_nf` | Exists; **2 sorries (n=1, n≥2 at k+1)** (KampPrior.lean:252) |
| insertEnv / Fin.cons bridge | (encoding) | `insertEnv`, `insertEnv_zero`, `insertEnv_last`, `insertEnv_init` | `(Fin n→α)→α→(Fin (n+1)→α)` etc. | Exists, sorry-free (NfDepth0Generalized.lean:42-56) |
| Main result: FOMLO(1 var) ⇒ TL(U,S) | Thm 4.4 (lit §4, line 112) | `kamp_prior_expressive_completeness` | every `MonadicFormula sig 1` has equivalent temporal formula on Prior structures | Depends on sorry #1 only (KampPrior.lean:535) |

---

## 6. H4 Adversarial Self-Verification

### Challenge 1: "Is the circularity really an artifact, or did the handoff find a true obstruction?"
**Adversarial test**: Construct the dependency chain for Approach 5 and check for ANY edge that
reaches depth k+2 or returns to `exist(k+1,1)`. Done in §2.2/§4.4: every dependency is at depth
≤ k. The only depth-k+2 reference is in the NF-disjunction-at-k+2 strategy (§2.1), which Approach
5 abandons. **The code itself confirms the IH is structural on k (equation-compiler `| 0 | k+1`
arms, verified by grep: the only self-call is at line 313, arity 1).** The handoff's "fundamental
mathematical difficulty" claim conflated one strategy with the theorem.
**VERIFIED. Confidence: HIGH.**

### Challenge 2: "Does the depth-k IH at arity 3 actually exist and have the right type?"
**Adversarial test**: The IH is `nf_nvar_exist_all_depths` applied at `(k, 2)` from within the
`k+1` arm. Is `(k,2)` structurally smaller? Yes — `k < k+1` and the equation compiler accepts any
arity at the smaller depth. The return type at `(k,2)` is
`∃A, temporal_truth t A ↔ ∃env:Fin 2, nf_eval_nf M k 3 (insertEnv env t) qnf`. The quantifier
layer needs `∃ y, nf_eval_nf M k 3 (Fin.cons y (x,t)) qnf` — a SINGLE existential over y with x,t
FIXED, not a double existential over (y,x). **This is a real gap**: the IH at `(k,2)` binds TWO
variables; the quantifier clause binds ONE (y) with x already chosen by the outer ∃x.
**Resolution**: This is exactly why the construction characterises the PAIR (x,t) first
(`nf_succ_char_formula2` producing a formula in (x,t)) and binds x LAST. Inside `char2`, the
clause `∃ y, nf_eval_nf M k 3 (y,x,t) qnf` is a formula in the FREE pair (x,t) — supplied by the
arity-1-in-x version of the IH, i.e. `nf_nvar_exist_all_depths_fn k 2` gives `∃ over Fin 2`
which, combined with the outer `∃ x`, telescopes correctly via the `insertEnv`/`Fin.cons` bridge
(the same telescoping already proved at lines 317-331). The bridge requires care.
**PARTIALLY VERIFIED. Confidence: MEDIUM-HIGH.** The telescoping of "outer ∃x ∘ inner ∃y" into
the IH's `∃env:Fin 2` is the main proof obligation; the bridge lemma pattern exists in-file but
must be generalized from Fin 1 to Fin 2. This is the principal implementation risk.

### Challenge 3: "Does Approach 2's mutual def truly fail to terminate?"
**Adversarial test**: Try to find ANY well-founded measure ranking both call-graph edges
(`char(k)→exist(k)` and `exist(k+1)→char(k+1)`). With the k+2 strategy, `exist(k+1)` calls
`char(k+2)` = `charM` at index `k+1` (since `charM` at index j produces `NF(j+1)`). So the edge is
`existM(k+1) → charM(k+1)`, same index. Combined with `charM(k)→existM(k)`, at constant index
there is a char↔exist 2-cycle ⇒ no measure exists. **REFUTED (Approach 2 unsound as stated).
Confidence: HIGH.** The "fix" (call exist at depth k arity 3) is Approach 5.

### Challenge 4: "Is `VecEA_m.existClosure` bidirectional and applicable to bind x?"
**Adversarial test**: Verified both `existClosure_correct` (VecEA_m.lean:251, forward) and
`existClosure_correct_rev` (:314, backward) exist and are sorry-free (grep + read). The binder
absorbs the rightmost free variable, matching "bind x, keep t". However, bridging the NF
characteristic `char2` into a `VecEA_m` value requires a `NF → VecEA_m` constructor; report 19
noted VecEA_m types exist but the NF→VecEA_m bridge may be partial. **Alternative vehicle**: the
depth-0 arity-2 case (`nf_2var_exist_depth0_tl`, sorry-free) binds one variable WITHOUT VecEA_m,
using `translateEF1` directly — this is the safer path. **VERIFIED existClosure exists; MEDIUM
confidence it is the cheapest binder.** Recommend the `translateEF1`/`nf_2var_exist_depth0_tl`
pattern as primary, VecEA_m as fallback.

### Challenge 5: "Line estimate 250-400 realistic?"
Reference points (all read): `nf_succ_char_formula` + correctness ≈ 70 lines (107-177);
`nf_characterizable_temporal_prior` succ case ≈ 50 lines (470-519); the Fin-bridge blocks ≈ 15
lines each. The arity-2 generalization roughly doubles the arity-1 char (order literals between
two positions add cases). Existential binding of x reuses the depth-0 arity-2 pattern (~40 lines
to adapt). **Estimate 250-400 lines. Confidence: MEDIUM** (could reach 500 if the (x,t) order-zone
handling in `char2` needs the full 3-way x-vs-t split written explicitly rather than delegated).

### Forbidden-output check (H2)
No "mathlib likely has this" without a search. All claims grounded in read source + grep + one
scoped `lake build`. No `sorry`/axiom deferral recommended. No `simp`/`omega` proposed to bypass
literature steps (the literature step — Prop 3.5 interval→U/S — is realized faithfully via
`translateEF1`). **Clean.**

---

## 7. H5 Divergence Audit (focus_prompt did not request audit; included briefly given churn)

`focus_prompt` does not contain "divergence"/"audit", so full H5 is not activated. Brief note
given 13+ dispatches: the churn on this sorry traces to **repeatedly re-deriving the circularity
under the k+2 strategy** (handoffs phase-2 through phase-3-dispatch-2) instead of invoking the
already-proved arity-tower IH at arity 3. Root cause: `nf_succ_char_formula` exists only at arity
1, so each dispatch reached for the k+2 NF-disjunction to characterise the arity-2 NF, recreating
the cycle. The corrected lean-ready target is the single new def `nf_succ_char_formula2` (§4.1).

---

## 8. RECOMMENDATION

**Adopt Approach 5** (direct construction via an arity-2 characteristic formula fed by the
depth-k arity-3 IH, then bind the outer variable). **Do NOT pursue Approach 2** (mutual def):
its terminating form is identical to Approach 5, and its naive form is non-terminating (§3, §6
Challenge 3).

### Concrete implementation steps

1. **Add `nf_succ_char_formula2`** (arity-2 analogue of KampPrior.lean:107): takes
   `exist_tl_fn3 : NormalForm sig k 3 → Formula`, produces a formula characterising
   `NormalForm sig (k+1) 2` in the pair (x,t). Atom layer via `nfPredAtPos` + order literal
   between positions 0 and 1; quant layer via `nf_quant_clause_tl ∘ exist_tl_fn3`. (~80-120 lines
   incl. correctness, mirroring lines 121-177.)
2. **Add the Fin 2 telescoping bridge**: generalize the in-file Fin 1 bridge (lines 317-331) to
   show `insertEnv env t = Fin.cons (env 0) (Fin.cons (env 1) (fun _ => t))` and that outer `∃x`
   ∘ inner `∃y` matches the IH's `∃ env : Fin 2`. (~30-50 lines.)
3. **Wire the n=1 arm (line 406)**: set `exist_tl_fn3 := nf_nvar_exist_all_depths_fn atomMap
   h_surj k 2` (with correctness from `nf_nvar_exist_all_depths_fn_correct`), build
   `char2 := nf_succ_char_formula2 … sub_nf`, then bind x using the `nf_2var_exist_depth0_tl`-style
   `translateEF1` pattern (or `VecEA_m.existClosure` fallback). (~80-150 lines.)
4. **Scoped build** `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`; confirm sorry
   count drops to 1 (only n≥2, off-path).
5. (Optional, off critical path) n≥2 arm via the same `nf_succ_char_formula2` generalized to
   `nf_succ_char_formula_n` + arity merge (reuse `mergeNF`/`merge_forward`).

### Estimates
- **Lines**: 250-400 (MEDIUM; up to 500 if the (x,t) order-zone split in `char2` must be explicit).
- **Risk**: MEDIUM. Single concentrated risk = the Fin 2 telescoping bridge (step 2 / Challenge 2).
  All other pieces are reuse of sorry-free infrastructure.
- **Critical-path impact**: completing steps 1-4 makes `kamp_prior_expressive_completeness`
  sorry-free (the n≥2 sorry at 409 is off-path).

### What NOT to do
- Do not build the NF-disjunction at depth k+2 (recreates the cycle).
- Do not attempt a `mutual def` of char/exist (non-terminating, §3).
- Do not refactor BracketFormula conventions (report 19 Approach B — too risky).

---

## 9. Findings Summary

1. Sole critical sorry = KampPrior.lean:406 (n=1, depth k+1). Build green otherwise (verified).
2. The "circularity" is an artifact of the NF-disjunction-at-k+2 strategy; the theorem only needs
   the depth-k IH at arity 3, which is structurally in scope but never invoked (line 313 uses
   arity 1 only).
3. Approach 2 (mutual def) is unsound as stated — refuted by a concrete non-decreasing measure on
   a constant-index char↔exist 2-cycle; its only terminating form collapses to Approach 5.
4. Approach 5 is the recommendation: build `nf_succ_char_formula2` (the missing arity-2 char),
   feed it `nf_nvar_exist_all_depths_fn k 2`, bind x via the existing `translateEF1` pattern.
5. All depended-upon lemmas verified present and sorry-free (table §5); only `nf_succ_char_formula2`
   is new.
6. Principal risk: the Fin 2 outer-∃x ∘ inner-∃y telescoping bridge (the Fin 1 version is already
   proved twice in-file).
7. Estimate 250-400 lines, MEDIUM risk; completes the critical path.
