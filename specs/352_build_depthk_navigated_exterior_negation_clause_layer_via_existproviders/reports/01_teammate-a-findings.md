# Task 352 — Teammate A (Primary): the ExistProviders channel

**Angle**: PRECISELY what `P : ExistProviders sig atomMap k` exposes, whether it can source the
rung-`k` navigated formulas the faithful Def-7.5 rung-`(k+1)` bracket needs WITHOUT
depth-hardwiring, the exact interface task 349 Phase 2 must consume, and whether `P` is in scope.

**Mode**: lean-research-hard (H2/H3/H4). Reference tier: **Tier 1** (Rabinovich 2014 Def 7.5 / Cor
5.4 + live Lean types). Read-only; only write is this file. All claims carry file:line evidence.

---

## Key Findings

### KF1 — What `P : ExistProviders sig atomMap k` exposes (Q1)

`ExistProviders` (PriorInterface.lean:38-45) is a two-field bundle:

```lean
structure ExistProviders (sig) (atomMap : Formula → sig.preds) (k : Nat) where
  existF  : (n : Nat) → NormalForm sig k (n + 1) → Formula
  correct : ∀ (n) (sub : NormalForm sig k (n + 1)) (M) (h_UZ) (h_SZ) (t : M.carrier),
      temporal_truth M atomMap t (existF n sub) ↔
        ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub
```

- **`existF n`** is an *all-arity, depth-`k` single-anchor existential converter*: it maps a
  depth-`k` arity-`(n+1)` normal form `sub` to a `Formula` whose temporal truth at `t` equals
  "∃ an `n`-vector env with `sub` realized at `(env, t)`" (`t` occupies the last, un-quantified
  slot via `insertEnv`). `correct` is UZ/SZ-conditional exactly like the `:351` consumer carries.
- The **only arity the clause layer needs is `n = 0`**: `existF 0 : NormalForm sig k 1 → Formula`.
  KampPrior.lean:936-960 (`kampPrior_existProviders_of_ih_existF0_char`) proves the `Fin 0` env
  collapse:

  ```lean
  temporal_truth M atomMap t (P.existF 0 χ)  ↔  nf_eval_nf M k 1 (fun _ => t) χ
  ```

  So **`P.existF 0` is precisely a depth-`k` arity-1 characteristic-formula converter** — the
  depth-`k` generalization of `nf_depth0_char_formula` (which is only the `k = 0` instance;
  OuterGate.lean:79 uses exactly this pairing: `charBase = nf_depth0_char_formula`,
  `charK = fun χ => P.existF 0 χ`, and `bracketEndChar_kvE2_hck`, OuterGate.lean:126-146, is its
  correctness bridge at depth 1).
- `existF 1 : NormalForm sig k 2 → Formula` (KampPrior.lean:966-998) is the `Fin.cons x (fun _=>t)`
  two-anchor form; not needed by the exterior clause but available.

### KF2 — The ExistProviders channel CAN source the rung-`k` formulas without depth-hardwiring (Q2). CONFIRMED.

**The depth-hardwiring is NOT in the ExistProviders channel — it is in the frozen clause layer's
formula source and its profile-list reads, both of which `P.existF 0` + the ExteriorBracketK
determinacy core replace cleanly.**

The frozen future clause `kvE2_futPos` (ExteriorNegation.lean:1124-1132) builds a Cor-5.4
`D`-guarded `Until` chain (`kvE2_futChain`, :1108-1118) visiting σ's *fresh / gap / ray profiles*.
Two depth-0 hardwirings live there:

1. **Formula source**: every profile is rendered by `nf_depth0_char_formula atomMap h_surj χ` for
   `χ : NormalForm sig 0 1` (ExteriorNegation.lean:1076, 1083, 1094, 1103, 1116). This is
   depth-0-only. **Replacement**: `P.existF 0 χ` for `χ : NormalForm sig k 1` — same
   truth-semantics one fold-layer deeper (KF1), provider-supplied, no `nf0_*` involvement.
