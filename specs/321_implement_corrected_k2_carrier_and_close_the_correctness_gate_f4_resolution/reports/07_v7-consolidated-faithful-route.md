# Task 321 — v7 Consolidated Pre-Implementation Research: the Faithful Separate-Bracket Route Against the Post-331 Module Landscape

**Task**: 321 — implement corrected k=2 carrier and close the correctness gate (F4 resolution)
**Dispatch**: hard-mode lean4 consolidated research (H2/H3/H4), `--lit` active (Rabinovich 2014 chunk read IN FULL this dispatch)
**Session**: sess_1783484615_56e1a4
**Date**: 2026-07-07
**Baseline tree**: post-task-331 split (`NfMultiAnchorBridge/` 10 modules + 88-line umbrella; all 331 gates PASS per `specs/331_.../summaries/01_split-summary.md`)
**Supersedes for coordinates**: every `file:line` in reports 01–06 and plans v1–v6 that cites the pre-331 monolith. **This report's coordinates are the fresh ground truth**, verified by grep + `lean_local_search` + direct reads this dispatch.

---

## Executive summary

1. **Coordinate re-map complete** (§1): 38 load-bearing symbols re-mapped from stale monolith
   lines to their post-331 module + current line, each verified against the tree this dispatch.
2. **The unbuilt object is smaller than report 06 estimated in one respect and larger in
   another** (§2–§3). Smaller: the Lemma 5.1 point-insertion machinery with a SHARED point —
   both the split direction and the combine direction — **already exists**
   (`BracketFormula.leftPart`/`rightPart`/`leftPart_holds`/`rightPart_holds`/`splitAt_combine`,
   `VecEAFormula.lean:360–478`), a fact no prior artifact recorded. Larger: the landed
   Prop 4.2 negation closure `neg_2var_vec_ea` has a **pointwise-existence statement shape**
   that cannot serve where a model-independent carrier or a negation biconditional is needed
   (§2.4, a new H4 finding), and two consumption-relevant k1v lemmas were left `private` by
   the split (§3.4), so the atom-layer discharge must be re-derived additively or a
   de-privatization sanctioned.
3. **Recommended candidate** (§2.2, Candidate A): a concrete, model-independent joint carrier
   `kvE2_sepBody : NormalForm sig 2 3 → VVecEA2` whose disjuncts are single FLAT brackets —
   one shared `ptW` slot, per-σ single-point E[Σ]-atom types interleaved per Lemma 3.2(1) —
   plus its correctness pair discharging `BracketCarrierCorrectVPrior`.
