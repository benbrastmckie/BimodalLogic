# Task 325 — Adversarial Verification of Research Claims

**Agent**: lean-research-hard-agent | **Session**: sess_1783441118_6b8bfa | **Mode**: --hard (H4/H5 divergence audit)
**Focus**: adversarial pre-plan verification of the task-324 spawn analysis (report 03) and its
machine-grounded blocker research (report 02), against the actual Lean sources.
**Constraints honored**: read-only on Lean sources; no `lake build`; no edits to any `.lean` file.
**Reference grounding tier**: Tier 3 (implementation-backed — every verdict traces to a Read of a
landed definition body in `NfMultiAnchorBridge.lean` / `ExistsForallNF.lean` / `VecEAFormula.lean`).

This section is **appended** to serve as the standalone adversarial gate before `/plan 325` is
dispatched. It re-checks the reports' load-bearing claims — including the false-∀-M negative claim
that motivated the whole redesign — directly against source, not against the reports' prose.

---

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verdict |
|-------|------------------------|---------|
| `kvE_subBracket2` exists; codomain is `Σ m, BracketFormula (m+1)` (single bracket, NOT a disjunction) | `NfMultiAnchorBridge.lean:6120,6123` (Read) — `noncomputable def kvE_subBracket2 … : Σ m, BracketFormula (m + 1)` | CONFIRMED |
| `kvE_subChain2` exists at the claimed anchor, `= (kvE_subBracket2 …).2.fChainPred` | `:6166,6170` (Read) | CONFIRMED |
| `kvE_subBracket2_sound` at :6530, `.holds` is a **hypothesis** `h` (:6537) | `:6530,6537` (Read) — soundness gates on `.holds`, confirming report 02 Q2(ii) shape asymmetry | CONFIRMED |
| `kvE_subBracket2_complete_extract` at :6683; reads `nf_eval_nf M 1 4`, carrier-agnostic (no `kvE_subBracket2.holds` in statement) | `:6683–6694` (Read) — hypothesis `nf_eval_nf M 1 4 [x1,w,x,t] σ`, conclusion = atom layer + off-fiber falsity + per-zone monotone witnesses; the name contains "subBracket2" but the **statement never mentions the bracket carrier** | CONFIRMED |
| `kvE_sub2_zoneHolds_cons_iff` :6615 and `_zXU`/`_zUW`/`_zWT` :6642/6653/6664 are pure `zoneHolds`↔inequalities over env `[x1,w,x,t]`, carrier-agnostic | `:6615–6671` (Read) — no reference to `kvE_subBracket2`'s carrier; only `zoneHolds`/order | CONFIRMED (survive near-verbatim) |
| `bracketEndChar_k1v_complete` at :2979 | `:2979` (Read) | CONFIRMED |
| `bracketFromLists.segmentTypes` is **per-side** 2-way `if i.val ≤ lL.length then segL else segR` at :1902 | `:1896–1902` (Read) | CONFIRMED |
| k1v kit lemmas exist near :2028–2825 | `k1v_zoneHolds_cons_iff:2041`, `k1v_bracket_extract:2150`, `bracketEndChar_k1v_sound:2338`, `k1v_sorted_insert:2751`, `k1v_sorted_realization:2797`, `k1v_bracket_construct:2838` (grep) | CONFIRMED (minor: `_bracket_construct` at 2838 is just past the stated 2825 upper bound; non-material) |
| `nf_eval_depth1_fold_iff` at :5187 forces only **own-zone** membership↔fold-bit, never cross-zone positivity | `:5187–5196` (Read) — biconditional is `(∃ v, zoneHolds env zs v ∧ nf_eval M 0 1 v χ) ↔ σ.2(nf0_assemble zs χ)`, quantified **per** `zs`; no clause forces a `zs`-realized type to be positive in another zone | CONFIRMED (this is the mechanical root of Obstruction 1) |
| **NEGATIVE CLAIM — Obstruction 1**: completeness converse is a false ∀-M statement because constant tri-zone `segExcl` vs per-point `IntervalPattern.holds` | `IntervalPattern.holds` requires each `beta_i` at **every** point of its segment (`ExistsForallNF.lean:112,124–132`, Read); `kvE_subBracket2.segmentTypes := fun _ => segExcl` (`:6159`, Read) with `segExcl` conjoining over **all three** zones `[zXU,zUW,zWT]` (`:6149–6152`, Read); fold only forces own-zone (row above). A point realized only in `zXU` satisfies the antecedent yet has `bits zUW = bits zWT = false`, falsifying `segExcl`'s neg-conjuncts at that point. | CONFIRMED GENUINE (not a misread) |
| **NEGATIVE CLAIM — Obstruction 2**: fixed filter-order `pointTypes` vs positional monotone witnesses | `pointTypes := (leftSlots ++ uSlot :: rightSlots)[i.val]` (`:6154–6155`, Read) with `leftSlots`/`rightSlots` from `List.filter` over `Finset.univ.toList` (`:6139–6144`, Read, fixed syntactic order); `IntervalPattern.holds` demands strictly-increasing witnesses with `alpha_i` at `witnesses i` **positionally** (`ExistsForallNF.lean:117,121`, Read). Independently fatal. | CONFIRMED GENUINE |
| **RESCUE SHAPE**: `bracketEndChar_k1v` works because its carrier is a `VVecEA2` finite disjunction over arrangement permutations with per-side segment types | `bracketEndChar_k1v : BracketEndCharCarrierV sig 1 = NormalForm sig 1 3 → VVecEA2` (`:1872–1873,1940–1943`, Read); disjuncts built `S_L.permutations.flatMap (fun lL => S_R.permutations.map (fun lR => mkDisjunct lL lR))`, gate-fail `disjuncts := []` (`:2013–2018`, Read); `mkDisjunct` uses `bracketFromLists … segL segR` per-side (`:2007–2012`, Read); `VVecEA2.holds = ∃ vea ∈ disjuncts, vea.2.holds` (`VecEAFormula.lean:276–279`, Read) → completeness can select the model-sorted disjunct | CONFIRMED |
| **VVecEA2 exists** and is the declared amended-spec codomain in 321 report §2 :225 | `VVecEA2` = `structure … disjuncts : List (Σ n, VecEA2 n)` (`VecEAFormula.lean:271–273`, Read); 321/reports/01 §2 declares `kvE2_body … : VVecEA2` at :225 and "reads σ.2, builds VVecEA2" at :71, over successor `NormalForm sig (j+1) 4` at :56 (grep/sed) | CONFIRMED |
| Gate-hypothesis rescue is circular (in completeness `.holds` is the conclusion, unlike soundness) | soundness `.holds` is hypothesis `h` at `:6537` (Read) vs completeness would need `.holds` as conclusion; a hypothesis discharging the 6 `IntervalPattern.holds` obligations would **be** the conclusion | CONFIRMED (structural) |

