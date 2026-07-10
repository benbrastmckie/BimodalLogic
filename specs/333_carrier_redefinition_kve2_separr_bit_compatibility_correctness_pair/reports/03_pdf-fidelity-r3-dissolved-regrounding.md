# Research Report: PDF Fidelity, Breakthrough Ledger, and Post-342 Re-Grounding of Plan-02 (task 333)

- **Task**: 333 — carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair
- **Type**: lean4 (hard-mode, READ-ONLY re-grounding dispatch)
- **Session**: sess_1783659497_144c59
- **HEAD at research time**: `924d76c49` (Phase-1 child of snapshot `235d181ef`)
- **Date**: 2026-07-09
- **Sources of truth**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` (16 pp., cited by PAGE); `SharedWitness.lean` / `OuterGate.lean` / `SubBracket2V.lean` at HEAD `924d76c49` (cited by `file:line`).
- **Standards**: `.claude/rules/artifact-formats.md`, `.claude/context/formats/report-format.md`

## Summary (headline findings)

1. **The re-extracted `.md` is NOT safe to cite for any load-bearing formula content.** Confirmed and *worse* than the orchestrator's read: every displayed equation is dropped (Def 3.1 body → blank; formula (5.1) → blank), AND at least one inline negation is **semantically inverted** (`k ≠ m` rendered as `k = m`, md:199). Additionally, **89 in-code `md:NN` citations in `SharedWitness.lean` alone now dangle** (md:77 ×27, md:168 ×24, …) because today's .md replacement shifted every line — e.g. plan-02's H3 table cites `md:72`/`md:78` (now blank) and `md:77` (now "M,t ⊨ F1∨F2", a Boolean-connective clause, not Lemma 3.2(1)).

2. **The crux this lineage orbited (321→334→337) is DISSOLVED, not relocated** — corroborated by 337 report 08 ("Task 337 is UNBLOCKED post-342 … Every prior blocker … is dissolved by the landed 338/340/342 chain") AND now by direct code inspection.

3. **Plan-02's Phase 3 (R3) is the WRONG obligation.** R3 asks to *prove* the forward-zone conjunct `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true`. In current HEAD that conjunct is **never a goal** — it is uniformly the *antecedent* of a per-owner `bit ⟹ witness` implication (`kvE2_sepBundleL` SW:5117; `kvE_subBracket2V_extract` SubBracket2V:1041). The gate `kvE2_sepGate` (SW:1238) has four clauses **all concluding `= false`** — it never demands a bit be true. R3 is re-fighting the dissolved task-321 O4 crux.

4. **The genuinely open work is R2 (mechanical) and R4 (the true make-or-break).** R2's `Pairwise`/`Nodup` side-conditions match `kvE2_sepBody_extract`'s open hypotheses verbatim and are correctly stated. R4 (outer depth-2 fold) is where the real remaining difficulty lives.

5. **Recommendation: (iii) RESTRUCTURE.** Keep R1 (done) and R2 (unchanged). **Delete R3 as stated**; replace it with a small "apply the landed per-σ sound kit to each bundle" phase. Promote R4 to the make-or-break. Re-ground all citations to PDF page numbers and purge `md:NN`.

---

## Part A — Literature Fidelity (from the PDF, by page)

### Faithful transcriptions of the displayed formulas

**Definition 3.1 (⃗∃∀-formulas), p.4.** An ⃗∃∀-formula over Σ has the form:

```
ψ(z₀,…,z_m) := ∃x_n … ∃x₁∃x₀
    (⋀_{k=0}^{m} z_k = x_{i_k}) ∧ (x_n > x_{n-1} > ⋯ > x₁ > x₀)      -- "ordering of x_i and z_j"
  ∧ ⋀_{j=0}^{n} α_j(x_j)                                            -- "Each α_j holds at x_j"
  ∧ ⋀_{j=1}^{n} [(∀y)_{>x_{j-1}}^{<x_j} β_j(y)]                     -- "Each β_j holds along (x_{j-1},x_j)"
  ∧ (∀y)_{>x_n} β_{n+1}(y)                                          -- "β_{n+1} holds everywhere after x_n"
  ∧ (∀y)^{<x_0} β_0(y)                                              -- "β_0 holds everywhere before x_0"
