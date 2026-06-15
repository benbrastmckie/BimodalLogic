# Teammate D (Horizons) Research Findings: Strategic Direction and Architecture

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Teammate**: D (Horizons) — Strategic direction and creative alternatives
- **Artifact Number**: 33
- **Date**: 2026-06-15
- **Session**: sess_1750002000_d4e5f6

## Summary

The KampBypass.lean sorry chain is now almost entirely mechanical at depth 0 (4 sorries remaining after the eq-case recipe was documented). The architectural analysis reveals that the current enriched-formula approach is sound and should be continued — no wholesale rewrite is warranted. The one genuinely hard sorry (`existPart_succ_n1_bypass` at depth >= 2, line 1837) has a clean recursive structure that mirrors depth 0. The key strategic finding is that the biggest leverage for reducing friction is **file splitting**, not formula redesign: KampBypass.lean at 1839 lines is becoming unwieldy, and the Since case (line 1749) is a near-symmetric mirror of the Until case whose 430+ lines of proof live in the same file. Splitting the file would allow focused dispatch without heartbeat budget conflicts. Automation opportunities exist for the conjunct-extraction goals in the zone-bridge wiring.

---

## Sorry Chain Map

### Full Dependency Tree from `completeness_discrete`

```
completeness_discrete (Completeness.lean:309)
  ├─── SORRY CHAIN A (task 273 — this task)
  │    US_expressively_complete_over_prior (PriorExpressiveness.lean:346)
  │      kamp_prior_expressive_completeness (KampPrior.lean:175)
  │        nf_characterizable_temporal_prior (NfCharFormula.lean)
  │          nf_characterizable_temporal_prior_classical
  │            nf_2var_exist_formula_prior (NfCharFormula.lean:612)
  │              [depth 0]: nf_2var_exist_depth0_tl — SORRY-FREE
  │              [depth 1]: existPart_succ_n1_bypass_k0 (KampBypass.lean:1760)
  │                ├─ existPart_succ_n1_bypass_k0_eq:
  │                │    compatible subcase (L974) — SORRY (needs filling)
  │                ├─ existPart_succ_n1_bypass_k0_until:
  │                │    backward_holdsLeft_of_nf_eval, bracket case (L1579) — SORRY
  │                │    forward_nf_eval_of_holdsLeft (L1637) — SORRY
  │                └─ existPart_succ_n1_bypass_k0_since (L1749) — SORRY (entire theorem)
  │              [depth >= 2]: existPart_succ_n1_bypass (KampBypass.lean:1810)
  │                └─ succ k' case (L1837) — SORRY (depth >= 2)
  │
  └─── SORRY CHAIN B (task 202 — Reynolds k-equivalence bypass)
       succ_cofinal → limitDomSubtype_isSuccArchimedean → succ_embed_surjective
         → countermodel_discrete_enriched → completeness_discrete
```

### Summary of KampBypass Sorries (5 total)

| Line | Theorem | Nature | Feasibility |
|------|---------|--------|-------------|
| L974 | `existPart_succ_n1_bypass_k0_eq` compat subcase | Zone-bridge wiring, eq case | HIGH |
| L1579 | `backward_holdsLeft_of_nf_eval` bracket case | IntervalPattern witness construction | MEDIUM |
| L1637 | `forward_nf_eval_of_holdsLeft` | NF reconstruction from VecEA2 holdsLeft | MEDIUM-HIGH |
| L1749 | `existPart_succ_n1_bypass_k0_since` | Mirror of Until case, Since direction | MEDIUM |
| L1837 | `existPart_succ_n1_bypass` succ case | Recursive depth >= 2 bypass | MEDIUM (recursive induction) |

**Non-KampBypass sorries on the critical path**: None. The `nf_exist_backward_prior` sorry (NfCharFormula.lean:542) is dead code on the critical path (the `nf_2var_exist_formula_prior` theorem at L612 bypasses it via KampBypass/VecEA2). Similarly, `NegationClosure.lean:1716` (`nf_exist_formula_nested_backward`) is the alternative approach; it is NOT on the critical path because `US_expressively_complete_over_prior` now uses `kamp_prior_expressive_completeness` (Kamp bypass) rather than `stavi_expressive_completeness` (the Stavi chain). `VecEADecomposition.lean:285/313` are also on a blocked alternative approach.

### Alternative Paths to `completeness_discrete`