**Contradiction Log**: none. Every load-bearing claim in reports 02 and 03 — including the two
false-∀-M obstructions, the rescue shape, the preserved-asset carrier-agnosticism, and the VVecEA2
codomain — is corroborated by a direct Read of the cited definition body. The task-324 blocker was
**not** an effort artifact or a misread; it is a genuine Phase-1 codomain design defect.

### Challenge pass (adversarial re-read of the reports' own claims)

- *Could `kvE_subBracket2_complete_extract` secretly bind the old carrier, making it non-reusable?*
  Rejected — its statement (`:6683–6694`) is `nf_eval_nf M 1 4 … → (atom layer ∧ off-fiber-false ∧
  per-zone witnesses)`. It reads the semantic evaluation, never the `Σ m, BracketFormula` object.
  Preserved-asset claim holds; the name is misleading but the type is carrier-agnostic.
- *Is the ∀-M counterexample vacuous?* No. Any linear order with an interior point of `(x,t)` whose
  complete 1-type is realized only in `zXU` refutes it; `nf_eval_depth1_fold_iff` (:5187) forces only
  own-zone membership, so such a point survives the antecedent. Dedekind-complete dense chains supply
  the class. One class suffices to break `∀ M`.
- *Does the rescue shape actually differ structurally, or is it re-phrasable?* Structurally different:
  `NormalForm sig 1 3 → VVecEA2` (a function into a `List`-of-disjuncts structure with `∃-over-disjuncts`
  semantics) vs `Σ m, BracketFormula (m+1)` (a single `IntervalPattern`). The object type differs; not
  a statement-shape issue.

