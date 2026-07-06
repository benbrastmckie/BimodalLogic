# Report 01 — Rabinovich-Faithful E[Σ]-Fold Encoding Design (task 310)

- **Task**: 310 — normalform_efold_encoding (spawned from 309, R2 NO-GO, commit 8fd4340b1)
- **Type**: lean4 (hard-mode literature-grounded research; H2/H3/H4)
- **Session**: sess_1783359214_93fd70
- **Focus**: Rabinovich-faithful E[Σ]-fold encoding design
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, **full 16-page PDF
  read this session**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`;
  the `.md` in that directory was NOT used as authority)
- **Source assets read this session** (file:line reads): `NormalForm.lean:58-60` (`AtomKind`),
  `:134-159` (`NormalForm`, `.base/.step/.atom_assgn/.quant_assgn`), `:198-221` (`nf_eval_nf`,
  `nf_characteristic`), `:245/:277` (`nf_eval_unique`/`nf_exists_unique`);
  `MonadicFO.lean:103-109` (`OrderedMonadicStructure` bundles `LinearOrder`);
  `KampPrior.lean:67-137` (`nf_succ_char_formula(_correct)`), `:265-354` (`ih_exist_1`,
  `exist_tl_fn_k`, `char_k1` local, the `:351`/`:354` sorries);
  `NfMultiAnchorBridge.lean:1536-1618` (`BracketEndCharCarrier`/`BracketCarrierCorrect`/
  `bracketEndChar_k0(_correct)` + the R2 NO-GO doc-comment record);
  `VecEADecomp.lean:33-51` (`nf_y_proj`/`nf_x_proj3`/`nf_t_proj3`), `:55-66` (`extract_y_nf`),
  `:233-257` (`nf_3var_bracket_xyt(_correct)`);
  `VecEAFormula.lean:128-169` (`BracketFormula(.holds)`), `:252-267` (`VecEA2(.holds)`),
  `:305-331` (`.trivial`/`.single`/`fromBracket`);
  `NfDepth0Generalized.lean:42-52` (`insertEnv`), `:90-105` (order-conflict falsity helper),
  `:109-175` (`skipFin`/`unskipFin`/`totalUnskip`/`mergeNF`);
  task-309 artifacts: `reports/03_rabinovich-faithful-path-research.md` (full),
  `reports/04_spawn-analysis.md` (full).
- **Search evidence**: no "mathlib likely has this" claims are made anywhere below; every
  existence claim about local artifacts is a direct `Read`/`grep` at the cited `file:line`. A
  repo-wide grep for `efold|EFold|ESigma|E\[Σ\]` confirmed **no fold encoding exists yet** (only
  the prose references in `NfMultiAnchorBridge.lean:1511,1515,1616`).

## VERDICT (one paragraph)

Rabinovich keeps arity fixed by never letting a quantified witness join the free variables of a
sub-evaluation: the witness meets the fixed points ONLY through pairwise order constraints
(Def 3.1's ordering conjuncts, p.4) and a **monadic** point type α (quantifier-free,
one-variable, p.4), where all already-processed quantifier depth has been folded into the
signature as a unary predicate (Def 4.1's E[Σ] expansion, p.5). The Lean transcription is a
parallel fold normal-form type whose depth-(k+1) quant assignment ranges over
`ZoneSpec n × NormalForm sig k 1` (order-relationship-to-env × monadic depth-k point type)
instead of `NormalForm sig k (n+1)` — the ≤2-free-variable cap (Lemma 3.2(2), p.4) becomes a
**type-level invariant**: the quant domain has no slot for joint witness/env evaluation. The
bridge to `nf_eval_nf` at the k=1 gate is **lossless**, because a depth-0 arity-(n+1) NF
provably factors as (zone spec) × (fresh-var point type) × (env restriction) — a bijection, not
a lossy projection. Three bridge lemmas plus one gate corollary (exact signatures in §5) reduce
the verbatim NO-GO residual to zone-bounded monadic existentials, which are Lemma-3.4/Prop-3.5
objects task 311 can discharge with the existing bracket builders. Recommended encoding:
**parallel fold-evaluator with a new quant-domain type (Alternative B, §7), general env arity
`n`**, ~350-540 lines over 4 phases (overrunning the task's 150-280 estimate — flagged
honestly; H8 split given in §9).

---

## 1. The paper's actual fold mechanism (verbatim, with page cites)

### 1.1 Def 3.1 (PDF p.4) — ∃∀-formulas: where the witness/anchor coupling lives

> "An ∃∀-formula over Σ is a formula of the form:
> ψ(z_0,…,z_m) := ∃x_n…∃x_1∃x_0
> (⋀_{k=0}^m z_k = x_{i_k}) ∧ (x_n > x_{n−1} > ⋯ > x_1 > x_0)   "ordering of x_i and z_j"
> ∧ ⋀_{j=0}^n α_j(x_j)   "Each α_j holds at x_j"
> ∧ ⋀_{j=1}^n [(∀y)^{<x_j}_{>x_{j−1}} β_j(y)]   "Each β_j holds along (x_{j−1}, x_j)"
> ∧ (∀y)_{>x_n} β_{n+1}(y) ∧ (∀y)^{<x_0} β_0(y)
> with a prefix of n+1 existential quantifiers and with all α_j, β_j quantifier free formulas
> with one variable over Σ, and i_0,…,i_m ∈ {0,…,n}." (PDF p.4, Definition 3.1)

Structural reading: a witness `x_j` touches the rest of the formula through exactly three
channels — (i) its **order position** among the other points (the ordering conjunct and the
`z_k = x_{i_k}` equations), (ii) its **monadic point type** `α_j(x_j)` (one variable,
quantifier-free), (iii) the **interval types** `β_j` on the segments it bounds (again
one-variable, quantifier-free, evaluated pointwise along an interval). There is **no channel**
by which a witness participates in a joint (≥2-ary) evaluation with the free variables.

### 1.2 Lemma 3.2 (PDF p.4) — the ≤2 cap and ∃-closure

> "(1) Conjunction of ∃∀-formulas is equivalent to a disjunction of ∃∀-formulas.
> (2) Every ∃∀-formula is equivalent to a conjunction of ∃∀-formulas with at most two free
> variables.
> (3) For every ∃∀-formula φ the formula ∃xφ is equivalent to a ∨∃∀-formula." (PDF p.4, Lemma
> 3.2; stated with "It is clear that" — the paper treats all three as structural facts of Def
> 3.1's shape)

(2) is the standing invariant the task directive demands "BY CONSTRUCTION": it holds because
Def 3.1's shape only ever relates points pairwise (orderings) or singly (α, β).

### 1.3 Lemma 3.4 (PDF p.5) — closure under ∃ (how new witnesses enter)

> "The set of ∨∃∀ formulas is closed under disjunction, conjunction, and existential
> quantification. Proof. By (1) and (3) of Lemma 3.2, and distributivity of ∃ over ∨." (PDF
> p.5, Lemma 3.4)

Existentially quantifying a point does not change the formula class — the new witness is
absorbed as one more `x_j` in the Def-3.1 shape (order position + monadic type), never as an
extra free variable of a deeper sub-evaluation.

### 1.4 Prop 3.5 (PDF p.5) — the bracket collapse at fixed endpoints

> "Every ∨∃∀-formula with one free variable is equivalent to a TL(Until,Since) formula. …
> Let A_i and B_i be temporal formulas equivalent to α_i and β_i (A_i and B_i do not even use
> Until and Since modalities). It is easy to see that ψ is equivalent to the conjunction of
> A_k ∧ (B_{k+1}Until(A_{k+1} ∧ (B_{k+2}Until ⋯ (A_{n−1} ∧ (B_n Until(A_n ∧ □B_{n+1}))) ⋯)))
> and
> A_k ∧ (B_{k−1}Since(A_{k−1} ∧ (B_{k−2}Since(⋯ A_1 ∧ (B_1Since(A_0 ∧ ⃖□B_0)) ⋯))." (PDF p.5,
> Proposition 3.5 and its proof)

This is 311's discharge machinery (already transcribed as `bracketBuildLeft/Right`,
VecEATranslation); 310 must deliver the fold in a shape whose residual obligations are
Prop-3.5-shaped (zone-bounded monadic existentials).

### 1.5 Def 4.1 (PDF p.5) — the E[Σ] fold itself

> "Let M be a Σ chain. We denote by E[Σ] the set of unary predicate names
> Σ ∪ {A | A is an TL(Until,Since)-formula over Σ}. The canonical TL(Until,Since)-expansion of
> M is an expansion of M to an E[Σ]-chain, where each predicate name A ∈ E[Σ] is interpreted as
> {a ∈ M | M, a ⊨ A}." (PDF p.5, Definition 4.1)

And the iterated-fold license (PDF p.6, first paragraph of §4 after Def 4.1):

> "Note that if A is a TL(Until,Since) formula over E[Σ] predicates, then it is equivalent to a
> TL(Until,Since) formula over Σ, and hence to an atomic formula in the canonical
> TL(Until,Since)-expansions." (PDF p.6)

### 1.6 Prop 4.3 (PDF p.6) — where the fold is exercised

> "Every first-order formula is equivalent over Dedekind complete chains to a disjunction of
> ∃∀-formulas. Proof. We proceed by structural induction. … ∃-quantifier: For ∃-quantifier, the
> claim follows from Lemma 3.4." (PDF p.6, Proposition 4.3)

Quantifiers are processed **one at a time, innermost first**; after each elimination the
residual TL content is an E[Σ]-atom (Def 4.1), so at every step the α/β of the current Def-3.1
shape are quantifier-free over the *current expanded signature*. Depth lives in the TL nesting
of the atoms, never in the arity of a sub-evaluation.

### 1.7 Precisely how this keeps arity fixed where `nf_eval_nf` conses

`nf_eval_nf` (NormalForm.lean:198-207), quant layer at depth k+1, arity n:

```
(∀ (sub_nf : NormalForm sig k (n + 1)),
  (∃ (x : M.carrier), nf_eval_nf M k (n + 1) (Fin.cons x env) sub_nf) ↔
    (quant_assignment sub_nf = true))
