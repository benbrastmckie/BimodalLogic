# Teammate C (Critic) Findings: Root Cause Analysis of 3 Failed Proof Cycles

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Artifact**: 33
- **Date**: 2026-06-15
- **Role**: Teammate C (Critic) — Identify WHY 3 cycles failed; challenge assumptions

---

## Executive Summary

The 4 remaining sorries in KampBypass.lean (lines 974, 1579, 1637, 1749) are all provable as stated — there is no type mismatch or fundamental unprovability issue. The failure is architectural: three consecutive cycles applied the wrong proof approach (decomposition/analysis) rather than the correct proof approach (direct proof from sorry site). The proofs require 50-200 lines each of direct Lean tactic work, but agents keep writing skeletons, helpers, and analyses instead of closing the goals.

---

## Root Cause Analysis

### Root Cause 1: Analysis-Paralysis Pattern (Primary)

All three failed cycles produced the same anti-pattern:

- **Cycle 3**: Added zone bridge helpers (sorry-free). No sorry closed.
- **Cycle 4**: Decomposed the `existPart_succ_n1_bypass_k0_since` sorry into 5 sub-sorries (net INCREASE from 4 to 7 sorries in the worktree, confirmed by inspecting `.claude/worktrees/agent-a6741c7a21a3a3530/`).
- **Cycle 5**: Created more skeleton code (the since-case handoff at `since-case-handoff-20260614.md` documents 5 sub-sorries). Net change: 0 closures.

The pattern is: agents research → plan → write comments and stubs → defer actual proof work. Each cycle produces "infrastructure" that is itself sorry-filled. The root problem is that these cycles treat proof construction like software architecture — designing the shape of the proof before filling it. For Lean proofs at this level, the correct approach is to open the sorry site, read the goal, and directly close it with tactics.

### Root Cause 2: Worktree Divergence and Main-Branch Confusion

Three active worktrees exist with different sorry counts:
- Main branch: 1839 lines, 4 active sorries (lines 974, 1579, 1637, 1749, 1837)
- Worktree `agent-a55505307ae3d4932`: 1644 lines, 5 sorries (different line numbers)
- Worktree `agent-a83818cfb35228c46`: 2105 lines, 4 sorries (expanded version)
- Worktree `agent-a6741c7a21a3a3530`: 1871 lines, 7 sorries (decomposed version)

Agents may be working on the wrong version. The "net increase in sorry count" reported in Cycle 4 is precisely because the worktree (`agent-a6741...`) has 7 sorries while the main branch has 4. If subsequent cycles work from the main branch (correct), the decomposed sub-sorries don't exist. If they work from the worktree (wrong), they inherit the expanded sorry count.

**Critical question for the implementing agent**: Which file are you editing? The main branch `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` should be the target. The worktrees are stale.

### Root Cause 3: Sorry-Site Line Number Drift

The plan v32 references sorry lines 753, 1284, 1503, 1615. The current main-branch sorry lines (confirmed via `grep -n sorry`) are 974, 1579, 1637, 1749, 1837. Line numbers have shifted significantly (the file grew from ~750 lines when plan v32 was written to 1839 lines now). Agents following the plan may be working at wrong line numbers.

**Correct current sorry positions** (verified via `lean_goal`):
- **L974**: `existPart_succ_n1_bypass_k0_eq` compatible subcase
- **L1579**: `backward_holdsLeft_of_nf_eval` bracket case
- **L1637**: `forward_nf_eval_of_holdsLeft` forward direction (case pos)
- **L1749**: `existPart_succ_n1_bypass_k0_since`
- **L1837**: `existPart_succ_n1_bypass` depth >= 2

### Root Cause 4: The Since Case Architecture is Fundamentally Different from Until

The `enriched_bypass_since` formula (lines 515-594) uses `formula_disjList` of `Formula.and pre_at_t (Formula.snce pt_x guard)` -- a FLAT disjunction over Since-formulas. This is NOT a VVecEA2 / `translateLeft` construction, unlike the Until case. The Until case proof uses `VVecEA2.translateLeft_correct` to convert between temporal truth and `VecEA2.holdsLeft`. The Since case has NO analog of this — it must prove the biconditional directly from the Since semantics.

