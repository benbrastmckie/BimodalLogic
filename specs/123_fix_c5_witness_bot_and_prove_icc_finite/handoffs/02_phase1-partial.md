# Handoff: Phase 1 Partial -- Collapse Architecture Established

## Status

Phase 1 of the revised plan (Post-Construction Collapse) is PARTIAL. The full collapse architecture is defined and compiles, with key foundational proofs complete. The quotient order infrastructure has 6 sorry stubs remaining. The old sorry-dependent pipeline (limitDomSubtype_Icc_finite through discrete_fmcs) has been REPLACED.

## What Was Accomplished

### Definitions Added (all compile, no errors)

1. **`collapse_equiv`** - Succ-reachability equivalence relation on LimitDomSubtype
2. **`collapse_setoid`** - Setoid instance from collapse_equiv
3. **`CollapseClass`** - Quotient type (LimitDomSubtype / collapse_equiv)
4. **`collapseClass_linearOrder`** - LinearOrder on CollapseClass [sorry]
5. **`collapseClass_succOrder`** - SuccOrder on CollapseClass [sorry]
6. **`collapseClass_predOrder`** - PredOrder on CollapseClass [sorry]
7. **`collapseClass_isSuccArchimedean`** - IsSuccArchimedean on CollapseClass [sorry]
8. **`collapseClass_noMaxOrder`** - NoMaxOrder on CollapseClass [sorry]
9. **`collapseClass_noMinOrder`** - NoMinOrder on CollapseClass [sorry]
10. **`collapse_iso`** - CollapseClass ≃o Z (via orderIsoIntOfLinearSuccPredArch)
11. **`collapse_map`** - LimitDomSubtype -> Z composition
12. **`discrete_f`** - MCS assignment via collapse (Z -> Set Formula)
13. **`discrete_zero`** - Origin integer
14. **`discrete_fmcs`** - FMCS Z via collapse

### Proofs Completed (sorry-free)

1. **`collapse_equiv_refl`** - Reflexivity of succ-reachability
2. **`collapse_equiv_symm`** - Symmetry of succ-reachability
3. **`collapse_equiv_trans`** - Transitivity of succ-reachability (complex: 4 cases with iterate composition and injectivity)
4. **`collapse_equiv_succ_congr`** - Succ maps equivalent elements to equivalent elements
5. **`collapse_orbit_convex`** - If a <= b <= succ^n(a), then b = succ^k(a) for some k <= n (induction on n using succ_le_iff)
6. **`collapse_orbit_bounded`** - If a < b and a !~ b, then succ^n(a) < b for all n (corollary of convexity)
7. **`collapse_not_equiv_of_orbit`** - Orbit elements preserve non-equivalence
8. **`collapse_class_sep`** - Different equivalence classes are totally separated (key lemma: if a < b and a !~ b, then a' < b' for any a' ~ a, b' ~ b)
9. **`discrete_f_is_mcs`** - Every integer maps to an MCS via discrete_f

### Helper Lemmas Proved

- `limitDomSubtype_succ_lt` - a < succ(a)
- `limitDomSubtype_succ_iter_lt` - succ^n(a) < succ^(n+1)(a)
- `limitDomSubtype_succ_iter_mono` - n <= m => succ^n(a) <= succ^m(a)
- `limitDomSubtype_succ_iter_strictMono` - n < m => succ^n(a) < succ^m(a)
- `limitDomSubtype_succ_iter_injective` - succ^n(a) = succ^m(a) => n = m

### Code Removed

The old sorry-dependent pipeline was REPLACED:
- `limitDomSubtype_Icc_finite` (had sorry) - REMOVED
- `limitDomSubtype_isSuccArchimedean` (depended on Icc_finite) - REMOVED
- `discrete_iso` (depended on isSuccArchimedean) - REMOVED (replaced by collapse_iso)

## What Remains

### Phase 1 Remaining Sorries (6 quotient infrastructure)

1. **`collapseClass_linearOrder`** - Build LinearOrder on quotient. Strategy: define LE via Quotient.lift2 (using collapse_class_sep for well-definedness), then use LinearOrder.mk' with decidable equality from Classical.

2. **`collapseClass_succOrder`** - Define successor on quotient classes. Strategy: for class [a], the successor class is [b] where b is the "next orbit's base point" - the element whose pred-orbit contains a's orbit. Formally, b is any element not equivalent to a with a < b (exists by NoMaxOrder on LimitDomSubtype). Show this is well-defined.

3. **`collapseClass_predOrder`** - Mirror of SuccOrder.

4. **`collapseClass_isSuccArchimedean`** - For [a] <= [b], show succ^n([a]) = [b] for some n. This is the KEY property that the collapse was designed to achieve. Strategy: between any two non-equivalent classes, there are finitely many intermediate classes.

5. **`collapseClass_noMaxOrder`** - Given [a], find [b] > [a] with a !~ b. Strategy: LimitDomSubtype has NoMaxOrder, so find b > all succ-iterates of a. This requires showing that NOT all elements above a are in a's orbit.

6. **`collapseClass_noMinOrder`** - Mirror.

### Phase 2 Remaining Sorries (3 FMCS transport)

7. **`discrete_f_at_zero`** - discrete_f(discrete_zero) = A. Strategy: show the representative of the class containing 0 maps to A via limit_f_zero.

8. **`discrete_fmcs.forward_G`** - G propagation on Z. Strategy: representatives are ordered (from collapse_class_sep), so limit_forward_G applies.

9. **`discrete_fmcs.backward_H`** - H propagation on Z. Strategy: mirror of forward_G.

### Phases 3-5

Not started. Phase 3 (Until/Since coherence) and Phase 4 (BFMCS) are task 122 scope since dd_countermodel_chronicle_nondense_sorry is already sorry'd. Phase 5 (cleanup) is mostly done since the old pipeline was already replaced.

## Key Design Decisions

1. **`set s` instead of `let s`**: Using `set` for the succ function abbreviation ensures hypotheses are rewritten, avoiding `s` vs `limitDomSubtype_succ A h_mcs h_discrete` mismatches in rewrites.

2. **`Function.iterate_add_apply`** for composition: `s^[p+q] x = s^[p] (s^[q] x)`, noting the order (p is outer, q is inner).

3. **Orbit convexity as foundation**: The key lemma `collapse_orbit_convex` (if a <= b <= succ^n(a) then b is in a's orbit) makes all other separation arguments follow easily.

4. **No-sorry count**: Original file had 2 sorries (limitDomSubtype_Icc_finite at line 1064, dd_countermodel_chronicle_nondense_sorry at line 836). Current file has 10 sorries (1 pre-existing + 9 new architectural stubs). Net change: +8 sorries. This is expected since the old 1-sorry pipeline was replaced with a 9-sorry architectural scaffold.

## File Locations

- Modified file: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- Collapse definitions start at the `/-! ## Collapse-Based Discrete Pipeline` section (around line 1050)
- The old `/-! ### Z-Isomorphism and FMCS on Int -/` section was replaced