```

The witness `x` is **consed into the environment** and the recursion descends into a
`(n+1)`-ary joint evaluation of `x` together with all of `env` at depth k — i.e. the witness's
coupling channel to the fixed points is the *full joint (n+1)-ary depth-k type*. In Rabinovich
there is no such object: the witness's coupling channels are exactly (order position, monadic
α-type, interval β-types) per Def 3.1, and everything of quantifier depth below the current
step has already been folded into monadic E[Σ]-atoms per Def 4.1/Prop 4.3. So where
`nf_eval_nf` grows `n → n+1` per depth, the paper's corresponding step holds the free-variable
set fixed and enriches the **signature** instead. The transcription must therefore replace the
quant-assignment domain `NormalForm sig k (n+1)` (joint types) by
`(order-position data) × (monadic depth-k point type)` — §4 below.

---

## 2. Literature Proof Structure (Tier 1 step map)

| Step | Paper item (page) | Content | Lean counterpart (this task / downstream) |
|---|---|---|---|
| S1 | Def 3.1 (p.4) | witness coupling = ordering + monadic α + interval β | `ZoneSpec`/`zoneHolds` (ordering) + `NormalForm sig k 1` atom (α); β implicit via completeness of the quant assignment (see Deviation D3) |
| S2 | Lemma 3.2(2) (p.4) | ≤2 free variables by construction | type-level: fold quant domain has no joint-evaluation slot (§4.2) |
| S3 | Lemma 3.2(3)+3.4 (p.4-5) | ∃-closure inside the class | task 311: zone-bounded monadic ∃ discharged by bracket builders (`VecEAClosure.existsBounded_right`) |
| S4 | Prop 3.5 (p.5) | ∨∃∀ (1 free var) → TL via Until/Since chains at fixed endpoints | existing `bracketBuildLeft/Right(_correct)` (VecEATranslation); consumed by 311, untouched by 310 |
| S5 | Def 4.1 (p.5) | processed depth folds into a monadic atom | fold atom = `NormalForm sig k 1` with semantics `nf_eval_nf M k 1 (fun _ => x)`; TL-realizability of that atom is the already-sorry-free arity-1 pipeline (`nf_succ_char_formula(_correct)` KampPrior:67/81; the `n = 0` arm KampPrior:339-346) |
| S6 | p.6 note after Def 4.1 | folds iterate (TL over E[Σ] ≡ TL over Σ) | general-`n` bridge lemma (§5.3) is the reusable one-step engine for 309-R3's inside-out iteration |
| S7 | Prop 4.3 (p.6) | innermost-first quantifier processing | the k=1 gate is exactly one innermost fold (depth-0 subs); deeper k = iterate S6 |

---

## 3. H3 Source-to-Implementation Mapping (5 columns)

| Paper item | Page | Proposed Lean artifact | Target file | Status |
|---|---|---|---|---|
| Def 3.1 ordering conjuncts (`x` vs each fixed point, incl. `z_k = x_{i_k}` equality) | p.4 | `ZoneSpec n := Fin n → Bool × Bool`; `zoneHolds M env zs x` | Kamp/NfEFold.lean | **new** |
| Def 3.1 monadic point type α (quantifier-free, one variable) | p.4 | fold atom slot `NormalForm sig k 1`, semantics `nf_eval_nf M k 1 (fun _ => x)` | Kamp/NfEFold.lean (type only; semantics existing NormalForm.lean:198) | **new** (slot) / **existing** (semantics) |
| Def 4.1 E[Σ]-atom (processed depth as unary predicate) | p.5 | quant domain `EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` | Kamp/NfEFold.lean | **new** |
| Lemma 3.2(2) ≤2-free-var cap as standing invariant | p.4 | `NormalFormEFold sig (k+1) n` quant assignment typed over `EAtomDom` (no `n+1`-ary slot exists) | Kamp/NfEFold.lean | **new** (type-level invariant) |
| Def 3.1 whole-shape evaluation | p.4 | `nf_eval_efold` recursion equation (§4.3) | Kamp/NfEFold.lean | **new** |
| depth-0 base (atoms only; fold = old encoding) | p.4 (α/β quantifier-free base) | `nf_eval_efold_zero_iff` | Kamp/NfEFold.lean | **new** (trivial) |
| factorization of a depth-0 (n+1)-type into Def-3.1 channels | p.4 (structural reading of Def 3.1) | `nf_eval_nf0_cons_factor` (§5.2) + split kit `nf0_zoneSpec`/`nf0_projFresh`/`nf0_dropFresh`/`nf0_assemble` | Kamp/NfEFold.lean | **new**; `nf0_dropFresh` = existing `mergeNF · ⟨0,_⟩` (NfDepth0Generalized:169) reused |
| one-step fold ≡ one-step `nf_eval_nf` quant layer (innermost fold, Prop 4.3 ∃-step) | p.6 | `nf_quant_layer_fold_iff` (§5.3) | Kamp/NfEFold.lean | **new** (bridge) |
| k=1 whole-evaluation bridge | p.5-6 | `efold_of_nf1` + `nf_eval_nf1_iff_efold` (§5.4) | Kamp/NfEFold.lean | **new** (bridge) |
| the exact R2 gate residual, fold-reduced | — (gate is codebase-derived; fold shape is p.4-6) | `nf_quant_layer_fold_k1_gate` (§5.5) | Kamp/NfEFold.lean | **new** (bridge corollary; 311's entry point) |
| Prop 3.5 chain builders (for 311, NOT 310) | p.5 | `bracketBuildLeft/Right(_correct)` | VecEATranslation.lean:273/50/503/234 | **existing**, sorry-free |
| Prop 3.5 depth-0 witness collapse | p.5 | `nf_3var_bracket_xyt(_correct)` | VecEADecomp.lean:233/244 | **existing**, sorry-free |
| E[Σ]-atom TL-realizability (arity-1, all depths) | p.5 (Def 4.1) + p.5 (Prop 3.5) | `nf_succ_char_formula(_correct)`; `nf_nvar_exist_all_depths` n=0 arm | KampPrior.lean:67/81/339-346 | **existing**, sorry-free (NOTE: `char_k1` at KampPrior:307 is a proof-local `let`, not a global; the global assets are these) |
| Lemma 3.4 ∃-closure vehicle (for 311) | p.5 | `existsBounded_right` | VecEAClosure.lean:265 | **existing** |
| G6 carrier shape (unchanged by 310) | p.5 (Prop 3.5 endpoints) | `BracketEndCharCarrier`/`BracketCarrierCorrect` | NfMultiAnchorBridge.lean:1536/1546 | **existing** (consumed by 311) |

---

## 4. Proposed Lean encoding

New file: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean`. Imports:
`Bimodal.Metalogic.WeakCanonical.NormalForm` and
`Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized` (for `skipFin`/`unskipFin`/`mergeNF`
reuse; both already compile together — NfDepth0Generalized imports NfZoneDepthK which imports
NormalForm). Nothing imports NfEFold → **off the live path**; `lake build` compiles it (library
glob) so it must be green, but no existing consumer changes.

