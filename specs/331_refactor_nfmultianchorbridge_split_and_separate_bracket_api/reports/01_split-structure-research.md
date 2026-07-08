# Research Report: NfMultiAnchorBridge.lean Split Structure (Task 331)

- **Task**: 331 — refactor_nfmultianchorbridge_split_and_separate_bracket_api
- **Session**: sess_1783475175_afdf09
- **Agent**: lean-research-hard-agent (H2/H3/H4 contracts active)
- **Reference grounding tier**: Tier 1 (literature: Rabinovich 2014) + code (every claim cites file:line)
- **File under study**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (9,249 lines, verified by `wc -l`)
- **Date**: 2026-07-07

## Summary

The 9,249-line monolith splits cleanly into **10 content modules + 1 umbrella file** along
task-phase seams that are already strictly define-before-use (single namespace, no `section`
variables, no top-level `attribute`/`set_option`). All seven anchor line numbers cited in the
task description verified **exact** (zero drift). There is exactly **one real importer**
(`KampPrior.lean:4`) and it currently consumes **zero symbols** from the file, so the umbrella
strategy (keep `NfMultiAnchorBridge.lean` as an import-only re-export file) yields **zero
consumer changes**. The only token edits required anywhere are removal of the `private` modifier
on **11 helper declarations** (inventoried below), none of which is on the do-not-edit protected
list, plus relocation of **one public lemma** (`nf_eval_depth1_fold_iff` :5344) out of the
merged-route region into shared plumbing so the faithful modules never import the quarantine
file. Three divergences between the task description and the actual file are flagged in the
adversarial section (most important: `bracketFromLists_flatMap_subchain_below_pin` belongs to
the **faithful** module, not the quarantine, because its only code consumers are the task-326
`_of_outer` closers).

---

## Findings

### 1. Rabinovich → Lean mapping table (H3 Tier-1, 5-column)

Source: `/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` (md:line refs below).

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature (abbrev.) | Status |
|---|---|---|---|---|
| Def 3.1 exists-forall bracket (md:61-74) | interval decomposition, points + interval types | `bracketFromLists` :1896 (2-region); `bracketFromLists3` :6766 (3-region lift); `kvE_subBracket2V` :6833 | `bracketFromLists : List TemporalPred → TemporalPred → List TemporalPred → TemporalPred → TemporalPred → BracketFormula _`; `kvE_subBracket2V : (charBase) → (charK) → NormalForm sig 1 4 → VVecEA2` | `kvE_subBracket2V` = PUBLIC faithful API (module `SubBracket2V`); `bracketFromLists` = shared plumbing (de-privatize); `bracketFromLists3` stays private inside `SubBracket2V` |
| Lemma 3.2(2) 2-variable reduction (md:78) | closure: ≤2 free vars | `neg_2var_vec_ea` — **external**, `EANegationClosure.lean:722` | negation of 2-var exists-forall is V-exists-forall | PUBLIC API (already outside the monolith; document in API header) |
| Lemma 3.4 / V-exists-forall closure (md:84-85) | disj/conj/∃ closure | `VVecEA2.disjList` :8938, `VVecEA2.disjList_holds` :8947; `VVecEA2.conj_struct` — external, `VecEAClosure.lean:195` | `disjList_holds : (VVecEA2.disjList vs).holds M atomMap z0 z1 ↔ ∃ v ∈ vs, v.holds …` | PUBLIC faithful API (module `NavigatedSpine`) |
| Prop 3.5 folding / F_i chain (md:87-94) | exists-forall → nested Until/Since | `kvE_fold_navigated` :8881; non-interior dischargers `kvE_nonInterior_z{PastX,FutT,AtX,AtT,AtW}_{sound,complete}` :9055-9176 | fold via `kvE_subBracket2V_correctness_pair`; dischargers over `formula_conjList` literals | PUBLIC faithful API (module `NavigatedSpine`) |
| Prop 4.2 negation closure (md:100-101) | hard case of induction | `reflatten_neg_step` :8976 | negation step consuming Prop 4.2 shape | PUBLIC faithful API (module `NavigatedSpine`) |
| Prop 4.3 structural induction (md:103-110) | FO → V-exists-forall | `reflatten_prop43` :8991 | induction step: disj case rides `VVecEA2.disjList_holds`, neg case rides `reflatten_neg_step` | PUBLIC faithful API (module `NavigatedSpine`) |
| Lemma 5.1 point insertion, quantifier-free point types (md:134-135, 159-173) | negation with fixed endpoint/interval types | partially: `kvE_subBracket2V_correctness_pair` :8549 (per-σ); the shared-interior-witness conjunction (∃w, conj over σ) is **the unbuilt task-321 object** | `correctness_pair : … → ((…).holds M atomMap x t ↔ ∃ x1, nf_eval_nf M 1 4 … σ) `(pair of directions) | PUBLIC faithful API (module `SubBracket2V`); no-nesting audit rule :8841-8846 enforces the quantifier-free point-type requirement |
| Cor 5.4 F_i-chain reduction (md:154-157) | chain predicate over bracket | `kvE_subChain2V` :6955 (protected byte-identical); `kvE_subChain` :5964; `kvE_subChain2` :6179 | per-arrangement Cor 5.4 F_i-chain as single `TemporalPred` | `kvE_subChain2V` = PUBLIC faithful API (module `SubBracket2V`); the 2-region `kvE_subChain` variants = foundation modules |
| (merged-route, violates Lemma 5.1 point-type rule) | bracket-whose-points-are-brackets | `kvE2_body` :8608, `bracketEndChar_kvE2` :8712, `slotsFor` (local `let` at :5632 and :8677), `kvE'_body` :5562, `kvE_pinArrangements/pinDisjunct/exclConj` :5521/:5531/:5544, `kvE_gate` :5172 | two-level carrier; witness slots are themselves sub-chain splices | QUARANTINE (module `MergedQuarantine`), byte-identical, do not delete |

