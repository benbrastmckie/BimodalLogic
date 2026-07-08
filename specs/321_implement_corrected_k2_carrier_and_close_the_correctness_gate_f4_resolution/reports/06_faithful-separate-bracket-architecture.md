# Task 321 — Faithful Separate-Bracket Architecture (Phase-7 Blocker Research)

**Date:** 2026-07-07
**Session:** sess_1783470318_b10c5a
**Mode:** blocker-escalation research (hard, Tier-1 literature, adversarially verified)
**Status:** research-complete — supersedes the v6 implementer's "decomposition-patch" framing
**Reference grounding:** `/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`

## Leading finding (literature-architecture verdict)

The v6 implementer handoff framed the remaining gap as "one decomposition lemma
(`bracketFromLists_slot_decompose`) + a ~200–500 line `kvE2_outer_fold` engine." Reading
Rabinovich 2014 against the actual Lean definitions **refutes that direction**:

> **The merged-bracket `slotsFor` construction is itself the un-faithful step.** Building
> `bracketFromLists_slot_decompose` would patch onto a structure that fights the paper — the
> same class of error (structure diverging from the source) that sank v1–v5.

### Why the merged bracket is un-faithful

- Rabinovich's ∃-∀ bracket `[α_0, β_1, …, α_n](z_0,z_1)` (Def 3.1, md:61–72; Notation 5.2,
  md:131) has **quantifier-free** point/interval types (stated md:72; Lemma 5.1, md:134).