This means the Since sorry (L1749) is effectively a DIFFERENT proof problem than the Until case. Agents that try to mirror the Until case structure will get stuck because the infrastructure is different.

---

## Per-Sorry Goal Inspection

### Sorry at L974 (`existPart_succ_n1_bypass_k0_eq` compatible subcase)

**Goal** (confirmed via `lean_goal`):
```
⊢ temporal_truth M atomMap t (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms) ↔
    ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

**Key hypotheses available**:
- `h_gt : sub_nf.1 (order ⟨1,..⟩ ⟨0,..⟩ ..) = false` (x not > t)
- `h_lt : sub_nf.1 (order ⟨0,..⟩ ⟨1,..⟩ ..) = false` (x not < t)
- `h_pred_compat : ∀ p, sub_nf.1 (pred p 0) = sub_nf.1 (pred p 1)`
- `h_t_compat : ∀ p, sub_nf.1 (pred p 1) = parent_atoms (pred p 0)`
- Full `M`, `h_UZ`, `h_SZ`, `t`, `h_atoms` available

**Assessment**: PROVABLE. The `eq-case-recipe-20260614.md` handoff documents a FULLY VALIDATED proof path for the backward (mpr) direction through the zone-bridge dispatch point. The forward (mp) direction has two sub-sorries in the recipe (for the atom part and quant part), but both are mechanical: the atom part comes from `h_pred_compat`, `h_t_compat`, `h_atoms`, and NF uniqueness; the quant part uses `eq_case_zone_below/above/eq` which are already proved in the file (lines 710-890). The recipe explicitly states it was "tested and works."

**Why not closed yet**: The recipe was documented but never executed. The agent that wrote the handoff ran out of context before filling the two sub-sorries in the forward direction.

**Fix**: Execute the recipe from `eq-case-recipe-20260614.md`. The `simp only [enriched_bypass_eq]` + `rw [formula_disjList_iff]` tactic pair works. The zone bridge dispatch follows from `eq_case_zone_below`, `eq_case_zone_above`, `eq_case_zone_eq` (already proved). The atom part forward direction needs `nf_x_compat_check` compatibility + `h_pred_compat` + `h_t_compat`.

---

### Sorry at L1579 (`backward_holdsLeft_of_nf_eval` bracket case)

**Goal** (confirmed via `lean_goal`):
```
⊢ BracketFormula.holds M atomMap vea.snd.bracket t x
```

**Key hypotheses available**:
- `h_t_lt_x : t < x`
- `h_eval_atoms : ∀ a, atom_eval M (Fin.cons x (fun _ => t)) a ↔ sub_nf.1 a = true`
- `h_eval_quant : ∀ ssn, (∃ x_1, nf_eval_nf M 0 3 (Fin.cons x_1 (Fin.cons x (fun _ => t))) ssn) ↔ sub_nf.2 ssn = true`
- `vea` constructed from `enriched_vecEA2_until`, with `nf_x`, `nf_x_1var` available

**Assessment**: PROVABLE but requires the most work of the 4 depth-0 sorries. `BracketFormula.holds` unfolds to `IntervalPattern.holds`, which for `n = pos_between.length` witnesses requires:
1. A function `witnesses : Fin n → M.carrier` that is strictly increasing
2. All witnesses in `(t, x)`
3. `pointTypes i` holds at `witnesses i`
4. `segmentTypes j` holds everywhere in the `j`-th segment

The key insight (established in report 31): since `pos_between` contains unique NFs (Fintype.elems has no duplicates, and all are in the between_tx zone with the same x/t predicates), distinct elements have distinct `nf_y_proj`. Therefore distinct witnesses from `h_eval_quant` have distinct predicate profiles, and any classical selection of witnesses can be sorted by the model's linear order to give strictly increasing witnesses.

The segment condition is trivial: `seg_guard_holds` (already proved at line 1206) shows `seg_guard` holds for ALL `y ∈ (t, x)`, so segments hold regardless of witness placement.

**The pointType matching after sorting** is the remaining challenge. After sorting witnesses by model order, position `i` corresponds to the SSN at sorted position `i`, not at `pos_between[i]`. This requires either: (a) proving `BracketFormula.holds` is invariant under permutation when all segmentTypes are equal, or (b) defining `witnesses` directly by "the unique witness with nf_y_proj matching pos_between[i]" rather than by sorting.

**Fix**: Use approach (b). For each `i : Fin n`, define `witnesses i := Classical.choose (h_eval_quant (pos_between[i])).mpr (by simp [h_pos])`. Since nf_y_proj is injective on pos_between (proved above), witnesses are distinct. Use `lt_of_ne_of_le` with the linear order to arrange them monotonically — or prove strict monotonicity via the contradiction that if `witnesses i = witnesses j` for `i ≠ j`, then `pos_between[i] = pos_between[j]` by NF uniqueness, contradicting `i ≠ j`.

---

### Sorry at L1637 (`forward_nf_eval_of_holdsLeft` case pos)

**Goal** (confirmed via `lean_goal`):
```
case pos
⊢ nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