```
with n+1 existential quantifiers, α_j, β_j quantifier-free with one variable over Σ, and **`i₀,…,i_m ∈ {0,…,n}` (NO distinctness requirement)**.

> **Load-bearing (confirms 342's ruling):** the witness chain `x_n > … > x_0` is **strict**; the pinning indices `i_k` carry **no distinctness**. Hence multiple free variables `z_k` may pin to the *same* strict witness `x_{i_k}` — the **tie-collapse is forced by Def 3.1**: coincident owners merge onto one strict slot whose type is the conjunction of the tied α's.

**Lemma 3.2, p.4** (prefaced verbatim by "**It is clear that**" — *no printed proof anywhere in 16 pp.*):
- (1) Conjunction of ⃗∃∀-formulas is equivalent to a disjunction of ⃗∃∀-formulas.
- (2) Every ⃗∃∀-formula is equivalent to a conjunction of ⃗∃∀-formulas with **at most two free variables**.
- (3) For every ⃗∃∀-formula φ, ∃xφ is equivalent to a ⃗∃∀-formula.

**Lemma 5.1, formula (5.1), p.7.** The negation of any formula of the form
```
∃x₀…∃x_n[(z₀ = x₀ < ⋯ < x_n = z₁) ∧ ⋀_{j=0}^{n} α_j(x_j) ∧ ⋀_{j=1}^{n}(∀y)_{>x_{j-1}}^{<x_j} β_j(y)]   (5.1)
```
where α_i, β_i are **quantifier-free**, is equivalent (over Dedekind complete chains) to a disjunction of ⃗∃∀-formulas.

> **Load-bearing:** formula (5.1) is **endpoint-anchored** (`z₀ = x₀`, `z₁ = x_n`) and contains **only** point types α_j (QF) and **open-interval** betweens β_j on `(x_{j-1}, x_j)`. There is **no** `β₀`/`β_{n+1}` (no "before"/"after" region, both ends pinned). This is the exact ground of the faithfulness constraint "QF point types (Lemma 5.1)".

**Notation 5.2, p.8.** `[α₀, β₁, …, α_{n-1}, β_n, α_n](z₀, z₁)` abbreviates the ⃗∃∀-formula (5.1): alternating point (α) / interval (β), anchored at `z₀=x₀`, `z₁=x_n`.

**Lemma 5.3, p.8.** `¬∃x₁…∃x_n (z₀ < x₁ < ⋯ < x_n < z₁) ∧ ⋀_{i=1}^{n} P_i(x_i)` is equivalent to a ∨⃗∃∀ formula `O_n(P₁,…,P_n,z₀,z₁)`. Basis: `¬(∃x₁)_{>z₀}^{<z₁} P₁(x₁) ≡ (∀y)_{>z₀}^{<z₁} ¬P₁(y)`. Inductive step uses **formula (5.2)**:
```
INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)_{>z₀}^{<r₀} ¬P₁(y) ∧ (P₁(r₀) ∨ 𝐊⁺(P₁)(r₀))   (5.2)
```

**Corollary 5.4, p.9** — the **fold representation** (this is what task 330 audited as the *correct* fold):
```
F_n     := α_n
F_{i-1} := α_{i-1} ∧ (β_i Until F_i)      for i = 1,…,n
```
"there is `z ∈ (z₀,z₁)` with `[α₀,β₁,α₁,…,α_n](z₀,z)` iff `F₀(z₀)` and there is an increasing sequence `x₁ < ⋯ < x_n` in `(z₀,z₁)` with `F_i(x_i)`." Lemma 5.1's 3-case split (p.9): Case 1 `¬α₀(z₀) ∨ 𝐊⁺(¬β₁)(z₀)`; Case 2 `α₀(z₀) ∧ β₁ holds along (z₀,z₁)`; Case 3 `α₀(z₀) ∧ ¬𝐊⁺(¬β₁)(z₀) ∧ ∃x∈(z₀,z₁) ¬β₁(x)`.

**Definition 7.5, p.13** — the **3-alternative** definition (NOT a half-open interval; corroborates 342):
> `z₀ > z₁`, **or** `z₀ = z₁`, **or** of the form `[α₀, β₁ …, β_{n-1}, α_{n-1}, β_n, α_n](z₀, z₁)`.

### Is the re-extracted `.md` faithful? — NO. Concrete corruption/loss list

| Location (.md line) | PDF ground truth (page) | Defect |
|---|---|---|
| md:109→110 | Def 3.1 body formula (p.4) | **DROPPED** — "…formula of the form:" then blank line; the entire ⃗∃∀ schema is gone |
| md:207→208 | formula (5.1) (p.7) | **DROPPED** — "…any formula of the form" then blank line; (5.1) is gone |
| md:199 | "in the second `k ≠ m`" (p.7) | **SEMANTIC INVERSION** — rendered "in the second `k = m`"; the `≠` is dropped, both cases read `k = m` |
| md:225 | Lemma 5.3 statement (p.8) | **SCRAMBLED** — `⋀_{i=1}^n P_i(x_i)` fused into "∧ⁿ i=1 Pi(xi)isequivalentoverDede-"; sub/superscript bounds collapsed |
| md:227 | Lemma 5.3 basis (p.8) | **SCRAMBLED** — `(∀y)_{>z₀}^{<z₁}` bounds rendered as "(∀y)<z >z1 0" |
| INF (5.2), Cor 5.4 folds `F_i` | pp.8–9 | **DROPPED/SCRAMBLED** (displayed equations) |
| ~89 `md:NN` anchors (see below) | — | Line-shift: every pre-2026-07-09 `md:NN` citation now points to different content |

**Verdict:** the `.md` is unsafe for any formula-level citation. Inline prose that survives (Notation 5.2 line 219, Def 7.5 line 407) is coincidentally intact because it is inline, but the paraphrase→extraction swap **shifted every line number**, so all `md:NN` anchors are unreliable regardless of content. The PDF (by page) is the only citable source. Use 342's mandated form for Lemma 3.2 / Def 3.1: *"the construction forced by Def 3.1 (p.4), corroborated by the k=m split (p.7) and Def 7.5 (p.13); Lemma 3.2(1) (p.4) states the closure without printed proof."*

> **Concrete grounding defect in current assets:** `SharedWitness.lean` carries **89 `md:NN` citations** (md:77 ×27, md:168 ×24, md:154 ×9, md:72 ×8, …). After today's .md replacement these dangle. Plan-02's H3 table (`plans/04…:61-63`) cites `md:72`/`md:77`/`md:78` — md:72 and md:78 are now **blank**, md:77 is now "M,t ⊨ F1∨F2 iff…". The good news: `kvE2_sepDisjValid`'s docstring (SW:~1755) already uses the robust **page-number** form ("Forced by Def 3.1 (p.4)… k=m split (p.7)… Def 7.5 (p.13)"); that citation is sound. Re-grounding should convert all `md:NN` to page numbers.

### H3 Source-to-Implementation Mapping (Tier 1 — re-grounded to PDF pages)

| Source claim | PDF location | Lean identifier (HEAD 924d76c49) | Status |
|---|---|---|---|
| Def 3.1: strict chain `x_n>…>x_0`, pinning `i_k` with **no distinctness** ⇒ tie-collapse forced | **p.4** | `KvE2SepSpikeOrderType` (SW:1258), `kvE2_sepDisjValid` conjunct (iv) `kvE2_sepTieRead` (SW:~1758) | GROUNDED (page-cited in code) |
| Lemma 3.2(1): conjunction ≡ disjunction of ⃗∃∀ — **stated, no printed proof** | **p.4** ("It is clear that") | `kvE2_sepArr'` / `kvE2_sepDisjValid` (per-order-type filter) | GROUNDED; do NOT quote a "proof of 3.2(1)" |
| Lemma 3.2(2): anchor cap 2 — ≤ two free variables | **p.4** | outer depth-2 fold over `(x,t)` (R4 target `kvE2_outer_fold`) | GROUNDED |
| Lemma 5.1 (5.1): QF point types, open-interval betweens, both ends pinned | **p.7** | `kvE2_sepPtX1L/R` point types = `charBase`/`charK (nfk_projFresh σ)`; no `fChainPred`, no nesting | GROUNDED (LITMUS active) |
| Cor 5.4 fold `F_{i-1}:=α_{i-1}∧(β_i Until F_i)` | **p.9** | navigated fold (task-330 verdict); `NavigatedSpine.lean` | GROUNDED |
| Def 7.5: 3-alternative `z₀>z₁ ∨ z₀=z₁ ∨ [bracket]` (NOT half-open) | **p.13** | tie-admitting validity, coincidence a first-class disjunct | GROUNDED |
| §5 ψ0/ψ1/φ split (interiority is a construction invariant) | **p.7** | `kvE2_sepPosI` (interior-restricted owner index, 222× in HEAD) | GROUNDED |

