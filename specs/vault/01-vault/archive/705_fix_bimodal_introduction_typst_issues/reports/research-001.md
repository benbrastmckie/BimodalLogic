# Research Report: Task #705

**Task**: Fix Bimodal Introduction Typst Issues
**Date**: 2026-01-28
**Focus**: Research Typst drawing techniques for double light cones and bold text formatting

## Summary

This research addresses two issues in the Bimodal TM Logic Reference Manual introduction chapter: (1) drawing a proper double light cone diagram using CeTZ, and (2) ensuring "TM" always appears in bold throughout the document. Both issues have straightforward solutions using Typst's CeTZ drawing library and show rules.

## Findings

### Issue 1: Double Light Cone Diagram (Line 18)

**Current Problem**: The existing diagram at lines 20-75 in `00-introduction.typ` attempts to draw light cones but the triangular regions are not properly filled. The code uses `line()` with `close: true` but the fill is applied incorrectly - fills are placed in separate line commands rather than on the closed polygon.

**Analysis of Current Code**:
```typst
// Current (incorrect) - fills are on separate non-closed lines
line(P, (-0.7, 1.0), stroke: gray.lighten(40%))
line(P, (-0.7, -1.2), stroke: gray.lighten(40%))
line((-0.7, 1.0), (-0.7, -1.2), stroke: none, fill: blue.transparentize(85%))
```

**Solution Using CeTZ `line()` with `close: true`**:

In CeTZ, to draw a filled polygon (like a triangular light cone), you must:
1. Specify all vertices as arguments to a single `line()` call
2. Set `close: true` to automatically connect the last point back to the first
3. Apply `fill` directly to the closed line command

**Correct Pattern**:
```typst
// Draw filled triangle with vertices P, A, B
line(P, (A_x, A_y), (B_x, B_y), close: true, fill: blue.transparentize(85%), stroke: gray.lighten(40%))
```

**Recommended Fix for Double Light Cone**:

For a double light cone (past and future) emanating from point P on a curve:

```typst
#cetz.canvas({
  import cetz.draw: *

  // Define point P on the worldline
  let P = (0.5, -0.2)

  // Past light cone (opens to the left) - filled triangle
  line(
    P,
    (-0.7, 1.0),    // upper-left vertex
    (-0.7, -1.2),   // lower-left vertex
    close: true,
    fill: blue.transparentize(85%),
    stroke: gray.lighten(40%)
  )

  // Future light cone (opens to the right) - filled triangle
  line(
    P,
    (1.7, 1.0),     // upper-right vertex
    (1.7, -1.2),    // lower-right vertex
    close: true,
    fill: orange.transparentize(85%),
    stroke: gray.lighten(40%)
  )

  // ... rest of diagram (worldline, counterfactual paths, point label)
})
```

**Key CeTZ Drawing Principles**:
- `line(a, b, c, close: true)` creates a closed triangle from points a, b, c
- `fill: color` fills the interior of the closed shape
- `stroke: color` controls the outline
- The current code creates 6 separate line commands when only 2 are needed for the filled cones

**Alternative Using `merge-path`**:

For more complex shapes (e.g., curved light cone edges), CeTZ provides `merge-path`:
```typst
merge-path(close: true, fill: blue.transparentize(85%), {
  line(P, (-0.7, 1.0))
  line((), (-0.7, -1.2))  // () continues from previous endpoint
})
```

### Issue 2: Bold "TM" Throughout Document (Line 78)

**Current Problem**: At line 80, "TM" appears without bold formatting: `"The diagram above illustrates the conceptual structure underlying TM logic."` However, earlier in the document at lines 11-12, TM appears in bold using `*TM*` syntax.

**Solution Using Typst Show Rules**:

Typst show rules can automatically transform text throughout a document. The pattern is:

```typst
#show "text to match": transformation
```

**Recommended Fix**:

Add to `BimodalReference.typ` (main document) or `template.typ`:

```typst
// Automatically bold all occurrences of "TM"
#show "TM": strong
```

This will make every occurrence of "TM" appear in bold (`strong` applies font weight increase).

**Placement Options**:

1. **In BimodalReference.typ** (recommended): Add after the document configuration section, before the `#show: thmbox-show` line:
   ```typst
   // Automatically bold "TM" throughout the document
   #show "TM": strong
   ```

2. **In template.typ**: If this should apply to any document using the template, add it there.

**Scope Considerations**:

- Show rules are scoped to the current block or file
- When placed at the document level, it applies to all included chapters
- The rule won't affect "TM" inside code blocks (`raw` text) - this is usually desired behavior

**Alternative Approaches**:

1. **Conditional formatting** (if "TM" might appear in contexts where bold is unwanted):
   ```typst
   #show "TM": it => {
     if it.at("context") != raw { strong(it) } else { it }
   }
   ```

2. **Define a command** (for explicit use):
   ```typst
   #let TM = strong[TM]
   // Usage: The #TM logic combines...
   ```

   However, this requires manually replacing all occurrences, whereas the show rule is automatic.

## Recommendations

### Phase 1: Fix Light Cone Diagram

1. **Simplify the cone drawing code** by using single `line()` calls with `close: true` and `fill`
2. **Remove redundant fill lines** (lines 30, 35, 38, 41 in current code)
3. **Test rendering** to verify the triangular cones appear correctly filled

**Estimated effort**: 30 minutes

### Phase 2: Bold "TM" Globally

1. **Add show rule** `#show "TM": strong` to `BimodalReference.typ`
2. **Place after document config** but before `#show: thmbox-show`
3. **Remove manual `*TM*` syntax** from places like lines 11, 12, 111, 112 if desired (optional - the show rule will handle it either way, and `*strong[TM]*` is still bold)
4. **Verify** that TM appears bold throughout all chapters

**Estimated effort**: 15 minutes

## References

- [CeTZ Package Documentation](https://cetz-package.github.io/docs/)
- [CeTZ Universe Page](https://typst.app/universe/package/cetz/)
- [Typst Styling Documentation](https://typst.app/docs/reference/styling/)
- [Typst Strong Function](https://typst.app/docs/reference/model/strong/)
- [Typst Polygon Function](https://typst.app/docs/reference/visualize/polygon/)
- [Karl's Tutorial (CeTZ)](https://cetz-package.github.io/docs/tutorials/karl/)

## Next Steps

Run `/plan 705` to create an implementation plan based on these findings. The implementation is straightforward with two independent phases that can be completed quickly.