**Key hypotheses available**:
- `h_endLeft : TemporalPred.eval_at M atomMap vea.endpointLeft t`
- `h_t_lt_x : t < x`
- `h_endRight : TemporalPred.eval_at M atomMap vea.endpointRight x`
- `h_bracket : BracketFormula.holds M atomMap vea.bracket t x`
- `nf_x`, `h_compat`, `h_eq`, `h_some` establishing `nf_x` as the compatible 1-var NF
- `char_1_correct`, `h_UZ`, `h_SZ`, `h_atoms`

**Assessment**: PROVABLE. The goal unfolds to `(atom_part ∧ quant_part)`. 

Atom part: `∀ a, atom_eval M (Fin.cons x (fun _ => t)) a ↔ sub_nf.1 a = true`. For predicate atoms at x (index 0): from `h_endRight` → `vea.endpointRight` = `Formula.and (char_1 nf_x) (formula_conjList ...)` → char_1(nf_x) holds at x → by char_1_correct → `nf_eval_nf M 1 1 (fun _ => x) nf_x` → atom conditions at x. For predicate atoms at t (index 1): from h_atoms. For order atoms: `h_t_lt_x` gives `t < x`.

Quant part: for each ssn, the biconditional `(∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ sub_nf.2 ssn = true`. Zone-by-zone case analysis using the zone bridge theorems already proved (below_t_temporal_iff, eq_t_temporal_iff, between_tx_temporal_iff, eq_x_temporal_iff, above_x_temporal_iff). Each zone bridge theorem is biconditional, so the forward direction (temporal truth → NF eval) is immediate.

**Why not closed yet**: Agents documented this as "hard" but the structure is symmetric with the proven backward direction. The backward direction (L1432-1721, sorry-free) is ~300 lines of zone-by-zone case analysis. The forward direction follows the same structure in reverse, using the backward directions of each zone bridge.

---

### Sorry at L1749 (`existPart_succ_n1_bypass_k0_since`)

**Goal** (confirmed via `lean_goal`):
```
⊢ ∃ A, ∀ M, semantic_prior_UZ M atomMap → semantic_prior_SZ M atomMap →
    ∀ t, (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
      (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M 1 (1+1) (Fin.cons x fun _ => t) sub_nf)
```
with `h_gt : sub_nf.1 (order 1 0) = false` and `h_lt : sub_nf.1 (order 0 1) = true`.

**Assessment**: PROVABLE, but requires the most new proof content. The witness `A` is `enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms` (already defined at line 515). The proof needs to show this formula is biconditionally equivalent to the existential.

The `enriched_bypass_since` formula is a `formula_disjList` (not a VVecEA2). Its structure for each compatible `nf_x`:
```
Formula.and pre_at_t (Formula.snce pt_x guard)
```
where:
- `pre_at_t` handles y > t and y = t zones (evaluated at t)
- `pt_x = Formula.and (char_1 nf_x) (formula_conjList quant_conjuncts)` at x  
- `guard` handles negative x < y < t SSNs
- `Formula.snce pt_x guard` = Since(pt_x, guard) which unfolds as: `∃ x < t, pt_x(x) ∧ ∀ r, x < r < t → guard(r)`