---

## Part B — Breakthrough Ledger

| Task | Blocking misconception | Structural insight that dissolved it | Key declaration(s) |
|---|---|---|---|
| **321** (F4 gate, PARTIAL) | The per-σ `hgate` forward-zone bit is *carrier-derivable* from realized segments; a bounded interior sub-witness can ride a flat single-point slot | Bounding a witness from above is a **structural bracket op** (Lemma 5.1 point-insertion), not a single-point assertion; the forward-zone conjunct dies at **cross-σ slot points** ("cross-σ order is free in `kvE2_sepSlotLe`") | O4 CRUX RECORD (SW:6588+, additive/inert); wall = `kvE_subBracket2V_sound_of_parts`'s `hx1t` |
| **330** (faithfulness audit) | Def 4.1 constant-arity E[Σ]-fold is the faithful normal form | Def 4.1 is an **alphabet expansion, not a fold**; the real fold (Cor 5.4, p.9) is **navigated** nested Until with QF point types; a static product loses the navigation coupling | Verdict REDESIGN → navigated carrier |
| **334** (carrier switch) | A joint single-point `mergeSort` realizes the arrangement; strict order suffices | Two owners' witnesses can **coincide** at a fresh anchor (`pt a = x1_σ`); the honest disjunct is the **COINCIDENCE (tie) order** reading the **CLOSED** `zAtX1L` bit, not a strict OPEN-bit disjunct | `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`; `kvE2_sepBody` rewired; strict `kvE2_sepModelOrder` abandoned |
| **337** (multi-owner engine) | `hLR` (all positives strictly interior) is faithful; global `Nodup` on payloads is needed | `hLR` is a **Lean artifact with no source counterpart** (`kvE2_sepHonest_hLR_absurd` falsifies it); merge is licensed by Def 3.1 + Lemma 3.2(1) equality cases, one **strict** slot per tie class | interior index `kvE2_sepPosI`; tie-admitting weak orders (ties = index-level only) |
| **339** (point-level merge) | "merged-chain-rank primary" is correct as written | Read literally that keeps each owner contiguous (block order, rank-insufficient); faithful reading is **region-rank PRIMARY, owner-rank SECONDARY** ⇒ genuinely interleaved single global chain | `kvE2_sepSlotsL/ROf` point-level `mergeSort` |
| **342** (interior + ties) | the `hLR` hypothesis; global-`Nodup` payload conjunct | interiority becomes a **construction invariant** (`kvE2_sepPosI`), never a hypothesis; global `Nodup` → **tie-admitting** validity: conjunct (iii)`Nodup` replaced by (iii′)`kvE2_sepAnchorDistinct` + (iv)`kvE2_sepTieRead`; point type = meet of tied types | `kvE2_sepPosI`, `kvE2_sepDisjValid` (tie form), `kvE2_sepBody_complete_holds'`; hLR deleted from 4 completeness theorems, guard retained |

