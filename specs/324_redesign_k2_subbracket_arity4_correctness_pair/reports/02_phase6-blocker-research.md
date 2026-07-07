# Task 324 — Phase 6 Blocker Research: Completeness Obstruction Verification & Resolution Path

**Agent**: lean-research-hard-agent | **Session**: sess_1783431658_f50ffc | **Mode**: --hard (H2/H3/H4/H5)
**Focus**: adversarial verification of Phase 6 completeness obstruction
**Constraints honored**: read-only on Lean sources; no lake build; no edits to landed code.
**Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014 Lemma 5.3 / Cor 5.4) + Tier 3 (implementation-backed — landed k1v template).

---

## Summary Verdict

Both recorded obstructions are **GENUINE and machine-grounded** against the landed definitions. The
Phase-6 agent did **not** misread the segment-type semantics. The completeness converse
`(∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ) → (kvE_subBracket2 …).2.holds M atomMap x t` is a **false
∀-M statement** over the current carrier. A correctly-shaped completeness statement **cannot** close
over the current carrier without either (a) trivializing the deliverable via a circular gate
hypothesis, or (b) redesigning the carrier's codomain from a single `BracketFormula` to a `VVecEA2`
arrangement disjunction. **Redesign is unavoidable.** Recommendation: **(b) finalize 324 as PARTIAL
(Phases 1–5 = soundness deliverable) and spawn the redesign as its own task.**

---

## Reference Grounding (H3 Tier 1) — Lemma-Level Mapping Table

| Source | Prop / Location | Lean Identifier | Type Signature (verified) | Status |
|--------|-----------------|-----------------|---------------------------|--------|
| Rabinovich 2014 | Lemma 5.3 (md:137–152), base-case negation → V-∃∀ | `IntervalPattern.holds` | `ExistsForallNF.lean:106` — segment `beta_i` must hold at **every** point of open segment | VERIFIED (Read) |
| Rabinovich 2014 | Cor 5.4 (md:154–157), F_i chain | `bracketEndChar_k1v` | `NfMultiAnchorBridge.lean:1940` — codomain `BracketEndCharCarrierV` = **`VVecEA2`** | VERIFIED (Read) |
| Rabinovich 2014 | §5 bracket, PDF p.7 | `bracketFromLists` | `:1896` — `segmentTypes := if i ≤ lL.length then segL else segR` (**per-side**) | VERIFIED (Read) |
| Landed asset | current arity-4 carrier | `kvE_subBracket2` | `:6120` — codomain `Σ m, BracketFormula (m+1)` (**single bracket**); `segmentTypes := fun _ => segExcl` (:6159) | VERIFIED (Read) |
| Landed asset | k1v completeness template | `k1v_sorted_realization` | `:2797` — sorts realized points into arrangement `Perm`; selects existing disjunct | VERIFIED (Read) |
| Landed asset | k1v construction | `k1v_bracket_construct` | `:2838` — needs `hsegL : ∀u, x<u→u<w→ segL.eval_at` (segL on **all** of (x,w)) | VERIFIED (Read) |
| Design spec | report 321 §2 Q1–Q3 | amended carrier header | `321/reports/01_…:225` — target codomain declared **`VVecEA2`** | VERIFIED (grep) |

