# Faithfulness Report: Witness Ordering for the Joint Multi-Owner Disjunct Bracket

**Task**: 337 — build joint multi-owner disjunct `bracket.holds` engine for `kvE2_sepDisjunct`
**Question**: How does Rabinovich (2014) construct/order the witness points for a bracket
spanning multiple owners / anchor points at nesting depth ≥ 2? Which of Option A (model-sorted
realization) or Option B (permutation enumeration) is the faithful transcription?
**Mode**: RESEARCH-ONLY (no Lean files edited)
**Source**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(indexed `rabinovich_2014`)

---

## RECOMMENDATION: Option A (model-sorted realization) — with a critical decomposition

**Option A is the faithful transcription of Rabinovich's WITNESS.** The `.holds` builder must
realize the model-order disjunct via a joint sorted-realization engine generalizing
`k1v_sorted_realizationK` from one owner to the merged multi-owner anchor set.

The key insight that dissolves the A-vs-B dilemma is a **two-level split** that Rabinovich's proof
makes and that the codebase *already* encodes:

| Level | Rabinovich object | Lean object | Shape |
|-------|-------------------|-------------|-------|
| **Formula / normal form** | Lemma 3.2(1): conjunction of ∃∀ formulas ≡ **disjunction** of ∃∀ formulas (md:77) | `kvE2_sepArr'` = valid order-types filter over `kvE2_sepOrderTypes` (SharedWitness.lean:763) | Disjunction over interleavings/order-types — "Option-B-shaped" but ALREADY landed and faithful |
| **Witness / realization (`.holds`)** | Def 3.1: a single **strictly-monotone** sequence `x_0 < x_1 < … < x_n` in actual model order (md:65-68) | the missing `(kvE2_sepDisjunct … slotsL slotsR).2.holds` for the **model-order** disjunct | Single global monotone merge — **Option A** |

Enumeration is faithful *only at the formula level*, where the codebase already performs it
(`kvE2_sepOrderTypes` / `kvE2_sepArr'`). At the **witness level**, Rabinovich never enumerates
permutations of witness points — he asserts one increasing sequence and, in a model, realizes it by
taking the merged anchors **in their true temporal order**. Re-enumerating permutations *again* at
the `.holds` level (Option B / `List.mem_permutations`) is a Lean-encoding artifact that duplicates
the carrier's already-faithful order-type enumeration.

---

## 1. What Rabinovich's witness IS (Q1, Q2)

**Definition 3.1 (Exists-Forall formula), md:63-72.** The normal form is
```
psi(z_0,…,z_m) := ∃ x_n … ∃ x_1 ∃ x_0
     (ordering constraints on x_i and z_j)
     ∧ alpha_j(x_j) at x_j          (point types)
     ∧ beta_j along (x_{j-1}, x_j)   (interval types)
```
The "ordering constraints" fix a **single strictly-increasing chain** `x_0 < x_1 < … < x_n`
(md:74: "existentially chosen points partition the chain into intervals"). The witness for the
existential is therefore **one global monotone sequence in the model's own temporal order** — there
is no per-owner slot list, no concatenation, and no permutation quantifier. This is Option A's
mathematical content exactly.

**Answer to Q1**: Rabinovich orders witness points by their **actual model/temporal order** — a
single global monotone enumeration. He does **not** quantify existentially over
arrangements/permutations *at the witness level*.

**Answer to Q2**: The exact object is the monotone realization `x_0 < x_1 < … < x_n` of
Definition 3.1 (md:65-68), whose point types `alpha_j` and interval types `beta_j` are read off in
that single order. The multi-reference-point generalization is Definition 7.13
`(z_0,…,z_k,∞)-exists-forall` (md:202) — still one global order over the merged points.

**Where enumeration legitimately appears** — Lemma 3.2(1) (md:77): "Conjunction of ∃∀ formulas is
equivalent to a **disjunction** of ∃∀ formulas." Merging two owners' interval decompositions (whose
relative interleaving is not fixed a priori) produces a disjunction over order-consistent
interleavings; *each disjunct internally fixes one monotone order*. This is a **normal-form
construction** step (syntactic, model-independent), **not** the witness. §5 / Lemma 5.1's case split
"for ALL possible positions i" (md:161-173, md:218-219) is this same disjunction over where a new
point falls in the global order, including the coincidence sub-case r_0 = z_0 vs the strict sub-case
r_0 ∈ (z_0,z_1) (md:151, Dedekind-INF md:145-152).

---

## 2. Which option is faithful vs. artifact (Q3)

**Option A = FAITHFUL (the witness).** "Reorder the merged slots by their actual model values before
requiring monotonicity" is precisely how one *realizes* Rabinovich's existential
`∃ x_0 < … < x_n` in a concrete model: the merged anchors, taken in true model order, ARE the
increasing sequence. A joint sorted-realization engine generalizing `k1v_sorted_realizationK`
(SubBracket2V.lean:633 — explicitly named in OuterGate.lean:86 as "the intended foundation") is the
direct transcription.