### The recurring axis (named precisely)

**Strict-vs-coincident order, whose discriminator is the OPEN-zone-bit vs CLOSED-anchor-bit — and, structurally, whether the carrier is *allowed to represent* a coincidence as a first-class disjunct or is forced to an all-distinct strict chain.** Its deepest root, named across records: *"a property relating two independently-chosen points cannot be asserted by a single-point formula"* — coincident distinct-owner witnesses are exactly two independently-chosen points. Every task in the lineage is a re-encounter with this: 334's crux (open bit FALSE / closed bit TRUE at self-coincidence, SW:2360-2363), 337's completeness hole (global `Nodup` makes equality-case disjuncts unrepresentable), 342's fix (tie-admitting validity), and 321's residue (segment channel fires only on OPEN sub-intervals, misses the witness point). The resolution was uniform: **stop forcing strictness; represent the coincidence as its own Lemma-3.2(1) disjunct reading the closed key.**

### Crux status: DISSOLVED

337 report 08 (executive summary): *"Task 337 is UNBLOCKED post-342 … Every prior blocker (flat-arrangement non-realizability, block-granularity, per-slot value order, hLR vacuity, strict-tie unrealizability) is dissolved by the landed 338/340/342 chain … What remains … is genuine new proof construction, not a missing prerequisite; no new spawn is needed."* Part C confirms this at the code level for the **soundness** direction that task 333 owns.

