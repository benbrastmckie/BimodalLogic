# Teammate B Findings: Codebase Infrastructure Analysis for Task 273

**Scope**: Infrastructure inventory and feasibility analysis for the three proposed approaches to closing the 3 sorry sites in `StaviCompleteness.lean` (lines 2405, 2487, 2857).

**Files examined**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (3327 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (1240 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Decomposition.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`
- `specs/273_chronicle_gap_contradiction_proof/plans/16_interval-zone-match-plan.md`

---

## Key Findings

### Finding 1 (CRITICAL, new): `nf_exist_sf_guarded_backward` (sorry at 2857) is mathematically FALSE as stated

**Confidence: HIGH**

The formula `nf_exist_sf_guarded` (StaviCompleteness.lean:2656-2692) depends ONLY on
`sub_nf.atom_assgn`, never on the quantifier part `sub_nf.quant_assgn`:

- `nf_t_consistent` (line 1475) reads only `sub_nf.atom_assgn (.pred p 1)`
- the order-consistency check reads only `sub_nf.atom_assgn (.order ...)`
- `atom_compat` filters witness types only by `sub_nf.atom_assgn (.pred p 0)`
- `nf_order_0_1` (line 1461) reads only the two order atoms
- the guard `interval_guard_sf char_k` is a disjunction of `char_k` over ALL 1-var NFs and is **always true** (`interval_guard_sf_true`, line 2637) — it constrains nothing and does not mention `sub_nf`

Consequently, for `k >= 1`, any two `sub_nf : NormalForm sig k 2` sharing the same atom
assignment but differing in quantifier part map to **the same StaviFormula** (the documented
"collision bug" at lines 3121-3123 that `nf_exist_sf` had; the guarded variant did NOT fix it).

Counterexample schema: let `sub_nf1 = nf_characteristic M k 2 (x0, t)` for any realized pair
(so the formula is true at `t` by `nf_exist_sf_guarded_forward`), and let
`sub_nf2 := (sub_nf1.atom_assgn, fun _ => false)`. `sub_nf2` is unrealizable in ANY nonempty
structure (the extension `w := x` always realizes its own depth-(k-1) 3-var characteristic NF,
so the quant part cannot be all-false). Both share `h_sf`, so the backward lemma would conclude
`∃ x, nf_eval_nf M k 2 (x, t) sub_nf2` — false.

**Implication**: closing sorries 1-2 (the transfer/bridge math) does NOT close sorry 3.
Sorry 3 requires a **formula redesign**, not a proof. The file's own design comment
(lines 2613-2624) already describes the correct fix: enumerate configurations
`(nf_x, ordering, interval_type_set S)` that produce `sub_nf` via the bridge lemma, and build
a detecting formula per configuration (witness `char_k nf_x` via Until/Since, with the
intermediate guard "current point's type ∈ S" plus, for each `s ∈ S`, "type s occurs strictly
between"). All of this is U/S-expressible with the available `char_k`.

The same falsehood applies to the discrete analogue (DiscreteStaviCompleteness.lean:338,
same formula, same collision; ℤ-like models satisfy the discrete instances).

**Containment**: the damage is modular. `nf_characterizable_by_stavi` (line 3130) consumes only
the existential statement `nf_2var_existence_characterizable` (line 2899) via `Classical.choose`.
That existential statement is plausibly TRUE — only its current witness
(`nf_exist_sf_guarded` + `nf_2var_exist_sf_classical`, line 2862/3109) is wrong. Replacing the
witness formula breaks nothing downstream.

### Finding 2: The plan-v16 circularity claim is wrong at the call-graph level, right at the strategy level

**Confidence: HIGH**

`nf_2var_existential_transfer` (line 2266) does **NOT** call `nf_fraisse_compression`. Verified
call graph:

```
nf_2var_from_interval_data (2500)
  ├─ calls nf_fraisse_compression (at 2570)          [fully proved, line 2006, arity-generic]
  └─ calls nf_2var_existential_transfer (at 2571)    [contains sorries 2405/2487]
       └─ calls zone_match_witness (2298, 2423)      [fully proved, line 2044]
nf_2var_transfer (2576) ── calls nf_2var_from_interval_data (2604)   [fully proved otherwise]
```

There is no cycle in the code. The circularity is purely a **proof-strategy** dead end for
closing the sorry at 2405 within arity 3: the goal there (exact `lean_goal` output obtained) is

```
⊢ (∃ w', nf_eval_nf M' j' 4 (w' :: u' :: x' :: t') sub_nf) ↔
  (∃ w,  nf_eval_nf M  j' 4 (w  :: u  :: x  :: t ) sub_nf)
```

with `hj : j' + 1 < k`, pairwise depth-k 1-var NF agreement for u/x/t, all pairwise orderings,
but interval/above/below data **only for the (x,t) pair**. Closing it via
`existential_transfer_from_nf` (NFGameBridge.lean:719) needs 3-var NF agreement at depth j'+1
for (u,x,t)/(u',x',t'); getting that via `nf_fraisse_compression` needs 4-var transfer at all
depths ≤ j' for the inner configuration — the goal itself. The strategy-circularity is real and
the only escape is generalizing over arity (Approach 2). The plan's lines 280-300 ("strong
induction on j works") are refuted by its own later analysis (lines 499-578): the outer IH covers
only the (x,t) configuration, not the inner (u,x,t) one. The configuration grows by one point
per round, so the induction MUST carry arity `n` free.

### Finding 3: Infrastructure inventory

**Confidence: HIGH** (all signatures read directly from source)

| Item | Location | Status | Arity-generic? |
|---|---|---|---|
| `NormalForm sig k n` | NormalForm.lean:134 | proved | yes — `(AtomKind sig n → Bool) × (NormalForm sig k' (n+1) → Bool)`; the quant part IS the indicator of the realized (n+1)-var depth-(k-1) extension-type set |
| `nf_eval_nf`, `nf_characteristic`, `nf_eval_unique`, `nf_characteristic_satisfies`, `nf_agreement_from_shared_nf`, `atom_agreement_from_nf` | NormalForm.lean:198-330 | proved | yes (all n) |
| `nf_fraisse_compression` | StaviCompleteness.lean:2006 | **proved** (NOT in NFGameBridge as the task brief said) | yes — takes `(k n : Nat)`, atoms agreement + transfer at all `j < k` for (n+1)-var, concludes depth-k n-var `nf_characteristic` equality |
| `existential_transfer_from_nf` | NFGameBridge.lean:719 | proved | yes — n-var NF agreement at depth d+1 ⟹ (n+1)-var existential transfer at depth d |
| `atom_agree_from_pointwise` | StaviCompleteness.lean:2216 | proved | **yes, already arbitrary arity n** — pairwise 1-var NF agreement (all depths) + pairwise order agreement ⟹ n-var atom agreement |
| `zone_match_witness` | StaviCompleteness.lean:2044 | proved | 2-point configurations only (x,t). Returns u' with same **depth-k** 1-var `nf_characteristic` and 4 ordering iffs. Does NOT return any sub-interval data |
| `interval_nf_types` | StaviCompleteness.lean:1835 | def | `Finset (NormalForm sig k 1)`: full-model depth-k 1-var types of points in open interval (lo,hi) |
| `interval_2var_nf_types` | StaviCompleteness.lean:1847 | def, **completely unused** (grep: definition site is its only occurrence in the repo) | `Finset (NormalForm sig k 2)`: depth-k 2-var NFs of `(u, hi)` for u in (lo,hi) — anchored at `hi` only |
| `interval_nf_types_depth_decrease` | StaviCompleteness.lean:1904 | proved | depth-(k+1) interval-set equality ⟹ depth-k equality |
| `above_max_depth_decrease` / `below_min_depth_decrease` | 1942 / 1971 | proved | same for outer zones |
| `nf_char_depth_decrease`, `nf_depth_k_from_shared_succ` | 1857 / 1886 | proved | 1-var only as stated (proof technique generalizes) |
| Game pipeline: `decomposition_agreement`, `ghr93_game_iff_decomposition`, `ghr93_strategy_compose` | Decomposition.lean:62-302, Composition.lean:40 | proved | general; but the NF→game bridge (`discrete_nf_to_decomposition_agreement`, NFGameBridge.lean:997) exists only under discrete instances (SuccOrder/PredOrder/Archimedean) |

Missing infrastructure (does not exist anywhere):
- **Projection lemma**: (n+1)-var depth-d NF of a tuple determines the n-var depth-d NF of any
  sub-tuple. Needed by every approach that extracts 1-var data from 2-var/3-var types (~100-150
  lines, induction on d).
- **Splitting lemma**: given depth-d interval-type-set agreement for (x,t)/(x',t') and
  `u ∈ (x,t)`, produce `u' ∈ (x',t')` with matching 1-var NF AND matching sub-interval type sets
  for (x,u)/(x',u') and (u,t)/(u',t') at depth d-1. **This is the irreducible mathematical kernel
  of all three approaches.** Nothing in the codebase proves or approximates it.
- n-point zone matching (zone classification of a new point against an n-point configuration).
- For `interval_2var_nf_types`: zero supporting lemmas (no depth-decrease analogue, no
  membership lemmas, no temporal extraction).

### Finding 4: Exact sorry-site anatomy

**Confidence: HIGH** (lean_goal run at 2405; 2487 is the mirror image; 2857 has no proof body)

- **2405 / 2487** (inside `nf_2var_existential_transfer`, forward/backward symmetric): the
  quantifier component of depth-(j'+1) 3-var NF agreement for (u,x,t)/(u',x',t') after
  zone-matching u→u'. Equivalent to 4-var existential transfer at depth j' for the 3-point
  configuration. Hypotheses available: pairwise depth-k 1-var NF equality (u,x,t), all 9 ordering
  iffs, (x,t)-interval/above/below data at depth k, `j' + 1 < k`. **Missing**: interval data for
  the new pairs (u,x) and (u,t).
- **2857** (`nf_exist_sf_guarded_backward`): entire proof is sorry. The in-file comment
  ("the bridge lemma is sorry'd (nf_2var_from_interval_data)") is **stale and wrong** —
  `nf_2var_from_interval_data` has a complete proof body (it inherits sorry-taint only through
  `nf_2var_existential_transfer`). Per Finding 1, this statement is false and must be replaced,
  along with `nf_exist_sf_guarded`'s definition, by a configuration-enumerating formula.

---

## Approach Feasibility Analysis

### Approach 1 — Replace `interval_nf_types` with `interval_2var_nf_types` throughout: NOT RECOMMENDED

**Confidence: HIGH on the cost analysis, MEDIUM on the mathematical dead-end claim**

1. **Zero existing support**: `interval_2var_nf_types` is dead code — no lemma in the repo
   touches it. Everything (depth-decrease, membership transfer, zone matching against it,
   projection back to 1-var types) is new code. Estimate ~800-1200 lines.
2. **Breaks live callers**: `zone_match_witness` is called with 1-var data at 4 sites — two in
   the sorry'd theorem (fine) and two in the **fully proved discrete pipeline**
   (NFGameBridge.lean:1111, 1154 inside `discrete_nf_to_decomposition_agreement`). Strengthening
   its hypotheses breaks the discrete path, which has no 2-var interval data. (Mitigation: add a
   strengthened variant instead of replacing — but proving the variant IS the splitting lemma.)
3. **Anchor asymmetry — the math does not close**: `interval_2var_nf_types` anchors pairs at
   `hi` only. The depth-k 2-var NF of (u,t) determines (via its quant part, order pattern
   u<w<t, plus the missing projection lemma) the depth-(k-1) 1-var types in the UPPER
   sub-interval (u,t). It says nothing that bounds witnesses below by `x`, so the LOWER
   sub-interval (x,u) split is still not determined. The sub-interval matching problem survives
   the strengthening for one of the two sub-intervals.
4. **Fatal interaction with sorry 3**: even if the strengthened bridge were proved, the
   backward-direction formula at 2857 must EXTRACT the bridge hypotheses from temporal-formula
   truth. At the relevant stage of the induction in `nf_characterizable_by_stavi` (line 3140),
   only `char_k` for depth-k **1-var** NFs exists. There is no temporal detector for depth-k
   2-var interval types — constructing one is precisely the 2-var-existence characterization
   being built (bootstrapping circularity at the formula level). 1-var interval type sets ARE
   extractable (evaluate `char_k` at intermediate points under Until/Since). So the bridge's
   hypothesis interface must stay 1-var for the completeness chain to close.

### Approach 2 — Depth-decreasing game (`game_transfer_at_depth`, induction on d, arity n free): RECOMMENDED, with one identified hard kernel

**Confidence: HIGH on infrastructure reuse, MEDIUM on the remaining math gap**

This is the only approach consistent with both the strategy-circularity (Finding 2: arity must
grow, so n must be free) and the 1-var extraction constraint (Approach 1 item 4).

Reusable as-is (no modification):
- `atom_agree_from_pointwise` — already handles the arity-n atom base/step obligations.
- `nf_fraisse_compression` — already arity-generic; converts per-depth transfer into NF equality.
- `existential_transfer_from_nf` — converts n-var depth-(d+1) NF agreement into (n+1)-var
  transfer at depth d; useful for wiring the conclusion back into the 2405/2487 goals.
- `interval_nf_types_depth_decrease`, `above_max_depth_decrease`, `below_min_depth_decrease` —
  give the old-pairs interval data at the decremented depth at each round.
- `nf_agreement_monotone`, `nf_depth_k_from_shared_succ`, `nf_char_depth_decrease` — depth
  bookkeeping.
- `zone_match_witness` — reusable as the 2-point kernel of an n-point zone match, OR its 5-case
  proof skeleton (lines 2064-2186) can be transplanted.

New code required:
1. **Splitting lemma** (the kernel, ~200-400 lines IF provable from 1-var data): zone match must
   additionally return sub-interval type-set agreement at depth d-1 for the two new pairs.
   Whether this follows from depth-d 1-var full-model interval-set agreement (+ endpoint NF
   agreement) is exactly GHR93 Prop 7 / 12.8.18's inductive content, which the file header
   (1813-1831) asserts is true with **1-var** data. This needs literature verification
   (teammate-A scope). Note the full-model depth-d NF of u is strong: its quant part encodes
   u's entire depth-(d-1) 2-var extension spectrum (everything above/below u globally) — the
   plausible mechanism by which 1-var data suffices. If GHR93's proof does NOT support it,
   the task should be marked BLOCKED for user review rather than papering over.
2. **n-point zone match + invariant record** (~150-250 lines): a structure bundling pairwise
   1-var NF agreement, pairwise orderings, adjacent-pair interval sets, above-max/below-min
   sets; plus the lemma classifying a new point against n points (reuses the 2-point proof
   shape).
3. **Projection lemma** (~100-150 lines): needed when the new point lands in the outer zones
   (above max / below min), to derive the new outer-zone sets at depth d-1 from the matched
   point's depth-d NF.
4. **`game_transfer_at_depth`** (~150-300 lines): induction on d with the invariant; atoms via
   `atom_agree_from_pointwise`; quant via zone-match + splitting + IH at (d-1, n+1).
5. **Rewiring 2405/2487** (~30-60 lines): instantiate at n=3, depth j'+1 for (u,x,t), then
   `existential_transfer_from_nf` (or read the quant component directly). The top-level
   instantiation needs the splitting lemma once more to supply (u,x)/(u,t) data from the
   (x,t) hypotheses — consistent, no extra machinery.

Total estimate: ~600-1100 new lines, no existing proofs broken, no signature changes to proved
theorems.

### Approach 3 — Hybrid (add `interval_2var_nf_types` hypothesis only to `nf_2var_existential_transfer`, derive it inside `nf_2var_from_interval_data`): NOT VIABLE

**Confidence: HIGH**

The derivability claim ("derive 2-var interval agreement from 1-var interval agreement +
endpoint NFs") is, unfolded, the bridge lemma applied to each pair (u,t) with u inside the
interval — which requires interval data for the sub-interval (u,t), which is the sub-interval
matching problem again. The hybrid does not reduce the mathematical content; it relocates the
identical gap one lemma earlier, and inherits Approach 1's anchor asymmetry (item 3) and its
lack of any supporting infrastructure. Additionally, if the derivation WERE provable, then
1-var hypotheses would suffice end-to-end and Approach 2 subsumes it.

---

## Recommended Approach

**Approach 2 (depth-decreasing game with arity n free), with two mandatory additions:**

1. **Reformulate sorry 3 first (independent of the bridge math)**: replace `nf_exist_sf_guarded`
   with the configuration-enumerating formula sketched in the file's own comments (2613-2624),
   since the current backward statement is false (Finding 1). The replacement keeps the 1-var
   interface: configurations are `(nf_x, direction, S : Finset (NormalForm sig k 1))` filtered
   by "bridge yields sub_nf", detected by `char_k`-based Until/Since formulas. Only
   `nf_2var_exist_sf_classical` and `nf_exist_sf_guarded_backward/forward` are replaced; the
   existential wrapper `nf_2var_existence_characterizable` and everything downstream
   (`nf_characterizable_by_stavi`, `stavi_expressive_completeness`) are untouched.
2. **Gate Phase 1 on a literature check of the splitting lemma** (GHR93 Prop 7 / Prop 12.8.18
   proof, whether the interval invariant is full-model 1-var type sets or substructure
   theories). If the literature uses interval-substructure theories (composition method) rather
   than full-model type sets, the invariant record in Approach 2 item 2 must carry segment
   0-var data instead, and the existing game pipeline (Decomposition.lean/Composition.lean,
   already sorry-free) becomes the better vehicle — at the cost of building the general
   (non-discrete) NF→game Bridge A analogous to `discrete_nf_to_decomposition_agreement`.

Approach ranking by (new code, breakage, mathematical risk):
1. **Approach 2**: ~600-1100 lines, zero breakage, math risk concentrated in one lemma.
2. Approach 1: ~800-1200 lines, breaks discrete pipeline call sites (or duplicates lemmas),
   PLUS unsolved lower-sub-interval gap, PLUS makes sorry 3 unfixable (no 2-var temporal
   extraction).
3. Approach 3: smallest apparent diff but the central claim is equivalent to the unsolved
   kernel; no infrastructure exists for it.

---

## Evidence / Examples

- Goal at 2405 (verbatim from `lean_goal`): hypotheses include `hj : j' + 1 < k`,
  `h_nf_u/x/t : nf_characteristic M k 1 ... = nf_characteristic M' k 1 ...`, ordering iffs
  `h_ux h_xu h_ut h_tu`, `h_3var_atoms`, and the (x,t)-only interval data; goal
  `(∃ w', nf_eval_nf M' j' (2+1+1) (Fin.cons w' (u',x',t')) sub_nf) ↔ (∃ w, nf_eval_nf M j' (2+1+1) (Fin.cons w (u,x,t)) sub_nf)`.
- `nf_fraisse_compression` signature (2006): `(k n : Nat) ... (h_atoms : ∀ a : AtomKind sig n, ...) (h_transfer : ∀ j < k, ∀ chi : NormalForm sig j (n+1), (∃ u, ...) ↔ (∃ u', ...)) : nf_characteristic M k n env_M = nf_characteristic M' k n env_M'`.
- `existential_transfer_from_nf` signature (NFGameBridge:719): `{d n : Nat} ... (h_sig_nf : ∀ nf : NormalForm sig (d+1) n, nf_eval_nf M (d+1) n env_M nf ↔ nf_eval_nf M' (d+1) n env_M' nf) : ∀ chi : NormalForm sig d (n+1), (∃ w, ...) ↔ (∃ w', ...)`.
- `atom_agree_from_pointwise` (2216) is already stated for arbitrary `n` with hypotheses
  `h_nf : ∀ i : Fin n, ∀ k, ∀ nf, ...` and `h_order : ∀ i j : Fin n, ...`.
- Collision-bug dependency trace: `nf_exist_sf_guarded` (2656) reads `sub_nf` only through
  `nf_t_consistent` (1475: atoms), the order-atom pair (2667-2668), `atom_compat` (2673-2676),
  `nf_order_0_1` (1461: atoms), and the equality-case order atoms (2688-2689). The quant part
  `sub_nf.2` is never consulted. Guard `interval_guard_sf` (2631) is `sub_nf`-independent and
  provably always true (2637).
- `interval_2var_nf_types` usage count: 1 occurrence in the entire repo (its definition, 1847).
- `zone_match_witness` call sites: StaviCompleteness 2298, 2423 (inside the sorry'd theorem);
  NFGameBridge 1111, 1154 (inside the proved discrete Bridge A).
- Sorry census in EFGames: StaviCompleteness 2405, 2487, 2857; DiscreteStaviCompleteness 338.
  No other sorries in the EFGames directory.

## Confidence Levels

| Finding | Confidence |
|---|---|
| 2857 statement false (collision bug) | HIGH — verified by direct definition trace; counterexample schema is elementary |
| No call-graph circularity; strategy-level circularity real | HIGH — verified by reading proof bodies + lean_goal |
| Infrastructure inventory and arity-generality claims | HIGH — signatures read from source |
| Approach 1 cost/breakage | HIGH |
| Approach 1 anchor-asymmetry math gap | MEDIUM — needs literature cross-check |
| Approach 2 line estimates | MEDIUM |
| Splitting lemma provable from 1-var full-model type sets | LOW/UNKNOWN — this is the open kernel; gate on GHR93 literature extraction (teammate-A) |