2. **Profile-list reads**: the frozen layer extracts profiles from `σ.2` (at the k=2 rung,
   `σ : NormalForm sig 1 4`, so `σ.2 : NormalForm sig 0 5 → Bool`) by the *lossless* depth-0
   coordinatization `σ.2 (nf0_assemble zs4 χ r)` (`nf0_assemble`, NfEFold.lean:180-193;
   round-trip losslessness `nf0_zoneSpec_assemble`/`nf0_projFresh_assemble`, :197-215). This
   losslessness holds **only at depth 0** — `nf0_assemble` consumes a depth-0 `χ` and depth-0 `r`
   (NfEFold.lean:181), and the F2 refutation (RefutationF2.lean:471) plus the NfEFold:549-561
   discussion certify that no lossless arity-1 factorization exists at depth `≥ 1`.
   **Replacement**: the *fiber-existential* full-arity read `kvE_subBit σ zs4 χ`
   (ExteriorBracketK.lean:302-307) — "does σ prescribe SOME depth-`k` arity-5 sub in zone `zs4`
   with fresh depth-`k` projection `χ`" — with honesty `kvE_subBit_iff` (:314-369) discharged by
   the Phase-1 bridge `nf_eval_nfk_iff_efold` (NfEFold.lean:627) + `nf_eval_unique M k`. This is
   exactly the "read `σ.2` fiber-existentially at FULL arity, never through an assembled arity-1
   re-encoding" that the ExteriorBracketK docstring (:295-301) already prescribes.

**Data path (traced), depth `k`, no `nf0_assemble` losslessness on σ's content:**

```
qnf : NormalForm sig (k+2) 3
  └─ kvE_sepPos qnf : List (NormalForm sig (k+1) 4)          -- ExteriorBracketK.lean:183
       positive subs σ : NormalForm sig (k+1) 4
         ├─ zone/profile enumeration of σ's OWN environment:
         │     kvE_subBit σ zs4 χ  (fiber-existential, full-arity)   -- ExteriorBracketK.lean:302
         │       χ : NormalForm sig k 1                              -- the depth-k profile
         └─ fresh shadow of σ at the anchor:
               kvE_projFreshD σ : NormalForm sig k 1                 -- ExteriorBracketK.lean:198
  └─ each depth-k profile χ  ──►  P.existF 0 χ : Formula             -- PriorInterface.lean:40
       (⇔ nf_eval_nf M k 1 (fun _=>·) χ, KampPrior.lean:952)
  └─ assemble D-guarded Until chain over these formulas             -- kvE2_futChain analog
```

The one place `nf0_*` losslessness is still legitimately used is the **atom/order (zone) layer**
(`nf0_zoneSpec σ.1`), which is genuinely depth-0 (the atom layer is a `NormalForm sig 0 n`) and
G1-safe — this is exactly the D7 discipline the determinacy core already follows
(ExteriorBracketK.lean:216-217). **No route through `nf0_assemble`'s content-losslessness is
required.**

### KF3 — Exact interface task 349 Phase 2 must consume (Q3)

The four Phase-2 targets `kvE_extBracketPast/Fut_sound/complete` are assembled the same way the
k=2 originals are (ExteriorBracket.lean:432-615): the per-side bracket soundness/completeness call
the **clause-layer** lemmas `kvE2_extNegFut_sound` (ExteriorNegation.lean:1243) and
`kvE2_extNegFut_complete` (:1484) at each positive sub, with the `habove`/`hbelow` zone-fact pin
supplied by the determinacy core. Task 352 must therefore export the **depth-`k`,
`P`-parameterized** clause layer below. Proposed Lean signatures (future side; Past mirrors in the
`ExteriorNegationPast` analog):