There is no alternative path to `completeness_discrete` that bypasses KampBypass.lean entirely, given the current architecture. The Stavi chain (`stavi_expressive_completeness`) was replaced by the Kamp bypass precisely because it had its own sorry (`nf_2var_existential_transfer` in StaviCompleteness.lean:2353). The KampBypass approach is architecturally cleaner and the current single active path.

---

## Alternative Strategies

### Could VecEA2 / Enriched Formula be Replaced?

The current approach uses `enriched_vecEA2_until` (a VecEA2 whose bracket encodes quantifier conditions for y in (t,x)). This is a sound design. The alternative `nf_exist_formula` (NfCharFormula.lean) approach encodes quantifier conditions as nested Since/Until but lacks a backward direction (blocked by the Feferman-Vaught composition theorem at depth >= 1). There is no simpler alternative that avoids the composition problem entirely without the enriched-formula trick.

**Verdict**: The enriched formula approach is the right architecture. Do not replace it.

### Could the Since Case Reuse the Until Proof?

The Until case (`existPart_succ_n1_bypass_k0_until`) has 430+ lines of proof in KampBypass.lean. The Since case (`existPart_succ_n1_bypass_k0_since`) is a sorry that needs approximately the same length. However, the two cases are genuinely symmetric: they use `enriched_bypass_since` (which uses VecEA2.holdsRight) vs `enriched_bypass_until` (which uses VecEA2.holdsLeft). The zone bridges are symmetric. A refactored approach could:

1. Abstract the "Until direction" proof into a generic helper parameterized by "left" vs "right"
2. Prove both Until and Since cases from the same abstract proof
3. Reduce total new code for the Since case from ~430 lines to ~80-100 lines

This is the highest-leverage single architectural improvement available.

### The Bracket Sorry (L1579)

The bracket case in `backward_holdsLeft_of_nf_eval` requires constructing an `IntervalPattern.holds` witness with strictly ordered points in (t, x). The analysis in report 31 established that `nf_y_proj` is injective on `pos_between` (distinct SSNs yield distinct y-predicate profiles), so sorting witnesses by model order is safe. The mathematical content is sound; it is a combinatorics/permutation argument in Lean.

**Alternative**: If the permutation argument is too complex, one can observe that `IntervalPattern.holds` with `n = pos_between.length` witnesses is constructively hard. A simpler approach: use Classical.choose directly with a `Finset.sort` on the model's linear order to extract a sorted witness list. This avoids the need for a permutation bijection.

---

## Clean Rewrite Proposal

A clean rewrite of KampBypass.lean would have the following structure:

### Proposed File Splitting

**Current**: 1839-line monolith KampBypass.lean

**Proposed**: Split into 3 focused files

**File 1**: `KampBypassDefs.lean` (~300 lines)
- All `noncomputable def` definitions (formula constructors)
- `nf_t_compat_check`, `ssn_xt_compatible`, `depth0_3var_exist_formula_v1`
- `quant_profile_conj_depth0`, `enriched_point_type_depth0`, `nf_x_compat_check`
- `enriched_point_type_x_until`, `enriched_vecEA2_until`, `enriched_bypass_until`
- `enriched_bypass_since`, `enriched_bypass_eq`, `enriched_bypass_formula_zone`

**File 2**: `KampBypassUntil.lean` (~900 lines)
- All Until-direction helper theorems and correctness proof
- `backward_holdsLeft_of_nf_eval` (including bracket case)
- `forward_nf_eval_of_holdsLeft`
- `existPart_succ_n1_bypass_k0_until`

**File 3**: `KampBypass.lean` (~640 lines, renamed as top-level)
- Zone-bridge helpers (ssn_xt_compat_*, zone_below_t_*, etc.)
- `existPart_succ_n1_bypass_k0_since` (Since direction, ~200 lines)
- `existPart_succ_n1_bypass_k0_eq` (eq direction, ~250 lines)
- `existPart_succ_n1_bypass_k0` (main zone split, ~80 lines)
- `existPart_succ_n1_bypass` (depth >= 2 recursive, ~150 lines)

**Benefits of splitting**:
1. Each dispatch can focus on one file without reading 1839 lines
2. Heartbeat budget per file is more manageable
3. The eq case and Since case can be proved in isolation from the Until infrastructure
4. Changes to Until case don't affect Since case dispatch

### What Should NOT Change

The mathematical structure of the enriched formula is sound. The `enriched_vecEA2_until` definition, the VecEA2 infrastructure, and the zone-bridge theorems in ZoneBridge.lean should not be touched.

---

## Automation Opportunities