### Corrections planning must incorporate (minor; none block PROCEED)

1. **Codomain precision.** "Codomain = `VVecEA2` (`Σ n, VecEA2 n`)" (task desc / report 02 Q3) is
   shorthand: `VVecEA2` is a `structure` wrapping `disjuncts : List (Σ n, VecEA2 n)`
   (`VecEAFormula.lean:271–273`); each *disjunct* is a `Σ n, VecEA2 n`. The landed k1v analogue's
   full carrier is `BracketEndCharCarrierV sig 1 = NormalForm sig 1 3 → VVecEA2`
   (`:1872–1873`). The arity-4 redesign that returns a `VVecEA2` **directly given `σ`** (as
   `kvE_subBracket2` returns its `Σ m, BracketFormula` directly given `σ`) is the correct read;
   plan should state the codomain as `VVecEA2` (the struct), not the bare `Σ n, VecEA2 n` disjunct
   type, and select disjuncts via `VVecEA2.holds`'s `∃ vea ∈ disjuncts` at `(x,t)`.
2. **k1v kit line bounds.** The "kit `:2028–2825`" span is inclusive-ish: `k1v_bracket_construct` is
   at :2838 and `bracketEndChar_k1v_complete` at :2979 (the direction *template*, consumed but not
   "kit"). Use the grep'd anchors, not the range endpoints, when citing.
3. **Preserved-asset naming caveat.** `kvE_subBracket2_complete_extract` and the
   `kvE_sub2_zoneHolds_*` lemmas survive near-verbatim **despite** carrying `subBracket2`/`sub2` in
   their names; plan should reuse them directly (do not rebuild) and not be misled by the name into
   assuming a carrier dependency.
4. **Successor threading.** The redesign must read `σ : NormalForm sig (j+1) 4` (321/01 §2 :56),
   with the landed `NormalForm sig 1 4` as the `j=0` instance; the VVecEA2 codomain converges the
   carrier onto the amended spec (321/01 §2 :225), it does not diverge further.

---

## Final Verdict

**PROCEED-TO-PLAN.**

The task-324 spawn analysis (report 03) and its machine-grounded blocker research (report 02) are
adversarially confirmed against the actual Lean sources on every load-bearing claim:
- The completeness converse over the **current** `kvE_subBracket2` carrier is a genuine **false ∀-M**
  statement (Obstruction 1 = constant tri-zone `segExcl` vs per-point `IntervalPattern.holds`;
  Obstruction 2 = fixed filter-order `pointTypes` vs positional monotone witnesses) — not a misread,
  not an effort artifact.
- The redesign target — a `VVecEA2` arrangement-disjunction carrier with three per-region segment
  types (`segXU`/`segUW`/`segWT`) over the k1v template one arity up — is the correct and available
  rescue, structurally mirroring the proven `bracketEndChar_k1v_complete` mechanism.
- The preserved-asset accounting is accurate: the `zoneHolds` lemmas, zone specs, and
  `complete_extract` are carrier-agnostic and survive near-verbatim; the carrier defs and the
  soundness/completeness pair are genuinely re-derived.
- `VVecEA2` exists and is the amended-spec codomain (321/01 §2 :225).

Planning should proceed with the four minor precision corrections above folded in. No
REVISE-RESEARCH is warranted; the research direction is sound and the deliverable (a fresh
sound+complete pair over the VVecEA2 carrier, driven through, not accepted on type-check) is
correctly specified.
