# Rabinovich Fidelity Audit — Task 342 Design (Parts I & II)

**Task**: 342 — rework kvE2_sep arrangement carrier with interior-restricted owner index and tie-admitting weak orders
**Session**: sess_1783617988_38e7cf
**Agent**: lean-research-hard-agent (H2+H3+H4+H5)
**Source of truth**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
(16 pp., extracted page-by-page via `pdftotext`; all pages 1–16 inspected). The companion `.md`
in the same directory is a hand-written paraphrase and was NOT used for any load-bearing claim
(see Divergence Table, rows D5–D6, for why).

---

## Verdict

**The task-342 design is FAITHFUL to Rabinovich 2014, with one citation-level correction required.**

- **Part I (interior-restricted owner index `kvE2_sepPosI`) is FULLY GROUNDED, verbatim, in
  Section 5 (p.7).** The ψ0/ψ1/φ split is exactly as the task states: non-interior witnesses are
  routed to one-free-variable formulas that become atomic E[Σ] endpoint content via Prop. 3.5
  (p.5), and interiority of φ's proper witnesses is a construction invariant of the strict chain
  with pinned endpoints — never a hypothesis on realized types. `hLR` has no counterpart in the
  paper; removing it in favor of a construction-level interior restriction is the faithful move.

- **Part II (tie-admitting order-type index with meet-folded strict disjuncts) is FAITHFUL IN
  SUBSTANCE but its citation must be corrected.** The paper states Lemma 3.2 with the preface
  "It is clear that" and prints **no proof anywhere in the 16 pages** (verified: pp.1–16 all
  extracted; the only other reference to 3.2 is Lemma 3.4's proof on p.5, which *uses* 3.2(1)/(3)).
  Therefore the specific tie-collapse mechanism ("tied witnesses collapse to ONE strict slot whose
  point type is the CONJUNCTION of the tied types, as a separate disjunct") **cannot be quoted from
  a proof text**. It is instead **forced by Definition 3.1** (the strict chain admits no equal
  witnesses, and a coincident point must satisfy both α's, so the merged slot type must be the
  conjunction — no other Def-3.1-conformant encoding of a realized coincidence exists), and it is
  **corroborated by three printed passages**: (i) Def 3.1's pinning indices `i_0,…,i_m ∈ {0,…,n}`
  carry no distinctness requirement, so multiple variables may legally share one slot; (ii) the
  `k = m` case split (p.7) resolves a coincident pinning through a single shared slot and emits the
  equality case `z0 = z1` as a first-class order-type disjunct; (iii) Def 7.5 (p.13) admits
  `z0 = z1` as a degenerate `(z0,z1)`-∃∀ formula. Future artifacts must cite Part II as
  *"the construction forced by Def 3.1 (p.4), corroborated by the k=m split (p.7) and Def 7.5
  (p.13); Lemma 3.2(1) (p.4) states the closure without printed proof"* — not as the content of a
  proof of Lemma 3.2(1).

- The machine-certified defect (honest tie models realize no disjunct under the `Nodup` conjunct,
  SW:1350–1354) independently establishes that equality cases are **necessary** for completeness:
  omitting them is refuted inside Lean regardless of the paper's silence.

- **Def 7.13 (p.15) is confirmed NOT to license coincidence merging** — it is segment-wise
  conjunction between *distinct* reference variables, exactly as the task states.

- No constraint violations are proposed: `IntervalPattern.holds` strict monotonicity
  (Kamp/ExistsForallNF.lean:106–132) is untouched and is verified below to transcribe Def 3.1's
  strict chain exactly; the LITMUS (NavigatedSpine.lean:437) is respected (witness bounds come from
  the bracket's own range in `IntervalPattern.holds`, lines 119–120); `kvE2_sepHonest_hLR_absurd`
  (SW:4618) is retained verbatim as design guard; the rejected `wo`-over-all-of-`kvE2_sepPos`
  alternative is not resurrected.

---

## Findings

### H3 Lemma-Level Mapping Table (Tier 1, literature-backed)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| Rabinovich 2014 | Def 3.1, p.4 (strict chain `xn > … > x0`, `∀ i j, i < j → strict`) | `IntervalPattern.holds` (Kamp/ExistsForallNF.lean:106–132) | `∃ witnesses : Fin (n+1) → M.carrier, (∀ i j, i < j → witnesses i < witnesses j) ∧ …` | transcribed — SOURCE-MANDATED, do not weaken |
| Rabinovich 2014 | Def 3.1, p.4 (pinned free variables `z_k = x_{i_k}`) | endpoint pinning in `kvE2_sepBracketN` / `VecEA2` (SW:1009ff; endpoints fixed, interior slots existential) | `BracketFormula (lL.length + 1 + lR.length)` with fixed endpoint predicates | transcribed |
| Rabinovich 2014 | §5 ψ0/ψ1/φ split, p.7 | `kvE2_sepPosI` (proposed; building block `kvE2_sepPosIn` exists, SW:199) | `(kvE2_sepPos qnf).filter (fun σ => decide (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3))` | pending |
| Rabinovich 2014 | §5 + Prop 3.5, pp.5,7 (non-interior → atomic E[Σ] endpoint content) | `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR` (SW:886–946), bits via `kvE2_sepHasPos` (SW:207) | endpoint literal conjunctions over `kvE2_sepLit` biconditional (SW:173) | transcribed (existing); endpoint/pivot honesty lemmas pending |
| Rabinovich 2014 | Lemma 3.2(1), p.4 — **statement only, no printed proof**; mechanism forced by Def 3.1 | `kvE2_sepTieGroupedL/R` + meet-folded disjunct builder (successor of `kvE2_sepDisjunct`, SW:1020) | tie class ↦ one slot with `formula_conjList (class.map (kvE2_sepSlotType charBase charK))` | pending |
| Rabinovich 2014 | Lemma 3.2(1) equality cases (necessity: machine-certified, see below) | `kvE2_sepDisjValid` conjunct (iii) (SW:1350–1354) | `decide (wo.flatMap (fun p => p.2.2)).Nodup` | DEFECTIVE — replace with anchor-distinct + ordered nonempty tie classes |
| Rabinovich 2014 | Def 7.13 + Lemma 7.14, p.15 (segment-wise conjunction, distinct variables) | outer `x < w < t` segmentation of `kvE2_sepBody` (SW:1645) | per-interval bracket conjunction | transcribed — confirmed NOT a merge license |
| Rabinovich 2014 | (no counterpart anywhere in paper) | `kvE2_sepHonest_hLR_absurd` (SW:4618) | `… (hLR : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) : False` | transcribed — RETAIN verbatim as permanent design guard |

### 1. Definition 3.1 (p.4) — verbatim

> "Definition 3.1 (∃⃗∀-formulas). Let Σ be a set of monadic predicate names. An ∃⃗∀-formula over Σ
> is a formula of the form:
> ψ(z0, . . . , zm) := ∃xn . . . ∃x1 ∃x0
> ⋀_{k=0}^{m} z_k = x_{i_k} ∧ (xn > xn−1 > · · · > x1 > x0) "ordering of xi and zj"
> ∧ ⋀_{j=0}^{n} αj(xj) "Each αj holds at xj"
> ∧ ⋀_{j=1}^{n} [(∀y)^{<xj}_{>xj−1} βj(y)] "Each βj holds along (xj−1, xj)"
> ∧ (∀y)_{>xn} βn+1(y) "βn+1 holds everywhere after xn"
> ∧ (∀y)_{<x0} β0(y) "β0 holds everywhere before x0"
> with a prefix of n + 1 existential quantifiers and with all αj, βj quantifier free formulas with
> one variable over Σ, and i0, . . . , im ∈ {0, . . . , n}."

**Confirmed**: the witness chain is STRICT (`xn > xn−1 > · · · > x1 > x0`); free variables are
pinned as `z_k = x_{i_k}`; the quantifier prefix is `∃xn . . . ∃x1 ∃x0`. **Additionally**: the
indices `i_0, …, i_m` range over `{0,…,n}` with *no distinctness requirement* — the definition
itself legalizes multiple free variables sharing a single strict slot. This is direct textual
evidence for the collapse-to-one-slot representation of coincidences.

`IntervalPattern.holds` (Kamp/ExistsForallNF.lean:106–132) transcribes this exactly: strictly
increasing witnesses (`∀ i j, i < j → witnesses i < witnesses j`), all witnesses inside
`(z0, z1)` (the bracket's OWN range — LITMUS-compliant), α's at witnesses, β's on the open
segments. Weakening the monotonicity to `≤` would diverge from Def 3.1 and is correctly forbidden.

### 2. Lemma 3.2(1) (p.4) and "its proof" — the pivotal finding

Verbatim (p.4):

> "It is clear that
> Lemma 3.2.
> (1) Conjunction of ∃⃗∀-formulas is equivalent to a disjunction of ∃⃗∀-formulas.
> (2) Every ∃⃗∀-formula is equivalent to a conjunction of ∃⃗∀-formulas with at most two free
> variables.
> (3) For every ∃⃗∀-formula ϕ the formula ∃xϕ is equivalent to a ∃⃗∀-formula."

**There is no proof of Lemma 3.2 anywhere in the paper.** The statement is prefaced "It is clear
that". All 16 pages were extracted and inspected; the only other occurrence of "3.2" is in the
proof of Lemma 3.4 (p.5): "By (1) and (3) of Lemma 3.2, and distributivity of ∃ over ∨." — a
*use*, not a proof — and in Proposition 4.3's Negation case (p.6), again a use of 3.2(2).

**Consequence for the task's PART II claim.** The task description asserts, as Rabinovich
grounding, that Lemma 3.2(1) works "via disjunction over order types of combined witnesses
INCLUDING equality cases: tied witnesses collapse to ONE strict slot whose point type is the
CONJUNCTION (meet) of the tied types, as a separate disjunct." This mechanism is **not printed in
the paper** and therefore cannot be "verified against the actual proof text" — there is no proof
text. This is a citation defect in the task description (Divergence D1 below), NOT a design
defect, because the mechanism is the unique construction compatible with Def 3.1:

- *Necessity of order-type disjunction*: a joint model of ψ ∧ ψ′ realizes both witness chains;
  the union of the realized witnesses, ordered by the model, falls into exactly one relative
  order type — a shuffle of the two chains in which coincidences may occur. A single Def-3.1
  formula fixes one such order type (its chain is one fixed strict sequence), so capturing all
  models requires one disjunct per order type.
- *Necessity of the equality cases*: nothing in the semantics prevents a witness of ψ from
  coinciding with a witness of ψ′ (only witnesses *within* one formula are strictly ordered).
  A disjunction ranging only over strict interleavings has no disjunct true in such a model.
  This is not merely abstract: it is **machine-certified in this codebase** — the `Nodup`
  conjunct (SW:1350–1354) makes tie order types unrepresentable, and honest tie models
  (base–base; base–foreign-anchor, cycle-8 "resolution (a) is FALSE") realize no disjunct.
- *Necessity of collapse-with-conjunction*: within one disjunct the chain is strict
  (`xn > … > x0`), so a coincidence cannot occupy two slots; the single shared slot's point
  formula must hold at a point where both original α's hold, and conversely must entail both —
  hence it is exactly their conjunction (α's are quantifier-free, so the conjunction is again a
  legal quantifier-free point type). Overlapping interval formulas conjoin for the same reason.
- *Printed corroboration*: (i) Def 3.1's non-distinct pinning indices (§1 above); (ii) the
  `k = m` case split, p.7, quoted verbatim below in §3a — coincident pinning is handled through
  ONE slot (`∃x0 [z0 = x0 ∧ z1 = x0 ∧ …]`) and the order types of `(z0, z1)` INCLUDING equality
  are enumerated as separate disjuncts; (iii) Def 7.5 (p.13), quoted in §4, admits `z0 = z1` as a
  first-class `(z0,z1)`-∃⃗∀ formula alternative.

**Refutation check requested by the dispatch** ("if the proof handles ties by a different
mechanism … report that as a REFUTATION"): no alternative mechanism exists in the paper to
refute against — the paper is silent. The silence itself is the reportable fact. The proposed
mechanism is NOT refuted; it is the unique Def-3.1-conformant construction, and no passage of the
paper is inconsistent with it.

**Terminology caution for the planner**: "tie-admitting weak orders" must remain a property of
the *enumeration index datum* (which slots coincide). The *emitted formula* of every disjunct
must remain a strict Def-3.1 bracket over the quotient (one slot per tie class, conjoined point
type). Report 07 §4 and the task description both specify exactly this (per-owner slot lists
unchanged; folding in the disjunct builder; `IntervalPattern.holds` untouched) — faithful. Any
drift toward weakening the bracket semantics itself to `≤` would be an infidelity.

### 3. Section 5 (p.7) — verbatim, and the k=m split

The section opens with ψ(z0, z1) in the Def 3.1 shape, then (verbatim):

> "We consider two cases. In the first case k = m, i.e., z0 = z1 and in the second k ≠ m."

**(a) k = m case** (verbatim):

> "If k = m, then ψ is equivalent to z0 = z1 ∧ ψ′(z0), where ψ′ is an ∃⃗∀-formula. By
> Proposition 3.5, ψ′ is equivalent to an TL(Until, Since) formula A′. Therefore, ψ is equivalent
> to an ∃⃗∀-formula ∃x0 [z0 = x0 ∧ z1 = x0 ∧ A′(x0)], and ¬ψ is equivalent to a ∨∃⃗∀ formula
> z0 < z1 ∨ z1 < z0 ∨ ∃x0 [z0 = x0 ∧ z1 = x0 ∧ ¬A′(x0)]."

Two variables pinned to the same slot are resolved through a SINGLE shared slot, and the
negation enumerates the three order types of `(z0, z1)` — `<`, `>`, `=` — as separate disjuncts.
The equality order type is first-class and printed.

**(b) k ≠ m case (the ψ0/ψ1/φ split)** — verbatim (with m < k w.l.o.g.):

> "Hence, ψ is equivalent to a conjunction of
> (1) ψ0(z0) defined as: ∃x0 . . . ∃xm−1 ∃xm [z0 = xm ∧ (x0 < x1 < · · · < xm) ∧ ⋀_{j=0}^{m} αj(xj)
>     ∧ ⋀_{j=1}^{m} (∀y)^{<xj}_{>xj−1} βj(y) ∧ (∀y)_{<x0} β0(y)]
> (2) ψ1(z1) defined as: ∃xk . . . ∃xk+1 ∃xn [z1 = xk ∧ (xk < xk+1 < · · · < xn) ∧ ⋀_{j=k}^{n} αj(xj)
>     ∧ ⋀_{j=k+1}^{n} (∀y)^{<xj}_{>xj−1} βj(y) ∧ (∀y)_{>xn} βn+1(y)]
> (3) ϕ(z0, z1) defined as: ∃xm . . . ∃xk [(z0 = xm < xm+1 < · · · < xk = z1) ∧ ⋀_{j=m}^{k} αj(xj)
>     ∧ ⋀_{j=m+1}^{k} (∀y)^{<xj}_{>xj−1} βj(y)]
> The first two formulas are ∃⃗∀-formulas with one free variable. Therefore, (by Proposition 3.5)
> they are equivalent to TL(Until, Since) formulas (in the signature E[Σ]). Hence, their negations
> are equivalent (over the canonical expansions) to atomic (and hence to ∃⃗∀) formulas."

**Both dispatch questions answered affirmatively, verbatim:**

- *Are non-interior witnesses genuinely routed to ATOMIC E[Σ] endpoint content via Prop 3.5?*
  **YES.** Witnesses below the lower pinned point (x0…xm−1, with the left tail β0) live in ψ0(z0);
  witnesses above the upper pinned point (xk+1…xn, with the right tail βn+1) live in ψ1(z1); each
  is a one-free-variable ∃⃗∀-formula sent to a TL formula by Prop 3.5, hence to atomic E[Σ]
  content in the canonical expansion (Def 4.1, p.5; and p.6: "if A is a TL(Until, Since) formula
  over E[Σ] predicates, then it is equivalent … to an atomic formula in the canonical
  TL(Until, Since)-expansions").
- *Is interiority a CONSTRUCTION INVARIANT of φ rather than a hypothesis on realized types?*
  **YES.** φ's chain is `z0 = xm < xm+1 < · · · < xk = z1` with both endpoints pinned; the proper
  witnesses xm+1,…,xk−1 satisfy `z0 < xj < z1` definitionally, by the strict chain — no
  hypothesis anywhere in the section restricts which types may be realized. There is no analogue
  of `hLR` in the paper.

**PART I verdict: FOUNDED.** The sole justification claimed for Part I is exactly what the paper
says. The Lean transposition — restrict the bracket's owner index to interior-zone owners by an
order-preserving filter (`kvE2_sepPosI`), route boundary classes zAtX3/zAtW3/zAtT3 (and
zPastX3/zFutT3) through the existing endpoint/pivot literals `kvE2_sepEpL`/`kvE2_sepPtW`/
`kvE2_sepEpR` with honest `kvE2_sepHasPos` bits — is the ψ0/ψ1/φ split at the owner-zone level.
Note the pinned-slot α's (αm at z0, αk at z1) also live in the endpoint conjuncts, matching the
routing of at-endpoint classes to `EpL`/`PtW`/`EpR` rather than into the bracket. The interiority
disjunction recovered via `List.mem_filter` is definitionally the same case split `hLR` supplied,
now sound because non-interior owners are simply not in the index.

### 4. Definition 7.13 (p.15) — verbatim

> "Definition 7.13. Let (z0, z1, . . . , zk) be a sequence of distinct variables. A formula is
> (z0, z1, . . . , zk, ∞)-∃⃗∀ formula if it is a conjunction ⋀_{i≤k} ϕi, where ϕk is (zk, ∞)-∃⃗∀
> formula and ϕi is (zi, zi+1)-∃⃗∀ formulas for i < k."

And Def 7.5 (p.13), on which it depends:

> "Definition 7.5 ((z0, z1)-∃⃗∀ formula). Let z0 and z1 be two variables. A formula z0 > z1,
> z0 = z1 or of the form [α0, β1 . . . , βn−1, αn−1, βn, αn](z0, z1) is called a (z0, z1)-∃⃗∀
> formula."

**Confirmed**: Def 7.13 is segment-wise conjunction of per-interval brackets between DISTINCT
reference variables (Lemma 7.14 additionally conjoins `z0 < z1 < · · · < zk`). It says nothing
about merging coincident witnesses and licenses only reference-point segmentation — i.e., the
outer `x < w < t` segmentation of `kvE2_sepBody`. The task's corrected attribution ("any
'Def 7.13 union' phrasing in older artifacts is a corrected misattribution") is **CONFIRMED
CORRECT**. Incidentally Def 7.5's `z0 = z1` alternative is further printed evidence that equality
order types are first-class disjuncts in this framework.

### 5. Divergence Table (task-description grounding vs. the paper)

| # | Task-342 statement | What the paper actually says | Verdict / required correction |
|---|--------------------|------------------------------|-------------------------------|
| D1 | "Lemma 3.2(1) (p.4) — conjunction closure via disjunction over order types … INCLUDING equality cases: tied witnesses collapse to ONE strict slot whose point type is the CONJUNCTION (meet) …" presented as paper content | Lemma 3.2 is stated with "It is clear that" and has **no printed proof** anywhere in the 16 pages | **Citation overreach; design unaffected.** The mechanism is forced by Def 3.1 and corroborated by Def 3.1's non-distinct pinning indices, the k=m split (p.7), and Def 7.5 (p.13). All future artifacts must cite it as "forced by Def 3.1; Lemma 3.2(1) states the closure without printed proof", never as "per the proof of Lemma 3.2(1)" |
| D2 | "(see also the k = m case split, p.7)" cited in support of witness-tie collapse | The k=m split concerns coincident FREE-VARIABLE pinnings (z0 = z1), at the negation stage of §5 — not bound-witness merging | **Accurate as corroboration, imprecise as mechanism.** Keep it as corroborating evidence only. In kvE2_sep the outer points x < w < t are hypothesized strictly ordered (hxw, hwt), so the k=m configuration itself never arises; admissible ties are witness-level (base–base, base–foreign-anchor) |
| D3 | "Def 3.1 (p.4) — single STRICT witness chain x_n > ... > x_0, free variables pinned z_k = x_{i_k}" | Exactly so, quoted in §1 | **CONFIRMED verbatim** |
| D4 | "Section 5 (p.7) — psi_0/psi_1/phi split routing non-interior content to atomic E[Sigma] endpoint literals"; "interiority is a construction invariant of phi" | Exactly so, quoted in §3(b) | **CONFIRMED verbatim** |
| D5 | "Def 7.13 (p.15) is NOT the license for coincidence merging … licenses ONLY the outer x < w < t segmentation" | Exactly so, quoted in §4 (distinct variables, segment-wise conjunction) | **CONFIRMED verbatim** |
| D6 | (corpus hazard, not a task claim) FTS index presents the `.md` paraphrase as "the" Rabinovich source | The `.md` renders Lemma 3.2 as an unproved one-liner with no order-type/equality content, renders Def 7.13 in one line, and mis-paraphrases Def 7.5 as "half-open interval" while omitting its `z0 > z1` / `z0 = z1` alternatives | **Do not cite the `.md` for any load-bearing claim.** All citations in 342 artifacts must be to PDF page numbers |
| D7 | "Anchor-anchor ties remain excluded by … nf_eval_unique (SW:2522-2529)" | The paper's disjunction would formally include anchor–anchor tie order types; it never discusses excluding any | **Faithful as a Lean-side pruning, flag for the planner**: excluding order types that `nf_eval_unique` proves honestly unrealizable preserves completeness (no honest model needs them) and does not affect soundness. This is a machine-checked, model-theoretic refinement with no paper counterpart — document it as such, not as Rabinovich content |

### Additional codebase findings for the planner

1. **`kvE2_sepPosIn` (SW:199) already implements the zone filter** —
   `(kvE2_sepPos qnf).filter (fun σ => decide (nf0_zoneSpec σ.1 = zs))`. The proposed
   `kvE2_sepPosI` is a two-zone disjunctive instance of the same order-preserving-filter shape,
   so the `Nodup`/`zipIdx`/membership transfer machinery has an in-file precedent. Note
   `kvE2_sepPosI ≠ kvE2_sepPosIn zXW3 ++ kvE2_sepPosIn zWT3` as lists (the filter preserves the
   global enumeration order; the append does not) — the single-filter form in the task
   description is the right one for order-sensitive transfer lemmas.
2. **Segment (β) meet-folding across owners already exists**: `kvE2_sepSegLAt`/`kvE2_sepSegRAt`
   (SW:983–994) compute each cut's segment as `formula_conjList` over ALL of `kvE2_sepPos` —
   the per-cut refined conjunction. Tie-class folding therefore requires only re-indexing the
   cuts to class boundaries in the grouped disjunct builder (the segment between two members of
   one tie class disappears with the slot); no new β-conjunction machinery is needed. This
   confirms report 07's claim that `kvE2_sepBracketN` (SW:1009) and banked
   `kvE2_sepBracketN_construct` (SW:4521) survive unchanged (both are generic over point-type
   lists and per-index segment functions).
3. **`kvE2_sepHonest_hLR_absurd` verified at SW:4618** with exactly the hypothesis shape the task
   quotes; its docstring already prescribes routing boundary classes through the endpoint/pivot
   literal machinery. Retaining it verbatim is compatible with Part I (it quantifies over
   `kvE2_sepPos`, which is untouched; only the *arrangement index* moves to `kvE2_sepPosI`).
4. **`IntervalPattern.holds` verified at Kamp/ExistsForallNF.lean:106–132** (note: the file lives
   at `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean`, not under
   `NfMultiAnchorBridge/`). Witness bounds are the bracket's own range (`z0 < witnesses i ∧
   witnesses i < z1`) — LITMUS-compliant; no chain-relative literal.

## Literature Proof Structure (Tier 1)

Rabinovich 2014, "A Proof of Kamp's Theorem", LMCS 10(1:14). Proof skeleton relevant to kvE2_sep:

1. **Def 3.1 (p.4)**: ∃⃗∀-formulas — strict witness chain, pinned free variables, quantifier-free
   point types α and interval types β, outer tails β0/βn+1. → Lean: `IntervalPattern`/`VecEA2`/
   `BracketFormula` layer.
2. **Lemma 3.2 (p.4, unproved "It is clear that")**: (1) conjunction closure via disjunction (the
   order-type interleaving with equality cases — forced by Def 3.1); (2) reduction to ≤2 free
   variables; (3) closure under ∃. → Lean: the arrangement carrier `kvE2_sepOrderTypes`/
   `kvE2_sepDisjValid`/`kvE2_sepArr'` (Part II fixes the equality cases).
3. **Prop 3.5 (p.5)**: one-free-variable ∃⃗∀ → TL(Until, Since), by the nested-Until/Since
   formalization split at the pinned slot k. → Lean: the bracket/endpoint literal split of
   `kvE2_sepBody`.
4. **§5 (p.7)**: negation of a two-variable ∃⃗∀: k=m equality split; k≠m ψ0/ψ1/φ split with
   ψ0/ψ1 atomic via Prop 3.5 and φ the pinned-endpoint interior bracket (Lemma 5.1, proved via
   Lemma 5.3 induction + Corollary 5.4 + the 3-case analysis, pp.8–11, using K+ and Dedekind
   completeness). → Lean Part I: interior-restricted owner index; boundary classes on endpoint
   literals.
5. **Def 7.13 + Lemma 7.14 (p.15)**: multi-reference-point segment-wise conjunction between
   distinct variables. → Lean: the outer x < w < t segmentation only.

## Adversarial Self-Verification

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| Def 3.1's witness chain is strict and free variables are pinned `z_k = x_{i_k}` with `i_k ∈ {0,…,n}` (no distinctness) | Verbatim quote, p.4: "`(xn > xn−1 > · · · > x1 > x0)`", "`⋀_{k=0}^m z_k = x_{i_k}`", "`i0, . . . , im ∈ {0, . . . , n}`" | `pdftotext -f 3 -l 5` page read of the PDF | High |
| Lemma 3.2 has NO printed proof anywhere in the paper | p.4: "It is clear that / Lemma 3.2."; p.5 Lemma 3.4 proof merely *uses* 3.2(1)/(3); full-text extraction of pp.1–16 with grep for "3.2" and "clear" found no proof (pp.1–2 checked separately: zero hits) | `pdftotext` over all 16 pages + targeted grep | High |
| The tie-collapse mechanism (order-type disjunction incl. equality; coincidences → one strict slot with conjoined α) is forced by Def 3.1 and corroborated in print | Necessity argument in §2 of Findings (strict chain + conjunction semantics); corroborations quoted: Def 3.1 pinning indices (p.4), k=m split with `z0 < z1 ∨ z1 < z0 ∨ ∃x0[z0 = x0 ∧ z1 = x0 ∧ ¬A′(x0)]` (p.7), Def 7.5's `z0 = z1` alternative (p.13) | Page reads pp.4, 7, 13; cross-checked against the machine-certified Lean counterexample (Nodup ⇒ tie models realize no disjunct, task/report-07 record) | High |
| §5 routes non-interior witnesses to atomic E[Σ] content via Prop 3.5, and interiority of φ is a construction invariant | Verbatim quote, p.7: "The first two formulas are ∃⃗∀-formulas with one free variable. Therefore, (by Proposition 3.5) they are equivalent to TL(Until, Since) formulas (in the signature E[Σ]). Hence, their negations are equivalent … to atomic … formulas"; φ's chain "`(z0 = xm < xm+1 < · · · < xk = z1)`" | `pdftotext -f 6 -l 9` page read | High |
| Def 7.13 is segment-wise conjunction between DISTINCT variables and licenses no coincidence merging | Verbatim quote, p.15: "Let (z0, z1, . . . , zk) be a sequence of distinct variables. A formula is … a conjunction ⋀_{i≤k} ϕi …" | `pdftotext -f 14 -l 16` page read | High |
| `hLR` has no Rabinovich counterpart | Exhaustive read of §§3–5 and §7: no hypothesis anywhere restricts realized types to interior zones; interiority appears only as φ's chain shape | Full-paper extraction + §5 close read; consistent with report 07 §§1–2 | High |
| `IntervalPattern.holds` transcribes Def 3.1's strict chain with bracket-range witness bounds (LITMUS-compliant) | Direct read of Kamp/ExistsForallNF.lean:106–132: `(∀ i j, i < j → witnesses i < witnesses j)` and `(∀ i, z0 < witnesses i ∧ witnesses i < z1)` | `Read`/`sed` of the file at the cited lines | High |
| `kvE2_sepDisjValid` conjunct (iii) is `Nodup` at SW:1350–1354; `kvE2_sepHonest_hLR_absurd` is at SW:4618 with the quoted hypothesis; `kvE2_sepPosI` does not yet exist; `kvE2_sepPosIn` exists at SW:199 | Direct file reads of SharedWitness.lean at those lines; grep for `kvE2_sepPosI` returned only `kvE2_sepPosIn` occurrences | `sed`/`grep` reads of SharedWitness.lean | High |
| Segments already meet-fold across all owners per cut (no new β machinery needed for tie folding) | `kvE2_sepSegLAt`/`RAt` (SW:983–994): `formula_conjList ((kvE2_sepPos qnf).map …)` | Direct read of SharedWitness.lean:983–994 | High |
| The `.md` paraphrase is unusable for load-bearing claims | Its Def 7.5 line says "half-open interval", contradicting the PDF's Def 7.5 (which is not an interval restriction but a 3-alternative definition incl. `z0 > z1`, `z0 = z1`); Lemma 3.2 and Def 7.13 are one-liners with no equality-case or distinctness content | grep/sed reads of the `.md` vs. PDF pp.13, 15 | High |
| Anchor–anchor tie exclusion via `nf_eval_unique` is a Lean-side completeness-preserving pruning with no paper counterpart | Paper never discusses pruning order types; the exclusion is justified only by the machine-checked lemma (SW:2522–2529 per task/report 07) | Paper full read + task/report-07 record (lemma existence not independently re-verified this dispatch — it is task-340 banked work) | Medium |

**Contradiction Log** (protocol applied): the task description's "Lemma 3.2(1) … tied witnesses
collapse …" (secondary summary) vs. the PDF (primary source, which prints no such proof).
Precedence rule 4 (primary paper source > secondary summary) resolves in favor of the PDF:
the *attribution* is corrected (D1) while the *mechanism* survives on independent grounds
(Def 3.1 necessity + printed corroborations + the machine-certified Lean counterexample).
No unresolved contradictions remain.

**Recommendations modified after verification**: one — Part II's citation basis was rewritten
from "per Lemma 3.2(1)'s proof" to "forced by Def 3.1; Lemma 3.2(1) states the closure without
printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13)". No design change.

## Recommendations

1. **Proceed to `/plan 342` with the design as described** — both parts pass the fidelity audit.
2. **Correct the citation discipline** in the plan and all downstream artifacts per D1/D2:
   never cite "the proof of Lemma 3.2(1)"; cite Def 3.1 (p.4) as the forcing definition, with
   the k=m split (p.7) and Def 7.5 (p.13) as printed corroboration of equality-case order types
   and single-slot coincidence handling.
3. **Plan-level guard for Part II**: state explicitly that tie classes are index-level data and
   every emitted disjunct is a strict Def-3.1 bracket over the quotient (one slot per class,
   `formula_conjList` point type); `IntervalPattern.holds` is never weakened.
4. **Plan-level note for D7**: document the anchor–anchor tie exclusion as a Lean-side,
   `nf_eval_unique`-certified pruning (completeness-preserving), not as Rabinovich content.
5. **Leverage the found in-file precedents**: `kvE2_sepPosIn` (SW:199) for the filter shape
   (use the single two-zone filter, not an append, to preserve enumeration order), and the
   existing per-cut refined-conjunction segments (SW:983–994) so tie folding is point-type +
   cut-reindexing only.
6. **Keep the constraints as stated**: retain `kvE2_sepHonest_hLR_absurd` verbatim; do not
   resurrect the rejected non-interior-true-branch alternative; preserve F1–F7 (esp. F5: the
   base–anchor tie discharge reads the anchor owner's CLOSED key at the foreign base type, per
   the `kvE2_sepClosedLeafStub` pattern SW:1316–1321); LITMUS at NavigatedSpine.lean:437.