### 2. Section map: exact line ranges → module assignment

Anchor verification: all seven task-cited anchors are **exact** in the current file —
`kvE_subBracket2V` :6833, `_sound_of_outer` :7910, `_complete` :8159, `correctness_pair` :8549,
no-nesting audit :8841-8846, `VVecEA2.disjList_holds` :8947, `reflatten_prop43` :8991.

Proposed directory: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`
(Lean permits sibling `NfMultiAnchorBridge.lean` + `NfMultiAnchorBridge/` directory, standard
Mathlib layout). All files keep `namespace Bimodal.Metalogic.WeakCanonical.Kamp` and the three
`open`s (:82-84).

| # | Module (file) | Line range (orig.) | ~Lines | Content | Role |
|---|---|---|---|---|---|
| 1 | `Base.lean` | 88-1522 | 1,435 | Phases 1-7 (tasks 307/309): `nf_char2_*` (:213-:544), `nf_zone_flatten_navigable` :712, `A_diag` :786, `nf_char3_endpoint_tl` :914, `endChar0` :1040, `seg` :1172, past/future off-diag formulas :1252/:1451; `cons_const_apply` :143 | baseline plumbing |
| 2 | `CarrierK1V.lean` | 1523-3603 | 2,081 | Phase 9 VecEA2 carrier (`bracketEndChar_k0` :1580, `_k1` :1687), `bracketFromLists` :1896, `bracketEndChar_k1v` :1940, k1v helper kit (:2032-:3135), `bracketEndChar_k1v_sound` :2495 / `_complete` :3136 / `_correct` :3548 | foundation (k=1 V-carrier) |
| 3 | `CarrierKv.lean` | 3604-4040 (+ relocated :5344 block) | ~455 | `atomKind_castLE` :3640, `nfk_take` :3656, `nfk_projFresh` :3668, `kv_body` :3738, `bracketEndChar_kv` :3824, `_correct_zero` :3953, `_correct_one` :3981, `_factors` :4008; **plus relocated** `nf_eval_depth1_fold_iff` (orig. :5344) | foundation (depth-k) |
| 4 | `RefutationF2.lean` | 4041-4987 | 947 | F1 finding record :4041, F2 probe machinery (`f2*` :4117-:4822, fully self-contained), `f2_relativized_refutation` :4884 | quarantine (negative-result record; part of F1-F4 protected records) |
| 5 | `PriorInterface.lean` | 4988-5076 | 89 | `ExistProviders` :5010, `BracketCarrierCorrectVPrior` :5032, `bracketEndChar_kv_correct_{zero,one}_prior` :5052/:5067 | protected interface (byte-identical) |
| 6 | `SubBracket.lean` | 5857-6106 | 250 | Task 321 F4 resolution: `kvE_subFoldBits` :5885, `kvE_subInteriorZones` :5908, `kvE_subBracket` :5936, `kvE_subChain` :5964, discrimination :6012-:6037, verdict record :6038-:6106 | faithful foundation |
| 7 | `SubBracket2.lean` | 6107-6733 | 627 | Task 324: `kvE_subBracket2` :6133, `kvE_subChain2` :6179, zone specs `kvE_sub2_z{XU,UW,WT}` :6213-:6221, kill-switch/soundness/completeness kit :6246-:6733 | faithful foundation |
| 8 | `SubBracket2V.lean` | 6734-8607 | 1,874 | Tasks 325/326 (protected byte-identical): `bracketFromLists3` :6766, `kvE_subBracket2V` :6833, `kvE_subChain2V` :6955, `k1v_sorted_realization3` :7073, `k1v_bracket_construct3` :7149, sound :7640, `_sound_of_parts` :7719, `bracketFromLists_flatMap_subchain_below_pin` :7793, `_bounded_anchor_of_outer` :7876, `_sound_of_outer` :7910, `_gate_holds_of_honest` :8086, `_nonvacuous` :8119, `_complete` :8159, `_correctness_pair` :8549 | **PUBLIC faithful separate-bracket API** |
| 9 | `MergedQuarantine.lean` | 5077-5766 (minus :5344 block) + 5767-5856 + 8608-8826 | ~985 | Phase 13.2/13.25/13.3/13.35: `kvE_gate` :5172, `kvE_body` :5193, `bracketEndChar_kvE` :5307, pin/excl channels :5507-:5560, `kvE'_body` :5562, `bracketEndChar_kvE'` :5667 (all with `slotsFor` local lets :5632); task-320 probes :5767-5856 (`probe_P1/P3/P4`, zero external uses); **kvE2 splice** `kvE2_body` :8608, `bracketEndChar_kvE2` :8712, `kvE2_joint_nonvacuous_at_honest` :8748, task-327 gate record :8760-:8826 | **QUARANTINE / DEAD-CODE** (merged route; byte-identical protected) |
| 10 | `NavigatedSpine.lean` | 8827-9249 | 423 | Task 321 v6: baseline/quarantine audit record :8827-:8858 (incl. no-nesting rule :8841-8846), `kvE_fold_navigated` :8881, `VVecEA2.disjList` :8938 + `disjList_holds` :8947, `reflatten_neg_step` :8976, `reflatten_prop43` :8991, `VVecEA2.holds_flatMap_map` :9018, 5+5 non-interior dischargers :9055-:9176, Phase-7 rescope record :9183-:9249 | **PUBLIC faithful API** (spine + Prop 4.3 engine + dischargers) |
| — | `NfMultiAnchorBridge.lean` (umbrella) | header 1-79 retained | ~90 | module doc (:30-:79) + `import` of modules 1-10 | re-export shim (zero consumer changes) |

Mapping to the task's proposed (a)-(f): (a) = modules 1+2+3+5; (b) = module 10 (spine +
reflatten); (c) = module 10 (`holds_flatMap_map` :9018 — 12 lines, not worth its own file);
(d) = module 10 (dischargers; could be split out as `Dischargers.lean` if desired — they have
**zero in-file dependencies**, verified on :9055-9068, :9106-9112, :9134-9141, all riding
external `formula_conjList_iff`); (e) = modules 6+7+8; (f) = modules 4+9.

### 3. Import DAG (acyclic, effectively linear)

```
Base ← CarrierK1V ← CarrierKv ← RefutationF2
                        ↑
                  PriorInterface ← SubBracket ← SubBracket2 ← SubBracket2V ← MergedQuarantine
                                                                    ↑              (also ← PriorInterface, transitively)
                                                              NavigatedSpine