**Option B = LEAN ARTIFACT (at the witness level).** "Enumerate ALL permutations of the merged slot
list and select the sorted one via `List.mem_permutations`" reconstructs the same sorted order
*indirectly*. It mirrors the single-owner `bracketEndChar_k1v_complete` (CarrierK1V.lean:1629)
pattern — but for a *single* owner the slots are already in that owner's order, so "pick the sorted
permutation" is trivial and hides the fact that cross-owner interleaving is the real content. Pushing
`mem_permutations` to the multi-owner `.holds` level duplicates the enumeration the carrier
(`kvE2_sepOrderTypes` / `kvE2_sepArr'`) already performs at the *formula* level. It is a workaround,
not Rabinovich's mathematics.

---

## 3. Is the fixed order actually correct, bug elsewhere? (Q4) — NO, and it resolves INTO Option A

The current `kvE2_sepBody` (SharedWitness.lean:835-836) pins disjuncts to the **flatMap
concatenation** `kvE2_sepSlotsL/R` (per-owner slot lists in owner-concatenation order). Rabinovich
**never concatenates per-owner sequences and keeps concatenation order** — his witness is always the
single *merge-sorted* model order. When two positive interior owners' anchors interleave, concatenation
order ≠ model order, so no monotone witness exists for the fixed order. This is exactly why
`kvE2_sepSlotsL_valid`/`_valid` were **deleted as FALSE** (SharedWitness.lean:1038-1044: "the identity
interleaving of the flat union … need not be cross-σ compat").

So the "bug is in the merge" hypothesis is *correct in substance* — but its fix **is Option A**: the
merge must be a model-order merge, not a concatenation. This is not a distinct third path; it is the
same retarget.

**The codebase already committed to this design at the non-vacuity level** (task 334 Phase 6):
- `kvE2_sepArr'` (SharedWitness.lean:763) = "**The faithful carrier** … the valid order-type
  disjuncts … (Lemma 3.2(1), md:77)" — enumerates valid weak orders on the merged anchor set.
- `kvE2_sepModelOrder qnf` = the distinguished **model-order** arrangement, proven a member of the
  enumeration (`kvE2_sepModelOrder_mem_orderTypes`, :791) and of the carrier when valid
  (`kvE2_sepArr'_mem_modelOrder`, :800). Described as "axiom-clean" (:1043).

The enumeration (formula side) is landed and faithful; the **only** un-landed piece is the
`.holds` realization for the model-order disjunct — which must be built by Option A's joint
sorted-realization, matching the already-present `kvE2_sepModelOrder` route. Building it by Option B
would contradict the carrier's own already-faithful order-type enumeration.

---

## 4. Rabinovich construct → Lean object mapping

| Rabinovich (2014) | Lean object | Status |
|-------------------|-------------|--------|
| Def 3.1 monotone witness `x_0<…<x_n` in model order (md:65-68) | model-order realization of `kvE2_sepModelOrder` disjunct | **MISSING — build via Option A** |
| Lemma 3.2(1) conjunction ≡ disjunction of ∃∀ (md:77) | `kvE2_sepArr'` = filter of `kvE2_sepOrderTypes` (:763) | landed, faithful |
| §5 case split "for all positions i" incl. strict/coincident (md:151,161-173) | order-types incl. strict (`zXU`/`zUW`) + coincidence (`zAtX1L`) bits (:810-814) | landed |
| Dedekind-INF meet point r_0 (md:145-152) | §5 meet-typed shared point (md:168-173, SharedWitness :814) | landed |
| single-owner region realization | `k1v_sorted_realizationK` (SubBracket2V.lean:633) | landed — **generalize to many owners** |
| Def 7.13 `(z_0,…,z_k,∞)`-∃∀ multi-reference (md:202) | depth-k≥2 multi-anchor bracket | target |

**Concrete next step (for planning, not this task)**: generalize `k1v_sorted_realizationK`
(one owner) to a joint engine over the merged anchor set, targeting the **model-order** disjunct
`kvE2_sepModelOrder`, and use it to discharge `(kvE2_sepDisjunct … slotsL slotsR).2.holds`. Do NOT
re-enumerate permutations at the `.holds` level — the carrier `kvE2_sepArr'` already supplies the
faithful disjunction.

---

## Key Citations

- **Rabinovich 2014, Definition 3.1** (md:63-74) — the ∃∀ witness is a single monotone sequence
  `x_0 < … < x_n` in model order. **[decides Q1, Q2, Q3]**
- **Rabinovich 2014, Lemma 3.2(1)** (md:77) — conjunction of ∃∀ ≡ disjunction of ∃∀; enumeration
  lives at the *formula* level (= carrier `kvE2_sepArr'`), not the witness level.
- **Rabinovich 2014, §5 / Lemma 5.1 + Insight #2** (md:161-173, 218-219) — case split over point
  position i, strict vs. coincident sub-cases (Dedekind-INF, md:145-152).
- **Rabinovich 2014, Definition 7.13** (md:202) — multi-reference-point `(z_0,…,z_k,∞)`-∃∀ (depth ≥ 2).
- Lean corroboration: `kvE2_sepArr'` faithful-carrier comment citing "Lemma 3.2(1), md:77"
  (SharedWitness.lean:761-765); `kvE2_sepModelOrder`/`kvE2_sepArr'_mem_modelOrder` (:791-805);
  deleted FALSE flatMap scaffolds (:1038-1044); `k1v_sorted_realizationK` as intended foundation
  (OuterGate.lean:84-90).
