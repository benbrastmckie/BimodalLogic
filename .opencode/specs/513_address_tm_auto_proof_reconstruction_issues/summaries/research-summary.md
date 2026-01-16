# Research Summary: TM_Auto Proof Reconstruction Issues

**Task**: 513  
**Status**: Complete  
**Date**: 2026-01-16  

## Findings

1. **Root Cause**: Aesop's proof reconstruction pipeline incompatible with custom `DerivationTree` type
2. **Specific Error**: "aesop: internal error during proof reconstruction: goal X was not normalised"
3. **Impact**: `tm_auto` tactic fails on many legitimate proof goals despite finding valid proof strategies

## Recommended Solution

Replace `tm_auto` macro with native `modal_search` implementation:

```lean
macro "tm_auto" : tactic => 
  `(tactic| modal_search (max_depth := 100) (strategy := .bestFirst))
```

## Benefits

- ✅ Eliminates all proof reconstruction issues
- ✅ Uses proven `modal_search` infrastructure  
- ✅ Maintains existing `tm_auto` API
- ✅ Low implementation risk
- ✅ 1-hour fix time

## Next Steps

1. Replace macro definition in `Tactics.lean`
2. Update documentation 
3. Run regression tests
4. Consider deprecating AesopRules.lean

## Files Created

- [Research Report](reports/research-001.md) - Complete technical analysis