```lean
-- (A) Navigated positive local-existence form (Cor 5.4(2)) — P.existF 0 replaces
--     nf_depth0_char_formula; profile lists from kvE_subBit / kvE_projFreshD.
noncomputable def kvE_futPos  {sig} {k}
    (atomMap : Formula → sig.preds)
    (h_surj  : ∀ p, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap k)
    (σ : NormalForm sig (k+1) 4) : Formula

-- (B) Complement clause = .neg (Phase-2 BINDING shape, mirrors ExteriorNegation.lean:1136).
noncomputable def kvE_extNegFut {sig} {k}
    (atomMap) (h_surj) (P : ExistProviders sig atomMap k)
    (σ : NormalForm sig (k+1) 4) : Formula := (kvE_futPos atomMap h_surj P σ).neg

-- (C) Soundness (generalizes kvE2_extNegFut_sound, ExteriorNegation.lean:1243):
theorem kvE_extNegFut_sound {sig} {k}
    (M) (atomMap) (h_surj) (P : ExistProviders sig atomMap k)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k+1) 4) (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE_extNegFut atomMap h_surj P σ)) :
    ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ

-- (D) Completeness (generalizes kvE2_extNegFut_complete, ExteriorNegation.lean:1484):
theorem kvE_extNegFut_complete {sig} {k}
    (M) (atomMap) (h_surj) (P : ExistProviders sig atomMap k)
    (h_UZ) (h_SZ)
    (qnf : NormalForm sig (k+2) 3) (σ : NormalForm sig (k+1) 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a, atom_eval M (Fin.cons w (Fin.cons x (fun _=>t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1), (zs ⟨2,_⟩).2 = false →
       ((∃ v, zoneHolds M (Fin.cons w (Fin.cons x (fun _=>t))) zs v ∧
              nf_eval_nf M k 1 (fun _=>v) χ) ↔ kvE_futAnyBit qnf zs χ = true))
    (hbase …) (hb …)                       -- the futMarked components, depth-k analog
    (hno : ∀ x1, t < x1 →
       ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _=>t)))) σ) :
    temporal_truth M atomMap t (kvE_futPos atomMap h_surj P σ)
```

Supporting decls task 352 must also export (depth-`k` analogs of the frozen names Phase 2's
bracket wrappers unfold through): `kvE_futAdmissible`, `kvE_futMarked` (+ `_iff`),
`kvE_futGapList` / `kvE_futRayList` (now built over `kvE_subBit` reads, list element type
`NormalForm sig k 1`), `kvE_futChain` / `kvE_futEnd` / `kvE_futRayForm` (over `P.existF 0`), and
their Spike specializations. The `kvE_futAnyBit` zone-fact pin (`habove`/`hbelow`) is **already
landed** in the determinacy core (`kvE_futAnyBit_correct`, ExteriorBracketK.lean:230-291) in the
exact `NormalForm sig k 1` / `nf_eval_nf M k 1` shape — Phase 2 supplies it as `hbelow`/`habove`,
task 352 does not re-derive it.

**Boundary**: task 352 delivers (A)-(D) + supporting clause decls. Task 349 Phase 2 delivers the
four `kvE_extBracketFut/Past_sound/complete` wrappers (the disj-over-positive-subs assembly +
`kvE_futMarked_of_realizer` marking bridge), consuming (A)-(D) and the determinacy core verbatim —
exactly mirroring ExteriorBracket.lean:432-615's consumption of the frozen clause layer.

### KF4 — `P` IS in scope at the point 349's recursion needs the brackets (Q4). CONFIRMED.