### 4.1 Zone specification (Def 3.1 ordering conjuncts)

```lean
/-- Order relationship of a fresh witness to each of the `n` environment points:
    for each `i`, `(zs i).1` = "x < env i", `(zs i).2` = "env i < x".
    `(false, false)` encodes `x = env i` (LinearOrder trichotomy, MonadicFO:103-109);
    `(true, true)` is unsatisfiable (harmless: its clauses are vacuously false).
    Rabinovich Def 3.1's ordering-and-equality conjuncts, PDF p.4. -/
def ZoneSpec (n : Nat) : Type := Fin n → Bool × Bool

def zoneHolds {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {n : Nat} (env : Fin n → M.carrier) (zs : ZoneSpec n) (x : M.carrier) : Prop :=
  ∀ i : Fin n, (x < env i ↔ (zs i).1 = true) ∧ (env i < x ↔ (zs i).2 = true)
```

`zoneHolds` mirrors `atom_eval` on the fresh-variable order atoms exactly (`atom_eval M env'
(.order 0 i.succ) = env' 0 < env' i.succ = x < env i` under `env' = Fin.cons x env`), so the
factorization proof is a direct case transport, not a semantic argument.

### 4.2 The fold normal-form type (Def 4.1 + Lemma 3.2(2) as a type)

```lean
/-- Quant-assignment domain of the E[Σ]-fold: order position (ZoneSpec) × monadic
    depth-k point type (the E[Σ]-atom, Def 4.1 PDF p.5). NO slot exists for a joint
    (n+1)-ary sub-evaluation — Lemma 3.2(2)'s ≤2-free-variable cap (PDF p.4) is
    enforced by this type, not by a guard. -/
abbrev EAtomDom (sig : MonadicSignature) (k n : Nat) : Type :=
  ZoneSpec n × NormalForm sig k 1

/-- E[Σ]-fold normal form: identical to `NormalForm` at depth 0 and in the atom
    layer; the quant layer ranges over `EAtomDom sig k n` (fixed arity n) instead of
    `NormalForm sig k (n+1)` (arity n+1). -/
def NormalFormEFold (sig : MonadicSignature) : Nat → Nat → Type
  | 0, n => AtomKind sig n → Bool
  | k + 1, n => (AtomKind sig n → Bool) × (EAtomDom sig k n → Bool)
```

(`Fintype`/`DecidableEq` instances are derivable exactly as `normalForm_fintype_and_decEq`
(NormalForm.lean:166) if 311 needs a decidable compatibility gate — see §5.6; include them in
Phase 1 only if free, else defer to 311.)

### 4.3 The fold evaluation (the load-bearing definition)

```lean
/-- Fixed-arity E[Σ]-fold evaluation (Rabinovich Def 4.1, PDF p.5; Def 3.1 shape,
    PDF p.4). The quant layer folds each processed depth into a monadic E[Σ]-atom
    `χ : NormalForm sig k 1` evaluated at the witness alone (`nf_eval_nf M k 1`),
    coupled to the SAME arity-n env only through `zoneHolds` (pairwise order = ≤2
    free variables per constraint, Lemma 3.2(2) PDF p.4). Arity `n` is constant
    across the depth recursion. -/
noncomputable def nf_eval_efold {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    (k n : Nat) → (env : Fin n → M.carrier) → NormalFormEFold sig k n → Prop
  | 0, _, env, assignment =>
    ∀ (a : AtomKind sig _), atom_eval M env a ↔ (assignment a = true)
  | k + 1, _, env, ⟨atom_assignment, quant_assignment⟩ =>
    (∀ (a : AtomKind sig _), atom_eval M env a ↔ (atom_assignment a = true)) ∧
    (∀ (e : EAtomDom sig k _),
      (∃ (x : M.carrier), zoneHolds M env e.1 x ∧
        nf_eval_nf M k 1 (fun _ => x) e.2) ↔ (quant_assignment e = true))
```

**Recursion-equation notes** (the account a planner needs):

1. **Arity is fixed by the equation itself**: `env : Fin n → M.carrier` appears unchanged in
   the quant clause; the witness `x` never enters an environment. The only depth-indexed object
   is the monadic atom `e.2 : NormalForm sig k 1`.