---

## Part C — Re-Grounding the Remaining Work (against HEAD `924d76c49`)

### C.1 — R3 (`kvE2_sepDisjValidOwner ⟹` forward-zone `hgate` conjunct): the WRONG obligation

**Finding: R3 as stated targets a goal that does not exist in the live chain.** Evidence:

- `kvE2_sepDisjValidOwner σ` (SW:1733) reads **σ's OWN fresh type**: `.strictBefore ↦ kvE2_sepBits σ kvE_sub2_zXU (nf0_projFresh σ.1)`, `.strictAfter ↦ zUW`, `.coincident ↦ kvE2_sepClosedLeafStub σ`. It carries **no** bit about a cross-owner χ.
- The forward-zone conjunct `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` occurs live at exactly three sites (SW:5117, SW:5175, SW:5289) — in **every** one it is the **antecedent** of an implication, never a goal:
  - `kvE2_sepBundleL` (SW:5110): `… ∧ (∀ χ, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true → ∃ u, x<u ∧ u<x1 ∧ ⟨charBase χ⟩.eval_at M atomMap u)`.
  - `kvE2_sepBundleL_parts` (SW:5167) passes it through unchanged; docstring: "yields **EXACTLY** the `kvE_subBracket2V_sound_of_parts` input 5-tuple."
- `kvE_subBracket2V_extract` (SubBracket2V:1027) — the engine under the sound kit — takes `.holds` and **produces** the same `bit ⟹ witness` shape; the bit is instantiated only via the carrier's **own** arrangement enumeration (`List.mem_filter.mpr ⟨_, hbit⟩`, SubBracket2V:~1063), i.e. self-owned, never cross-σ.
- `kvE2_sepGate` (SW:1238) has **four clauses, all concluding `= false`** (off-fiber, outer-inconsistent, off-anchor, inner-inconsistent-zone). No clause demands any bit be `true`. So "prove the forward-zone bit true" is not a gate obligation and never was, post-334.
- `kvE2_sepBody_extract` (SW:6328) is **landed and sorry-free** (file has 3 total `sorry` hits, all in comments/prose; none in the extract body). It already *produces* `kvE2_sepBundleL`/`kvE2_sepBundleR` — so the witness-finding that the old O4 crux thought impossible is already discharged inside it, via `kvE2_sepDisjunct_extract` (SW:6167).

**Why the old crux dissolved:** the pre-334 flat single-point carrier conflated positions, so a foreign owner τ's χ-witness landing in σ's `zXU` zone appeared to *demand* proving σ's bit true (the goal `⊢ σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` at SW:6560). The 334/342 per-order-type + interior-restricted + tie-admitting arrangement makes each owner's slots its own and handles cross-owner placement through `kvE2_sepDisjValid`'s consistency conjuncts (ii `kvE2_sepConsistentBlock`, iii′ `kvE2_sepAnchorDistinct`, iv `kvE2_sepTieRead`) — **without** ever imposing a bit obligation on the wrong owner. Cross-σ points are just other owners' witnesses; σ's realization does not require them to satisfy σ's bit.