### Tactic Survey Results

Based on structural analysis (without lean_goal output for specific sorries, which requires LSP):

| Goal Pattern | Recommended Tactic | Rationale |
|---|---|---|
| `atom_eval M (fun _ => t) a ↔ parent_atoms a = true` | `simp [atom_eval] at *; exact h_atoms a` | Standard atom evaluation unfolding |
| `ssn_xt_compatible = true` (boolean computations) | `simp [ssn_xt_compatible, Bool.and_eq_true]` + `decide` | Boolean decision procedure |
| `Fintype.elems.val.toList.all` membership | `simp [List.all_eq_true, Multiset.mem_toList]` + `exact Fintype.complete p` | Fintype completeness |
| Zone-bridge extraction from `h_eval_atoms`/`h_eval_quant` | `exact (zone_bridge_* M ...).mpr ⟨..., ...⟩` | Direct application of zone-bridge theorems |
| Conjunction goals in NF reconstruction | `refine ⟨?_, ?_⟩; intro a; cases a with ...` | Systematic case analysis |
| `nf_eval_nf M 1 2 (Fin.cons x fun _ => t) sub_nf` reconstruction | `exact ⟨h_atoms_part, h_quant_part⟩` after extracting atom and quantifier parts | Direct constructor |

### simp Lemma Candidates

For the eq case (L974), these simp lemmas would accelerate proof:
- `enriched_bypass_eq` unfolding
- `formula_disjList_iff`
- `nf_x_compat_check` (if simplified to Bool equality)

For the forward direction (L1637), the critical automation target:
- `VecEA2.holdsLeft` unfolding (already used at L1632)
- `nf_eval_nf` unfolding from char_1_correct
- The 6 zone-bridge backward directions in a single `simp only [...]` call

### The k >= 2 Sorry (L1837): Recursive IH Strategy

