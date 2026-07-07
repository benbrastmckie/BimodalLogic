# Research Report: k≥2 Carrier Redesign via Per-Round Vocabulary Enrichment (Blocker Research for Plan v6)

## Metadata

- **Task**: 309 — offdiag_two_anchor_fi_chain
- **Report**: 05 (blocker research after Phase-13 finding F1)
- **Date**: 2026-07-06
- **Session**: sess_1783391112_643ec1
- **Agent**: lean-research-hard-agent (H2/H3/H4 contracts active; H5 not triggered — focus_prompt contains neither "divergence" nor "audit")
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014) + Tier 3 (extends landed task-310/311 implementation)
- **Sources read (bounded)**: phase-13/phase-12 handoffs; summary 04; NfMultiAnchorBridge.lean:1855-1964, :3378-3434, :3771-3934; KampPrior.lean:40-158, :200-410; NfEFold.lean:42-130, :363-490 (outline + regions); PriorDefs.lean:1-42; PriorINF.lean:194-240; EANegation.lean / EANegationClosure.lean (outlines + :604-663); plan v5 :101-320, :407-586; Rabinovich md:55-174

## Summary

The plan-v5 Phase-13 target (`bracketEndChar_kv_correct`, unconditional ∀k, arbitrary `M`,
provider = point-characteristic family `charF` only) was **stated strictly stronger than the
KampPrior:351 consumer needs, in two independent ways**:

1. **Model-unconditional**: the target quantified over ALL `OrderedMonadicStructure`s. The
   `:351` arm sits inside `nf_nvar_exist_all_depths` (KampPrior:212-224), whose statement carries
   `h_UZ : semantic_prior_UZ` and `h_SZ : semantic_prior_SZ` (PriorDefs:22/:33 — attained
   first/last occurrences for every temporal formula). The F1 countermodel `M = (ℚ,<)` with a
   3-point predicate **violates `semantic_prior_UZ`** (a dense co-finite ¬P set has no first
   occurrence), so it never occurs at the consumer.
2. **Provider-unconditional**: at the `:351` arm (outer depth `k+1`), the structural recursion
   on `k` supplies single-anchor existential converters at **all depths ≤ k and all arities**
   (the `ih_exist_1` pattern, KampPrior:265-291, generalizes: the recursive call
   `nf_nvar_exist_all_depths atomMap h_surj k n'` is structurally legal for any `n'`). The
   Phase-13 target allowed itself only `charF` (arity-1 point characteristics).

**However, statement surgery alone is (very likely) not enough**: the F1 information loss is
carrier-definitional (`bracketEndChar_kv_factors`, :3838, machine-checked), and an analysis-level
extension of the F1 countermodel to `ℤ` with `P = {0,10,20}` — a structure that **does** satisfy
UZ/SZ — indicates the fiber-existential carrier stays refuted even relativized (finding F2 below,
not yet machine-checked; mandated as the plan-v6 decision gate).