4. **Obligation decomposition** (§3): 8 obligations, estimated **650–1,100 additive lines**
   (honestly above report 06's 400–700; discrepancy analyzed in §3.3). The make-or-break is
   O4 (per-σ `hgate` derivation from the joint carrier's realized segments — crux step (d)).
5. **Risk-profile inversion finding** (§5.1): in the separate-bracket route the EXTERIOR zones
   are no longer the high-risk item (they compose trivially at the shared fixed endpoints);
   the residual risk concentrates in the interior interleaving + hgate derivation. The
   RE-SCOPE fallback is therefore re-derived along two axes (§5.2) with concrete obligation
   lists, and the v7 plan should place a decision gate after the first joint-carrier phase.

---

## §1 Coordinate re-map (stale → fresh), verified this dispatch

Modules under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` unless
noted. "Stale ref" = the monolith line cited by reports 05/06, plan v6, or the in-file v6
records (which retain orig `:NNNN` refs by design — 331 Non-Goal).

### 1.1 Faithful API — SubBracket2V.lean (orig slab :6734–:8585)

| Symbol | Stale ref | Fresh location (verified) | Visibility |
|---|---|---|---|
| `kvE_subBracket2V` (def) | :6833 | `SubBracket2V.lean:139` | public |
| `kvE_subChain2V` (def) | :6955 / :6988 / :6674 (mixed) | `SubBracket2V.lean:261` | public |
| `kvE_subBracket2V_sound` | :7370 | `SubBracket2V.lean:946` | public |
| `kvE_subBracket2V_sound_of_parts` | :7449 / :7719 (mixed) | `SubBracket2V.lean:1025` | public |
| `bracketFromLists_flatMap_subchain_below_pin` | :7793 | `SubBracket2V.lean:1099` | **private** (settled divergence 1 of 331 — its only consumers are the `_of_outer` closers in the same module) |
| `kvE_sub2V_bounded_anchor_of_outer` | (unnamed in 05/06) | `SubBracket2V.lean:1182` | public |
| `kvE_subBracket2V_sound_of_outer` | :7910 | `SubBracket2V.lean:1216` | public |
| `kvE_sub2V_zone_consistent` | — | `SubBracket2V.lean:1270` | private |
| `kvE_subBracket2V_gate_holds_of_honest` | :8086 | `SubBracket2V.lean:1392` | public |
| `kvE_subBracket2V_nonvacuous` | :8119 | `SubBracket2V.lean:1425` | public |
| `kvE_subBracket2V_complete` | :8159 | `SubBracket2V.lean:1465` | public |
| `kvE_subBracket2V_correctness_pair` | :8549 | `SubBracket2V.lean:1855` | public |
| `bracketFromLists3` (3-region builder) | :6609–6621 / :6741 | `SubBracket2V.lean:72` | private |
| Shared-interior-witness boundary NOTE | — | `SubBracket2V.lean:25–27` (API banner: "the ONE unbuilt object … owned by task 321; this module deliberately provides only the per-σ half") | — |

### 1.2 Faithful API — NavigatedSpine.lean (orig slab :8827–:9249)

| Symbol | Stale ref | Fresh location (verified) | Visibility |
|---|---|---|---|
| v6 Phase-1 baseline/quarantine record | :8827–:8858 | `NavigatedSpine.lean:29–59` | — |
| no-nesting audit rule | :8841–:8846 | `NavigatedSpine.lean:43–48` | — |
| `kvE_fold_navigated` | :8894-ish (v6 P2) | `NavigatedSpine.lean:83` | public |
| `VVecEA2.disjList` (def) | :8940-ish | `NavigatedSpine.lean:140` | public |
| `VVecEA2.disjList_holds` | :8947 | `NavigatedSpine.lean:149` | public |
| `reflatten_neg_step` | — | `NavigatedSpine.lean:178` | public |
| `reflatten_prop43` | :8991 | `NavigatedSpine.lean:193` | public |
| `VVecEA2.holds_flatMap_map` | :9018 | `NavigatedSpine.lean:220` | public |
| `kvE_nonInterior_zPastX_sound` | :9055–:9176 (block) | `NavigatedSpine.lean:257` | public |
| `kvE_nonInterior_zFutT_sound` | 〃 | `NavigatedSpine.lean:271` | public |
| `kvE_nonInterior_zAtX_sound` | 〃 | `NavigatedSpine.lean:284` | public |
| `kvE_nonInterior_zAtT_sound` | 〃 | `NavigatedSpine.lean:295` | public |
| `kvE_nonInterior_zAtW_sound` | 〃 | `NavigatedSpine.lean:308` | public |
| `kvE_nonInterior_zPastX_complete` | 〃 | `NavigatedSpine.lean:336` | public |
| `kvE_nonInterior_zFutT_complete` | 〃 | `NavigatedSpine.lean:348` | public |
| `kvE_nonInterior_zAtX_complete` | 〃 | `NavigatedSpine.lean:359` | public |
| `kvE_nonInterior_zAtT_complete` | 〃 | `NavigatedSpine.lean:368` | public |
| `kvE_nonInterior_zAtW_complete` | 〃 | `NavigatedSpine.lean:378` | public |
| Phase-7 RESCOPE record + captured crux | :9183–:9249 | `NavigatedSpine.lean:385–449` | — |

### 1.3 Carrier types, Prior interface, atom-layer assets

| Symbol | Stale ref | Fresh location (verified) | Visibility |
|---|---|---|---|
| `BracketEndCharCarrierV` | :1872 | `CarrierK1V.lean:365` | public |
| `BracketCarrierCorrectV` | :1881 | `CarrierK1V.lean:374` | public |
| `bracketFromLists` (2-region builder) | :1896 | `CarrierK1V.lean:389` | public (de-privatized by 331, sanctioned edit #1) |
| `bracketEndChar_k1v` | :1940 | `CarrierK1V.lean:433` | public |
| `k1v_bracket_extract` | :2150 | `CarrierK1V.lean:643` | **private** |
| `k1v_reconstruct_nf3` | :2425 | `CarrierK1V.lean:918` | **private** |
| `bracketEndChar_k1v_sound` / `_complete` | :2338 / :2979 | `CarrierK1V.lean:988` / `:1629` | private |
| G6 / R2 NO-GO record | :1609–:1641 | `CarrierK1V.lean:102–141` | — |
| `ExistProviders` (`existF`/`correct`) | :5013 | `PriorInterface.lean:40–45` (structure fields) | public |
| `BracketCarrierCorrectVPrior` | :5032 | `PriorInterface.lean:60` | public |
| `nf_eval_depth1_fold_iff` | :5344 | `CarrierKv.lean:466` (331 sanctioned relocation) | public |

### 1.4 External combinators (files unchanged by 331 — locations re-verified anyway)

| Symbol | Fresh location (verified) | Note |
|---|---|---|
| `VVecEA2` (structure) / `.holds` | `VecEAFormula.lean:271` / `:276` | disjuncts : `List (Σ n, VecEA2 n)` |
| `VVecEA2.disj` / `disj_holds` | `VecEAFormula.lean:282` / `:286` | biconditional (`↔`) |
| `BracketFormula.leftPart` / `rightPart` | `VecEAFormula.lean:360` / `:368` | **the A_i^-/A_i^+ split — Lemma 5.1** |
| `BracketFormula.leftPart_holds` / `rightPart_holds` | `VecEAFormula.lean:375` / `:412` | split direction (holds-with-witnesses → parts at the shared witness point) |
| `BracketFormula.splitAt_combine` | `VecEAFormula.lean:478` | **combine direction: left(z0,z) ∧ pt@z ∧ right(z,z1) → holds(z0,z1)** |
| `BracketFormula.conjStruct` / `conjStruct_holds` | `VecEAClosure.lean:109` / `:126` | forward direction only |
| `VVecEA2.conj_struct` / `conj_struct_holds` | `VecEAClosure.lean:195` / `:205` | forward direction only |
| `VVecEA2.conj_holds_vvecEA2` | `VecEAClosure.lean:238` | pointwise existence form |
| `neg_vecEA2` / `neg_2var_vec_ea` | `EANegationClosure.lean:648` / `:722` | pointwise existence form — see §2.4 |
| `exists_permutation_cons_head` | `EANegationClosure.lean:752` | public; arrangement selection |
| `nf_eval_nf` (depth-(k+1) unfold) | `NormalForm.lean:198–207` | atom clause + `∀ sub` quant clause |
| `nf_characteristic` / `_satisfies` / `nf_eval_unique` | `NormalForm.lean:214` / `:224` / `:245` | generic over k |
| `Fintype (NormalForm sig k n)` | `NormalForm.lean:167–178` | positives enumerable via `Finset.univ.toList.filter` |
| `HasAttainedINF` | `PriorINF.lean:202` | — |

### 1.5 Quarantined (MergedQuarantine.lean, orig :5077–:5332, :5360–:5856, :8586–:8826; RefutationF2.lean, orig :4041–:4987)

| Symbol | Stale ref | Fresh location (verified) |
|---|---|---|
| `kvE_consistent` / `kvE_consistentZones` | :5157 / :5507 | `MergedQuarantine.lean:112` / `:435` (private) |
| `kvE_gate` | :5172 | `MergedQuarantine.lean:127` (private) |
| `kvE_body` | :5193 | `MergedQuarantine.lean:148` (private) |
| `bracketEndChar_kvE` | :5307 | `MergedQuarantine.lean:262` |
| `kvE_pinArrangements` / `kvE_pinDisjunct` / `kvE_exclConj` | :5521 / :5531 / :5545-ish | `MergedQuarantine.lean:449` / `:459` / `:472` (private) |
| `kvE'_body` (with `slotsFor` local let) | :5562 (let :5632) | `MergedQuarantine.lean:490` (let `:560`) (private) |
| `bracketEndChar_kvE'` | :5667 | `MergedQuarantine.lean:595` |
| F4 carrier-shape defect record + task-320 probes | :5689–:5765, :5767–:5856 | `MergedQuarantine.lean:619–:806` region |
| `kvE2_body` (with `slotsFor` local let) | :8608 (zones :8618–:8624) | `MergedQuarantine.lean:807` (let `:876`) (private) |
| `bracketEndChar_kvE2` / `_two_eq` | :8712 / — | `MergedQuarantine.lean:911` / `:926` |
| `kvE2_joint_nonvacuous_at_honest` | :8306 / :8748 (mixed) | `MergedQuarantine.lean:947` |
| task-327 k=2 NO-GO gate record | :8760–:8825 | `MergedQuarantine.lean:959–end` |
| F2 relativized-refutation record | :4041–:4987 | `RefutationF2.lean` (`f2_relativized_refutation` `:859`) |

**Trust note**: every fresh line above was obtained by grep against the current tree and
spot-checked by reading the declaration text; `lean_local_search` confirmed the fully-qualified
names for `kvE_subBracket2V_correctness_pair`, `BracketFormula.splitAt_combine`, and
`BracketFormula.leftPart_holds` resolve in the build index.

---

## §2 The unbuilt object, precisely

### 2.1 Statement of the gap (against fresh coordinates)

The k=2 gate is `BracketCarrierCorrectVPrior atomMap carrier` (`PriorInterface.lean:60`):
for all `qnf : NormalForm sig 2 3` in the bracket zone, all Prior structures `M`, and fixed
endpoints `x t`,

```
(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

The RHS unfolds (`NormalForm.lean:198–207`) to the depth-0 atom layer over `[w,x,t]` PLUS the
outer quant layer `∀ sub : NormalForm sig 1 4, (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] sub) ↔ qnf.2 sub`.
The landed per-σ carrier `kvE_subBracket2V σ` (`SubBracket2V.lean:139`) discharges each
positive sub's biconditional **at a given `w`** via `kvE_subBracket2V_correctness_pair`
(`SubBracket2V.lean:1855`), but each per-σ bracket carries its own `ptW` witness slot: a
conjunction of separate per-σ carriers realizes each σ at a possibly **different** `w_σ`.
The gap is the **shared-interior-witness conjunction**

```
∃ w, ⋀_{σ positive} (per-σ realization at that same w)   [plus atom layer and negatives]
```

exactly as the SubBracket2V API banner records (`SubBracket2V.lean:25–27`: "the
shared-interior-witness conjunction (`∃ w, ⋀_σ ...`) … is the ONE unbuilt object. It is owned
by task 321").

### 2.2 Candidate A (recommended): concrete joint separate-content carrier + correctness pair

```lean
noncomputable def kvE2_sepBody {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : VVecEA2
```

Construction (all pieces flat, single-point, model-independent):
- `pos : List (NormalForm sig 1 4) := Finset.univ.toList.filter qnf.2` (Fintype instance
  `NormalForm.lean:167–178`; same enumeration device the quarantined `kvE_body` used at
  `MergedQuarantine.lean:170`, reused as a *pattern*, not imported).
- ONE shared `ptW` slot (point type: `charBase` of the coord-1 projection of `qnf.1`-level
  content + self-zone literals — the arity-3 analog of the per-σ `ptW`,
  `SubBracket2V.lean:216–219`).
- Per positive σ: one `ptX1_σ` slot with point type `charK (nfk_projFresh σ)` — a **unary
  E[Σ]-atom** typing that slot's point — plus σ's per-region interior-positive `charBase χ`
  types.
- Disjuncts enumerate the **joint interleavings**: for each function assigning every positive
  σ's slots to refined positions between `x`, the shared `w`-slot, and `t` (a permutation
  product generalizing `S_XU.permutations ×ₗ S_UW.permutations ×ₗ S_WT.permutations` of
  `SubBracket2V.lean:249–251` to the union over `pos`), one flat
  `bracketFromLists`-style bracket whose refined segment types are the **conjunction of every
  σ's exclusion content on that refined sub-interval**.
- Endpoint predicates: `epL_joint`/`epR_joint` = `formula_conjList` of all per-σ exterior and
  boundary literals (the per-σ `epL`/`epR` content, `SubBracket2V.lean:183–192`) PLUS
  `qnf.1`'s own endpoint 1-types — these conjoin **trivially** because they are all evaluated
  at the same two fixed points `x` and `t` (§5.1).
- Gate-failure branch = `{ disjuncts := [] }` under the depth-2 gate (off-fiber falsity +
  joint-zone-consistency), mirroring `SubBracket2V.lean:232–252`.

Plus the correctness theorem (the deliverable that closes Phase 7):

```lean
theorem kvE2_sepBody_correct_prior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap) :   -- or the concrete charK := P.existF 0 instantiation
    BracketCarrierCorrectVPrior atomMap
      (fun qnf => kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) (P.existF 0) qnf)