---

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|-------|-------------------------|---------------------|------------|
| `IntervalPattern.holds` requires each `beta_i` (segment type) to hold at **every** point of its open segment | `ExistsForallNF.lean:112,124–132` (Read); doc-comment :100–105 | Read of definition body | High |
| `kvE_subBracket2.segmentTypes` is the **constant** `segExcl` on every segment | `NfMultiAnchorBridge.lean:6159` (Read) | Read of definition | High |
| `segExcl` conjoins `if bits zs χ then ⊤ else (charBase χ).neg` over **all three** zones `[zXU,zUW,zWT]` | `:6149–6152` (Read) | Read of definition | High |
| `charBase = nf_depth0_char_formula` is a **complete** 1-type char (each point realizes exactly one χ; `⟨charBase χ⟩.eval_at ↔ nf_eval_nf M 0 1`) | `nfPred_correct` used at `:6449,6470,6491,6577`; `nf_eval_unique` NormalForm:245 (cited :2791) | Read + cross-ref | High |
| Obstruction 1: converse false — an interior point in zone `zXU` whose type is zUW-/zWT-negative falsifies `segExcl`, while `nf_eval_nf M 1 4` still holds | Derived from the four rows above; recorded counterexample in handoff | Semantic derivation over definition bodies | High |
| `kvE_subBracket2.pointTypes` is a **fixed filter-order** list `leftSlots ++ uSlot :: rightSlots` (`Finset.univ.toList` order) | `:6154–6158`, `leftSlots` :6139, `rightSlots` :6142 (Read) | Read of definition | High |
| Obstruction 2: `IntervalPattern.holds` demands **positional** monotone witnesses `alpha_i @ x_i` — filter order need not match model order | `ExistsForallNF.lean:117,121` (Read) | Read of definition | High |
| k1v completeness works **because** carrier is a `VVecEA2` disjunction over `S_L.permutations × S_R.permutations` with **per-side** segment types | `bracketEndChar_k1v` :2013–2018 (disjunction); `bracketFromLists` :1902 (per-side); `k1v_sorted_realization` :2797 (disjunct selection) | Read of three definitions | High |
| `kvE_subBracket2` codomain differs from k1v: `Σ m, BracketFormula (m+1)` vs `VVecEA2` | `:6123` vs `BracketEndCharCarrierV`/`VVecEA2.holds` VecEAFormula:276 | Read + type comparison | High |
| A gate-hypothesis-absorbed completeness over the current carrier would be **vacuous/circular** (the hypothesis = the conclusion's segment+order obligations) | Structural: completeness's `.holds` is the *conclusion*, not a hypothesis (contrast soundness :6530 where `.holds` is a *hypothesis*) | Structural analysis of statement shape | High |

**Contradiction Log**: none. The Phase-6 agent's recorded claims are consistent with the landed
definitions on every point checked. No forbidden verification outputs ("mathlib likely has",
instinct-only claims) were relied upon — every verdict traces to a Read of a definition body.

### Challenge pass (adversarial re-read of the blocker's own claims)

- *Could `segExcl` be satisfiable after all if `nf_eval_nf M 1 4` constrains M enough?* Challenged
  and rejected: the depth-1 fold (`nf_eval_depth1_fold_iff` :5187, driven in
  `kvE_subBracket2_complete_extract` :6703) only forces *zone-membership ↔ fold-bit*. It says a type
  appears in zone `zXU` iff `bits zXU χ`; it does **not** force every `zXU`-realized type to also be
  `zUW`/`zWT`-positive. So an interior `zXU` point with single-zone-positive type survives the
  antecedent yet kills `segExcl`. The obstruction stands.
- *Is the counterexample vacuous (no such M)?* No. The statement under test is `∀ M …`. Any linear
  order M containing an interior point of (x,t) below the anchor whose complete 1-type is realized
  only in (x,x1) falsifies it. Dedekind-complete dense chains (Rabinovich's own model class,
  Lemma 5.1/5.3) contain such points. One counterexample class suffices to refute the ∀-M claim.

---

## Q1 — Are the two obstructions genuine, or a misread?

**GENUINE. Not a misread.**

**Obstruction 1 (constant tri-zone `segExcl` segment type).**
`IntervalPattern.holds` (`ExistsForallNF.lean:106–132`) requires, for the `n+1`-witness form, that
each segment type `beta_i` hold at **every** point `y` of its open segment (clauses :124–132).
`kvE_subBracket2` sets `segmentTypes := fun _ => segExcl` (:6159), and
`segExcl := ⟨formula_conjList ([zXU,zUW,zWT].flatMap (fun zs => allTypes.map fun χ => if bits zs χ then ⊤ else (charBase χ).neg))⟩`
(:6149–6152). Because `charBase` is a complete 1-type characteristic (`nfPred_correct` bridge, used at
:6449/:6577; uniqueness `nf_eval_unique` NormalForm:245), any interior point `y` realizes exactly one
type `χ_y`, and `segExcl` holds at `y` **iff `χ_y` is fold-bit-positive in all three zones
simultaneously**. In the completeness antecedent `nf_eval_nf M 1 4 [x1,w,x,t] σ`, the fold
(`kvE_subBracket2_complete_extract` :6683–6719, via `nf_eval_depth1_fold_iff` :5187) guarantees only
that a `zXU`-realized point's type is `zXU`-positive — **not** `zUW`/`zWT`-positive. An interior point
of `(x, x1)` whose complete type occurs only below the anchor therefore has
`bits zUW χ_y = bits zWT χ_y = false`, making `segExcl`'s `zUW`/`zWT` conjuncts `(charBase χ_y).neg`
**false at `y`**, while the antecedent still holds. Hence the converse is a **false ∀-M statement**.
The recorded counterexample is correct.

**Obstruction 2 (fixed filter-order point types).**
`kvE_subBracket2.pointTypes := (leftSlots ++ uSlot :: rightSlots)[i.val]` (:6154), with `leftSlots`
(:6139) and `rightSlots` (:6142) built by `List.filter` over `Finset.univ.toList` — a **fixed
syntactic order**. `IntervalPattern.holds` requires strictly-monotone witnesses `x_0 < … < x_n` with
`alpha_i` at `x_i` **positionally** (:117, :121). The model order in which the realized types occur
need not equal filter order, so no monotone assignment exists in general. This is independent of
Obstruction 1 and independently fatal. It is the exact defect the k1v carrier avoids by ranging a
`VVecEA2` disjunction over **all arrangements** `S_L.permutations × S_R.permutations` (:2016–2017),
letting completeness select the model-sorted disjunct (`k1v_sorted_realization` :2797).

---

## Q2 — Can a correctly-shaped completeness statement close over the CURRENT carrier without redesign?

**No.** Two independent reasons, both machine-grounded.

**(i) The current carrier has the wrong codomain SHAPE.** `kvE_subBracket2` returns
`Σ m, BracketFormula (m + 1)` (:6123) — a **single** `IntervalPattern` — whose `.holds` is one
existential over positionally-typed monotone witnesses with constant segment type. The k1v template's
completeness (`bracketEndChar_k1v_complete` :2979 kit) is provable **only because** its carrier is a
`VVecEA2` — a finite **disjunction over arrangements** (`VVecEA2.holds = ∃ vea ∈ disjuncts, …`,
VecEAFormula:276; disjuncts built at :2013–2018) — with **per-side** segment types
(`bracketFromLists.segmentTypes = if i ≤ lL.length then segL else segR`, :1902) where `segL` excludes
**only** the `(x,w)`-zone negatives and `segR` **only** the `(w,t)`-zone negatives. Completeness then
(1) sorts the realized points into model order and names the matching arrangement disjunct
(`k1v_sorted_realization` :2797, `k1v_bracket_construct` :2838), and (2) discharges `segL`/`segR` on
each full side because every point of `(x,w)` is zone-positive there (`hsegL` :2852). Neither device
exists on the current single-bracket, constant-`segExcl` carrier. This is not a statement-shape issue
fixable by re-phrasing; the *object* is the wrong type.

**(ii) A gate-hypothesis rescue would TRIVIALIZE the deliverable.** One could, in principle, mirror
soundness by adding an explicit hypothesis absorbing the six `IntervalPattern.holds` obligations. But
soundness's gate (`kvE_subBracket2_sound` :6539) is legitimate precisely because there `.holds` is a
**hypothesis** and the bracket still contributes genuine content (the below-anchor `zXU` existence
witnesses, :6573–6586 — the Correction-1 signature datum). In completeness, `.holds` is the
**conclusion**; any hypothesis strong enough to make it provable would have to assert the monotone
positional realization + per-segment `segExcl` satisfaction — i.e. it would *be* the conclusion. That
is circular and delivers none of the task's required "IntervalPattern.holds data (Rabinovich Lemma
5.3, order-theoretic) + arrangement-disjunct closure — the k1v :2979 template re-derived at arity 4"
(deliverable 3). It would satisfy the letter of a `theorem` while vacuating its content — a prohibited
vacuous pattern in spirit. **Rejected.**