The recursion instantiates providers via the Phase-16 shim
`kampPrior_existProviders_of_ih atomMap j ih` (KampPrior.lean:895-907), which packages the
`nf_nvar_exist_all_depths` IH family at depth `j`. The shim docstring (KampPrior.lean:889-906,
1004-1006) states the depth-`j` IH family is **structurally available at the `| k+1 =>` recursion
site for every `j ≤ k`** (F-A: the ∀k quantifier lives in KampPrior's `Nat.rec`). At the k=2 rung
the gate consumes `P : ExistProviders sig atomMap 1` (OuterGate.lean:73; ExteriorBracket.lean:664).

Index reconciliation for the general rung: for a carrier at rung `(k+2)` (i.e.
`qnf : NormalForm sig (k+2) 3`, positive subs `σ : NormalForm sig (k+1) 4`,
`kvE_sepPos qnf : List (NormalForm sig (k+1) 4)`, ExteriorBracketK.lean:183-184), the exterior
clause profiles are `χ : NormalForm sig k 1` (`kvE_projFreshD`, :198), so the clause layer needs
**`P : ExistProviders sig atomMap k`** — while the interior gate needs `ExistProviders sig atomMap
(k+1)`. Both depths (`k` and `k+1`) are `≤ k+1`, hence both structurally available at the `|k+1=>`
site. So 349's `endInterval` recursion, at the arm building the rung-`(k+2)` enriched carrier, has
`P` at the depth the exterior clause requires. The `bracketEndChar_kvE2Ext` carrier already threads
`P` into both interior and exterior positions (ExteriorBracket.lean:661-669); the general-`k`
carrier does the same with a depth-`k` `P` for the clause and a depth-`(k+1)` `P` for the interior.

---

## Recommended Approach (concrete)

1. **New leaf module** `ExteriorNegationK.lean` (+ `ExteriorNegationKPast.lean` mirror), importing
   `ExteriorBracketK` + `ExteriorNegation` (frozen, for the `k=0`-rung agreement lemmas). Purely
   additive; touches no frozen file (7 frozen providers + KampPrior byte-identical — respected,
   this task writes only new decls).
2. **Formula source = `P.existF 0`**, threaded as `charK := fun χ => P.existF 0 χ` exactly as the
   interior gate does (OuterGate.lean:79). Keep `nf_depth0_char_formula` ONLY on the genuinely
   depth-0 order/zone layer (G1/D7-safe).
3. **Profile lists from `kvE_subBit` / `kvE_projFreshD`** (ExteriorBracketK.lean:302/198), NOT
   `nf0_assemble` on σ's content. This is the single structural change vs. the frozen layer and is
   what removes root-cause-1/2 (report 11).
4. **Correctness via `P.correct` + `nf_eval_unique M k`**: soundness/completeness reuse the frozen
   proof skeletons (`kvE2_futChainBuild`, ExteriorNegation.lean:1180; `kvE2_futMinPick`, :1146)
   verbatim in shape, swapping the depth-0 char-formula correctness (`nf_depth0_char_formula_correct`)
   for `P.correct 0 · M h_UZ h_SZ ·` (KampPrior.lean:952 bridge) and the `nf0_assemble` round-trips
   for `kvE_subBit_iff`. `h_UZ`/`h_SZ` enter exactly where `P.correct` is invoked (the clause becomes
   UZ/SZ-conditional, matching `BracketCarrierCorrectVPrior`, PriorInterface.lean:60).
5. **`k = 0`-rung agreement lemmas** (`kvE_futPos_zero`, `kvE_extNegFut_zero`) proving the new
   decls reduce to the frozen `kvE2_*` at the `k = 0` parameter — the non-weakening certificate,
   mirroring the determinacy core's `kvE_futAnyBit_zero` (ExteriorBracketK.lean:389).
6. **Axiom gate**: `lean_verify` must show exactly `[propext, Classical.choice, Quot.sound]` — do
   NOT reference `nf_nvar_exist_all_depths` by name (it carries `sorryAx` from open arms,
   KampPrior.lean:861-864); take `P` as a parameter, as the shim pattern mandates.

---

## Evidence (file:line)

- `ExistProviders` fields: PriorInterface.lean:38-45. UZ/SZ-conditional target
  `BracketCarrierCorrectVPrior`: :60-73.
- `existF 0` = depth-`k` arity-1 characteristic converter: KampPrior.lean:936-960
  (`kampPrior_existProviders_of_ih_existF0_char`); depth-1 bridge `bracketEndChar_kvE2_hck`:
  OuterGate.lean:126-146. Interior gate uses `charK = fun χ => P.existF 0 χ`: OuterGate.lean:70-79.
- Shim / instantiation: `kampPrior_existProviders_of_ih` KampPrior.lean:895-907;
  `kampPrior_existProviders_one_of_ih` :1007-1018; `kampPrior_existProviders_zero` :1026-1032;
  structural availability at `|k+1=>` for `j ≤ k`: :889-906, 1004-1006.
- Frozen depth-0 hardwiring: `nf_depth0_char_formula` renders in `kvE2_futPos`/chain/end
  ExteriorNegation.lean:1076,1083,1094,1103,1116,1124-1132; complement `kvE2_extNegFut` :1136-1140;
  `_sound` :1243; `_complete` :1484. `nf0_assemble` (depth-0-lossless-only) NfEFold.lean:180-193;
  round-trips :197-215; losslessness-fails-at-depth-≥1 discussion :549-561.
- Determinacy core replacements (green, sorry-free, to consume UNCHANGED):
  `kvE_subBit`/`kvE_subBit_iff` ExteriorBracketK.lean:302-369; `kvE_projFreshD` :198-210;
  `kvE_futAnyBit`/`_correct` (the habove/hbelow pin) :218-291; `kvE_sepPos` :183-191;
  `nfk_truncD`/`nf_eval_truncD` :62-102; `k=0`-agreement `kvE_futAnyBit_zero` :389-392.
- Phase-1 bridge `nf_eval_nfk_iff_efold`: NfEFold.lean:627-632 (+ `nf_eval_efold_k` :608-613,
  `nfk_dropFresh` :578, `nfk_zoneSpec` :586).
- k=2 bracket assembly consuming the clause layer (the pattern 349 Phase 2 mirrors):
  ExteriorBracket.lean:432-476 (`_sound`), 547-615 (`_complete`), 661-684 (`bracketEndChar_kvE2Ext`
  + `_holds_iff`); `P` consumed at `ExistProviders sig atomMap 1`: :664,677,724,806,1072.
- Blocker root causes this resolves: report 11 (spawn-analysis) lines 22-38 (depth-hardwiring,
  truncation-shadow unsatisfiability, recursive rung-`k` consumption); report 10 lines 141-176
  (the general-`k` fold bridge + `k`-generalized clause prescription), C4-C7 table.

---

## Confidence: HIGH

The `existF 0 ⇔ nf_eval_nf M k 1` equivalence (KampPrior.lean:952) and the interior gate's existing
`charK = fun χ => P.existF 0 χ` usage (OuterGate.lean:79) are machine-landed facts that directly
establish `P.existF 0` as the depth-`k` char-formula source (Q1, Q2). The determinacy core already
exposes the full-arity fiber-existential reads that replace `nf0_assemble` (Q2), and its
`kvE_futAnyBit_correct` supplies the Phase-2 pin in the exact prescribed shape (Q3). Threading (Q4)
is confirmed by the shim's stated `j ≤ k` availability. The one residual is *construction*
(re-deriving `kvE2_futChainBuild`/`kvE2_futMinPick`-scale soundness at depth `k` with `P.correct`
substituted) — ExteriorNegation-scale (~1700 lines frozen ⇒ comparable new), engineering-bounded,
not a semantic obstruction (consistent with report 10's GO verdict). Confidence is on the
*channel adequacy and interface shape*, not on the line-count estimate.

---

## Open questions for other teammates

1. **(Completeness teammate)** The frozen `kvE2_futMarked` / `kvE2_futAdmissible` /
   `kvE2_futPossibleZones` machinery (ExteriorNegation.lean:875-983) reads σ's zone content at
   depth 0. Does the depth-`k` `kvE_futMarked` need a *new* honesty lemma beyond `kvE_subBit_iff`,
   or does `kvE_subBit` + `kvE_futAnyBit_correct` fully cover the marking predicate's obligations?
   (I believe the latter, but the marking `_iff` shape — `hbase`/`hb` decomposition consumed at
   ExteriorBracket.lean:499,529,574,610 — should be confirmed reconstructible from the core.)
2. **(Spike teammate)** The `S_gap = {χmid}, S_ray = ∅` spike specialization
   (`kvE2_extNegFutSpike`, ExteriorNegation.lean:301, `_sound` :469, `_complete` :694) is the
   base case of the navigated chain. Does its depth-`k` analog need `P.existF 0` only, or does the
   `U(χmid ∧ U(end,χmid), χmid)` nesting require `existF 1` (arity-2)? My read says `existF 0`
   suffices (all points in the chain are single-anchor at the fresh var), but the nested-Until
   witness ordering (`kvE2_futChainBuild`, :1180) should be checked for a two-anchor obligation.
3. **(Faithfulness/Rabinovich teammate)** Confirm against Rabinovich 2014 Cor 5.4 (PDF p.7/p.9)
   that rendering the depth-`k` profiles via `P.existF 0` (a black-box existential converter) is
   the *faithful* transcription of the "the `F_i` are TL formulas, per-round provider threading"
   device (cited PriorInterface.lean:35), i.e. that the paper's rung-`(k+1)` clause is genuinely
   built from rung-`k` closed formulas and not from a richer inductive object the `existF 0`
   black box would under-specify.