```

**Why the carrier must be a concrete `def`**: `BracketCarrierCorrectVPrior` quantifies over
`M` INSIDE its statement, so the carrier has to be built model-independently. This rules out
consuming the pointwise-existence combinators (`reflatten_prop43`, `conj_holds_vvecEA2`,
`neg_2var_vec_ea`) *as the carrier* — see §2.4.

### 2.3 Candidate B: split-halves composition via the landed Lemma 5.1 kit

Split each per-σ bracket at its `ptW` slot (index `lXU.length + 1 + lUW.length` within the
arrangement) using `BracketFormula.leftPart`/`rightPart` (`VecEAFormula.lean:360/:368`);
conjoin the per-σ left halves over `(x, w)` and right halves over `(w, t)`; re-insert `w` as
the single shared point via:

- split direction: `leftPart_holds` / `rightPart_holds` (`VecEAFormula.lean:375/:412`) —
  from a realized joint bracket, both halves hold **at the shared witness point**;
- combine direction: `splitAt_combine` (`VecEAFormula.lean:478`) —
  `(bf.leftPart i).holds z0 z → (bf.pointTypes i) @ z → (bf.rightPart i).holds z z1 → bf.holds z0 z1`.

**Trade-off vs Candidate A**: B makes the Lemma 5.1 shared-endpoint mechanism explicit and
reuses the landed kit, but the half-conjunction step still requires the same joint
interleaving enumeration Candidate A performs (multiple σ's left-half content must interleave
inside `(x, w)`), plus extra split/recombine plumbing and a reverse extraction through
`conjStruct` that does not exist (only the forward `conjStruct_holds`,
`VecEAClosure.lean:126`). **Recommendation: use A for the carrier; consume B's
`leftPart_holds`/`rightPart_holds`/`splitAt_combine` inside A's proofs** wherever the
shared-`w` pivot is needed (O3/O6 below) — they are exactly the two directions of the
Lemma 5.1 insertion at `w`.

### 2.4 Candidate C (staging of A) + the negation-closure caveat (new H4 finding)

State the shared-w conjunction first as a standalone theorem over an arbitrary positive list,
then wrap the gate:

```lean
theorem kvE2_sepConj_sharedW {sig} (charBase charK) (σs : List (NormalForm sig 1 4))
    (M) (x t : M.carrier) (…per-σ order-bit and hcharK hypotheses…) :
    (kvE2_sepConj charBase charK σs).holds M atomMap x t ↔
      ∃ w, x < w ∧ w < t ∧ wAnchor w ∧
        ∀ σ ∈ σs, ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