umbrella NfMultiAnchorBridge ← {all 10}
```

Key verified edges:
- `MergedQuarantine` (part 8608-8826) **must import** `SubBracket2V`: `kvE2_body` :8677 uses
  `kvE_subChain2V` (public, :6955) and `kvE2_joint_nonvacuous_at_honest` :8757 calls
  `kvE_subBracket2V_nonvacuous` (:8119). Verified code at :8676-8686, :8757.
- `NavigatedSpine` **must import** `SubBracket2V` + `SubBracket2`: `kvE_fold_navigated` uses
  `kvE_subBracket2V_correctness_pair` (:8912-8914, code) and `kvE_sub2_zXU` in its statement
  (:8904, code). All `kvE2_body`/`bracketEndChar_kvE2` mentions in 8827-9249 are **comments
  only** (verified :9006, :9015, :9187-9243) — the spine has **no code dependency on the
  quarantine**, so quarantine and spine are independent leaves.
- Nothing outside `MergedQuarantine` code-depends on its contents **except**
  `nf_eval_depth1_fold_iff` (public theorem, orig. :5344), used in code by module 7
  (:6577, :6578, :6606, :6687, :6716) and module 8 (:7672, :7673, :7754, :8104, :8177).
  **Relocate it** (token-identical) into `CarrierKv.lean` so faithful modules never import the
  quarantine. All other apparent crossings (`kvE_gate` :6510/:6528/:6600/:7695/:7773,
  `kvE'_body`, `kvE_pinDisjunct/exclConj` :5866/:6098/:8588-8589, `kv_body`
  :5111/:5170/:5181/:5186/:5200/:5236, `bracketEndChar_k1v_eq_kv_body` :5321,
  `kv_body_gate_fail` :5286) were individually inspected and are **comment/docstring text, not
  code**.