The depth >= 2 case (`existPart_succ_n1_bypass` succ k') has a clean recursive structure:

```lean
| succ k' =>
  -- At depth k'+2, the 3-var quantifier conditions are depth-(k'+1).
  -- The IH `char_kp1_correct` gives temporal formulas for depth-(k'+2) 1-var NFs.
  -- For each ssn : NormalForm sig (k'+1) 3, the existential
  --   ∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn
  -- has a temporal formula equivalent via the IH at depth k'+1:
  --   Use `nf_2var_exist_formula_prior` recursively (it's the outer function).
  -- But this requires an IH at ARITY 3, not just arity 2.
```

The core issue is that `nf_2var_exist_formula_prior` characterizes arity-2 (2-variable) existentials, but the inner 3-var conditions need arity-3 characterization. This is the `existPart_succ` for n >= 2 problem also visible in `RabinovichGeneralized.lean:465`. The enriched formula approach avoids needing a separate n >= 2 result by encoding the quantifier conditions directly as conjuncts evaluated at the witness x — but the depth >= 2 sorry propagates this exact gap.

**Strategic recommendation**: For the depth >= 2 case, the cleanest approach is to prove a general `nf_nvar_exist_formula_prior` that works for all arities n, by strong induction on depth k:
- Base: k = 0 (all arities: purely atomic, sorry-free)
- Step: k = k'+1, arity n = any. Encode each (n+1)-var existential as: (i) find x with the right n-var NF for (x, remaining vars), then (ii) check all (n+1)-var quantifier conditions at x. The IH at depth k' for all arities provides temporal formulas for each step. This is the "general" bypass that the current code partially approximates.

However, implementing this generalization from scratch is a substantial undertaking. A more pragmatic approach is to implement depth 2 specifically (using the now-sorry-free depth 1 formulas as IH) and document depth >= 3 as an orthogonal extension.

---

## Strategic Alignment

### Current Plan (v32) is Correct

The plan v32 (`32_depth0-sorries-completion.md`) correctly identifies the 5 remaining sorries and the fill order (eq -> bracket -> forward -> since -> depth >= 2). No plan revision is needed.

### File Splitting as a High-Value Improvement

The main architectural change that would accelerate closure is splitting KampBypass.lean as described above. This should be done **before** filling the Since case and the depth >= 2 case, since those are the two largest remaining sorry bodies. A split would allow:

- Since case to be dispatched independently in `KampBypassSince.lean` (~200 lines)
- Depth >= 2 recursive case to be dispatched in a focused context (~150 lines)

**Recommended action**: Before the Since dispatch, move definitions to `KampBypassDefs.lean` and split the Until proof into `KampBypassUntil.lean`. This is a mechanical refactor (no theorem changes) that can be done in one dispatch.

### ROADMAP Alignment

Task 273 is on the critical path to:
1. `kamp_prior_expressive_completeness` (sorry-free)
2. `US_expressively_complete_over_prior` (sorry-free)
3. `gap_prior_UZ_contradiction` (sorry-free, requires US_expressively_complete_over_prior)
4. `no_gaps_discrete_model_surgery` (sorry-free)
5. `completeness_discrete` (sorry-free given BOTH chains: task 273 + task 202)

The ROADMAP explicitly states that task 202 (Reynolds k-equivalence bypass) is the second independent sorry chain. Even after task 273 is complete, `completeness_discrete` will still have `sorryAx` via the `succ_cofinal` chain until task 202 completes.

### Scope of Non-KampBypass Sorries

Several sorries exist outside the KampBypass chain that are NOT on the critical path to `completeness_discrete`:

- **TruthLemma.lean** (6 sorries): Non-critical (parametric truth lemma in BFMCS handles via coherence)
- **Bundle/SuccRelation.lean** (7 sorries): Dead code — superseded by Reynolds bypass
- **Bundle/UntilSinceCoherence.lean** (2 sorries): Dead code
- **BXCanonical/Frame.lean** (1 sorry): Dead code (BXCanonical path is mathematically false under irreflexive semantics)
- **BXCanonical/Chronicle/ChronicleToCountermodel.lean** (5 sorries): May be unblocked once task 273 + 202 complete
- **WeakCanonical/OrderedSum.lean** (1 sorry): Assess separately
- **Expressiveness/CaseAnalysis.lean** (4 sorries): Task 155, separate chain
- **EFGames/StaviCompleteness.lean** (2 sorries): The OLD Stavi chain, no longer on critical path
- **EFGames/DiscreteStaviCompleteness.lean** (1 sorry): Same

The dead code sorries (Bundle/, BXCanonical/) should be moved to Boneyard/ to reduce noise. This is explicitly on the ROADMAP (Priority 4) and would eliminate ~17 sorries by archival.

---

## Confidence Level

**Sorry chain map**: HIGH (traced via grep + file reading, consistent with ROADMAP)

**Alternative strategies**: HIGH (enriched formula approach is sound; no better alternative exists)

**File splitting recommendation**: HIGH (straightforward mechanical refactor, high benefit/risk ratio)

**Since case mirrors Until case**: HIGH (both use VecEA2, symmetric zone bridges)

**Depth >= 2 recursive strategy**: MEDIUM (the general n-var approach requires careful Lean type-level handling of `Fin.cons` at varying arities; specializing to n=1 is safer)

**Automation via simp/omega**: MEDIUM-HIGH for atom goals; LOW for zone-bridge wiring (requires structural proof, not just rewriting)

---

## Recommendations for Implementer

1. **Fill eq case (L974) first**: Highest feasibility. Recipe exists in `handoffs/eq-case-recipe-20260614.md`. Expected ~250 lines.

2. **Fill Since case (L1749) second**: Mirror the Until structure (`existPart_succ_n1_bypass_k0_until`). Use `enriched_bypass_since` as the formula witness and mirror the proof structure from the Until case. Consider symmetric zone-bridge helpers. Expected ~200-250 lines.

3. **Fill bracket case (L1579) third**: Use Classical.choose + Finset.sort on `pos_between` to construct strictly ordered witnesses. The key fact is that `nf_y_proj` is injective on `pos_between`. Expected ~100-150 lines.

4. **Fill forward direction (L1637) fourth**: Extract NF conditions zone-by-zone from VecEA2.holdsLeft. Mirror the backward direction proof structure. Expected ~150-200 lines.

5. **Consider file splitting before or alongside steps 2-4**: Extract definitions to `KampBypassDefs.lean` and Until proof to `KampBypassUntil.lean`. This is a mechanical refactor (no proofs change, only file structure).

6. **Fill depth >= 2 (L1837) last**: Start by examining what `existPart_succ_n1_bypass_k0` produces at depth 1 (now sorry-free) and generalize. The inductive structure is: construct the enriched formula for depth k'+2 using the IH `char_kp1_correct`, prove backward direction from nf_eval, prove forward direction from formula truth. Expected ~150-200 lines.

7. **Do NOT move dead code yet**: Archival of Bundle/, BXCanonical/ is a ROADMAP task (Priority 4), not part of task 273's scope.