```

with `kvE2_sepConj` a model-independent def over the list. This isolates the genuinely new
mathematics (shared-w) from the thin gate wrapper (atom layer + negatives) and gives the v7
plan a smaller first make-or-break phase. A = C + wrapper.

**Negation-closure caveat (load-bearing for the plan).** The landed Prop 4.2 assets are
stated in pointwise-existence form:
`neg_2var_vec_ea (h_INF) (v) (z0 z1) (h_lt) (h_neg : ¬v.holds …) : ∃ v' : VVecEA2, v'.holds M atomMap z0 z1`
(`EANegationClosure.lean:722–733`; same shape `neg_vecEA2:648`, `reflatten_neg_step`
`NavigatedSpine.lean:178`, `conj_holds_vvecEA2` `VecEAClosure.lean:238`). As *stated*, the
conclusion `∃ v', v'.holds` is satisfiable by the trivial-top `VVecEA2` regardless of the
hypotheses (the `nil` branch of `neg_disjunct_list`, `EANegationClosure.lean:700–708`,
constructs exactly that). The mathematical content lives in the *construction inside the
proof*, which the statement does not expose: there is **no lemma of the form
`∃ v', ∀ z0 z1, v'.holds ↔ ¬v.holds`** and no model-independent negation operator. Consequence
for v7: the gate's negative subs (`qnf.2 sub = false`) must NOT be routed through Prop 4.2
existence forms; they are handled by the **uniqueness/coverage mechanism** (`nf_eval_unique`
`NormalForm.lean:245` + `nf_characteristic_satisfies` `:224` + the joint gate's off-fiber and
zone-consistency clauses), exactly as the landed per-σ and k1v gates do. This does not block
the route — it removes one advertised crutch and is why O5 below cites uniqueness, not
Prop 4.2.

### 2.5 Literature grounding of each piece (chunk read in full; quotes verbatim)

| Piece of the construction | Rabinovich item | Verbatim licence (md line) |
|---|---|---|
| Combining separate per-σ brackets into a disjunction of single flat brackets (the joint interleaving enumeration) | **Lemma 3.2(1)** | md:77: "Conjunction of exists-forall formulas is equivalent to a disjunction of exists-forall formulas." |
| Anchor cap — everything stated over the two fixed endpoints `(x, t)` | **Lemma 3.2(2)** | md:78: "Every exists-forall formula is equivalent to a conjunction of exists-forall formulas with at most two free variables." |
| Closure of the disjunction under the ∃w step and further conjunction | **Lemma 3.4** | md:85: "The set of V-exists-forall formulas is closed under disjunction, conjunction, and existential quantification." |
| The shared point `w` as a structural split/insertion point (never a formula literal) | **Lemma 5.1 point insertion** | md:168–171: "The A_i^- and A_i^+ formulas decompose the interval at a new point z: A_i^-(z_0, z) = [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z); A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., beta_{n+1}, alpha_{n+1}](z, z_1); A_i(z_0, z, z_1) = A_i^-(z_0, z) AND A_i^+(z, z_1)"; md:218: "The key constraint is **which i** the new point corresponds to". |
| Quantifier-free point/interval types; depth carried by E[Σ]-atoms (`charK` as a unary TL-formula-atom typing one slot) | **Def 3.1 + Lemma 5.1** | md:72: "where alpha_j, beta_j are quantifier-free formulas over Sigma." |
| Per-σ navigation internal to each single bracket (Until/Since reach) | **Prop 3.5** | md:91–92: "A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))" — "the interval decomposition directly maps to nested Until/Since" (md:94). |
| Higher FO depth by re-flattening, never nesting | **Prop 4.3** | md:104–110: "Every first-order formula is equivalent over Dedekind complete chains to a disjunction of exists-forall formulas. Proof by structural induction". |
| Negation only where needed, and only over Dedekind-complete chains | **Prop 4.2** | md:100–101: "The negation of exists-forall formulas with at most two free variables is equivalent over Dedekind complete chains to a disjunction of exists-forall formulas." (see §2.4 for the gap between this and the landed statement shape) |

Lean-side anchors for the already-realized pieces: Lemma 5.1 split/combine =
`VecEAFormula.lean:360–490`; Lemma 3.4 ∨-collapse = `VVecEA2.disjList_holds`
(`NavigatedSpine.lean:149`); Prop 3.5 per-σ fold = `kvE_subBracket2V_correctness_pair`
(`SubBracket2V.lean:1855`) + the exterior dischargers (`NavigatedSpine.lean:257–354`);
Prop 4.3 step = `reflatten_prop43` (`NavigatedSpine.lean:193`, pointwise form — usable inside
a fixed-M direction only).

---

## §3 Proof-obligation decomposition (650–1,100 additive lines)

Failure-mode codes: **FM-G6** = arity-4 residual behind a static arity-1 channel (G6/F4/327,
one obstruction per audit 330); **FM-x1t** = unbounded-above `fChainPred` cannot certify
`x1 < t` (report 03); **FM-merge** = per-σ chains spliced as point types of one bracket
(report 06, the un-faithful `slotsFor` step); **FM-vac** = vacuous carrier/empty-gate closure
(task 324/325-v1); **FM-lvl** = per-sub closer applied to the outer quant map (crux failed
closer 1, `NavigatedSpine.lean:424–427`).

| # | Obligation | Inputs available (fresh coords) | Est. lines | Difficulty | Failure mode it must avoid, and how |
|---|---|---|---|---|---|
| O1 | `kvE2_sepBody` def (joint flat carrier, one `ptW`, per-σ E[Σ]-atom slots, refined-conjunction segments, depth-2 gate + empty-branch) | pattern: `kvE_subBracket2V` `SubBracket2V.lean:139–252`; `Fintype` `NormalForm.lean:167`; `bracketFromLists` `CarrierK1V.lean:389` (public) — a new N-slot builder is written fresh (the private `bracketFromLists3:72` is a 2-slot pattern only) | 130–200 | MED | **FM-merge**: point types restricted to `charBase χ` / `charK (nfk_projFresh σ)` — never a `fChainPred`. **FM-vac**: joint gate must include the two self-zones per witness slot (nine-zone lesson, `SubBracket2V.lean:160–166`); non-vacuity lemma mandatory (O1b, analog of `:1425`). |
| O2 | Arrangement membership collapse for the joint enumeration | `VVecEA2.holds_flatMap_map` (`NavigatedSpine.lean:220`, public, general over `mk`) — needs a carrier-specific instantiation the crux showed cannot be `rw`-matched through `let`-bound internals (failed closer 3, `NavigatedSpine.lean:431–434`); expose the disjunct builder as a top-level `def` so the collapse applies by `rfl`/`rw` | 40–80 | LOW-MED | crux failed-closer 3: avoid `let`-buried `S_L`/`S_R`/`mkDisjunct` — name them at top level. |
| O3 | Soundness extraction: realized joint disjunct → shared `w` (from the `ptW` slot, `x < w < t` from bracket range) + per-σ `(x1_σ, hxx1, hx1t, hanchor, hbelow)` bundles | templates: `kvE_subBracket2V_extract` (private `:762` — pattern), `kvE_sub2V_bounded_anchor_of_outer` (public `:1182`); Lemma 5.1 kit `leftPart_holds`/`rightPart_holds` (`VecEAFormula.lean:375/:412`) for the shared-`w` pivot | 150–250 | MED-HIGH | **FM-x1t**: `x1_σ < t` comes from the bracket's own range/ordering (every witness strictly inside `(x,t)`), never from a chain — the joint bracket is single-level, so the report-03 wall does not arise. **FM-G6**: the arity-4 zone data rides `zoneHolds M [x1_σ,w,x,t] zs v` slot-position reads, as in the landed pair. |
| O4 | **Per-σ `hgate` derivation from the joint carrier's realized segments + endpoint literals** (crux step (d)) — the 6-conjunct bundle of `correctness_pair:1868–1882` for each positive σ, at the extracted shared `w` | joint segments = refined conjunction of per-σ exclusions (O1); `epL`/`epR` joint literals; `kvE_sub2V_zone_consistent` (private `:1270` — re-derive N-point analog); `kvE_subBracket2V_gate_holds_of_honest` (`:1392`) is honest-side only — the carrier-side derivation is genuinely new | 150–250 | **HIGH (make-or-break)** | This is the exact residue of the captured crux (`NavigatedSpine.lean:414–421`, step (d)). It must be scheduled as v7's earliest gated phase; if the zone biconditionals cannot be recovered from refined segments + E[Σ]-atom literals, escalate to §5 — do NOT fall back to chain splicing (**FM-merge**) or a `x1 < e_i` literal (LITMUS). |
| O5 | Soundness assembly: per-σ `sound_of_parts` (`:1025`) applications + negatives via coverage | `nf_eval_unique` (`NormalForm.lean:245`, generic over k), `nf_characteristic_satisfies` (`:224`), joint off-fiber gate clause | 60–120 | MED | **FM-lvl**: the per-sub closers are applied per σ ∈ pos AFTER O3/O4 supply per-σ data — never to `qnf.2` wholesale. Negatives NOT via `neg_2var_vec_ea` (§2.4 statement-shape caveat). |
| O6 | Completeness: honest `w` + per-σ honest `x1_σ` → joint arrangement selection → slot + refined-segment realization → `splitAt_combine`-style assembly | per-σ `_complete` (`:1465`) as template; `exists_permutation_cons_head` (`EANegationClosure.lean:752`); `splitAt_combine` (`VecEAFormula.lean:478`); exterior/boundary intro dischargers (`NavigatedSpine.lean:336–383`) | 150–250 | MED-HIGH | **FM-merge**-dual (report 03 Determination-2 completeness tension): the joint carrier is a DISJUNCTION over interleavings, so the honest model realizes its own sorted interleaving — never all splices simultaneously. Refined segments hold because each σ's completeness-side zone bits hold on each refined sub-interval (per-σ `_complete` mechanism (d), `:1448–1464` doc). |
| O7 | Gate wrapper: `BracketCarrierCorrectVPrior` discharge — depth-2 unfold, atom layer at `[w,x,t]`, order-bit recovery | depth-2 unfold `NormalForm.lean:198–207`; atom-layer reconstruction: `k1v_reconstruct_nf3` is **private** (`CarrierK1V.lean:918`) → re-derive additively from `epL`/`epR`/`ptW` heads (est. +40–60 of the range) or sanction a 331-style de-privatization (plan-level decision, one token) | 60–100 | MED | **FM-vac**: both directions stated against the real `nf_eval_nf M 2 3`, no `True`-shaped placeholder (lean4 rules, vacuous defs prohibited). |
| O8 | F4 ℤ adversarial LHS-FALSE + GO verdict record (v6 Phase 8, preserved consumer) | plan v6 Phase 8 spec (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`, `σ''=char[14,16,11,20]` vs honest `char[14,15,10,20]`) | 80–120 | MED | The F4 defect class itself: the test MUST fail against the new carrier; if LHS still holds, completeness lost the `σ.2` dependence — return to O4/O6, do not weaken the test. |

