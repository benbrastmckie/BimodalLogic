# Critic Findings: Order Atom Blocker in sum_nf_agree

**Task**: 154 — sum_preservation and doets_lemma_1_4
**Date**: 2026-05-16
**Role**: Teammate C — Critic

---

## Key Findings

### 1. The Blocker IS Real — But the Diagnosis Is Slightly Imprecise

The phase-3 handoff correctly identifies that same-component order atoms between the new witness
`⟨i, a⟩`/`⟨i, b⟩` and existing environment elements cannot be resolved from the current
hypotheses. However, the root cause needs a sharper statement:

**Exact gap**: At the sorry sites (NEquivalence.lean lines 264, 334, 400, 459), the goal after
`simp only [atom_eval]` in the `| order j₁ j₂ h_ne =>` case reduces to showing the sigma-lex order
comparison is preserved. After case-splitting on `j₁` and `j₂`:

- `succ j₁, succ j₂`: both are old environment elements → handled by `h_atoms`.
- `0, succ j` or `succ j, 0`: involves new witness vs old element.
  - Cross-component case (index `i` vs `(env_M j).1` different): resolved by `h_idx` since index
    comparison is purely determined by component indices.
  - **Same-component case** (`i = (env_M j).1`): requires
    `a < (env_M j).2 ↔ b < (env_N j).2` within the component. THIS IS THE GAP.

The gap is not merely "1-var NFs don't encode order between distinct elements" — it is more
specific: `AtomKind sig 1` contains NO order atoms at all (since order atoms require two distinct
indices `i ≠ j` with `i, j : Fin 1`, but `Fin 1 = {0}` has only one element). The 1-variable
NF `char_a` encodes only unary predicate truth values. It says nothing about `a`'s position in the
linear order relative to any other element.

### 2. The 1-var NF Transfer Was the Right Mechanism for Predicates, Wrong for Orders

The proof's existing approach works perfectly for predicate atoms (`pred p j`). It correctly:
- Extracts predicate agreement from `char_a.atom_assgn (.pred p 0) = true`
- Uses `ha_pred` and `hb_pred` to show `(ms i).interp p a ↔ (ms' i).interp p b`

But it fundamentally cannot handle order atoms because the component-level 1-variable NF transfer
provides NO information about order relationships. This is not a tactic issue — it's a structural
incompleteness in the invariants tracked by `sum_nf_agree`.

### 3. The `h_elem` Hypothesis Does NOT Help With the Gap

`h_elem` provides: for each existing environment index `j : Fin n` and each `nf_j : NormalForm sig m 1`,
`nf_eval_nf (ms ((env_M j).1)) m 1 (fun _ => (env_M j).2) nf_j ↔ nf_eval_nf (ms' ((env_N j).1)) m 1 (fun _ => (env_N j).2) nf_j`.

This encodes 1-variable NF agreement for the EXISTING elements `(env_M j).2` and `(env_N j).2`,
not for pairs involving the new witness. For the same reason (no order atoms in `AtomKind sig 1`),
`h_elem` cannot provide `a < (env_M j).2 ↔ b < (env_N j).2`.

To get pairwise order information, we would need 2-variable NF agreement for the pair
`(a, (env_M j).2)` vs `(b, (env_N j).2)` — information that is entirely absent from the current
hypothesis set.

### 4. The `h_atoms` Hypothesis Is Insufficient AND Its Generation Is Circular

`h_atoms` covers order atoms ONLY for the original n-element environment. When the IH is applied
with extended environments `Fin.cons ⟨i, a⟩ env_M` and `Fin.cons ⟨i, b⟩ env_N`, the caller must
supply a NEW `h_atoms` for the extended environment. This new `h_atoms` is what the sorry blocks.
It cannot be derived from the existing `h_atoms`, `h_elem`, or `char_a`/`char_b`. So the structure
of the proof creates an obligation it cannot discharge.

### 5. A Simpler Targeted Fix Exists for the Cross-Component Case

Before reaching the same-component impasse, note: if `i ≠ (env_M j).1`, the order comparison is
`i < (env_M j).1 ↔ i < (env_N j).1` which is trivially true since `(env_M j).1 = (env_N j).1`
by `h_idx j`. So the cross-component sub-case of the sorry is ACTUALLY CLOSABLE with the current
hypotheses. The previous agent may have left both sub-cases as sorry instead of splitting further.

Specifically: after `cases j₁ using Fin.cases` and `cases j₂ using Fin.cases`:
- Case `j₁ = succ j₁', j₂ = succ j₂'`: use `h_atoms (.order j₁' j₂' _)` directly.
- Case `j₁ = 0, j₂ = succ j` (or symmetric): need sigma-lex order `⟨i, a⟩ < env_M (succ j)`.
  - Sub-case `i < (env_M j).1`: True on both sides. `h_idx j` closes it.
  - Sub-case `i > (env_M j).1`: False on both sides. `h_idx j` closes it.
  - Sub-case `i = (env_M j).1`: needs `a < (env_M j).2 ↔ b < (env_N j).2`. **Cannot close.**