### C.2 — What SW:6556 ("`kvE2_sepSlotLe` leaves cross-σ order free") means for R3

`kvE2_sepSlotLe` (SW:1034) is a **pure Bool comparator**. It genuinely does not constrain cross-σ order — **and that is the intended design post-342, not a bug.** The comment at SW:6556 sits **inside the task-321-v7 Phase-9 O4 CRUX RECORD**, which is explicitly annotated *"This is NOT a route NO-GO … This record is additive and inert."* Immediately below it (SW:6644+) is the **task-334 make-or-break spike** that abandons the additive-filter framing the crux assumed. The cross-σ ordering is now pinned not by the comparator but by **which weak orders `wo` are admitted into `kvE2_sepArr'`** (via `kvE2_sepDisjValid`). So SW:6556 is a **stale description of a since-resolved obstruction**; it should not be read as a live defect.

> Direct answer to the orchestrator's question: cross-σ order freedom in `kvE2_sepSlotLe` is **the intended design post-342**, not a residual arrangement-blind bug. Arrangement-awareness moved from the comparator into the validity filter.

### C.3 — R2 (`Pairwise`/`Nodup` side-conditions): correctly stated, genuinely open

`kvE2_sepBody_extract` (SW:6328) has exactly these open hypotheses:
```
(hpairL : ∀ wo ∈ kvE2_sepArr' qnf, (kvE2_sepSlotsLOf wo).Pairwise (fun a b => kvE2_sepSlotLe a b = true))
(hpairR : ∀ wo ∈ kvE2_sepArr' qnf, (kvE2_sepSlotsROf wo).Pairwise (fun a b => kvE2_sepSlotLe a b = true))
(hnd    : ∀ wo ∈ kvE2_sepArr' qnf, ((kvE2_sepSlotsLOf wo).map (kvE2_sepSlotGIdx wo)).Nodup ∧ ((kvE2_sepSlotsROf wo).map (kvE2_sepSlotGIdx wo)).Nodup)
```
R2 (plan-02 Phase 2) matches these **verbatim** and is correctly scoped. The landed lemmas do **not** already discharge them: `kvE2_sepSlotsLFor_rank_sorted` (SW:745) is per-σ (For-list), not the merged `Of`-list over arbitrary `wo`; `kvE2_sepSlotsLOf_nodup` (SW:4299) is `Nodup` of the slots, not of `.map kvE2_sepSlotGIdx`. So R2 is genuine, mechanical, and correctly stated. **KEEP unchanged.**

### C.4 — R4 (`kvE2_outer_fold`): correctly identified, and the TRUE make-or-break