- The Cor 5.4 F-chain `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (md:157) is the **output**
  TL-translation of ONE bracket evaluated at `z_0` — it is **never** an **input** point type of
  a larger bracket.
- Lean `kvE2_body` (:8608) builds
  `bracketFromLists (slotsFor lL) ptW (slotsFor lR) segL segR` (:8686) where
  `slotsFor l = l.flatMap (fun σ => kvE_subChain2V σ ++ pinSlots σ)` (:8677) and
  `kvE_subChain2V σ = bracketFromLists3(…).fChainPred` (:6988) — a nested-Until F-chain.
  So the outer bracket's `pointTypes` (:1899) are nested-Until formulas = **not**
  quantifier-free. This is a bracket-whose-points-are-brackets (two-level nesting) — exactly
  what Prop 4.3's re-flatten (md:103–110) exists to *avoid*. **The file's own audit note
  (:8841–8846) states this no-nesting rule verbatim; `slotsFor` violates it.**

### Answers to the three literature questions

1. **Per-σ recovery from the merged bracket:** no paper analogue. Rabinovich never merges
   sub-formulas into one bracket; he combines *separate* single-interval brackets via
   Lemma 3.2(1) (conjunction of ∃-∀ ≡ disjunction of ∃-∀) and Lemma 3.4 (md:84–85).
   `slotsFor`-concatenation is the divergence; `bracketFromLists_flatMap_subchain_below_pin`
   (:7793) is an engineering artifact undoing a merge the paper never performs.
2. **Prop 4.3 granularity:** per-sub-formula / keep-separate. Prop 4.3 (md:106–110) inducts on
   FO syntax; each step preserves a *disjunction of separate brackets*. The interval split
   (Lemma 5.1, `A_i⁻(z_0,z) ∧ A_i⁺(z,z_1)`, md:168–171) yields two *separate* sub-brackets
   sharing endpoint `z`. Faithful architecture = decompose-**never**, keep-separate.
3. **Faithful alternative:** build the outer carrier as a Prop 4.2/4.3 disj/conj combination of
   **separate** per-σ standalone carriers `kvE_subBracket2V σ` (:6833, both directions landed
   via `correctness_pair` :8549), using the landed `disjList_holds` / `VVecEA2.conj` /
   `neg_2var_vec_ea`. The gate then reads each separate sub-bracket directly — no slot-decompose.
   LITMUS honored: navigation stays internal to each single bracket (Cor 5.4 F-chain riding the
   Until/Since evaluation point).

## The one genuine unbuilt object (faithful route)

Rabinovich's point-insertion makes the new point `z` a **shared endpoint** of `A⁻`/`A⁺`
(Lemma 5.1, md:168–171); in Lean the outer witness `w` must be **shared** across all per-σ
sub-brackets. `kvE_subBracket2V σ` carries `w` as an interior-witness parameter, but a plain
`VVecEA2.conj` gives each conjunct *independent* witnesses — it does **not** force a shared `w`.

The single missing combinator is a **shared-interior-witness conjunction**:
`∃ w, ⋀_σ (sub-bracket σ at that same w)` = Lemma 5.1 `A⁻∧A⁺` point insertion + Lemma 3.2(2)
2-var reduction (md:78). Whether it is expressible with the landed `VVecEA2` closures is the
make-or-break question — a cheap, decisive probe.

This route **dissolves** the exterior-sub risk the merged route carries: `kvE_gate`/
`kvE_consistent` (:5157) admit exterior zones `zPastX` (x1<x) / `zFutT` (x1>t); in the merged
bracket these positive subs get no witness slot and only a 1-type `P.existF 0` epL/epR literal,
which `ExistProviders.correct` n=0 (:5013) reconstructs to the anchor's own 1-type, never full
arity-4 `σ.2` content (the F4 defect class). In the faithful route each order-type gets its own
single-bracket carrier via the same landed navigation.

## Recommended next-attempt plan (feeds task 321 v7, AFTER task 331 refactor)

1. **P1 probe (gated, do first):** shared-interior-witness conjunction PoC for two per-σ
   sub-brackets (one interior, one exterior) sharing `w`, using only landed
   `VVecEA2.disj/conj` + `correctness_pair`. Small, decisive GO/NO-GO.
2. **If GO:** faithful `kvE2_body` rewrite + shared-`w` combinator + `kvE2_outer_fold` direct
   read ≈ 400–700 additive lines, 3–4 phases; retires `slotsFor`, `subchain_below_pin`, and the
   1-type non-interior dischargers as dead. Then Phase 8 (F4 ℤ adversarial gate).
3. **Residual risk: MEDIUM** (one provability question), *lower* than the merged route's
   MEDIUM-HIGH exterior NO-GO risk. Not a NO-GO under current evidence.

## Adversarial self-verification (H4) — summary

| Claim | Source | Confidence |
|---|---|---|
| Outer bracket point types are nested-Until, not quantifier-free | `kvE_subChain2V` :6988 → `pointTypes` :1899 | High |
| Rabinovich requires quantifier-free point types | md:72, Lemma 5.1 md:134 | High |
| Rabinovich never merges sub-formulas into one bracket | Lemma 3.2(1)/3.4 md:77–85; Prop 4.3 md:106–110; split A⁻∧A⁺ md:168–171 | High |
| Captured crux has `w` in the wrong scope | crux `⊢ ∃ x1 w, …` vs `nf_eval M 2 3 [w,x,t] qnf` needs ONE shared `w` outside `∀σ` | High |
| Faithful separate-bracket route dissolves the exterior-sub NO-GO | `kvE_consistent` 7 zones :5157; `existF 3` dropped :8594/:8673; `ExistProviders.correct` n=0 :5013 | Medium-High |
| Landed Phase-3 combinators are the faithful inputs | `disjList_holds` :8947, `reflatten_prop43` :8991 | High |

**Precedence resolution:** literature fidelity (Tier 1) + the file's own no-nesting audit rule
(:8841–8846) outrank the implementer's engineering framing. The decomposition patch is refuted;
the faithful separate-bracket rewrite is recommended. Converges independently with report 05's H4
(Layer-3 exterior gap; naive 0→1 fold BLOCKED).

## Relationship to task 331 (structural refactor)

Task 331 (created this session; task 321 now depends on it) will split the 9,249-line
`NfMultiAnchorBridge.lean` and surface the **separate-bracket API** (per-σ `kvE_subBracket2V` +
`disjList_holds`/`VVecEA2.conj`/`neg_2var_vec_ea`) as the clean public interface, quarantining
the dead merged-route `slotsFor`/`subchain_below_pin` machinery. Task 321's v7 plan (faithful
route above, probe-first) should be authored **after** 331 lands, against the stabilized API — so
it does not reference pre-refactor line numbers.

**Line numbers in this report are baseline `cb1631d` (post-phases-1-6) and will shift after the
task-331 refactor; treat symbol names, not line numbers, as the stable references.**