So 3 of the 4 sub-cases per sorry ARE closable. Only the same-component order comparison is stuck.

### 6. The Proposed Restructuring (Option 2) Is Sound But Requires Proof Redesign

The handoff recommends Option 2: restructure `sum_nf_agree` to use FULL ordered-sum NF agreement
as the inductive invariant (rather than `h_atoms` + `h_elem`). This is mathematically correct and
parallels the structure of `nf_agreement_monotone` exactly:

```
nf_agreement_monotone:
  INPUT:  depth-k NF agreement for (M, env_M) and (N, env_N)
  OUTPUT: depth-m NF agreement (m ≤ k)
  KEY:    atom agreement derived from NF agreement via atom_agreement_from_nf
          witness found by shared depth-k' NF → nf_agreement_from_shared_nf
          → full NF agreement for extended env → IH

sum_nf_agree (restructured):
  INPUT:  component k-equivalence at sentence level
  OUTPUT: ordered-sum depth-k NF agreement
  KEY:    prove by induction on k, where IH gives ordered-sum depth-(k-1) NF agreement
          atom agreement derived from NF agreement via atom_agreement_from_nf
          witness found by BOTH component NF agreement AND same-component environment tracking
```

The key difference from `nf_agreement_monotone`: the witness selection mechanism requires more care
because we must simultaneously satisfy:
(a) the sub-NF `sub_nf` (depth k-1, n+1 variables) in the ordered sum
(b) the order constraints with existing same-component environment elements

This is resolved by using a multi-variable NF for the component-level joint environment.

### 7. Why Option 1 (Joint NF Witness Selection) Also Works — and May Be Simpler to Implement

Option 1: When selecting witness `b` for `a = ⟨i, a_val⟩`, instead of using just `char_a =
nf_characteristic (ms i) k 1 (fun _ => a_val)`, form the joint n+1-variable NF for the tuple
`(a_val, (env_M j₁).2, ..., (env_M jₛ).2)` where `j₁,...,jₛ` are the same-component positions
(those `j` with `(env_M j).1 = i`).

This joint NF encodes ALL 2-variable order atoms `a_val < (env_M jₗ).2` and
`(env_M jₗ).2 < a_val`. By component (k+1)-equivalence at MULTI-variable level (derived from
sentence-level k-equiv using `nf_agreement_monotone` applied within the component), find `b_val`
in `ms' i` satisfying the same joint NF. Then `b_val` preserves order with all existing
same-component environment elements.

The feasibility argument: the number of same-component elements at variable index `n` is at most
`n`. By the IH structure (n grows by 1 per quantifier step), we never need more variables in the
joint NF than the current depth allows.

This option avoids restructuring the entire `sum_nf_agree` proof from scratch; it only changes how
the witness is selected.

---

## Recommended Approach

**Primary recommendation**: Option 1 (Joint NF Witness Selection) modified as follows:

Instead of selecting `b` via `h_q_transfer char_a` (which uses 1-variable NFs), select it using
a multi-variable NF for all elements in the SAME component. Specifically:

1. Identify the "same-component sub-environment": positions `j : Fin n` where `(env_M j).1 = i`.
2. Form `joint_env_M : Fin (s+1) → (ms i).carrier` where `s` is the number of same-component
   positions and position 0 maps to `a_val`, positions 1..s map to the same-component elements.
3. Compute `char_joint := nf_characteristic (ms i) k (s+1) joint_env_M`.
4. From sentence-level `h_comp` at depth k, derive multi-variable NF agreement for `(ms i, joint_env_M)`
   and `(ms' i, joint_env_N)` using `nf_agreement_monotone`.
5. Find `b_val` satisfying `char_joint` in `ms' i` via the (k+1)-quantifier of `ms i ≡_{k+1} ms' i`.
6. `nf_agreement_from_shared_nf` then gives: `(ms i, joint_env_M with a)` and
   `(ms' i, joint_env_N with b)` agree on all NFs, INCLUDING order atoms.

This gives exactly `a < (env_M jₗ).2 ↔ b < (env_N jₗ).2` for all same-component `jₗ`,
closing the sorry.

**Alternative**: Option 2 (full proof restructuring) is cleaner mathematically but requires
rewriting `sum_nf_agree` from scratch with a different top-level invariant. Recommended if the
implementation agent finds Option 1's same-component sub-environment construction awkward in Lean.

**Rejected approaches**:
- Strengthening `h_elem` to 2-variable NFs: would propagate the change throughout all 4 sorry
  contexts but does not address the root cause (the gap appears when crossing existing and new
  elements, not just existing vs existing).
- Adding `h_order : ∀ j, a < (env_M j).2 ↔ b < (env_N j).2` as a separate hypothesis: requires
  the CALLER to provide this, pushing the obligation upward without resolving it.

---

## Evidence and Examples

### Concrete Counterexample Confirming the Gap