2. **The E[Σ]-atom's semantics is `nf_eval_nf M k 1 (fun _ => x)`, not a recursive
   `nf_eval_efold` call.** Rationale (Def 4.1 fidelity): the E[Σ]-atom is "a TL formula over Σ
   interpreted as `{a | M, a ⊨ A}`" — and the codebase's proven tie between TL truth and NF
   semantics at arity 1 is exactly the `nf_eval_nf`-side arity-1 pipeline
   (`nf_succ_char_formula_correct` KampPrior:81-137: `temporal_truth … ↔ nf_eval_nf M (k+1) 1
   (fun _ => t) nf`). Using `nf_eval_nf M k 1` makes the fold's atoms *literally* the objects
   whose TL-realizability is already sorry-free, so 311 needs no new atom-level work. The
   arity-1 evaluation's own internal arity growth is interior to the atom and already
   discharged (Deviation D5). This also keeps `nf_eval_efold` structurally non-recursive in the
   quant clause (only the equation for `k+1` mentions `nf_eval_nf` at `k`), avoiding any
   termination/universe complication.
3. **β interval types have no explicit slot** — as in `nf_eval_nf`, ∀-content along segments is
   carried by the *completeness* of the quant assignment: `quant_assignment e = false` states
   "no witness in zone `e.1` realizes atom `e.2`", which is exactly a `(∀y)`-interval clause.
   See Deviation D3.
4. **Depth-0 coincidence** (task deliverable, trivial by definitional equality of the two `0`
   clauses):

```lean
theorem nf_eval_efold_zero_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (n : Nat) (env : Fin n → M.carrier)
    (a : NormalFormEFold sig 0 n) :
    nf_eval_efold M 0 n env a ↔ nf_eval_nf M 0 n env a := Iff.rfl
```

(`NormalFormEFold sig 0 n` and `NormalForm sig 0 n` are both definitionally
`AtomKind sig n → Bool`, so this statement typechecks as written.)

### 4.4 Depth-0 split kit (the lossless factorization data)

For `sub : NormalForm sig 0 (n+1)` with the fresh variable at index 0 (matching `Fin.cons x
env`), the atoms of `AtomKind sig (n+1)` partition into four groups; the split kit names each:

```lean
/-- Zone spec of the fresh variable (index 0): the order atoms coupling it to env. -/
def nf0_zoneSpec {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : ZoneSpec n :=
  fun i => (sub (.order 0 i.succ (by simp [Fin.ext_iff])),
            sub (.order i.succ 0 (by simp [Fin.ext_iff])))

/-- Monadic point type of the fresh variable (its pred atoms; AtomKind sig 1 has no
    order atoms — `i ≠ j` is uninhabited at arity 1, cf. nf_y_proj VecEADecomp:33). -/
def nf0_projFresh {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => sub (.pred p 0)
  | .order i j h => absurd (Subsingleton.elim i j) h

/-- Env-side restriction: drop the fresh variable. REUSES mergeNF at position 0
    (NfDepth0Generalized:169): skipFin ⟨0⟩ maps Fin n to indices 1..n. -/
noncomputable def nf0_dropFresh {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : NormalForm sig 0 n :=
  mergeNF sub ⟨0, Nat.succ_pos n⟩

/-- Reassemble a full (n+1)-ary depth-0 NF from the three channels. -/
def nf0_assemble {sig : MonadicSignature} {n : Nat}
    (zs : ZoneSpec n) (χ : NormalForm sig 0 1) (r : NormalForm sig 0 n) :
    NormalForm sig 0 (n + 1) :=
  fun a => -- by cases on a via Fin.cases on each index:
  match a with
  | .pred p i => Fin.cases (χ (.pred p 0)) (fun i' => r (.pred p i')) i
  | .order i j h => -- four sub-cases: (0, j'.succ) ↦ (zs j').1; (i'.succ, 0) ↦ (zs i').2;
                    -- (i'.succ, j'.succ) ↦ r (.order i' j' _); (0,0) impossible by h
    sorry -- (spelled out in implementation; pure Fin.cases bookkeeping, no semantics)
```

(The `sorry` above is a *report-level* elision of ~15 lines of `Fin.cases` bookkeeping, not a
proposed proof debt; the implementer writes the total match. Zero-debt policy applies to the
implementation, and nothing here is blocked.)

Round-trip lemmas (make the factorization a bijection — this is what distinguishes the fold
from the FALSIFIED lossy projections, see §7 Alt-E and the G2 note in §8):

```lean
theorem nf0_split_assemble {sig} {n} (sub : NormalForm sig 0 (n+1)) :
    nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) (nf0_dropFresh sub) = sub

theorem nf0_zoneSpec_assemble {sig} {n} (zs) (χ) (r) :
    nf0_zoneSpec (nf0_assemble (sig := sig) (n := n) zs χ r) = zs
theorem nf0_projFresh_assemble … = χ
theorem nf0_dropFresh_assemble … = r
```

(`funext` + atom case analysis; `skipFin ⟨0⟩ i = i.succ` should be proved once as a simp lemma
`skipFin_zero_succ` to make `nf0_dropFresh` compute.)

---

## 5. Bridge lemma statements (exact signatures) and direction analysis

### 5.1 What must bridge, and in which direction

The R2 NO-GO residual (verbatim, NfMultiAnchorBridge.lean:1601-1603 / this task's acceptance
probe) is, at `n = 3`, `env = [w,x,t] = Fin.cons w (Fin.cons x (fun _ => t))`:

```
∀ sub_nf : NormalForm sig 0 4,
  (∃ x_1, nf_eval_nf M 0 4 (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) sub_nf) ↔
    qnf.2 sub_nf = true
```

Task 311 must (a) **prove** this from fold-shaped facts its carrier supplies (needs the
right-to-left direction of the bridge below), and (b) in the converse arm of
`BracketCarrierCorrect`, **consume** it to establish fold-shaped facts (needs left-to-right).
**Full `↔` is therefore required — but only at depth-0 subs (k=1) and only up to the env's own
atom layer being pinned** (the hypothesis `h_atom : nf_eval_nf M 0 3 [w,x,t] qnf.1` available
at that point in the R2 proof). Full depth-k equivalence of the two encodings is NOT required
and NOT claimed (§6, D7).

### 5.2 Factorization (the mathematical core; Def 3.1's three channels)

```lean
/-- A depth-0 (n+1)-ary evaluation with the fresh witness consed factors exactly
    into Rabinovich's Def 3.1 channels (PDF p.4): ordering (zoneHolds), monadic
    point type (projFresh), env restriction (dropFresh). Lossless: with
    nf0_split_assemble this is a bijection of characterizations, not a projection. -/
theorem nf_eval_nf0_cons_factor {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (x : M.carrier) (sub : NormalForm sig 0 (n + 1)) :
    nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub ↔
      zoneHolds M env (nf0_zoneSpec sub) x ∧
      nf_eval_nf M 0 1 (fun _ => x) (nf0_projFresh sub) ∧
      nf_eval_nf M 0 n env (nf0_dropFresh sub)
```

Proof shape: unfold `nf_eval_nf` at depth 0 on both sides (`∀ a, atom_eval … ↔ …`); forward:
instantiate at the four atom groups (the `extract_y_nf` pattern, VecEADecomp:55-66,
generalized); backward: given an arbitrary `a : AtomKind sig (n+1)`, `Fin.cases` its indices
and discharge from the matching channel. `Fin.cons` computation lemmas (`Fin.cons_zero`,
`Fin.cons_succ`) do the indexing.

### 5.3 One-step quant-layer fold (general n — the reusable engine)