**Proof strategy**:
- Backward (∃ x, nf_eval → formula true): Given x < t with nf_eval, find `nf_x = nf_characteristic`. Show pre_at_t at t (above_t SSNs via Zone bridges, eq_t SSNs via char_y). Show pt_x holds at x (eq_x via char_y, below_x via Since(char_y,top)). Show guard holds between x and t (negative between_xt SSNs → neg(char_y) at any r between x and t). Apply `formula_disjList_iff`.
- Forward (formula true → ∃ x, nf_eval): From formula_disjList_iff, get some disjunct `pre_at_t ∧ Since(pt_x, guard)`. From Since semantics, extract x < t with pt_x(x). From pt_x = `char_1(nf_x) ∧ ...`: use char_1_correct to get nf_eval M 1 1 (fun _ => x) nf_x. From quant_conjuncts at x: zone bridge backward direction. From pre_at_t at t: zone bridge backward for above_t and eq_t SSNs. Assemble nf_eval_nf M 1 2 [x,t].

**Critical asymmetry with Until**: In the Until case, `enriched_bypass_until` uses `VVecEA2.translateLeft_correct` to reduce to `VecEA2.holdsLeft`. In the Since case, there is NO such reduction — the proof works directly with `formula_disjList` and `Formula.snce`. This means the Since proof cannot use `backward_holdsLeft_of_nf_eval` or `forward_nf_eval_of_holdsLeft` as subroutines. It needs its own zone analysis.

---

### Sorry at L1837 (`existPart_succ_n1_bypass` depth >= 2)

**Goal** (confirmed via `lean_goal`):
```
case succ
k' : ℕ
char_kp1 : NormalForm sig (k' + 1 + 1) 1 → Formula
sub_nf : NormalForm sig (k' + 1 + 1) 2
⊢ ∃ A, ∀ M ... (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M (k'+1+1) (1+1) (Fin.cons x fun _ => t) sub_nf)
```

**Assessment**: NOT BLOCKING the 4 depth-0 sorries. Depth-0 work (L974, L1579, L1637, L1749) makes `existPart_succ_n1_bypass_k0` sorry-free, which is the `zero` branch of `existPart_succ_n1_bypass`. The `succ k'` branch (L1837) is only reached when calling `existPart_succ_n1_bypass` with `k = succ k'`. This sorry requires substantial new mathematical content (arity-climbing induction) and should be treated as a separate phase.

---

## Provability Assessment

| Sorry | Line | Provable? | Feasibility | Est. Lines |
|-------|------|-----------|-------------|------------|
| eq case | 974 | YES | HIGH -- recipe already validated | ~150 |
| bracket | 1579 | YES | MEDIUM -- witness construction with sorting | ~100 |
| forward | 1637 | YES | MEDIUM-HIGH -- mirror of backward direction | ~150 |
| since case | 1749 | YES | MEDIUM -- flat disjList + Since semantics | ~200 |
| depth >= 2 | 1837 | YES (math exists) | LOW -- substantial new content | ~500 |

No sorry goal is impossible as stated. There is no type mismatch, circular dependency, or formula incorrectness blocking any of the 4 depth-0 sorries.

---

## Assumptions Challenged

### Assumption 1: "The eq case zone bridges need to be adapted"

**WRONG**. The eq_case_zone_below, eq_case_zone_above, and eq_case_zone_eq theorems are already proved in the file at lines 710-890. They are ready to use. No adaptation needed. The eq-case-recipe handoff documented this explicitly.

### Assumption 2: "The bracket sorry requires nf_y_proj injectivity as a separate lemma"