**Verdict**: completeness cannot be honestly stated/closed over the current carrier. The k1v template
is provable *because* it is an arrangement disjunction; `kvE_subBracket2` is not one.

---

## Q3 — Corrected target definition (if redesign unavoidable)

Redesign **is** unavoidable. Precise corrected shape, verified against Guards G1–G6 + Corrected
Anchor-Cap and against report 321 §2 (whose amended spec, :225, already declares the codomain
`VVecEA2` — the current `Σ m, BracketFormula` deviates from that binding spec):

**Corrected carrier `kvE_subBracket2V` (name at implementer discretion):**
- **Codomain**: `VVecEA2` (`Σ n, VecEA2 n` finite disjunction), replacing `Σ m, BracketFormula (m+1)`.
  Satisfies **G6** (codomain may be witness-growing `VVecEA2`) and report 321 :225. [structural]
- **Fixed endpoints**: `{x, t}` only; every disjunct's `VecEA2.holds` is at `(x,t)`. Satisfies **G4**
  (anchor set fixed at {x,t}) and **Corrected Anchor-Cap** (endpoint/anchor count ≤ 2). [G4/Cap]
- **Interior region structure — THREE regions, not two.** Unlike k1v (one interior zone per side of a
  single anchor `w`), the arity-4 env `[x1,w,x,t]` has **two** interior fixed references `x1` (the
  depth-1 anchor, realizing `charK (nfk_projFresh σ)`) and `w`, giving regions `(x,x1)=zXU`,
  `(x1,w)=zUW`, `(w,t)=zWT`. Both `x1` and `w` become **bracket witness slots** (not endpoints/anchors
  — so G4/Cap are respected; anchor count stays 2). Point-type layout per disjunct:
  `zXU-arrangement ++ [x1-slot] ++ zUW-arrangement ++ [w-slot] ++ zWT-arrangement`.