**Total: 650–1,100 additive lines** (O1b non-vacuity included in O1's band).

### 3.3 Why this exceeds report 06's 400–700

Report 06 priced "faithful `kvE2_body` rewrite + shared-`w` combinator + direct gate read".
The decomposition above adds two costs report 06 did not itemize: (i) O4 — the carrier-side
`hgate` derivation, which the landed per-σ kit takes as a *hypothesis* everywhere
(`:946`, `:1025`, `:1216`, `:1855` all consume `hgate`; only the honest-side `:1392` derives
it, from an `nf_eval` the soundness direction does not yet have); (ii) the §2.4 finding that
Prop 4.2 existence forms cannot carry the negatives, forcing the uniqueness/coverage route
(cheap per line but not free). Against this, the §1.4 discovery of the complete Lemma 5.1
split/combine kit removes the risk report 06 flagged as "the make-or-break question" of
expressibility — the shared-`w` pivot machinery exists; what remains open is O4's derivability,
a narrower question. Net: higher line estimate, **lower** structural risk than report 06's
MEDIUM.

### 3.4 Placement + visibility constraints (new-API sufficiency audit)

- All load-bearing per-σ closers and combinators are **public** in the new modules
  (§1.1–§1.4) — nothing needed was *lost* in the split.
- Two consumption-relevant lemmas are **private**: `k1v_reconstruct_nf3`
  (`CarrierK1V.lean:918`, atom-layer reconstruction — needed in spirit by O7) and
  `k1v_bracket_extract` (`CarrierK1V.lean:643` — superseded by the per-σ extraction templates
  in SubBracket2V, so not blocking). Private per-σ plumbing in SubBracket2V
  (`bracketFromLists3:72`, `kvE_sub2V_zone_consistent:1270`, `kvE_subBracket2V_extract:762`)
  serves as *templates*; the joint versions are new code regardless (N slots vs 2).
- **Placement recommendation**: a NEW module
  `NfMultiAnchorBridge/SharedWitness.lean` importing `SubBracket2V` + `NavigatedSpine`
  (per the 331 handoff: "task 321's blocked engine work should build against SubBracket2V +
  NavigatedSpine only"), plus ONE added import line in the umbrella
  (`NfMultiAnchorBridge.lean` — an additive edit; the umbrella is import-only and not on the
  do-not-edit lemma list). Alternative: append to `NavigatedSpine.lean` (continuous with v6
  practice — its slab already contains the v6 phase records). Either preserves byte-identity
  of every protected slab; the plan should pick one and record it.

---

## §4 LITMUS + no-nesting compliance argument

**LITMUS (no `x1 < e_i` relative-position literal).** Every position in Candidate A is carried
by structure, not by a two-variable order literal: (i) per-σ `x1_σ` and the shared `w` are
bracket **witness slots** — their ordering is the bracket's internal witness monotonicity +
range (`IntervalPattern.holds` fields), never a formula literal; (ii) exterior zone content
rides the `Since`/`Until` **evaluation point** at the fixed endpoints (`snce φ ⊤` at `x`,
`untl φ ⊤` at `t` — the landed dischargers `NavigatedSpine.lean:257–354`, whose docstrings
carry the LITMUS note verbatim); (iii) the shared-`w` pivot uses `leftPart`/`rightPart`
**structural split at an index** (md:218: "which i the new point corresponds to" — an index,
not an order assertion). The captured crux confirmed the v6 obstruction was never a
positioning literal (`NavigatedSpine.lean:437–439`); Candidate A introduces none.

**No-nesting (quantifier-free point types, Lemma 5.1 md:72/md:134–135).** The joint bracket's
point types are exactly two kinds: `charBase χ` (depth-0 characteristic formulas — quantifier
-free over Σ) and `charK (nfk_projFresh σ)` (a **unary** TL formula typing the slot point
itself — an E[Σ]-atom in the Def 4.1 sense: a TL-formula-as-unary-predicate *of that point*).
What the no-nesting rule (`NavigatedSpine.lean:43–48`) and report 06 bar is a point type that
smuggles in ANOTHER bracket's witness structure — `slotsFor`'s `fChainPred` splice, where the
slot "type" asserts the existence of other points. An E[Σ]-atom predicates only of its own
point; a `fChainPred` predicates of a whole witness cascade. Candidate A contains no
`fChainPred` (or any nested-`Until` chain of a bracket) in any point-type position; per-σ
navigation appears only where Prop 3.5 puts it — in the (eventual, downstream) TL translation
of each single bracket, and in the endpoint `Since`/`Until` wrappers evaluated at the fixed
anchors. The interleaving disjunction is precisely Lemma 3.2(1)'s "conjunction ≡ disjunction
of exists-forall" (md:77) — the combination happens at the *bracket* level, never inside a
point type.

---

## §5 RE-SCOPE fallback specification (audit-sanctioned decision gate)

### 5.1 Risk-profile inversion (new finding, changes the fallback's shape)

In the **merged** route the exterior zones were the NO-GO risk (positive exterior subs got no
witness slot and only a 1-type `existF 0` literal — report 06). In the **separate-bracket**
route this inverts: exterior and boundary content lives in `epL`/`epR`/`ptW` **evaluated at
the shared fixed points `x`, `t`, `w`**, so the per-σ contributions conjoin by plain
`formula_conjList` at a single point — no interleaving, no shared-witness problem; the landed
`kvE_nonInterior_*` dischargers (`NavigatedSpine.lean:257–383`) already give both directions
per literal. The genuinely hard core is the **interior** interleaving (O1/O3) and the `hgate`
derivation (O4). A v7 fallback should therefore narrow along the axis that actually removes
O1/O3/O4 volume:

### 5.2 Two concrete narrowings (the v7 plan's decision gate chooses among FULL / N1 / N2)

**N1 — interior+boundary fragment (the audit's named fallback, plan v6 Rollback).** Restrict
the gate to `qnf` whose positive subs have no exterior-positive bits:

```lean
def interiorBoundaryOnly {sig} (σ : NormalForm sig 1 4) : Prop :=
  ∀ χ : NormalForm sig 0 1,
    σ.2 (nf0_assemble zPastX χ σ.1) = false ∧ σ.2 (nf0_assemble zFutT χ σ.1) = false

theorem kvE2_sepBody_correct_interiorBoundary … :
  ∀ qnf, (∀ σ, qnf.2 σ = true → interiorBoundaryOnly σ) → (gate biconditional for qnf)
```

Obligations dropped: the exterior halves of O1's `epL`/`epR` content and the two exterior
discharger wirings in O5/O6 (consumers `zPastX`/`zFutT`). Obligations kept: O1–O8 otherwise
unchanged — N1 saves roughly 100–150 lines and removes the (already low, §5.1) exterior
navigation risk, but does NOT dodge O4. Use N1 if the exterior wiring, not O4, is what
overruns.

**N2 — single-positive-sub fragment (dodges the interleaving engine entirely).** Restrict to
`qnf` with at most one positive sub:

```lean
theorem kvE2_sepBody_correct_singleton … :
  ∀ qnf, (∀ σ σ', qnf.2 σ = true → qnf.2 σ' = true → σ = σ') → (gate biconditional for qnf)
```

Here the joint carrier degenerates to that σ's `kvE_subBracket2V` (+ atom layer + negatives):
no interleaving (O1 collapses to a wrapper), O3 collapses to the landed per-σ extraction,
O4 remains but over ONE σ against σ's OWN segments — exactly the configuration
`sound_of_outer:1216` + `bounded_anchor_of_outer:1182` already handle for the pin-spliced
shape. Estimated 200–350 lines total. N2 is the correct fallback if **O4 in joint form** is
the overrun: it isolates the same make-or-break at minimum size and still yields a citable,
adversarially-testable gate fragment (F4's counterexample is a single-σ discriminator, so O8
still runs meaningfully against N2).

**Decision-gate placement for the v7 plan**: Phase ordering O1 → O2 → O3+O4 (gated) — if
O4 fails to close in one dedicated dispatch, the plan drops to N2 (not N1) since O4 is the
crux; if O4 closes but exterior volume overruns, drop to N1. Neither narrowing re-admits any
constant-arity or merged-bracket construction.

---

## §6 What v7 must NOT do (quarantine + refuted-infrastructure table)

| Off-limits symbol / pattern | Location | Reason |
|---|---|---|
| `kvE2_body`, `kvE'_body`, `kvE_body` (and their local `slotsFor` lets) | `MergedQuarantine.lean:807/:490/:148` (lets `:876`/`:560`) | The merged bracket-whose-points-are-brackets — violates the no-nesting rule (`NavigatedSpine.lean:43–48`) and Lemma 5.1 quantifier-free point types (md:72); the un-faithful step per report 06. Also `private` and off the faithful import path. |
| `bracketEndChar_kvE` / `bracketEndChar_kvE'` / `bracketEndChar_kvE2` / `_two_eq` | `MergedQuarantine.lean:262/:595/:911/:926` | Carriers over the merged bodies; `_two_eq` is a protected verdict record (do-not-edit), not a consumable. |
| `kvE_gate` / `kvE_pinArrangements` / `kvE_pinDisjunct` / `kvE_exclConj` / `kvE_consistent(-Zones)` | `MergedQuarantine.lean:127/:449/:459/:472/:112/:435` | Union/existential zone content (`(filter qnf.2 …).any`) is what made per-sub `hgate` underivable (Phase-7 blocker root cause, plan v6 §Phase 7). All `private` in the quarantine. |
| `kvE2_joint_nonvacuous_at_honest` | `MergedQuarantine.lean:947` | Non-vacuity of the merged carrier only; proves nothing about the separate route (write a fresh O1b analog of `SubBracket2V.lean:1425`). |
| `bracketFromLists_flatMap_subchain_below_pin` | `SubBracket2V.lean:1099` (private, faithful module) | "An engineering artifact undoing a merge the paper never performs" (report 06 Q1); retained only as the internal support of the landed `_of_outer` closers — new code must not extend the pattern. |
| `nfk_assemble` / `nfk_dropFresh` / `nfk_zoneSpec` / `nf_eval_nf1_cons_factor` / `efold_of_nfk` / `nf_quant_layer_fold_k2_gate` | prose-only, task-327 record (`MergedQuarantine.lean:959–end`) | Do not exist as declarations; the constant-arity route 327 refuted and audit 330 found unfaithful. Do NOT create. |
| `EAtomDom` static arity-1 factorization as a live path | `NfEFold.lean:69` | The category error at k≥1 (audit 330 Part 1). |
| Any `fChainPred`-typed point slot; any `x1 < e_i` literal; any provider-side pinning (`w = e 1`) | — | FM-merge / LITMUS / Amendment F3. |
| `RefutationF2.lean` contents (`f2_relativized_refutation:859`) | quarantined module | Negative-result record; reachable only via the umbrella; not an input to the faithful route. |
| Pointwise-existence combinators AS the gate carrier (`reflatten_prop43`, `conj_holds_vvecEA2`, `neg_2var_vec_ea`, `reflatten_neg_step`) | `NavigatedSpine.lean:193`, `VecEAClosure.lean:238`, `EANegationClosure.lean:722`, `NavigatedSpine.lean:178` | §2.4: the gate needs a model-independent `def`; these produce a `VVecEA2` per (M, z0, z1) and their conclusions are trivially satisfiable as stated. They remain usable inside fixed-M proof directions. |

Binding constraints re-affirmed unchanged: purely additive; DO-NOT-EDIT byte-identical
task-325/326 lemma sets, `kvE2_body`/`bracketEndChar_kvE2` splice, `kvE_subChain2V`,
`BracketCarrierCorrectVPrior`, `EANegation`, F1–F4 records; anchor cap 2; axiom-clean
`[propext, Classical.choice, Quot.sound]`; no `sorry` on any live path; G5 citations at every
chain step.

---

## Adversarial Self-Verification

Mandate: refute the re-map, the sufficiency claim, the candidate signatures, and the
additive-only feasibility before endorsing.

### Claim Verification Table

| Claim | Source/Counterexample | Verdict |
|-------|------------------------|---------|
| All §1 fresh line numbers are correct | grep -n against the post-331 tree + direct Read of the declaration text at `SubBracket2V.lean:139/:1216/:1465/:1855`, `NavigatedSpine.lean:83/:140/:149/:193/:220/:257–383`, `PriorInterface.lean:60`, `CarrierK1V.lean:365/:374/:389/:643/:918`, `CarrierKv.lean:466`, `VecEAFormula.lean:271–490`, `VecEAClosure.lean:109–238`, `EANegationClosure.lean:648/:722/:752`, `MergedQuarantine.lean:112–959`, `RefutationF2.lean:859`; `lean_local_search` hits for `kvE_subBracket2V_correctness_pair`, `BracketFormula.splitAt_combine`, `BracketFormula.leftPart_holds` | **Verified (High)** |
| Every literature citation quotes the chunk correctly | chunk read IN FULL this dispatch (245 lines); md:72, md:77, md:78, md:85, md:91–92, md:100–101, md:104–110, md:168–171, md:218 quoted verbatim above and re-checked against the read | **Verified (High)** |
| Report 06's "one genuine unbuilt object" framing survives against the new tree | tried to refute by hunting for an existing shared-w combinator: `lean_local_search`/grep for insert/concat/shared-witness lemmas found `leftPart`/`rightPart`/`splitAt_combine` (`VecEAFormula.lean:360–478`) — the Lemma 5.1 pivot EXISTS both directions, which report 06 did not record; but no joint carrier, no joint extraction, no carrier-side hgate derivation exists | **Refined, not refuted**: the unbuilt object shrinks to O1–O7 with O4 the residual make-or-break (Medium-High) |
| `neg_2var_vec_ea` is consumable as "the landed Prop 4.2 negation closure" wherever the plan needs negation | read the statement (`EANegationClosure.lean:722–733`) and the `nil` branch of `neg_disjunct_list` (`:700–708`): conclusion `∃ v', v'.holds` is satisfiable by trivial-top regardless of hypotheses; no `↔`-form, no model-independent operator exists (grep for a biconditional negation lemma: none) | **Refuted as a gate-carrier input; verified as a fixed-M direction tool** (High). v7 negatives route through `nf_eval_unique` (`NormalForm.lean:245`) + coverage instead |
| The new API is sufficient (no needed lemma lost or left private) | per-symbol visibility audit §1 + §3.4: all closers/combinators public; counterexamples found: `k1v_reconstruct_nf3` (`CarrierK1V.lean:918`) and `k1v_bracket_extract` (`:643`) are private; per-σ plumbing (`bracketFromLists3:72`, `kvE_sub2V_zone_consistent:1270`, `kvE_subBracket2V_extract:762`) private but template-only (joint versions are new code regardless) | **Verified with two flagged exceptions** (High): O7 must re-derive the atom-layer reconstruction additively or the plan must sanction a 331-style de-privatization |
| Additive-only feasibility | new module + one umbrella import line (umbrella is import-only, 88 lines, not on the do-not-edit lemma list) OR append to `NavigatedSpine.lean` (v6 practice); no protected slab touched; the only token-edit temptation is the optional de-privatization, surfaced as an explicit plan decision, mirroring 331's sanctioned-edit protocol | **Verified (High)** |
| The exterior zones remain the top risk (report 06's residual-risk framing) | tried to confirm; counter-evidence: in the separate route exterior content is `formula_conjList` literals at the FIXED points x/t with both directions already landed (`NavigatedSpine.lean:257–354`); the interleaving + hgate (O1/O3/O4) is where the crux's failed closers actually died (`NavigatedSpine.lean:423–435`) | **Refuted → risk-profile inversion recorded** (§5.1, Medium-High); fallback re-derived accordingly (N2 over N1 for an O4 overrun) |
| Line estimate 400–700 (report 06) | O1–O8 sized against the landed per-σ analogs (def 115 lines; `_sound`+plumbing ≈ 800; `_complete` ≈ 390 for ONE σ) | **Revised to 650–1,100** (§3.3, Medium) — report 06 under-itemized O4 and the §2.4 caveat |
| The captured crux's step (d) is derivable from the separate carrier's structure | could NOT verify this dispatch (it is the open mathematics — the honest-side `gate_holds_of_honest:1392` derives hgate from an `nf_eval` the soundness direction lacks) | **Flagged OPEN (the make-or-break)** — isolated into O4 as v7's earliest gated phase with the N2 fallback wired to it |
| Task-331 split left the build green and the faithful modules quarantine-free | 331 summary Phase-8 gates (build exit 0, axiom check on 4 flagship theorems incl. `kvE_subBracket2V_correctness_pair` and `reflatten_prop43`, sorry parity 47=47 prose-only, import DAG: no faithful module imports a quarantine module) | **Verified from artifact + spot-checked imports** (`NavigatedSpine.lean:1`, `MergedQuarantine.lean:1–2`) (High) |

### Contradiction Log

**Report 06 §"Recommended next-attempt plan" ("retires … the 1-type non-interior dischargers
as dead") vs v6 Phases 5–6 (landed 5+5 dischargers, `NavigatedSpine.lean:257–383`).**
Resolution by precedence (machine tree > prior recommendation): the landed dischargers are
stated over raw `formula_conjList fs` + membership — they are channel-abstract literal
extract/intro lemmas, not the merged route's `existF 0`-pinned 1-type reconstruction that
report 06 (correctly) declared dead. They remain the O5/O6 consumers for the exterior/boundary
literals of the JOINT `epL`/`epR`/`ptW`. No unresolved contradiction: report 06's retirement
applies to the merged-route reconstruction pattern, not to these lemmas.

**Report 06's residual-risk ranking vs the captured crux.** Resolved above (risk-profile
inversion, §5.1); crux evidence outranks the pre-crux estimate.

### Recommendations modified after verification

- Initially drafted the negatives obligation around `reflatten_neg_step`/`neg_2var_vec_ea`;
  **retracted** after the §2.4 statement-shape finding; replaced with the uniqueness/coverage
  route (O5).
- Initially adopted report 06's 400–700 estimate; **revised** to 650–1,100 after itemizing O4
  and the atom-layer re-derivation.
- Initially placed the RE-SCOPE fallback as the audit's interior+boundary narrowing only;
  **extended** to the two-axis N1/N2 spec after the risk-inversion finding, with N2 wired to
  an O4 failure specifically.

---

## Recommendation (one paragraph, for the v7 plan)

Adopt Candidate A staged as Candidate C: Phase A (O1+O1b+O2, the model-independent joint
carrier + non-vacuity + membership collapse), Phase B (O3+O4, GATED — the shared-`w`
extraction and the carrier-side per-σ `hgate` derivation; on failure in one dedicated
dispatch, drop to fallback N2), Phase C (O5+O6, both directions), Phase D (O7 gate wrapper —
decide re-derive-vs-de-privatize for the atom layer up front), Phase E (O8, F4 ℤ adversarial
gate + verdict record). Build in `NfMultiAnchorBridge/SharedWitness.lean` (new module,
imports SubBracket2V + NavigatedSpine, one additive umbrella import line) or by appending to
`NavigatedSpine.lean` — plan picks one. Consume `leftPart_holds`/`rightPart_holds`/
`splitAt_combine` for every shared-`w` pivot; cite Lemma 3.2(1) (md:77) at the interleaving
enumeration, Lemma 5.1 (md:72, md:168–171) at each split/insertion step, Prop 3.5 (md:91–94)
at each navigation literal, Prop 4.3 (md:104–110) at the depth ladder (G5). 650–1,100
additive lines, 5 phases, decision gate after Phase B.