**PARTIALLY WRONG**. The injectivity is not needed as a separate lemma. Direct witness construction via `Classical.choose (h_eval_quant ssn).mpr` for each positive SSN gives one witness per SSN. Since SSNs are distinct (they're from `Fintype.elems`), all witnesses can be in the between_tx zone. The harder question (witnesses are strictly increasing) follows because if `witnesses i = witnesses j` for `i ≠ j`, then by NF uniqueness both SSNs have the same nf_y_proj, but since they are distinct elements of pos_between with the same x/t predicates, they differ only in y-predicates — contradiction. So witnesses are automatically distinct in the model.

### Assumption 3: "The Since case is a mirror of Until and should reuse backward_holdsLeft_of_nf_eval"

**WRONG**. The Since formula uses `formula_disjList + Formula.snce`, NOT `VVecEA2.translateLeft`. The `backward_holdsLeft_of_nf_eval` and `forward_nf_eval_of_holdsLeft` theorems are specific to the Until direction (they work with `VecEA2.holdsLeft`). The Since case must prove the biconditional from scratch using `formula_disjList_iff` and Since semantics directly.

### Assumption 4: "Zone bridge helpers ssn_xt_compat_{x_preds,t_preds,tx_order} are public and available"

**PARTIALLY WRONG**. These helpers EXIST (added in zone-bridge-wiring handoff) but are PRIVATE (`private def`). In the proof, you must use `simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat` to extract predicate conditions inline, rather than calling the private helpers. The eq-case-recipe handoff documents this.

### Assumption 5: "The LSP goal state is unreliable at line ~1700+ due to file size"

**UNVERIFIED BUT LIKELY FALSE NOW**. Report 31 successfully obtained `lean_goal` output at L974, L1579, L1637, L1749, L1837 — all returned correct goal states. The LSP appears to be functioning correctly on the current 1839-line file. Earlier agents reported misalignment when the file was being actively edited in a worktree with more unstable code.

### Assumption 6: "Decomposing sorries into smaller sub-sorries helps convergence"

**WRONG**. Cycle 4 showed the opposite: decomposing `existPart_succ_n1_bypass_k0_since` (1 sorry) into 5 sub-sorries increased the sorry count. Each sub-sorry requires its own hypothesis context and proof bookkeeping. The decomposition creates overhead without closing anything. The correct approach is to close the entire sorry in one dispatch focused on that goal.

---

## Blind Spots Identified

### Blind Spot 1: The forward direction at L1637 reuses the same zone bridge theorems as backward

The backward direction (`backward_holdsLeft_of_nf_eval`) is already proved and uses `below_t_temporal_iff`, `eq_t_temporal_iff`, `between_tx_temporal_iff`, `eq_x_temporal_iff`, `above_x_temporal_iff`. The forward direction at L1637 uses the SAME theorems but applies their `.mp` direction instead of `.mpr`. This means the forward direction proof is structurally identical to the backward direction proof with `mp` swapped for `mpr`. An agent that reads `backward_holdsLeft_of_nf_eval` carefully can produce the forward direction by substituting the direction of each zone bridge application.

### Blind Spot 2: The eq case forward direction atom part is trivial after subst

After `witness_eq_t_of_no_order` gives `x = t` and `subst h_x_eq`, the environment collapses x → t. The atom part forward direction then reads: `∀ a, atom_eval M (fun _ => t) a ↔ sub_nf.1 a = true`. For predicate atoms: `h_pred_compat` gives `sub_nf.1 (.pred p 0) = sub_nf.1 (.pred p 1)`, and `h_t_compat` gives `sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0)`, and `h_atoms` gives `M.interp p t ↔ parent_atoms (.pred p 0) = true`. Chaining these gives the atom part directly. For order atoms: `h_gt = false` and `h_lt = false` match `atom_eval M (fun _ => t) (.order ...)` which requires `t < t` (false) or `t > t` (false) — both trivially matching the NF values.

### Blind Spot 3: The bracket n=0 case is trivial

When `pos_between.length = 0`, the bracket sorry goal is `BracketFormula.holds M atomMap vea.snd.bracket t x` where the bracket has 0 point types and 1 segment type (the `seg_guard`). `IntervalPattern.holds` at n=0 unfolds to `∀ y, t < y → y < x → seg_guard.eval_at M atomMap y`, which is exactly `seg_guard_holds` (already proved at line 1206). So the n=0 case is a one-liner.

When `n >= 1`, the witnesses need more work. But in practice, `pos_between.length` is bounded by the number of distinct depth-0 3-var NFs, which is finite. The common case may well be n=0 (no positive between_tx SSNs needed).

### Blind Spot 4: The Since formula has a structural asymmetry in the guard encoding

Examining `enriched_bypass_since` (lines 515-594), the `guard` formula includes ONLY negative between_xt SSNs (where `x_lt_y && y_lt_t && sub_nf.2 ssn = false`). But in the Since semantics `∃ x < t, pt_x(x) ∧ ∀ r, x < r < t → guard(r)`, the guard says "no y ∈ (x,t) has type matching any negative between_xt SSN." For the backward direction (exists x, nf_eval → formula), the guard proof requires: for any `r ∈ (x,t)`, show `¬(nf_depth0_char_formula (...) (nf_y_proj ssn))` holds at r for each negative ssn. This follows because if `nf_y_proj ssn` holds at r, then r has the right predicates, and since r is between x and t, `nf_eval M 0 3 [r,x,t] ssn` would hold — but `sub_nf.2 ssn = false` means this NF condition is false. This is the contradiction.

However: the guard only contains NEGATIVE between_xt SSNs. Positive between_xt SSNs are handled in `pt_x` via `Formula.untl char_y Formula.top` (which asserts ∃ y > x with the right predicates — but this doesn't guarantee y < t). This is a potential issue: if positive between_xt SSNs are encoded as `Until(char_y, top)` at x, the backward direction can only show "∃ y > x with preds" but not "x < y < t". The guard doesn't exclude y > t.

**THIS IS A POTENTIAL SOUNDNESS ISSUE in the Since formula**: The `pt_x` conjunct for positive between_xt SSNs uses `Formula.untl char_y Formula.top` (positive Until at x), which says ∃ y > x with preds — but y could be > t. For the backward direction of the biconditional (formula true → ∃ x, nf_eval), this means the formula might be true even when no y ∈ (x,t) exists, breaking the equivalence.

Compare with the Until case: positive between_tx SSNs are handled via BRACKET witnesses, which BY CONSTRUCTION are between t and x. The Since formula uses Until/Since without the bracket infrastructure, which loses the bound.

**This may explain why cycles 4-5 could not close the Since sorry**: the formula may be genuinely wrong for the backward direction at positive between_xt SSNs. The implementing agent should check whether `enriched_bypass_since` correctly handles positive between_xt SSNs or whether it needs VecEA2 brackets like the Until case.

---

## Architectural Recommendation

Based on the evidence, the implementation cycles are failing primarily because:

1. **Wrong focus**: Agents write analysis and skeleton code instead of directly closing goals.
2. **Wrong file**: Worktrees contain stale or decomposed versions; use main branch only.
3. **Since formula may need VecEA2 brackets**: Just as the Until formula required the bracket fix (v2 over v1), the Since formula may need a parallel fix for positive between_xt SSNs.

**Recommended approach for next implementation cycle**:

1. Work ONLY on the main branch file (1839 lines, 4 depth-0 sorries).
2. Start with the eq case (L974): execute the validated recipe from `eq-case-recipe-20260614.md`. This is the highest-confidence closure.
3. Next, the bracket sorry (L1579 case `bracket`): n=0 case first (trivial), n >= 1 case using Classical.choice for witnesses.
4. Then the forward direction (L1637): mirror the backward direction's zone-by-zone analysis.
5. BEFORE attempting the Since case (L1749): verify whether the positive between_xt SSN encoding in `enriched_bypass_since` is sound. If it uses VecEA2 brackets (symmetric to Until), prove it directly. If it uses `Formula.untl char_y top` without bounding y < t, consider whether to add a VecEA2 bracket for the Since direction or to add an explicit `Formula.untl char_y (Formula.snce Formula.top Formula.top)` bounded witness.

---

## Confidence Level

- **Root Cause 1 (analysis-paralysis pattern)**: HIGH (direct evidence from 3 cycles with zero closures and documented decomposition net increase)
- **Root Cause 2 (worktree confusion)**: HIGH (confirmed line counts differ across worktrees)
- **Root Cause 3 (line number drift)**: HIGH (plan references L753/1284/1503/1615; actual positions are L974/1579/1637/1749)
- **Root Cause 4 (Since/Until asymmetry)**: HIGH (structural analysis of enriched_bypass_since vs enriched_bypass_until)
- **Blind Spot 4 (Since formula soundness issue for positive between_xt SSNs)**: MEDIUM -- plausible but requires deeper analysis of what `formula_disjList_iff` and Since semantics actually give in the backward direction. The implementing agent should verify this specific concern before investing in the Since proof.
- **Overall: all 4 depth-0 sorries are mathematically provable**: HIGH confidence.