No landed depth-2 quant-layer fold exists (`nf_quant_layer_fold_iff`, `NfEFold.lean:391`, folds depth-0 subs; the k=2 layer ranges over depth-1 subs). R4 must assemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ realizations. Both `kvE2_sepBundleL_parts` (SW:5167) and `kvE2_sepBundleR_parts` (SW:5184) already reduce a bundle to the `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1025) input, so applying the per-σ kit is near-mechanical; **the open difficulty is the outer `∃ w` fold**, which plan-02 already flags (Risk-MEDIUM, `NavigatedSpine.lean:445` sketch). This — not R3 — is the make-or-break.

### C.5 — Task 335's ⇒ obligation

`OuterGate.lean:180-203` records 335's ⇒ half (`.holds ⟹ ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`) as **BLOCKED**, citing the **same task-321 O4 CRUX RECORD** as its "Root obstruction (LANDED, machine-checked)" and citing a **missing authorization** to edit the carrier. **Both grounds are stale:** (a) the O4 crux is dissolved (C.1); (b) plan-02's Territory Contract (`plans/04…:75-82`) already GRANTS 335 authorization to consume additive R2–R4 lemmas, and no carrier edit is needed. 335's real remaining need is exactly "R2 + R4 landed and shaped for its consumer" — which is what task 333 delivers. The obligation matches, split across files: R4's `kvE2_outer_fold` (SharedWitness) is wrapped by 335's `bracketEndChar_kvE2_sound_two_prior` (OuterGate). 335 should be updated: its blocker is not a crux but an un-landed prerequisite (333 R2/R4).

### hLR sanity (challenge of established fact 4)

Established fact 4 said "hLR was deleted." Precisely: hLR is deleted as a hypothesis from the four completeness theorems; the only surviving `hLR :` binder is `kvE2_sepHonest_hLR_absurd` (SW:5714), the **retained design-guard** that takes hLR and derives `False`. No completeness regression. (16 raw `hLR` hits = this guard + prose.)

---

## Adversarial Self-Verification (H4)

**Central conclusion challenged:** "R3-as-stated is dissolved; the forward-zone conjunct is never a goal."

**Refutation attempt 1 — maybe the gate hides a bit=true goal.** Checked `kvE2_sepGate` (SW:1238): all four clauses conclude `= false`. In `kvE2_sepBody_extract` the gate is discharged by `by_cases hg`; the false branch makes `.holds` vacuous (`kvE2_sepBody_gate_fail`). **Refutation fails** — no hidden bit-true goal.

**Refutation attempt 2 — maybe the bundle's `∀χ` antecedent is vacuous, hiding the real work elsewhere.** Even if the antecedent were rarely satisfied, `kvE2_sepBody_extract` is a landed sorry-free theorem that *produces* the bundle for arbitrary realized models; the cross-σ content is handled by `kvE2_sepDisjunct_extract` + the arrangement consistency conjuncts, not by a bit-proof. **Refutation fails** — the R3 conclusion is unaffected.

**Refutation attempt 3 — maybe the right-interior class lacks a kit, resurrecting a real obligation R3 was gesturing at.** The `kvE2_sepBundleR` docstring (SW:5138) carries a Phase-7-era note "no landed per-σ correctness kit serves this class yet." But `kvE2_sepBundleR_parts` (SW:5184) exists and targets the **same** `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1025) as the left class. **Partial residual, not a refutation:** the right-class kit *application* should be verified during R-restructure; it does not revive R3's "prove the bit true" goal. Flagged as a MEDIUM watch item below.

**Claim Verification Table**

| Claim | Verification method | Confidence |
|---|---|---|
| .md drops Def 3.1 body & formula (5.1); inverts `k≠m`→`k=m` | `grep`/`sed` on .md vs PDF pages 4,7 (image-read) | **High** |
| 89 `md:NN` citations in SharedWitness now dangle | `grep -oE 'md:[0-9]+'` count + sed on md:72/77/78 | **High** |
| `kvE2_sepDisjValidOwner` reads σ's OWN fresh type | `lean`/`sed` read of SW:1733-1738 | **High** |
| forward-zone conjunct is antecedent-only (3 live sites) | `grep 'nf0_assemble kvE_sub2_zXU'` + read SW:5110-5135, 5289 | **High** |
| `kvE2_sepGate` = 4 falsity clauses (no bit-true goal) | read SW:1238-1246 | **High** |
| `kvE2_sepBody_extract` landed sorry-free, produces bundles | grep sorry (3 total, comments) + read SW:6328-6362 | **High** |
| SubBracket2V kit consumes `bit⟹witness`, self-owned bit | read SubBracket2V:1027-1075 | **High** |
| SW:6556 comment is inside inert task-321 crux record | read SW:6534-6642 | **High** |
| R2 hypotheses match `kvE2_sepBody_extract` verbatim | read SW:6331-6340 | **High** |
| Crux "DISSOLVED" per 337 report 08 | agent-read record quote (secondary source) | **Medium** |
| Right-interior kit application fully lands | `kvE2_sepBundleR_parts` exists (SW:5184); not exercised | **Medium** |

**Contradiction log:** Plan-02 and OuterGate:180-203 both assert the O4 crux is a *live* root obstruction; direct code inspection contradicts this. Resolution (precedence: live code > prose record): the crux record is task-321-vintage and self-annotated "additive and inert"; the live architecture (334/342) supersedes it. **Resolved — no unresolved contradiction.**

---

## Part D — Recommendation