**Recommended route** (details in §a): (i) restate R3b as the UZ/SZ-relativized,
provider-conditional one-step correctness (the landed `nf_succ_char_formula_correct` hypothesis
pattern, KampPrior:81-100, moved one arity up); (ii) redesign the successor-depth carrier to read
`qnf.2` **per-sub** (finding-F1 item 3's "required behavior"), flattening each positive sub's
deeper existentials into additional bracket witnesses (Lemma 3.4 / G6-amendment mechanism) with
**temporal-formula (enriched) point and segment types** — `TemporalPred` already wraps an
arbitrary `Formula`, so no codomain type change is needed; (iii) discharge negative-sub exclusion
content via the **already-landed, sorry-free Lemma 5.1/Prop 4.2 negation stack**
(`EANegationClosure.lean`, keyed on `HasAttainedINF`, bridged from `h_UZ` by
`prior_hasAttainedINF`, PriorINF:224) — a consumable asset the plan-v5 asset table did not list;
(iv) de-risk at k=2 with a decision-gate phase before general k (the task-311 Phase-5 pattern).

## Findings

### F-A (verified): what KampPrior:351 actually consumes — the generality shrink

The `:351` arm (`n = 1` case of `nf_nvar_exist_all_depths`, outer depth `k+1`) needs, per
arity-3 depth-k sub `qnf` of the quant layer of `sub_nf : NormalForm sig (k+1) 2`, exactly the
two-anchor equivalence
`(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` — i.e.
`BracketCarrierCorrectV` (NfMultiAnchorBridge:1868) **at depth k, for the ambient k of the outer
recursion**. Verified in scope at that point (KampPrior:228-354):

- `M` with `h_UZ h_SZ` (statement hypotheses, :218-220);
- recursive calls `nf_nvar_exist_all_depths atomMap h_surj k n'` for **any** `n'` (structural on
  the first argument; the existing code already makes the `n' = 1` call at :273);
- `char_k1` at depth `k+1` (:307) and `exist_tl_fn_k` (:294).

So the corrected R3b target may be **conditional on a same-depth single-anchor provider family
plus UZ/SZ**, with the ∀k recursion living where it already lives — in KampPrior's outer
`Nat.rec` — instead of inside the Bridge with only `charF` in hand. This is precisely the
mechanism by which the **landed, sorry-free arity-1 enrichment** works:
`nf_succ_char_formula_correct` (KampPrior:81) takes `exist_tl_fn : NormalForm sig k 2 → Formula`
plus a correctness hypothesis `h_exist_correct` and handles the quant layer **per-sub**
(`nf_quant_clause_tl (exist_tl_fn sub) (nf.2 sub)`, one clause per sub, no fiber projection).
Rabinovich's per-round α/β enrichment (Def 3.1, md:61-74; Cor 5.4's `F_i` are TL formulas,
md:154-157) is realized in this codebase, for arity 1, exactly as "providers = TL formulas from
the previous round, threaded as hypotheses". The two-anchor case must copy that architecture, not
the fiber-existential projection.

### F-B (analysis, high confidence, not machine-checked): UZ/SZ relativization alone does NOT rescue the Phase-12 carrier — proposed finding F2

The F1 counterexample transfers to `M* = (ℤ, <)`, `P = {0, 10, 20}`, `x = 2`, `u₂ = 4`,
`u₁ = 12`, `w = 15`, `t = 18`:

- `ℤ` satisfies `semantic_prior_UZ/SZ` for every temporal ψ (each nonempty subset of `(t,∞)` /
  `(-∞,t)` in `ℤ` has a least/greatest element).
- `u₁, u₂` share their complete depth-1 1-type over `sig = {P}` (both `¬P`, with P-points
  strictly below — `{0,10}` / `{0}` — and strictly above — `{20}` / `{10,20}`; all depth-0
  2-type-realization bits agree), while `[u₁,w,x,t]` and `[u₂,w,x,t]` have distinct depth-1
  arity-4 types in the same `(zXW, χ, qnf.1)` fiber: the depth-0 5-type "`P z'' ∧ x < z'' < z`"
  is realized (via `z'' = 10`) below `u₁` and not below `u₂`.
- With `qnf := nf_characteristic M* 2 3 [15,2,18]` and `qnf' := qnf` with the `u₂`-sub un-marked:
  `bracketEndChar_kv_factors` gives carrier equality, `qnf` is realized at `w = 15`, and the
  case analysis over `w' ∈ (2,18)` suggests no `w'` realizes `qnf'` (`w' ≤ 11`: the `u₁`-sub is
  marked true but unrealizable, since a witness needs `P ∩ (2,z) ≠ ∅`, forcing `z ≥ 11 > w'`;
  `12 ≤ w' ≤ 15`: a `u₂`-type witness exists (e.g. `z = 5`), so the un-marked sub is realized;
  `w' ≥ 16`: z-independent segment-emptiness entries of the positively-marked subs of `qnf'`
  mismatch).