### 4. De-privatization inventory (the ONLY token edits)

A `private` declaration is invisible outside its file, so every private whose **code** users land
in a different module must have the `private ` modifier removed at extraction time. Verified
code-crossing privates (11 total; none appears in the task's protected byte-identical list nor in
the file's own do-not-edit records at :5866/:6098):

| Private decl | Defined | Cross-module code uses (verified) | Home → consumer modules |
|---|---|---|---|
| `bracketFromLists` | :1896 | :3806 (`kv_body`), :5276/:5641 (kvE/kvE' bodies), :7887/:7923 (statements of `_bounded_anchor_of_outer`/`_sound_of_outer`), :8686 (`kvE2_body`) | 2 → 3, 8, 9 |
| `k1v_bool_eq_false` | :2032 | :8003-8076 (`kvE_sub2V_zone_consistent` proof) | 2 → 8 |
| `k1v_not_of_iff_false` | :2465 | :8374-8453 (`_complete` proof) | 2 → 8 |
| `k1v_bracket_extract_mono` | :2274 | :7812 (`subchain_below_pin` proof) | 2 → 8 |
| `getElem_append3_mid` | :2300 | :7833, :7853 (`subchain_below_pin` proof) | 2 → 8 |
| `k1v_sorted_realization` | :2954 | :7091-7095 (`k1v_sorted_realization3` proof) | 2 → 8 |
| `atomKind_castLE` | :3640 | :4520 (f2 block proof) | 3 → 4 |
| `kvE_sub2_zXU` | :6213 | :7044, :7466 (statements in module 8), :8904 (`kvE_fold_navigated` statement) | 7 → 8, 10 |
| `kvE_sub2_zUW` | :6217 | :7470, :7541, :7600, :8270-8329 | 7 → 8 |
| `kvE_sub2_zWT` | :6221 | :7471, :7560, :7619, :8289-8331 | 7 → 8 |
| `kvE_sub2_zoneHolds_cons_iff` | :6628 | :8237-8451 (`_complete` proof) | 7 → 8 |

Privates that stay private (spot-verified no code crossing): all `f2*` (module-4-internal),
`kv_body`/`kv_body_gate_fail`/`bracketEndChar_k1v_eq_kv_body` (module-3-internal; all later
mentions are comments), `bracketEndChar_k1v_sound`/`_complete` (crossings :6540/:7358/:7474/
:7638/:8143/:8530 are all comments), `k1v_zone_consistent`, `k1v_zoneHolds_cons_iff`,
`k1v_bracket_extract`, `bracketFromLists_flatMap_block_extract`, `bracketFromLists3` (:8667/:8739
are comments — `kvE2_body` does NOT use it in code), `bracketFromLists_flatMap_subchain_below_pin`
(:7869/:7895 internal to module 8), `k1v_sorted_realization3`, `k1v_bracket_construct3`,
`kvE_sub2V_zone_consistent`, `kvE2_body` (uses :8701-8738 all within module 9),
`kvE_gate`/`kvE_pinArrangements`/`kvE_pinDisjunct`/`kvE_exclConj`/`kvE_consistentZones`/
`kvE_body`/`kvE'_body` (crossing uses :8653/:8676/:8687/:8700/:5808 are all inside module 9's
combined range — this is precisely why 5077-5856 and 8608-8826 must share one file; splitting
them would force de-privatizing `kvE_pinDisjunct`/`kvE_exclConj`, which ARE on the file's
do-not-edit list at :5866/:6098).

### 5. Consumer / shim inventory

Exhaustive grep of `Theories/` and `Tests/` for `NfMultiAnchorBridge`:

| Consumer | Kind | Symbols used | Shim needed |
|---|---|---|---|
| `KampPrior.lean:4` | **real `import`** (the only one) | **none** — grep of KampPrior.lean for every public bridge symbol family (`bracketEndChar*`, `kvE_*`, `nf_char2*`, `nf_zone_flatten*`, `A_diag`, `endChar0`, `VVecEA2`, `reflatten*`, `f2_relativized*`) returns zero hits; the :351-353 strategic-sorry hook (`| 1 => sorry` inside `nf_nvar_exist_all_depths`) is where task 321 will consume the API | none — umbrella file keeps the import path valid unchanged |
| `NfDepth0Generalized.lean:1724`, `NfEFold.lean:370,520`, `EANegationClosure.lean:738-744`, `NfZoneFlattenNavigable.lean:307,323` | comment references only (incl. stale `:NNNN` line refs) | n/a | none (stale line refs acceptable; see Risks) |
| task-309 general-k consumers | none found outside the file itself | n/a | none |

Since all files keep the same namespace and the umbrella imports everything, **no `export`/alias
shims are needed anywhere**. Lean 4 imports are transitive: `import …NfMultiAnchorBridge` exposes
all 10 sub-modules to KampPrior unchanged.

Build-system note: `lakefile.lean` uses `roots := #[`Bimodal]` (not globs) for the `Bimodal`
lib, so new files are built exactly when reachable via the import graph — the umbrella file
guarantees this. No lakefile change needed.

### 6. Scoping constructs affecting relocation

- Single `namespace Bimodal.Metalogic.WeakCanonical.Kamp` :80 … `end` :9249; three top-level
  `open`s :82-84. **No `section`, no top-level `variable`, no `attribute`, no `set_option`**
  anywhere in the file (verified by grep) — the classic relocation hazards are absent.
- Six `open Classical in` occurrences (:3814, :3865, :3999, :5179, :5551, :8586) — each is a
  per-declaration modifier that travels with its declaration verbatim.
- `slotsFor` is a **local `let`** inside `kvE'_body` (:5632) and `kvE2_body` (:8677), not a
  top-level def — "quarantining slotsFor" means quarantining those two bodies (already planned).
- Header module docstring :30-:79 stays in the umbrella file; each new module should get a short
  new header noting provenance (`extracted from NfMultiAnchorBridge.lean lines X-Y, task 331`)
  — new text is additive and touches no landed tokens.

### 7. Recommended split order (each step: extract → `lake build` → commit)

Extract top-down so the shrinking monolith always compiles (everything below an extraction point
only depends upward):

1. **Base** (88-1522). Monolith gains `import …NfMultiAnchorBridge.Base`.
2. **CarrierK1V** (1523-3603); de-privatize the 6 module-2 helpers listed above.
3. **CarrierKv** (3604-4040) **plus** cut the `nf_eval_depth1_fold_iff` block (docstring +
   theorem, orig. :5344) from the monolith and append it here token-identically; de-privatize
   `atomKind_castLE`.
4. **RefutationF2** (4041-4987).
5. **PriorInterface** (4988-5076).
6. **MergedQuarantine part 1** (5077-5766 minus the relocated lemma, plus 5767-5856). Mark file
   header QUARANTINE/DEAD-CODE.
7. **SubBracket** (5857-6106).
8. **SubBracket2** (6107-6733); de-privatize the 4 module-7 helpers.
9. **SubBracket2V** (6734-8607) — the protected task-325/326 block moves as one token-identical
   slab.
10. **MergedQuarantine part 2**: append 8608-8826 to `MergedQuarantine.lean` and add
    `import …SubBracket2V` to it (acyclic: SubBracket2V does not import MergedQuarantine).
11. **NavigatedSpine** (8827-9249). Monolith is now the umbrella (header doc + 10 imports).
    Final gates: `lake build` (whole lib), axiom check on flagship theorems
    (`kvE_subBracket2V_correctness_pair`, `reflatten_prop43`, `bracketEndChar_kvE2_two_eq`,
    `f2_relativized_refutation`) via `#print axioms`/`lean_verify` expecting
    `[propext, Classical.choice, Quot.sound]`, and a token-diff check that protected slabs moved
    unchanged (e.g. `git diff --word-diff` or extraction-by-`sed` so slabs are byte-copies).

Step 6 lands before steps 7-9 even though its second half (step 10) depends on them — this is
safe because part 1 (5077-5856) only depends on modules ≤5 (single relocation in step 3 removes
its one downstream-consumed lemma).

### 8. Faithful separate-bracket API surface (what task 321 v7 consumes)

The public interface the plan should name and document (in `SubBracket2V.lean` +
`NavigatedSpine.lean` headers):

- Per-σ carrier: `kvE_subBracket2V` :6833, `kvE_subChain2V` :6955 (protected)
- Correctness: `kvE_subBracket2V_sound` :7640, `_sound_of_parts` :7719, `_sound_of_outer` :7910,
  `_gate_holds_of_honest` :8086, `_nonvacuous` :8119, `_complete` :8159,
  `_correctness_pair` :8549 (protected)
- Spine/engine: `kvE_fold_navigated` :8881, `VVecEA2.disjList`/`disjList_holds` :8938/:8947,
  `reflatten_neg_step` :8976, `reflatten_prop43` :8991, `VVecEA2.holds_flatMap_map` :9018
- Dischargers: `kvE_nonInterior_*` :9055-:9176 (10 lemmas, dependency-free)
- External combinators to cross-reference in the API doc: `neg_2var_vec_ea`
  (`EANegationClosure.lean:722`, Lemma 3.2(2)), `VVecEA2.conj_struct` (`VecEAClosure.lean:195`),
  `VVecEA2.holdsRight` (`NfToVecEA.lean:50`)
- The one genuine unbuilt object (task 321, NOT this task): the shared-interior-witness
  conjunction `∃ w, ⋀_σ (kvE_subBracket2V … σ holds at that same w)` = Lemma 5.1 point-insertion
  + Lemma 3.2(2) reduction.

## Risks

1. **`private`-modifier edits vs. byte-identity** (medium, managed): 11 declarations lose
   `private `. None is on the task's protected list ("task-325/326 landed lemmas, kvE2 splice,
   `kvE_subChain2V`, `BracketCarrierCorrectVPrior`/`Prior`, `EANegation`, F1-F4 records") nor on
   the in-file do-not-edit records (:5866, :6098). Statements and proof terms are untouched. The
   plan should state this interpretation explicitly so the implementer doesn't improvise.
2. **`nf_eval_depth1_fold_iff` relocation** (medium): it is the single load-bearing extraction
   from the merged-route region. If any additional code use of 5077-5766 content by modules 6-8
   surfaced during implementation (my check covered every private and every public `bracketEndChar_kvE*`
   name), fallback is: faithful modules import `MergedQuarantine` (ugly but correct) — record as
   plan contingency, not default.
3. **Stale `:NNNN` comment references** (low, cosmetic): hundreds of intra-file line refs in
   docstrings (and 6 cross-file comment refs) go stale. Do NOT rewrite them inside protected
   slabs (would violate byte-identity). Optionally add a provenance header per module.
4. **Proof-term identity across files** (low): no `section variable`s exist, so elaboration
   context is identical; `open Classical in` travels with each decl; instance environment is
   unchanged because imports are a superset chain. Residual risk only from `Finset.univ.toList`
   -style dependence on import order — not plausible here, and `lake build` + axiom check per
   step catches it.
5. **Module 2 size** (low): `CarrierK1V` at 2,081 lines slightly exceeds the ~2,000 target; if
   the planner wants strict compliance, cut at the Phase-5 seam :2836 (`CarrierK1V.lean`
   1523-2835 / `CarrierK1VComplete.lean` 2836-3603). Same for module 8 (1,874 lines, within
   target).
6. **Umbrella keeps `Boneyard` untouched**: `Kamp/Boneyard/` exists but is a separate lake target
   (`BoneyardArchive`); no interaction.

## Adversarial Self-Verification

Method key: `Read/sed` = direct source inspection; `grep-scan` = exhaustive line-number
enumeration of an identifier; all inspections performed on the current working tree.

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| File is 9,249 lines | `wc -l` output | VERIFIED (High) |
| All 7 task-cited anchors exact (:6833, :7910, :8159, :8549, :8841-8846, :8947, :8991) | grep-scan + `sed -n` on each | VERIFIED (High) — zero drift |
| Only real importer is `KampPrior.lean:4`; all other cross-file mentions are comments | `grep -rn NfMultiAnchorBridge Theories/ Tests/` — 1 import line, 8 comment lines | VERIFIED (High) |
| KampPrior currently uses zero bridge symbols | grep of KampPrior.lean for all public symbol families returned empty | VERIFIED (High) — caveat: checked name families, not an automated full-decl-list sweep; Low residual risk since KampPrior predates the bridge API and its only hook is the :352 `sorry` |
| No `section`/`variable`/`attribute`/`set_option` at top level | grep `^(section|end|variable|set_option|attribute|open)` — only :80 namespace, :82-84 opens, :9249 end, 6 `open Classical in` | VERIFIED (High) |
| `kv_body`/`kvE_gate`/`kvE'_body`/pin/excl channels have NO code consumers outside module 9's combined range | line-by-line `sed` inspection of every crossing candidate (:5111-:5321, :6510-:6600, :7695, :7773, :5866, :6098, :8588-8589 — all comments; :8653/:8676/:8687/:8700 code but inside 8608-8826) | VERIFIED (High) |
| `nf_eval_depth1_fold_iff` is the ONLY 5077-5766 decl code-used by faithful modules | grep-scan of every private (:5157-:5651) + every public `bracketEndChar_kvE*` in that range; fold_iff code uses at :6577-:8177 | VERIFIED (Medium-High) — the crossing uses (:6577 etc.) were classified as code by cluster pattern, individually spot-checked at :7672-7673 region only via context; flagged as implementation-time re-check in Risks §2 |
| `kvE2_body` does not code-use `bracketFromLists3`; spine does not code-use `kvE2_body`/`bracketEndChar_kvE2` | `sed` on :8667, :8739 (comments); :9006, :9015, :9187-9243 (comments); `kvE2_joint_nonvacuous_at_honest` proof :8748-8759 read in full (uses `_nonvacuous` :8119) | VERIFIED (High) |
| Dischargers :9055-9176 have zero in-file dependencies | full `Read` of :9055-9068, :9106-9112, :9134-9145; grep of `kvE_sub2_zXU` shows no uses >8904 | VERIFIED (High for the 4 read; Medium for the remaining 6 — same syntactic pattern, riding `formula_conjList_iff` only) |
| De-privatization list complete (11 items) | derived from exhaustive 117-private usage enumeration + code/comment classification of every cross-boundary hit | VERIFIED (Medium-High) — classification of ~15 ambiguous lines done by direct `sed`; any misclassified comment merely makes a de-privatization unnecessary (harmless); a missed code use fails loudly at `lake build` of that step |
| `lakefile` builds new files iff imported (roots-based) | `lakefile.lean` read: `roots := #[`Bimodal]` | VERIFIED (High) |
| Rabinovich mapping rows | literature chunk read in full (246 lines); Lean names verified via grep (e.g. `neg_2var_vec_ea` EANegationClosure.lean:722, `VVecEA2.conj_struct` VecEAClosure.lean:195) | VERIFIED (High) |

**Divergences from the task description found during verification** (H5-adjacent, load-bearing
for the plan):

1. `bracketFromLists_flatMap_subchain_below_pin` (:7793) is listed in task scope item 1(f) as
   merged-route quarantine, but its only code consumers are `kvE_sub2V_bounded_anchor_of_outer`
   (:7876) and `kvE_subBracket2V_sound_of_outer` (:7910) — task-326 closers the same task text
   assigns to (e). It must live in `SubBracket2V.lean` (it is `private`; moving it to quarantine
   would require de-privatizing it AND making the faithful module import quarantine).
   Resolution: keep in module 8; the `_of_outer` lemmas' statements quantify over an outer
   merged bracket shape via `bracketFromLists` but do not depend on any quarantined definition.
2. `slotsFor` is not a top-level definition — it is a local `let` at :5632 and :8677. Quarantine
   of "slotsFor" is realized by quarantining `kvE'_body`/`kvE2_body`.