**Verdict: (iii) RESTRUCTURE plan-02.** R3 as stated is the wrong obligation; the make-or-break has moved to R4. Concrete phase-sized ordered plan:

1. **P0 (grounding fix, ~0.5 h).** Re-cite plan-02's H3 table and the load-bearing SharedWitness docstrings from `md:NN` to **PDF page numbers** (use 342's mandated form for Def 3.1 / Lemma 3.2). Do NOT cite the `.md` for any formula. (This is a doc/plan edit; if code docstrings are touched it stays additive/comment-only.)
2. **P1 — R1 (DONE, committed `924d76c49`).** Correct; no action.
3. **P2 — R2 side-conditions (UNCHANGED, mechanical, ~2-3 h).** Prove `hpairL`/`hpairR`/`hnd` over arbitrary `wo ∈ kvE2_sepArr' qnf` (verbatim shape at SW:6331-6340). Low risk.
4. **P3 — per-σ realization (NEW, REPLACES R3, ~1-2 h).** Thread `kvE2_sepBody_extract`'s bundles through `kvE2_sepBundleL_parts` (SW:5167) / `kvE2_sepBundleR_parts` (SW:5184) into `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1025) to obtain each positive owner's `nf_eval`. **Verify the right-interior class kit application lands** (the one genuine residual; MEDIUM). This is *not* a bit-proof and *not* a make-or-break.
5. **P4 — R4 outer depth-2 fold (THE MAKE-OR-BREAK, ~3-4 h, split if >300 lines).** Assemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ realizations via `ExistProviders.correct` + the `NavigatedSpine.lean:445` navigated sub-chain. If the fold has no viable route, `/spawn` a scoped depth-2 quant-layer-fold research task — do NOT fabricate.
6. **Follow-on (task 335).** Update 335's BLOCKED record: its cited O4-crux root obstruction is stale and its authorization concern is resolved by plan-02's Territory Contract. Its real prerequisite is 333's R2+R4; once landed, `bracketEndChar_kvE2_sound_two_prior` wraps `kvE2_outer_fold`.

**The true make-or-break:** the **R4 outer depth-2 fold** (P4). Not R3.

**Plainly stated (the most valuable finding):** *The crux this lineage orbited from task 321 — "the cross-σ forward-zone `hgate` conjunct is underdetermined by the carrier" — has been genuinely DISSOLVED by 334 (per-order-type validity) + 337/342 (interior-restricted index + tie-admitting weak orders). In current HEAD that conjunct is never a proof goal; it is the antecedent of a per-owner `bit ⟹ witness` implication that the landed, sorry-free `kvE2_sepBody_extract` already discharges. Plan-02's R3 — and task 335's BLOCKED record — are both re-fighting a battle that the carrier rework already won.*

### Binding-constraint compliance
QF point types (Lemma 5.1, p.7) honored in the H3 map; no filter weakened; anchor cap 2 (Lemma 3.2(2), p.4) preserved as the R4 target; no-nesting / LITMUS respected (no `x1 < e_i`, no `fChainPred` introduced — this was a read-only audit); zero-debt (no `sorry`/axiom recommended). No `Theories/` file edited.

## Memory Candidates

1. **When a "prove-the-bit-true" obligation persists across a carrier rework, check whether the bit became an *antecedent*.** In this lineage the forward-zone conjunct flipped from goal (pre-334) to the antecedent of a `bit ⟹ witness` bundle (post-342); the "hard" obligation dissolved by restructuring, not by a new proof. (keywords: lean4, soundness-extraction, antecedent-vs-goal, carrier-rework)
2. **Crux records embedded in source are timestamped artifacts; verify "additive/inert" annotations before treating them as live.** The SW:6556 O4 record misled two downstream plans (333 R3, 335 block) despite self-annotating "inert." (keywords: lean4, crux-record, staleness, provenance)
3. **A literature `.md` re-extraction can silently invert inline logic (`k≠m`→`k=m`) and shift every line number, dangling all `md:NN` citations.** Prefer page-number citations to line-number citations for PDF-sourced ground truth. (keywords: literature, citation-hygiene, pdf-extraction, page-vs-line)