- **Per-region segment types (three)**: `segXU` excludes only `zXU`-negatives on `(x,x1)`; `segUW`
  only `zUW`-negatives on `(x1,w)`; `segWT` only `zWT`-negatives on `(w,t)`. `segmentTypes` keyed by
  slot index against the two interior anchor positions (the arity-4 lift of `bracketFromLists.` :1902,
  extended from a 2-way to a 3-way `if`). Satisfies **G3** (real exclusion segments, never top). Each
  region-segment is satisfiable in completeness because every point of that region is zone-positive
  there — the exact property Obstruction 1 violated with the constant tri-zone `segExcl`.
- **Disjuncts**: one per arrangement in `S_XU.permutations × S_UW.permutations × S_WT.permutations`
  (each `S_z = allTypes.filter (bits z ·)`), rule N5; gate-failure branch = empty disjunction `⟨[]⟩`
  (holds = False). Mirrors `bracketEndChar_k1v` :2013–2018. [G5/N5]
- **No provider pinning (F3)**: witness positions are the temporal-semantics-quantified bracket
  witnesses; no `w = e 1` / `x1 = e 0` residual equation. `w` enters as a witness *type* slot
  (`charBase` of `w`'s projection), realized by *some* point sorted between the zUW and zWT blocks —
  consistent with the given `w` by 1-type uniqueness. [F3]
- **G1/G2**: no arity-1 collapse, no projection third-anchor tower — the disjunction is a two-fixed-
  endpoint bracket with interior witnesses only. [G1/G2]

**Successor-parameterized compatibility (report 321 §2 Q1–Q3)**: the redesign must read `σ.2` at the
`j+1` successor shift (`σ : NormalForm sig (j+1) 4`, spec :56/:225); at `j=0` this is the landed
`NormalForm sig 1 4`. The `VVecEA2` codomain is exactly the spec's declared target, so the redesign
*converges* the carrier onto the amended spec rather than diverging further.

**Preserved-asset accounting (which Phase 1–5 assets survive):**

| Asset | Fate under redesign |
|-------|--------------------|
| `kvE_sub2_zoneHolds_cons_iff` :6615, `_zXU`/`_zUW`/`_zWT` :6642–6671 | **Survive near-verbatim** — pure `zoneHolds`↔inequalities over env `[x1,w,x,t]`, carrier-agnostic |
| `kvE_subBracket2_complete_extract` :6683 | **Survives near-verbatim** — reads `nf_eval_nf M 1 4`, independent of carrier; supplies the per-zone monotone witnesses the new disjunct closure consumes |
| `kvE_sub2_zXU/zUW/zWT` zone specs :6200–6209 | **Survive verbatim** — fold-bit zone specs, carrier-independent |
| `kvE_subBracket2_extract` :6233, `_reaches_z*` :6327–6381 | **Re-derived** — restated over `VVecEA2` disjunct `.holds` (destructure disjunction first, as `bracketEndChar_k1v_sound` :2352 does); proof shape survives, statement changes |
| `kvE_subBracket2_fold_z*` :6434–6491 | **Re-derived** — depend on `_reaches_z*` shape |
| `kvE_subBracket2_sound` :6530 | **Genuinely re-derived** — soundness is stated against the *current* single bracket; the redesign owns a fresh sound/complete pair over the new carrier (handoff `next_action_hint` confirms) |
| `kvE_subBracket2` / `kvE_subChain2` defs :6120/:6166 | **Replaced** (new separately-named `…V` defs; originals stay byte-identical, unreferenced) |

**Effort sizing**: the redesign is a **new carrier + full sound/complete pair** (soundness must be
re-derived because the landed `kvE_subBracket2_sound` binds the old single bracket). It re-uses the
k1v template kit (`k1v_sorted_realization`/`_insert`/`_bracket_construct`/`_bracket_extract`) one
arity up but with a **three-region** (vs two-region) arrangement — strictly more machinery than k1v
had. Realistic decomposition: (P1) `VVecEA2` carrier def + three per-region segment types + gate;
(P2) three-region `sorted_realization`/`bracket_construct` lift; (P3) soundness over the disjunction;
(P4) completeness (disjunct selection + per-region segment discharge). This is **4 one-dispatch
phases at minimum and plausibly 5**, each ~150–400 lines, plus the successor-parameter threading.
**It does not fit inside a Phase-6 continuation of task 324 — it is its own task.**

---

## Q4 — Recommendation

**(b) Finalize task 324 as PARTIAL (Phases 1–5 = the soundness deliverable) and spawn the carrier
redesign as its own task.**

Grounding:
- **Q1**: the completeness converse over the current carrier is a *false ∀-M statement* (two
  independent, machine-grounded obstructions). Re-dispatching Phase 6 against `kvE_subBracket2`
  cannot succeed sorry-free — confirmed by the handoff's `is_genuine_not_effort: true`.
- **Q2**: no correctly-shaped, non-vacuous completeness statement closes over the current carrier; the
  only honest completeness needs a `VVecEA2` arrangement-disjunction carrier (the k1v mechanism), and
  a gate-hypothesis rescue would trivialize the deliverable.
- **Q3**: the fix is a **codomain change** (`Σ m, BracketFormula` → `VVecEA2`) plus a **three-region**
  per-side-segment redesign that also forces re-derivation of soundness (the landed
  `kvE_subBracket2_sound` binds the old bracket). Phases 1–5's *reusable* order-theoretic kit
  (`complete_extract`, the `zoneHolds` lemmas, zone specs) survives near-verbatim, but the carrier and
  the correctness *pair* are re-derived — 4–5 one-dispatch phases. That exceeds a single Phase-6
  construction dispatch and matches the binding constraint "Phase-1 defects = blocker reports, not
  edits" (the codomain is a Phase-1 design decision).

Option (a) — re-dispatch Phase 6 over the current carrier with a corrected statement shape — is
**rejected**: there is no such shape that is both non-vacuous and satisfies deliverable 3 (Q2).

---

## Resolution Path

1. **Finalize task 324 as `[PARTIAL]`.** Phases 1–5 (commit `f77478f1c`, byte-identical, sorry-free,
   axiom-clean) stand as the **soundness deliverable**: `kvE_subBracket2` + kill-switch reachability
   kit + `kvE_subBracket2_sound` (:6530) + the completeness *extraction* kit
   (`kvE_subBracket2_complete_extract` :6683, which is reusable raw material, not the false converse).
2. **Spawn a redesign task** (`/spawn 324`) — "redesign the arity-4 sub-bracket into a `VVecEA2`
   arrangement-disjunction carrier with three per-region segment types (`segXU`/`segUW`/`segWT`) and
   two interior witness slots (`x1`, `w`); re-derive the full soundness/completeness pair over the new
   carrier." Carry forward: Guards G1–G6 + Corrected Anchor-Cap, Amendment F3, the successor-`j+1`
   spec (321/reports/01 §2), the k1v template kit (`:2028–2825`), and the preserved-asset table above.
   Forbidden: consuming `EANegation` :1090/:1249; editing landed Phase 1–5 code.
3. **Redesign phase skeleton** (owned by the new task): P1 carrier def + segments + gate; P2 three-
   region `sorted_realization`/`bracket_construct`; P3 soundness over the disjunction; P4 completeness
   (disjunct selection + per-region segment discharge). Re-use `kvE_subBracket2_complete_extract`
   :6683 and the `kvE_sub2_zoneHolds_*` lemmas near-verbatim.
4. **Then** resume task 321 via `/revise 321` to re-point Phase 8 at the redesigned carrier (already
   the documented post-completion step; unchanged).

**Do NOT** re-dispatch Phase 6 against `kvE_subBracket2`.

---

## Literature Proof Structure (Rabinovich Lemma 5.3 / Cor 5.4, Tier 1)

- **Lemma 5.3** (md:137–152): `¬∃ increasing x_1<…<x_n with each P_i(x_i)` ≡ V-∃∀ over Dedekind-
  complete chains, by induction on `n`, using `INF(z0,r0,z1,P1)` (r0 = inf of P1-points; exists by
  Dedekind completeness). The **key** is that each induction sub-case yields a *shorter interval* or
  *fewer predicates* — i.e. a **disjunction over cases/arrangements**, mirrored in Lean by the
  `VVecEA2` disjunction over `permutations`. The current single-bracket carrier has **no** disjunction,
  which is precisely why it cannot realize the Lemma-5.3 V-∃∀ structure — the formal root of both
  obstructions.
- **Cor 5.4** (md:154–157): `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`; bracket holds iff an
  increasing sequence with `F_0(z_0)` exists. The per-`β_i` Until-chaining is per-segment; encoding it
  faithfully requires per-region segment types (`segXU`/`segUW`/`segWT`), not a constant tri-zone
  `segExcl`.

---

## Memory Candidates

1. **Pattern (lean4, Kamp/VecEA)**: A completeness converse `(∃ witness, nf_eval) → carrier.holds`
   over an `IntervalPattern`-based carrier is provable **only** when the carrier is a `VVecEA2`
   disjunction over witness arrangements with **per-region** segment exclusions; a single
   `BracketFormula` with a constant multi-zone segment type is structurally incomplete (segment types
   must hold at every point of a segment, but a segment's points are only guaranteed positive in
   *their own* zone). Diagnostic: `segmentTypes := fun _ => <multi-zone conj>` is a completeness
   red flag.
2. **Verification technique**: To disprove a `∀ M` completeness claim, exhibit an interior point whose
   complete 1-type is single-zone-positive; the depth-1 fold (`nf_eval_depth1_fold_iff`) forces only
   *zone-membership ↔ fold-bit*, never cross-zone positivity, so such points always survive the
   antecedent.