Let `sig` have no predicates, `I = {0}` (one-element index), `ms 0 = ms' 0 = (Z, <)`. Then
`k_equiv sig k (ms 0) (ms' 0)` holds trivially (same structure). Take `env_M : Fin 1 → Z` with
`env_M 0 = 5`, and `env_N : Fin 1 → Z` with `env_N 0 = 10`.

In the quantifier step, when looking for `b` to match `a = 3` in ms 0, the 1-variable NF
`char_a = nf_characteristic Z k 1 (fun _ => 3)` encodes no order atoms. So `b = 7` satisfies
`char_a` in ms' 0 (Z has no unary predicates, so all 1-variable NFs with no predicates are trivially
satisfied). But `3 < 5` while `7 > 10`, so the order atom `atom_eval Z (Fin.cons 3 env_M) (.order 0 1 _)` is true but `atom_eval Z (Fin.cons 7 env_N) (.order 0 1 _)` is false. This concretely demonstrates the sorry cannot be closed with `b` selected by 1-variable NF alone.

(Note: in this example the whole theorem is still true — we should have chosen `b = 3` which
satisfies `3 < 5 ↔ 3 < 10`... wait, that's actually FALSE as well. We need `b` such that
`b < 10 ↔ 3 < 5`, i.e., `b < 10 ↔ true`, i.e., `b < 10`. So any `b < 10` works. The CORRECT
choice requires knowing the order relationship with the environment element, which is exactly
the multi-variable NF information.)

### Why `AtomKind sig 1` Has No Order Atoms

`AtomKind sig 1 = { .pred p 0 | p : sig.preds } ∪ { .order i j _ | i j : Fin 1, i ≠ j }`.
Since `Fin 1 = {0}`, the order atoms require `i ≠ j` with `i, j : Fin 1`, which is impossible.
The order atoms set is empty. Therefore `NormalForm sig k 1` encodes ONLY unary predicate truth
values, not any order relationships. This is confirmed by the AtomKind definition in NormalForm.lean
lines 58-60: `order (i j : Fin n) (h : i ≠ j)`.

### Partial Closability of Current Sorries

Each of the 4 sorry sites can be PARTIALLY resolved with current hypotheses:
- Cross-component order (different index): `i ≠ (env_M j).1` → `h_idx j` closes it
- Same-index case (new vs new): `j₁ = j₂ = 0` → impossible since `h_ne : j₁ ≠ j₂`
- Old vs old: `j₁ = succ j₁', j₂ = succ j₂'` → `h_atoms` closes it
- Same-component new vs old: **STUCK** (needs order information)

The sorry should be split into these cases with only the last remaining as a sorry, as this
gives a cleaner picture of what actually needs to be fixed.

### nf_agreement_monotone as the Template

The existing `nf_agreement_monotone` proof (NormalForm.lean:339-421) proves that if two pairs
(M, env_M) and (N, env_N) agree on all depth-k NFs, they agree on all depth-m NFs (m ≤ k).
Its quantifier step (lines 396-420) selects witnesses by their depth-(k-1) NF in the SAME
structure M (not M and N separately), then uses `nf_agreement_from_shared_nf` to establish
full agreement for the extended environment. This gives atom agreement (including order atoms)
for free via `atom_agreement_from_nf`.

The `sum_nf_agree` proof should adopt this SAME pattern: select the witness `b` in `ms' i` such
that `(ms' i, [b] ++ same_comp_N_env)` satisfies the same multi-variable NF as
`(ms i, [a] ++ same_comp_M_env)`. Then `nf_agreement_from_shared_nf` gives full NF agreement
(including order atoms) for the extended component environments, which translates to the
ordered-sum level via the localization lemma.

---

## Confidence Level

**High confidence**:
- The blocker is real (confirmed by `AtomKind sig 1` having no order atoms).
- The partial closability (3 of 4 sub-cases per sorry are closable now) is confirmed by reading
  the sigma-lex definition in Mathlib and the h_idx hypothesis.
- Option 1 and Option 2 are both mathematically valid approaches to fix the proof.
- `nf_agreement_monotone` provides the exact template for the fix.

**Medium confidence**:
- Option 1 (Joint NF) is implementable within the existing `sum_nf_agree` framework with
  moderate restructuring (estimated 50-100 additional lines vs full rewrite).
- The same-component sub-environment extraction does not cause universe or dependent-type issues
  in Lean 4.

**Low confidence**:
- Whether the "number of same-component elements ≤ k" bound is easy to maintain formally
  across the induction. This requires tracking how many same-component elements exist at each
  quantifier depth, which may add bookkeeping not accounted for in the current plan.

**Verdict**: Phase 3 is blocked as reported. The fix requires either (a) augmenting how witnesses
are chosen in the quantifier transfer to include multi-variable order information, or (b) restructuring
the top-level invariant of `sum_nf_agree` to track full NF agreement. Option 2 from the handoff
is recommended; Option 1 is a valid alternative. No simpler fix exists.