3. `VVecEA2.conj` (named in the task's API list) does not exist under that name; the actual
   combinator is `VVecEA2.conj_struct` (`VecEAClosure.lean:195`, external to the monolith).

No recommendations were retracted after verification; divergence 1 changed the module assignment
of one lemma relative to the task text (documented above).

## Recommendations for the plan

1. Adopt the 10-module + umbrella layout and the 11-step extraction order verbatim; one
   `lake build` + one commit per step (H9 incremental discipline).
2. Perform extractions as byte-copies (e.g. `sed -n 'A,Bp'` slabs) so protected regions are
   provably token-identical; only permitted edits are the 11 `private ` removals and the two new
   `import` headers per file.
3. Add a short QUARANTINE banner header to `RefutationF2.lean` and `MergedQuarantine.lean`
   (new text, additive) and a faithful-API banner to `SubBracket2V.lean`/`NavigatedSpine.lean`
   naming the Rabinovich items per the mapping table.
4. Final phase gate: full `lake build`, axiom check on the 4 flagship theorems, grep that no
   `sorry` was introduced, and confirmation that `KampPrior.lean` is untouched.

## Memory candidates

1. (pattern, lean4) Splitting a monolithic Lean file that uses one namespace and no sections:
   umbrella-import file at the old path gives zero consumer changes; the only true blocker class
   is `private` declarations with cross-boundary code uses — enumerate them by grepping every
   private name's usage lines and classifying code vs comment before planning the cut.
2. (fact, repo) `lakefile.lean` uses `roots := #[`Bimodal]`, so new `.lean` files build only when
   reachable through the import graph from `Theories/Bimodal.lean`.