```lean
/-- One step of nf_eval_nf's quant layer (depth-0 subs) is equivalent to the
    E[Σ]-fold form, given the env's own depth-0 type r. This is Prop 4.3's
    innermost ∃-fold (PDF p.6) in NF form. LHS = the R2 residual shape; RHS =
    zone-bounded monadic existentials (Lemma 3.4 / Prop 3.5 objects) plus the
    off-fiber falsity clause. -/
theorem nf_quant_layer_fold_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (r : NormalForm sig 0 n)
    (h_r : nf_eval_nf M 0 n env r)
    (q : NormalForm sig 0 (n + 1) → Bool) :
    (∀ sub : NormalForm sig 0 (n + 1),
        (∃ x : M.carrier, nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub) ↔ q sub = true)
    ↔
    ((∀ (zs : ZoneSpec n) (χ : NormalForm sig 0 1),
        (∃ x : M.carrier, zoneHolds M env zs x ∧ nf_eval_nf M 0 1 (fun _ => x) χ) ↔
          q (nf0_assemble zs χ r) = true) ∧
     (∀ sub : NormalForm sig 0 (n + 1), nf0_dropFresh sub ≠ r → q sub = false))
```

Proof shape:
- **→, first conjunct**: for `(zs, χ)`, apply the LHS at `nf0_assemble zs χ r`; rewrite the
  `∃x` side with `nf_eval_nf0_cons_factor` + the round-trips (§4.4); the `dropFresh = r`
  conjunct is discharged by `h_r` (any `x` works since `nf_eval_nf M 0 n env r` holds
  unconditionally — the third factor is witness-independent).
- **→, second conjunct**: if `nf0_dropFresh sub ≠ r`, the `∃x` side is false: any witness would
  give `nf_eval_nf M 0 n env (nf0_dropFresh sub)` by the factorization, contradicting
  `nf_eval_unique M 0 n env … r` (NormalForm.lean:245) + `h_r`. Hence `q sub = false` by the
  LHS iff.
- **←**: for arbitrary `sub`, factor via `nf0_split_assemble`: if `nf0_dropFresh sub = r`,
  rewrite `sub = nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) r` and apply the first
  RHS conjunct + `nf_eval_nf0_cons_factor` (third factor supplied by `h_r`); if `≠ r`, both
  sides false (∃-side by factorization + uniqueness as above; `q sub = false` by the second
  conjunct).

**Why general `n` and not just `n = 3`**: (i) the proof is index-structural (`Fin.cases`), no
shorter at `n = 3` — the concrete-arity version would instead explode into `Fin 4` literal
cases; (ii) Rabinovich's fold iterates innermost-first (Prop 4.3, PDF p.6; §1.7), and the
inside-out iteration that 309-R3 will need applies this same lemma at env arities 4, 5, … —
general `n` makes 310's engine reusable rather than gate-only. The gate corollary (§5.5) then
*instantiates* `n = 3`.

### 5.4 k=1 whole-evaluation bridge (transport + iff)

```lean
/-- Transport a depth-1 NormalForm into the fold encoding along its own atom layer
    (the compatible fiber over qnf.1). -/
noncomputable def efold_of_nf1 {sig : MonadicSignature} {n : Nat}
    (qnf : NormalForm sig 1 n) : NormalFormEFold sig 1 n :=
  ⟨qnf.1, fun e => qnf.2 (nf0_assemble e.1 e.2 qnf.1)⟩

/-- The k=1 evaluation bridge: nf_eval_nf at depth 1 is the fold evaluation of the
    transported form, PLUS off-fiber falsity of qnf.2. Both directions used by 311. -/
theorem nf_eval_nf1_iff_efold {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (qnf : NormalForm sig 1 n) :
    nf_eval_nf M 1 n env qnf ↔
      (nf_eval_efold M 1 n env (efold_of_nf1 qnf) ∧
       ∀ sub : NormalForm sig 0 (n + 1), nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)
```

(Atom layers coincide definitionally; quant layers by `nf_quant_layer_fold_iff` with
`r := qnf.1`, `h_r :=` the atom layer. Note `qnf.1 : AtomKind sig n → Bool` IS a
`NormalForm sig 0 n` definitionally, and `nf_eval_nf M 1 n env qnf`'s atom conjunct IS
`nf_eval_nf M 0 n env qnf.1` — same `∀ a, atom_eval … ↔ …` shape, NormalForm.lean:201-204.)

The off-fiber clause cannot be absorbed silently: `qnf.2`'s values on subs whose env-restriction
contradicts `qnf.1` are unconstrained by the fold (the fold has no slot for them — that is the
point), but `nf_eval_nf M 1 n env qnf` FORCES them false. Making it an explicit conjunct is the
honest bridge. It is a decidable, model-independent, purely combinatorial condition on `qnf`
(Fintype domain, Bool codomain), so 311 can gate its carrier on
`decide (∀ sub, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)` — see §5.6.

### 5.5 The gate corollary (311's entry point — closes the acceptance probe)

```lean
/-- The exact R2 NO-GO residual (NfMultiAnchorBridge.lean:1601-1603), fold-reduced:
    under h_atom (available at that proof point), the arity-4 quant residual is
    equivalent to zone-bounded MONADIC existentials over env [w,x,t] plus the
    off-fiber falsity of qnf.2. No arity-4 object remains on the RHS. -/
theorem nf_quant_layer_fold_k1_gate {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (qnf : NormalForm sig 1 3)
    (h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1) :
    (∀ sub_nf : NormalForm sig 0 4,
        (∃ x_1, nf_eval_nf M 0 4
          (Fin.cons x_1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub_nf) ↔
          qnf.2 sub_nf = true)
    ↔
    ((∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
        (∃ x_1, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs x_1 ∧
          nf_eval_nf M 0 1 (fun _ => x_1) χ) ↔
          qnf.2 (nf0_assemble zs χ qnf.1) = true) ∧
     (∀ sub_nf, nf0_dropFresh sub_nf ≠ qnf.1 → qnf.2 sub_nf = false)) :=
  nf_quant_layer_fold_iff M _ qnf.1 h_atom qnf.2
```

**Why this makes the k=1 goal provable under the new encoding (paper-derived, no probe
substitution)**: the LHS is the verbatim NO-GO goal. The RHS's first conjunct quantifies only
over `ZoneSpec 3 × NormalForm sig 0 1` — each instance is a **zone-bounded monadic
existential**: precisely a Def-3.1 shape with one witness whose point type is quantifier-free
one-variable (PDF p.4) and whose bounds are the fixed points — i.e., a Lemma-3.4/Prop-3.5
object (PDF p.5) that the VecEA2 bracket machinery evaluates. Under the R2 order zone
`x < w < t`, the seven satisfiable zones of `x_1` relative to `[w,x,t]` (below `x`, `= x`,
`(x,w)`, `= w`, `(w,t)`, `= t`, above `t`) are each expressible with the fixed endpoints
`{x,t}` and the single bracket witness `w` (equality zones read a point type at a fixed
point/witness; interval zones are one extra Until/Since witness inside a segment — Lemma 3.4's
∃-closure absorbs it as a bracket witness, PDF p.5). Inconsistent zone specs make the ∃-side
false and force `qnf.2 (assemble …) = false` — legitimate clauses, discharged by
order-conflict falsity (NfDepth0Generalized:90-105 pattern). The second conjunct is decidable
(§5.6). Discharging the RHS is task 311; task 310's obligation is exactly this corollary. If
Rabinovich's fold implied a *different* natural probe, it would be this RHS — but per the task
directive the probe is FIXED as the LHS, and the corollary shows the fold meets it as stated;
no substitution is proposed.