Caveat: discreteness makes gap-emptiness depth-1-visible, so the full per-entry check is more
delicate than the ℚ density argument; this is why F2 is proposed as the **first dispatch of plan
v6** (a decision-gate probe), not asserted as settled. If F2 fails (i.e. UZ/SZ rescues the
current carrier at k=2), plan v6 collapses to statement surgery only — a cheap, high-value
branch point either way.

### F-C (verified): the enrichment vehicle already exists at the type level; the redesign is a read-channel change, not a codomain change

- `TemporalPred` slots in `VecEA2`/`VVecEA2`/`bracketFromLists` hold arbitrary `Formula`s
  (`xType : TemporalPred := ⟨char …⟩`, NfMultiAnchorBridge:1955; `BracketFormula.pointTypes`
  :1886-1889). Nothing restricts point/segment types to depth-0 characteristic formulas.
  Rabinovich's enriched α/β (TL formulas over the round-j vocabulary) therefore need **no new
  carrier codomain**: enrichment = putting provider-built temporal formulas into existing slots.
- The G6-amendment / Lemma 3.4 mechanism ("each absorbed existential joins the prefix as a
  witness", plan v5 :189-199) already licenses witness-count growth. Flattening a positive
  depth-k arity-4 sub's own inner existentials into further bracket witnesses is more of the
  same licensed move, not a new shape.
- What must change is the **information channel**: at successor depth the carrier currently
  reads `qnf.2` only through the atom-layer off-fiber Prop and the fiber-existential bits
  (F1 item 2, machine-checked at :3838). The corrected carrier reads `qnf.2` **per-sub**
  (F1 item 3), as `nf_succ_char_formula` does at arity 1.

### F-D (verified): a consumable, sorry-free Lemma 5.1/Prop 4.2 negation stack already exists and was absent from the plan-v5 asset table

| Asset | Location | Status |
|---|---|---|
| `HasAttainedINF` (attained first occurrence for TL-definable P on subintervals) | PriorINF.lean:202 | landed, sorry-free file |
| `prior_hasAttainedINF : semantic_prior_UZ M atomMap → HasAttainedINF M atomMap` | PriorINF.lean:224 | landed, sorry-free |
| `neg_interval_formula` (Lemma 5.1, forward, model-dependent) | EANegationClosure.lean:401 | landed; file has 0 sorries |
| `neg_bounded_exists` (Cor 5.4, forward, model-dependent) | EANegationClosure.lean:492 | landed |
| `neg_vecEA2` / `neg_2var_vec_ea` (Prop 4.2, single conjunct / 2-var) | EANegationClosure.lean:646/:720 | landed |
| `neg_orderedPointsExist_is_vbracket` (Lemma 5.3) | EANegation.lean:347 | landed (EANegation's two sorries at :1090/:1249 are in the *uniform backward* variants, explicitly documented as non-blocking; the semantic variants in EANegationClosure are sorry-free) |
| F-chain construction (`fChainFrom`/`fChainPred`, Cor 5.4 `F_i`) | EANegation.lean:552/:567 | landed |

Caveat (verified from statements): the EANegationClosure lemmas are **model-dependent
existentials** (`∃ v : VVecEA2, v.holds M atomMap z0 z1` for the given `M, z0, z1`), not uniform
formula equivalences. For carrier construction (a fixed formula chosen before `M`), the v6 design
must either (i) use them only in the correctness *proof* (per-model direction obligations), or
(ii) take finite disjunctions over the finitely-generated candidate family (subs, arrangements,
and point-type sets are all finite at each depth). This is real design work for the gate probe,
flagged, not hand-waved.

### F-E (verified/analysis): rejected alternatives

1. **Gate strengthening on the current carrier** — refuted, F1 item 4 (:3922-3928): honest
   characteristic types distinguish same-fiber subs; no model-independent syntactic gate exists.
   Phase-12 Key Decision 2 ("fiber-existential read — do not re-open without a counterexample")
   is now legitimately re-opened: F1 **is** the counterexample.
2. **One-jump enriched-signature re-indexing** (compress `NormalForm sig (k+1) n` to
   `NormalForm sigE 1 n` with `sigE.preds` = depth-k 1-types, then reuse `bracketEndChar_k1v`
   verbatim at `sigE`) — analysis: **lossy by the same F1 pattern one level down**: a depth-k
   arity-(m+1) sub is not determined by order + pointwise depth-k 1-types (the F1 pair `sub₁,
   sub₂` is itself a witness at k=1, arity 4). Any faithful compression must iterate
   **inside-out, one round at a time**, which re-derives Prop 4.3 wholesale — strictly more
   machinery than the per-sub carrier, plus `atomMap`/`h_surj` re-plumbing and a formula
   substitution/truth-transfer lemma that does not currently exist. Rejected as primary; the
   per-sub design below achieves the same Def 4.1 p.6 "iterated fold" content locally.
3. **`nf_eval_efold` as the depth-k semantics** — not available: `EAtomDom sig k n =
   ZoneSpec n × NormalForm sig k 1` (NfEFold:69) carries plain base-signature unary types; D7
   (NfEFold:373-375) explicitly claims the bridge only at depth-0 subs, and the F1 pair shows
   `zone × unary-type` cannot separate joint content at k≥2 (in either ℚ or ℤ form).

### Source-to-Implementation Mapping (H3, Tier 1, 5-column)

| Paper construct (Rabinovich 2014) | Lean identifier | File:line | Status | Phase (v6 sketch) |
|---|---|---|---|---|
| Def 3.1 α/β over the CURRENT (per-round enriched) vocabulary (md:61-74) | temporal-formula point/segment types in `TemporalPred` slots, provider-built | NfMultiAnchorBridge:1886/:1955 (slots landed); provider wiring MISSING | partial | 13.II |
| Prop 4.3 fold round / Def 4.1 p.6 note (inside-out iteration) | `nf_quant_layer_fold_iff` (general n, depth-0 engine) | NfEFold:391 | landed | consumed 13.II/13.III |
| Per-round provider threading (Cor 5.4 `F_i` are TL formulas, md:154-157) | `nf_succ_char_formula`(_correct) hypothesis pattern; `ExistProviders` bundle (NEW) | KampPrior:67/:81 (pattern landed); bundle MISSING | partial | 13.I |
| Lemma 3.2(2) ≤2 free anchors (md:76-79) | `VVecEA2.holds` two-point signature | VecEAFormula:276 | landed | invariant, all |
| Lemma 3.4 ∃-closure (witness joins prefix) (md:84-85) | `existsBounded_right`; G6-amendment witness growth | VecEAClosure:265 | landed | 13.II/14 |
| Lemma 5.3 (INF splitting base, md:137-152) | `neg_orderedPointsExist_is_vbracket`; `HasAttainedINF.first_occ` | EANegation:347; PriorINF:202 | landed | consumed 13.II |
| Lemma 5.1 (bracket negation, md:134-135) | `neg_interval_formula` (forward, model-dependent) | EANegationClosure:401 | landed (uniform backward variant MISSING) | 13.II obligations |
| Prop 4.2 (negation closure, md:100-101) | `neg_vecEA2` / `neg_2var_vec_ea` | EANegationClosure:646/:720 | landed (model-dependent form) | 13.II obligations |
| Dedekind completeness (attained INF over Prior structures) | `semantic_prior_UZ/SZ`; `prior_hasAttainedINF` | PriorDefs:22/:33; PriorINF:224 | landed | 13.I hypotheses |
| §5 bracket `[α_0,…,α_n](z_0,z_1)` (md:127-132) | `VVecEA2` / `bracketFromLists` | VecEAFormula:271; NfMultiAnchorBridge:1883 | landed | reused |
| Prop 3.5 ∃-witness → Until/Since (md:87-94) | `bracketEndChar_k1v_correct` (k=1 template) | NfMultiAnchorBridge:3378 | landed | k≤1 base |

## (a) Recommended design at lemma-signature granularity

**Pillar 1 — statement surgery (settled by F-A).** New correctness predicate and target, additive
in NfMultiAnchorBridge.lean (namespace-local `Prior` hypotheses are importable: PriorDefs is
below the Bridge in the import order — verify at implementation; if not, keep the hypotheses as
explicit ∀-quantified Props exactly as `nf_succ_char_formula_correct` does, which needs no
import):

```lean
/-- Provider bundle: single-anchor existential converters at depth k, all arities,
    correct on Prior (UZ/SZ) structures — what the outer recursion supplies at :351. -/
structure ExistProviders (sig : MonadicSignature) (atomMap : Formula → sig.preds) (k : Nat) where
  existF : (n : Nat) → NormalForm sig k (n + 1) → Formula
  correct : ∀ (n : Nat) (sub : NormalForm sig k (n + 1))
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (existF n sub) ↔
        ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub

/-- UZ/SZ-relativized, provider-conditional carrier correctness — the corrected R3b target. -/
def BracketCarrierCorrectVPrior {sig} (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrierV sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3) (…six bracket-zone order hypotheses on the atom layer…)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

**Pillar 2 — per-sub carrier (the F1 item-3 "required behavior").** New definition (additive; do
NOT edit `bracketEndChar_kv` — it stays as the landed k≤1 instance and F1 exhibit):

```lean
noncomputable def bracketEndChar_kvE {sig} (atomMap …) (h_surj …)
    (P : ExistProviders sig atomMap k)          -- providers at the PREVIOUS/SAME round
    : BracketEndCharCarrierV sig (k + 1)
```

with, at successor depth: the interior-positive enumeration ranges over **positive subs**
`σ : NormalForm sig k 4` (each `qnf.2 σ = true` in an interior zone), NOT over
`(ZoneSpec 3 × NormalForm sig k 1)` fibers; each positive σ contributes a `z`-witness slot whose
point type and adjacent segment types are **temporal formulas built from `P.existF`** (the
enriched vocabulary), plus σ's own inner existentials flattened as further witnesses (Lemma 3.4
license); negative subs contribute segment/endpoint exclusion literals over the same enriched
vocabulary, with correctness-proof obligations discharged through the
`HasAttainedINF`/first-occurrence splitting (`prior_hasAttainedINF h_UZ` + the EANegationClosure
stack). The exact literal shapes are the k=2 gate probe's design deliverable (Pillar 4) — this
report fixes the interface and information channel, not every conjunct.

**Pillar 3 — correctness, one step, conditional:**

```lean
theorem bracketEndChar_kvE_correct {sig} (atomMap …) (h_surj …)
    (P : ExistProviders sig atomMap k) :
    BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE atomMap h_surj P)
```

At the Phase-14 call site (outer depth `k+1`, needing depth-k carrier), instantiate
`P.existF n := fun sub => (nf_nvar_exist_all_depths atomMap h_surj k n sub).choose` — hmm, note
the depth alignment: the carrier needed at depth `k` is `bracketEndChar_kvE` at `k = j + 1` with
providers at depth `j = k - 1`, which the outer recursion supplies for `j < k+1`; depth-0 stays
`bracketEndChar_k0`, depth-1 stays the k1v instance (both landed).

**Pillar 4 — decision gates (H5/H6 discipline).** Two probes precede full generality:
- **F2 probe**: attempt to machine-check the ℤ-extension (F-B) refuting the UZ/SZ-relativized
  statement for the CURRENT carrier at k=2. If refutation fails and the relativized statement is
  provable, STOP: plan v6 reduces to statement surgery + Phase 14.
- **k=2 GO/NO-GO**: prove `bracketEndChar_kvE_correct` at the k=2 instance (where each positive
  sub's inner layer is depth-0, so the landed split kit `nf0_split_assemble` at arity 5 and the
  general engine `nf_quant_layer_fold_iff` apply directly) before dispatching general k.

## (b) Preserved vs. redefined

**Preserved unchanged (consume by name; byte-identical):**

| Asset | Location | Role in v6 |
|---|---|---|
| `bracketEndChar_kv_correct_zero` / `_one` | NfMultiAnchorBridge:3783/:3811 | k≤1 instances of the relativized predicate (weakening lemmas lift them: an unconditional ↔ implies the UZ/SZ-conditional one) |
| `bracketEndChar_kv_factors` + F1 record | :3838/:3871-3934 | permanent defect exhibit; F2 probe input |
| `bracketEndChar_kv` (Phase-12 def) | :3630 | stays as the landed k≤1 instance; NOT edited, NOT consumed at k≥2 |
| Whole k1v kit (`bracketEndChar_k1v`, `_correct`, `_sound`, `_complete`, helpers :2028-2825) | :1923-3392 | depth-1 template + proof machinery for the kvE step |
| `bracketEndChar_k0`/`_correct` | :1563/:1577 | recursion base |
| Fold engine (all of NfEFold: `nf_quant_layer_fold_iff`, `efold_of_nf1`, `nf_eval_nf1_iff_efold`, gate corollary, split kit) | NfEFold:102-541 | consumed at each inner round; never redefined (plan Do-NOT preserved) |
| `VVecEA2`/`VecEA2`/`bracketFromLists`/`existsBounded_right` | VecEAFormula:252-286; Bridge:1883; VecEAClosure:265 | carrier codomain + witness growth |
| Phases 1-5 arms (`A_past`/`A_future`/`A_diag`/`nf_char2_{past,future}_formula`) + trichotomy | per plan v5 asset table | Phase 14 unchanged |
| `nf_succ_char_formula`(_correct), `char_k1`, `nf_nvar_exist_all_depths` skeleton | KampPrior:67/:81/:307/:212 | provider source + architectural template |
| NEW to the asset table: EANegationClosure stack + `prior_hasAttainedINF` + `HasAttainedINF` | EANegationClosure.lean; PriorINF:202/:224 | exclusion-content obligations |

**Redefined / new for k≥2:** `ExistProviders`, `BracketCarrierCorrectVPrior`,
`bracketEndChar_kvE` (+ per-sub successor body), `bracketEndChar_kvE_correct` (+ direction
lemmas), the F2 probe artifact, and a Phase-14 instantiation shim (providers from the outer
recursion). The plan-v5 Phase-13 deliverable names (`bracketEndChar_kv_correct`,
`_sound`/`_complete` unconditional) are **retired**, not restated.

## (c) Phase decomposition sketch for plan v6 (H8: one agent run each)

Answer to the depth question first (verified, F-A): **Phase 14/:351 does NOT need the
unconditional ∀k theorem.** It needs, at each outer depth `k+1`, a depth-k carrier correct on
UZ/SZ structures, conditional on providers the outer recursion already supplies. The ∀k
quantifier is discharged by KampPrior's existing `Nat.rec`, not inside the Bridge.

| Phase | Content | Est. lines | Gate |
|---|---|---|---|
| 13.0 | F2 probe: attempt UZ/SZ-relativized k=2 statement for the CURRENT carrier; expected outcome = machine-checked refutation (ℤ, P={0,10,20}) recorded as F2 next to F1; else GO-to-surgery-only | 80-200 | DECISION: continue vs. collapse to 13.I+14 |
| 13.I | Statement surgery: `ExistProviders`, `BracketCarrierCorrectVPrior`, relativized lifts of the k=0/k=1 instances | 100-180 | build green, 0 sorries |
| 13.II-a | `bracketEndChar_kvE` definition, per-sub successor body; k=2 instance elaborated concretely (positive-sub witness flattening via `nf0_split_assemble` at arity 5; exclusion literal shapes) | 150-250 | typecheck, axiom-clean |
| 13.II-b | k=2 correctness GO/NO-GO (soundness + completeness at k=2; EANegationClosure consumption; the task-311 Phase-5 verdict-record pattern) | 200-250 | DECISION: R3-E = GO before 13.III |
| 13.III | General k step: `bracketEndChar_kvE_correct` by the one-step argument with symbolic k (template = 13.II-b) | 150-250 | 0 sorries or documented strategic-sorry |
| 14 | Unchanged shape (plan v5 Phase 14): hook discharge + `:351` rewire; provider instantiation from recursive calls; full-tree build + `lean_verify` = `[propext, Classical.choice, Quot.sound]` | 80-150 | live sorries 2 → 1 |

Contingency: if 13.II-b NO-GOes on the exclusion-content encoding (the model-dependent-negation
uniformization gap flagged in F-D), the fallback is a dedicated uniformization phase (finite
disjunction over the finitely-generated candidate family) before retrying — bounded, since all
index sets (`NormalForm sig k m`) are finite.

## (d) Guards audit (G1-G6-as-amended, N1-N5)

- **G1, G3** — respected: carrier stays a two-anchor bracket; segments carry real (now enriched)
  exclusion content, never trivial-top.
- **G2, G4, Corrected Anchor-Cap** — respected: per-sub flattening grows WITNESSES only (Lemma
  3.4 / §5 license, exactly the G6-amendment mechanism); `VVecEA2.holds` stays two-point;
  no `nf_char3_deeper_split`.
- **G5, N1, N2, N3** — respected with an **extension**: chain steps at k≥2 must additionally cite
  Lemma 5.3/5.1 + Prop 4.2 (md:100-152) for exclusion content, keeping the N2 discipline (fold =
  Def 4.1 p.6 note; Prop 4.3 cited only for "residual is ∨∃∀ over E[Σ] atoms").
- **G6-as-amended** — carrier SHAPE unchanged (two-anchor, fixed `{x,t}`, witness-growing
  `VVecEA2`). **One documented amendment required (A1)**: the correctness *predicate* gains
  `(h_UZ, h_SZ)` hypotheses and provider conditionality (`BracketCarrierCorrectVPrior`). This
  amends the plan's target statement, not G6's carrier shape; justification = F1 (the
  counterexample license Phase-12 KD2 demanded) + F-A (the consumer's actual hypotheses).
- **"Do NOT reconstruct the arity-4 residual"** — **second documented amendment required (A2)**:
  at k≥2 the per-sub read makes `NormalForm sig k 4` subs appear as *indices/data* and as
  *per-sub proof obligations*. Amended rule: every per-sub obligation must be discharged by
  inside-out application of `nf_quant_layer_fold_iff` at its innermost (depth-0) layer with
  witnesses flattened into the bracket; no NAVIGATED arity-3/4 characteristic, no third anchor,
  no raw `nf_eval_nf M (k+1)` split that leaves a joint (n+1)-ary existential standing
  undischarged. (The old rule's intent — no fiber-blind arity-4 resurrection — is preserved; its
  letter banned the only mathematically possible read channel.)
- **N4, N5** — respected: interior-positive content (now per-sub, transitively flattened) rides
  witness slots between the fixed endpoints; arrangements stay a finite disjunction (index sets
  finite at every depth); `nf_eval_unique` still supplies distinctness.
- **Do-NOT list** — respected: no fold asset redefined; no k1v/k0/310/311 asset edited; no import
  cycle: new material is additive in NfMultiAnchorBridge.lean, and adding
  `import …Kamp.EANegationClosure` there is verified cycle-free (only KampPrior imports the
  Bridge; the negation stack's transitive closure — EANegation, PriorINF, PriorDefs,
  ExistsForallNF, VecEAFormula, VecEAClosure — reaches neither KampPrior nor the Bridge).

## Adversarial Self-Verification

Verification pass performed against sources after drafting; two claims were downgraded
(F-B marked analysis-only; EANegationClosure marked model-dependent) and one recommendation
was modified (added the 13.0 F2 probe as first dispatch instead of asserting the redesign
unconditionally).

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| Phase-13 target is FALSE at k=2 for the Phase-12 carrier (unconditional form) | F1 record, NfMultiAnchorBridge.lean:3871-3934; `bracketEndChar_kv_factors` :3838 | Read of the machine-checked lemma + defect record | High |
| `:351` consumer has `h_UZ`/`h_SZ` in scope | KampPrior.lean:216-223 (statement) and :265-291 (arm context) | Read of `nf_nvar_exist_all_depths` statement | High |
| Recursive calls at depth k, ANY arity, are available at the `:351` arm | KampPrior.lean:273 makes the (k, n'=1) call; recursion is structural on the first (Nat) argument | Read of the existing recursive call; generalization to other `n'` is the same structural descent — flagged for compile-check in 13.I | Medium-High |
| `(ℚ,<)` with finite P fails `semantic_prior_UZ` (so F1's model never reaches the consumer) | PriorDefs.lean:22-28: take ψ with a dense complement-of-finite extension (e.g. `(.atom a).neg`); no first occurrence exists | Direct read of the abbrev + one-line order argument | High |
| `ℤ` with `P={0,10,20}` satisfies UZ/SZ AND extends F1 (statement surgery alone insufficient) | F-B case analysis (this report); UZ/SZ from well-ordering of `(t,∞) ⊆ ℤ` | Analysis only — NOT machine-checked; mandated as v6 Phase 13.0 | Medium (UZ/SZ part: High; full per-entry type-match case analysis: Medium) |
| `nf_succ_char_formula_correct` is the landed provider-conditional per-sub enrichment pattern | KampPrior.lean:67-137 | Read of definition + correctness proof (per-sub `nf_quant_clause_tl`, hypothesis `h_exist_correct`) | High |
| `EAtomDom` carries plain base-signature unary types; D7 claims the bridge at depth-0 subs only | NfEFold.lean:69-70, :373-375 | Read of abbrev + D7 comment | High |
| EANegationClosure.lean is sorry-free and contains Lemma 5.1/Cor 5.4/Prop 4.2 (forward, model-dependent) | `grep -c sorry` = 0; outline :401/:492/:646/:720; `neg_vecEA2` statement read at :646-663 | grep + targeted read | High |
| `prior_hasAttainedINF : semantic_prior_UZ → HasAttainedINF` is landed sorry-free | PriorINF.lean:224-238; file sorry count 0 | Read + grep | High |
| EANegationClosure lemmas are model-dependent (`∃ v, v.holds M … z0 z1`), needing uniformization or proof-side-only use in a fixed carrier | `neg_vecEA2` statement :646-652 (`∃ v : VVecEA2, v.holds M atomMap z0 z1`) | Read of statement | High |
| One-jump enriched-signature compression is lossy (F1 pattern one level down) | The F1 pair `sub₁,sub₂ : NormalForm sig 1 4` share order + pointwise depth-1 1-types yet differ | Analysis from the F1 record's own data | High |
| `TemporalPred` accepts arbitrary formulas (enrichment needs no codomain change) | NfMultiAnchorBridge:1955-1964 (`⟨formula_conjList …⟩` constructions) | Read of k1v construction | High |
| `nf0_split_assemble` is stated at general n (k=2 probe can use it at arity 5) | NfEFold.lean:235 (`{n : Nat}`) | Read of outline + theorem header | High |
| Import direction: `import …Kamp.EANegationClosure` into NfMultiAnchorBridge is cycle-free (transitively supplies PriorINF, PriorDefs, EANegation) | Only KampPrior.lean:4 imports the Bridge; the negation stack's transitive imports (EANegation ← {VecEAFormula, PriorINF ← {ExistsForallNF, PriorDefs}, VecEAClosure}) reach neither KampPrior nor the Bridge | grep of all `import` edges in the Kamp directory | High |

**Contradiction log**: none found between sources. The only tension — plan v5's "Do NOT
reconstruct the arity-4 residual" vs. the per-sub read — is resolved as a documented guard
amendment (A2, §d), per the precedence of a machine-checked counterexample (F1) over a plan
guard whose letter presupposed the refuted design.

**Forbidden-output check**: no "mathlib likely has this" claims (all assets verified at
file:line); no sorry-deferral recommendation (the 13.x phases each end 0-sorry or
NO-GO-record); no new axioms proposed.

## Recommended next step

`/revise 309` (plan v6) implementing §c, with Phase 13.0 (F2 probe) as the first dispatch and
the two guard amendments (A1: relativized+conditional correctness predicate; A2: per-sub read
discipline) recorded in the plan preamble.