### 5.6 Design note for 311 (recorded, not a 310 obligation)

- The off-fiber clause is decidable: `[Fintype (NormalForm sig 0 4)]` and `[DecidableEq
  (NormalForm sig 0 3)]` exist (NormalForm.lean:177/181), so 311's carrier can include a
  Boolean guard, mapping incompatible `qnf` to the empty carrier — mirroring Rabinovich's
  disjunctions ranging only over consistent order types.
- Zone-(x,w)/(w,t) existentials put a second interior point between the fixed endpoints
  `{x,t}`: in bracket terms a `BracketFormula 2` (two witnesses: `x_1` and `w`), or per-segment
  `K⁺/K⁻`-style INF handling (Lemma 5.3, PDF p.8). `BracketEndCharCarrier` currently fixes
  `VecEA2 1`; 311 may need `VecEA2 2`-shaped disjuncts or `VVecEA2` while keeping anchors
  `{x,t}` fixed and `w` a witness — this preserves G6's SHAPE (fixed endpoints, w a bracket
  witness; witness COUNT is not what G6 caps — Lemma 3.4 explicitly grows witness count under
  ∃-closure, PDF p.5). Flagged so the 311 planner budgets for it; NOT a 310 concern.

---

## 6. Deviation ledger (our NormalForm design vs the paper, section by section)

| # | Deviation | Paper locus | Fold fixes it? |
|---|---|---|---|
| D1 | `nf_eval_nf` grows env arity `n → n+1` at every depth descent (NormalForm.lean:205-207); the paper has NO arity growth — depth is TL nesting over quantifier-free α/β (Def 3.1 p.4, Def 4.1 p.5, Prop 4.3 p.6) | §3-4 | **FIXED at the point of use** by the parallel fold (quant domain `EAtomDom`, §4.2-4.3); `nf_eval_nf` itself is retained for existing assets (task scope: additive, not a rewrite) |
| D2 | Quant assignment ranges over joint (n+1)-ary sub-types `NormalForm sig k (n+1)`; paper witnesses couple only via ordering + monadic α (Def 3.1 p.4, Lemma 3.2(2) p.4) | §3 | **FIXED** in the fold type (type-level ≤2 invariant); bridged to the old encoding losslessly at depth-0 subs (§5.2-5.3) |
| D3 | Paper has explicit interval types β_j with `(∀y)` clauses (Def 3.1 p.4); the NF encoding has no β slot — ∀-content is carried by `q e = false` entries (complete enumeration over the quant domain) | §3 | **WORKED AROUND, semantically equivalent** (a false entry = "no witness of that zone/type", which is the ∀-clause); β resurfaces syntactically in 311 when brackets are built (segment types from the false entries). Deviation retained in the fold deliberately — it keeps the fold uniform with `nf_eval_nf`'s ∀-mechanism, easing the bridge |
| D4 | Codebase evaluates with a 3-slot env `[w,x,t]`; the paper evaluates at ONE point `t_0` with ≤2 free variables as interval endpoints (p.1 `M,t_0 ⊨ A`; Prop 3.5 p.5) | §2-3 | **UNCHANGED by 310** (309's G6 carrier shape already realigns this: `{x,t}` fixed endpoints, `w` a bracket witness; the fold removes the arity-4 obstacle underneath that shape) |
| D5 | The fold atom's semantics `nf_eval_nf M k 1` internally still grows arity on its own recursion; the paper's atom is an opaque unary predicate (Def 4.1 p.5) | §4 | **ACCEPTED, interior-only**: the growth is inside the atom, invisible to the fold layer; the atom's TL-realizability (what Def 4.1 actually requires) is already sorry-free (`nf_succ_char_formula_correct` KampPrior:81; n=0 arm KampPrior:339-346). No new obligation |
| D6 | Paper handles witness=anchor coincidence via explicit `z_k = x_{i_k}` equations (Def 3.1 p.4); the codebase has no equality atoms — only strict-order atoms | §3 | **FIXED in the fold's ZoneSpec**: `(false,false)` per anchor encodes equality via LinearOrder trichotomy (MonadicFO:103-109); no equality atom needed |
| D7 | The fold at depth-k subs (k ≥ 1) is NOT pointwise-equivalent to `nf_eval_nf` (a joint depth-k (n+1)-ary type is strictly finer than zone × monadic-type × restriction: e.g. "∃z between x and env₀ with P(z)" lives in the joint type but in neither arity-1 type) | §4-5 (the paper resolves this by folding innermost-first, Prop 4.3 p.6, with atoms over the EXPANDED signature, p.6 note) | **OUT OF 310's SCOPE, honestly bounded**: the k=1 gate needs only depth-0 subs, where the factorization is a proven bijection. 309-R3's depth-k lift must iterate the one-step fold inside-out (innermost layer first, at growing env arity — hence the general-`n` lemma), NOT assume a pointwise depth-k equivalence. Any future attempt to state `nf_eval_efold M k n ↔ nf_eval_nf M k n` pointwise for k ≥ 2 via arity-1 atoms should be expected to FAIL (this is a feature of the paper's design, not a defect of the fold) |

---

## 7. Candidate alternatives (fidelity first, then feasibility/migration cost; H4-adversarial)

### Alt A — Re-encode `NormalForm` itself (global rewrite of the k+1 clause)
- **Fidelity**: high (the whole codebase would speak Def 4.1).
- **Feasibility/migration**: REJECTED — project-scale rewrite touching every `Nf*` file
  (14,000+ lines in Kamp/ alone), orphaning the sorry-free depth-0/arity-1 assets; explicitly
  ruled out by the task description ("deliberately narrow — NOT a project-wide re-encoding")
  and report 03 §3.
- **Verdict: REJECT** (out of scope by task definition).

### Alt B (RECOMMENDED) — Parallel fold type + evaluator + lossless depth-0 bridge (§4-5)
- **Fidelity: HIGHEST available in-scope.** The quant domain IS Def 3.1's coupling channels
  (ordering × monadic α), the ≤2 cap is the TYPE (Lemma 3.2(2) "by construction", per the
  binding user directive), the atom is Def 4.1's E[Σ]-predicate keyed to the already-TL-realized
  arity-1 pipeline, and the bridge is the innermost fold of Prop 4.3 — each element cites a
  specific paper locus (§3 table).
- **Feasibility: HIGH, bounded.** All proofs are depth-0 order/atom combinatorics of the exact
  kind already landed (`extract_y_nf` VecEADecomp:55, `mergeNF` machinery
  NfDepth0Generalized:109-175, order-conflict falsity :90-105). No temporal formulas, no
  `h_UZ/h_SZ` hypotheses, no model-theoretic content beyond `nf_eval_unique` — 310 is a pure
  NF-combinatorics task, which is why it is spawnable independently of 311.
- **Migration cost: ZERO now** (nothing imports the new file); 311 consumes three named lemmas.
- **Verdict: ENDORSE.**

### Alt C — No new type: only the quant-layer lemma family (§5.2-5.3-5.5) over existing `NormalForm`
- **Fidelity**: the *lemmas* are faithful, but there is no encoding artifact whose type carries
  Lemma 3.2(2); the invariant would remain hand-enforced (guards), which the user directive
  explicitly rejects ("as a type-level invariant of the encoding, not a hand-enforced guard").
  Also fails the task's own mandate to "define a NEW fixed-arity … evaluation function".
- **Feasibility**: highest (≈70% of Alt B's lines).
- **Verdict: REJECT as a standalone; SUBSUMED by Alt B** (B = C + ~80 lines of type/eval/
  coincidence; the load-bearing bridge lemmas are shared).

### Alt D — Fold atom = `TemporalPred`/`Formula` instead of `NormalForm sig k 1`
- **Fidelity**: superficially closer to Def 4.1's "A is a TL-formula", but WRONG as a quant
  domain: the fold's quant assignment must totally enumerate its domain (the ∀/completeness
  mechanism, D3), and `Formula`/`TemporalPred` is an infinite syntactic class — quantifying an
  assignment over it has no finite-characteristic reading and breaks the Fintype/decidability
  properties the NF development is built on (NormalForm.lean:166-183). The finitely many
  depth-k arity-1 NFs are exactly the semantically distinct E[Σ]-atoms needed at depth k.
- **Verdict: REJECT**; the NF-atom converts to its `TemporalPred` at 311's bracket-building
  step (via `nfPred`/`nf_succ_char_formula`), which is where Def 4.1's TL-formula reading
  belongs.

### Alt E — Resurrect a lossy depth-k projection (projFresh/dropFresh at k ≥ 1)
- Falsified territory: this is the shape of the refuted routes (endChar arity-1 navigated,
  plan-v2 P8; lossy depth-k projections, G2's "projection tower"). D7 documents why depth-k
  pointwise factorization is mathematically false. The fold's projections are **depth-0 only**,
  where `nf0_split_assemble` proves losslessness (bijection). Any k ≥ 1 projection in a future
  plan is a red flag to police.
- **Verdict: REJECT (and BAR, consistent with G2/G6).**

---

## 8. Guards compliance (G1-G6 + Corrected Anchor-Cap, inherited verbatim)

- **G1** (no arity-1 collapse of the off-diagonal): the fold keeps env intact at arity n; no
  off-diagonal collapse is proposed. COMPLIANT.
- **G2** (no projection-based VecEA2 / third-free-anchor tower): the fold's projections are
  depth-0 only and provably lossless (round-trip bijection §4.4) — categorically different
  from the refuted lossy depth-k projections; `ZoneSpec` is order data, not an anchor. Alt E
  explicitly re-bars the tower. COMPLIANT.
- **G3** (no trivial-top segment on off-diagonal arms): 310 builds no segments; the fold's
  `q e = false` entries are what 311 turns into real (non-⊤) segment types. N/A here,
  preserved for 311.
- **G4** (w stays a bracket witness; anchors ≤ {x,t}): the fold never puts w (or any witness)
  into an environment slot beyond the existing `[w,x,t]` instantiation of the gate lemma;
  anchors stay {x,t}. COMPLIANT.
- **G5** (F_i chains step-by-step, cite PDF p.4-5 per step): 310 builds no chains; the report
  cites Def 3.1/Lemma 3.2/Lemma 3.4/Prop 3.5/Def 4.1/Prop 4.3 at each design step. The
  implementation phases must cite pages in doc-comments (phase contract, §9).
- **G6** (carrier = two-anchor fixed-endpoint bracket): untouched;
  `BracketEndCharCarrier`/`BracketCarrierCorrect` remain the 311 target. §5.6 flags the
  witness-count question WITHIN G6's shape (fixed endpoints preserved; Lemma 3.4 grows witness
  count, not anchor count — PDF p.5).
- **Corrected Anchor-Cap**: `nf_char3_deeper_split` is not used, not needed, and remains
  BARRED; the fold is the bracket-witness-collapse-compatible mechanism.

---

## 9. Recommended phase decomposition (H8: one agent run per phase)

All phases: new file `Kamp/NfEFold.lean` only; no edits to existing files; every new
declaration doc-commented with its PDF page cite; phase-end `lake build
Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` green; `#print axioms` on each new
theorem = `[propext, Classical.choice, Quot.sound]` (or fewer); grep-clean of `sorry`.

- **Phase 1 — Fold encoding core (~70-110 lines).** `ZoneSpec`, `zoneHolds`, `EAtomDom`,
  `NormalFormEFold`, `nf_eval_efold`, `nf_eval_efold_zero_iff` (depth-0 coincidence, task
  deliverable), plus the `skipFin_zero_succ` simp lemma and (only if free) Fintype/DecidableEq
  instances for `NormalFormEFold`. Cites: Def 3.1 p.4, Lemma 3.2(2) p.4, Def 4.1 p.5.
- **Phase 2 — Depth-0 split kit (~90-140 lines).** `nf0_zoneSpec`, `nf0_projFresh`,
  `nf0_dropFresh` (:= `mergeNF · ⟨0,_⟩`, reuse), `nf0_assemble`, and the four round-trip
  lemmas (`nf0_split_assemble` + three `*_assemble` projections). Pure `funext`/`Fin.cases`
  bookkeeping. Cites: Def 3.1 p.4 (the three channels).
- **Phase 3 — Factorization theorem (~100-160 lines).** `nf_eval_nf0_cons_factor` (§5.2), by
  the generalized `extract_*` pattern. This is the riskiest phase for line overrun (atom case
  analysis with `Fin.cons` computation); if it overruns H8, split at the forward/backward seam.
  Cites: Def 3.1 p.4.
- **Phase 4 — Bridge lemmas + gate corollary (~90-140 lines).** `nf_quant_layer_fold_iff`
  (§5.3, uses `nf_eval_unique`), `efold_of_nf1` + `nf_eval_nf1_iff_efold` (§5.4),
  `nf_quant_layer_fold_k1_gate` (§5.5, a one-line instantiation — its statement must match the
  R2 residual VERBATIM so 311 can `exact`/`rw` it at the NO-GO point). Cites: Prop 4.3 p.6,
  Lemma 3.4 p.5.

**Total: ~350-550 lines over 4 phases** — this exceeds the task's ~150-280 estimate. Flagged
honestly rather than trimmed by dropping the general-`n` engine or the round-trip lemmas (both
load-bearing: the first for 309-R3's iteration, the second for the G2 losslessness defense).
If the planner must cut: the k=1-only variant (Alt C + minimal type) fits ~230-320 lines by
stating Phases 2-3 at `n = 3` concretely — NOT recommended (§5.3 rationale; concrete-arity
case analysis is typically LONGER per lemma, saving only the generic-index lemmas).

**Documentation obligation for the completion summary** (per task description): record the
chosen names (`NormalFormEFold`, `nf_eval_efold`, `nf_quant_layer_fold_iff`,
`nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, split-kit names) — task 311's re-probe
is constructed against these.

---

## Adversarial Self-Verification

Verification methods: `PDF read` (direct Read of the source PDF, all 16 pages, this session);
`source read` (Read/grep at cited file:line this session); `analytic` (derivation from
verified premises, marked as such).

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Def 3.1: witnesses couple only via ordering conjuncts + one-variable quantifier-free α_j, β_j | PDF p.4, Def 3.1 display + "with all α_j, β_j quantifier free formulas with one variable" | PDF read | High |
| Lemma 3.2(2): ≤2 free variables; Lemma 3.2(3)+3.4: ∃-closure | PDF p.4 Lemma 3.2; p.5 Lemma 3.4 + proof "By (1) and (3) of Lemma 3.2, and distributivity of ∃ over ∨" | PDF read | High |
| Def 4.1: E[Σ] = Σ ∪ {A | A a TL-formula}, A interpreted as {a | M,a ⊨ A} | PDF p.5, Def 4.1 verbatim | PDF read | High |
| Iterated folds licensed: TL over E[Σ] ≡ TL over Σ ≡ atomic in the expansion | PDF p.6 first note after Def 4.1 | PDF read | High |
| Prop 4.3 processes quantifiers innermost-first via Lemma 3.4; Prop 3.5 chains at fixed endpoints | PDF p.6 Prop 4.3 proof (∃-quantifier case); p.5 Prop 3.5 proof (A_k ∧ (B_{k+1}Until…)) | PDF read | High |
| `nf_eval_nf` quant layer conses the witness and grows arity n→n+1 | NormalForm.lean:203-207 | source read | High |
| The R2 NO-GO residual is exactly the §5.5 LHS at n=3, env=[w,x,t] | NfMultiAnchorBridge.lean:1601-1613 (doc-comment record) + task description (verbatim goal) | source read | High |
| `M.carrier` is a LinearOrder (trichotomy available for equality zones) | MonadicFO.lean:103-109 (`carrier_order : LinearOrder carrier`, instance) | source read | High |
| `AtomKind sig 1` has no order atoms (i ≠ j uninhabited at arity 1) | NormalForm.lean:58-60 (`order` requires `h : i ≠ j`); nf_y_proj's absurd branch VecEADecomp:37 | source read | High |
| `mergeNF sub ⟨0⟩` implements the fresh-var restriction (`skipFin ⟨0⟩ k = k.succ`) | NfDepth0Generalized.lean:109-112 (skipFin: k.val < 0 false → ⟨k+1⟩), :168-175 (mergeNF) | source read | High |
| `nf_eval_unique` exists for the off-fiber falsity step | NormalForm.lean:245 | source read | High |
| No E[Σ]-fold encoding already exists (the task is not duplicative) | repo grep `efold\|EFold\|ESigma\|E\[Σ\]` → only prose mentions (NfMultiAnchorBridge:1511,1515,1616) | source read (grep) | High |
| `char_k1` is a proof-local `let`, NOT a global asset; the global E[Σ]-atom assets are `nf_succ_char_formula(_correct)` + the n=0 arm | KampPrior.lean:307 (`let char_k1 …` inside `nf_nvar_exist_all_depths`), :67/81 (globals) | source read | High |
| Depth-0 factorization (§5.2) is provable: both sides are ∀-over-atoms statements and the atom groups partition | analytic over verified premises (AtomKind constructors NormalForm:58-60; Fin.cons indexing; extract_* precedent VecEADecomp:55-66) | analytic | High |
| Depth-0 split is a bijection (losslessness; G2 defense) | analytic: the four atom groups are disjoint and jointly exhaustive by constructor/index cases; round-trips are funext + cases | analytic | High |
| Depth-k (k≥1) pointwise factorization into arity-1 atoms is FALSE (D7) | counterexample sketch: "∃z ∈ (x, env₀) with P(z)" is in the joint depth-1 arity-2 type of (x, env₀) but not determined by the two arity-1 depth-1 types + order — an arity-1 type can only bound z relative to its own point | analytic (counterexample) | High |
| The §5.5 RHS is dischargeable by 311 with bracket machinery (zones → Prop 3.5 objects) | PDF p.5 (Lemma 3.4 absorbs the zone witness; Prop 3.5 translates); existing `bracketBuildLeft/Right`, `existsBounded_right` (VecEATranslation:273/50, VecEAClosure:265 — per report 03 H3 table, sorry-free) | PDF read + source read (report-03 cross-ref) | Medium-High (311's obligation, incl. the §5.6 witness-count question — flagged, not asserted closed) |
| Line estimate ~350-550 (overrunning the task's 150-280) | component sizing vs. comparable landed lemmas (extract_* ~12 lines each at n=3 fixed; factorization generalizes ~6 atom groups × 2 directions) | Estimate | Medium |
| Axioms will be exactly [propext, Classical.choice, Quot.sound] | all constructions are Classical.dec + funext + order reasoning, same profile as the landed NF lemmas | analytic | High |

### Contradiction Log

- *Task description ("~150-280 lines") vs. this report's estimate (~350-550).* Precedence:
  actual component sizing over the spawn-time estimate (the spawn report 04 wrote the estimate
  before the general-`n` engine and the round-trip obligations were identified). Resolution:
  keep scope, split per H8 into 4 phases (the task itself anticipates: "split into sub-phases
  if it overruns"). Downstream risk if instead trimmed to n=3-only: 309-R3 loses the reusable
  iteration engine and must re-derive it.
- *G2 ("no projection-based VecEA2") vs. the fold's projFresh/dropFresh.* Resolved
  analytically: G2's refuted object was a **lossy depth-k** projection (information-discarding,
  anchor-growing); the fold's projections are **depth-0 and bijective** (round-trip lemmas are
  deliverables, not hopes). Alt E re-bars the depth-k version. No contradiction remains.
- *Task text "prove a bridge … FOR THE ARITY-3 TWO-ANCHOR SHAPE" vs. this report's general-`n`
  main lemma.* Resolved: the general lemma **instantiates** to the required shape (§5.5 is
  stated verbatim at `[w,x,t]`); generality is strictly additional, costs no fidelity, and is
  paper-motivated (Prop 4.3's iteration, PDF p.6). The gate corollary satisfies the task
  letter exactly.

### Recommendations modified after verification

- Initial design used a bespoke `nf0_dropFresh` definition; replaced by **reusing `mergeNF` at
  position 0** after the source read of NfDepth0Generalized:109-175 (less new code, and its
  `skipFin` round-trip lemmas are already landed).
- Initial instinct was to cite `char_k1` (KampPrior:307) as the global E[Σ]-atom asset (as
  task-309 artifacts do); corrected after the source read showed it is a proof-local `let` —
  the report and the H3 table now point 311 at the global `nf_succ_char_formula(_correct)` and
  the n=0 arm instead.
- Initial fold sketch made the quant clause recurse through `nf_eval_efold` at arity 1;
  changed to `nf_eval_nf M k 1` after checking that Def 4.1 requires the atom to be a
  TL-realized predicate and that the codebase's TL tie-in is proven for `nf_eval_nf` (D5) —
  this removes an entire equivalence obligation from 310.

### Forbidden-output check

No "mathlib likely has this" (no mathlib claim is load-bearing; all assets are local and
file:line-verified). No sorry-deferral, no vacuous placeholder, no new axiom: every proposed
declaration has a concrete proof shape targeting `[propext, Classical.choice, Quot.sound]`,
and the one report-level `sorry` in §4.4 is an elision of spelled-out bookkeeping in a design
sketch, explicitly not proposed as committed debt. The falsified routes (endChar navigated
carrier; lossy depth-k projections) are not resurrected — Alt E bars them again. The
acceptance probe is kept verbatim (no substitution proposed; §5.5).
