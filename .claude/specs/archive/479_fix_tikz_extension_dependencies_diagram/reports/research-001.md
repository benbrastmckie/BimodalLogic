# Research Report: Task #479

**Task**: Fix TikZ extension dependencies diagram
**Date**: 2026-01-13
**Focus**: Compare TikZ diagram with README.md ASCII diagram, document structure, identify TikZ techniques for professional styling

## Summary

The current TikZ diagram in `00-Introduction.tex` has a different layout than the README.md ASCII diagram. The README shows a vertical flow with a grey horizontal background grouping the middle extensions (Epistemic, Normative, Spatial), plus ellipses to indicate extensibility. This report documents the exact target structure, required TikZ libraries, and techniques for professional styling including rounded corners, grey backgrounds, and non-intersecting lines.

## Findings

### Current vs Target Structure Comparison

#### Current TikZ Diagram (00-Introduction.tex:26-108)

The existing diagram uses:
- `rectangle` and `smallbox` styles with `minimum width=4cm`/`2.8cm`
- Manual positioning via absolute coordinates: `at (0, 6)`, `at (-4, 1.5)`, etc.
- Direct arrow connections with `\draw[arrow]` using `--` paths
- No background grouping for middle extensions
- No ellipsis indicators for extensibility
- Reflection inherits from Epistemic only (lines 102-103)

Layout issues:
1. Middle extensions (Epistemic, Normative, Spatial) at different y-coordinates than Agential/Reflection
2. No visual grouping to indicate these are modular plugins
3. Missing ellipses to show extensibility
4. Arrows potentially cross paths due to manual positioning

#### Target Structure (README.md:13-49)

```
Constitutive Foundation (full width)
         |
         | required
         v
Explanatory Extension (full width)
         |
    -----+-----
    |    |    |
    v    v    v
[Epistemic] [Normative] [Spatial]  <-- ALL IN GREY HORIZONTAL BOX
    |    |    |                        with ellipses on left/right
    -----+-----
         |
         | at least one required
         v
Agential Extension (full width)
         |
         | inherits from Epistemic
         v
Reflection Extension (full width)
```

Key differences:
1. README shows vertical stacking with full-width boxes for Foundation, Explanatory, Agential, Reflection
2. Middle extensions in a grey horizontal band
3. Ellipses (`...`) on left and right of middle extensions
4. Cleaner arrow paths without crossing

### Required TikZ Libraries

Based on the web research, the following libraries are needed:

| Library | Purpose | Already Loaded? |
|---------|---------|-----------------|
| `fit` | Fit background box around middle extensions | No |
| `backgrounds` | Place fitted box on background layer | No |
| `positioning` | Modern `below=of` syntax for node placement | No |
| `shapes` | Additional node shapes if needed | No |

**Recommendation**: Add to LogosReference.tex or 00-Introduction.tex:
```latex
\usetikzlibrary{fit,backgrounds,positioning}
```

### TikZ Techniques for Professional Styling

#### 1. Rounded Corners

Apply `rounded corners=<radius>` to node styles:

```latex
box/.style={
  rectangle,
  draw,
  rounded corners=4pt,  % or 0.5ex for relative sizing
  minimum width=10cm,
  minimum height=1cm,
  text centered
}
```

#### 2. Grey Background Box for Middle Extensions

Use `fit` library with `backgrounds` layer:

```latex
% Define middle extension nodes first
\node[smallbox] (epistemic) {...};
\node[smallbox] (normative) [right=of epistemic] {...};
\node[smallbox] (spatial) [right=of normative] {...};

% Then fit a background rectangle around them
\begin{pgfonlayer}{background}
  \node[fill=gray!15, draw=gray!50, rounded corners=3pt,
        fit=(epistemic)(normative)(spatial),
        inner sep=10pt] (middlebox) {};
\end{pgfonlayer}
```

The `gray!15` means 15% gray mixed with white (very light gray).
The `inner sep=10pt` adds padding around the fitted nodes.

#### 3. Ellipses for Extensibility

Add ellipsis nodes on left and right of the middle box:

```latex
% Ellipsis nodes (no border)
\node[draw=none, left=8mm of epistemic] {\ldots};
\node[draw=none, right=8mm of spatial] {\ldots};
```

Alternatively, use `$\cdots$` for centered dots.

#### 4. Non-Intersecting Lines

Use `positioning` library for relative placement:

```latex
% Vertical arrow from Explanatory to middle layer center
\coordinate (middle-top) at ($(normative.north)+(0,1cm)$);
\draw[arrow] (explanatory) -- (middle-top);

% Branch to three extensions
\draw[arrow] (middle-top) -| (epistemic);
\draw[arrow] (middle-top) -- (normative);
\draw[arrow] (middle-top) -| (spatial);
```

The `-|` operator creates right-angle connections (horizontal then vertical or vice versa).

#### 5. Arrow Styling

```latex
arrow/.style={->, thick, >=stealth}
```

### Existing Package Support

From `formatting.sty`:
- `xcolor` with `dvipsnames` is already loaded - supports `gray!15` syntax
- No TikZ libraries currently loaded

From `logos-notation.sty`:
- No TikZ-specific definitions

### Recommended Diagram Structure

Based on README.md analysis, the target structure should have:

**Layer 1**: Constitutive Foundation (full width, rounded corners)
**Layer 2**: Explanatory Extension (full width, rounded corners)
**Layer 3**: Grey box containing:
  - Left ellipsis (`...`)
  - Epistemic Extension (smaller box)
  - Normative Extension (smaller box)
  - Spatial Extension (smaller box)
  - Right ellipsis (`...`)
**Layer 4**: Agential Extension (full width, rounded corners)
**Layer 5**: Reflection Extension (full width, rounded corners)

### Arrow Labels

From README.md:
- Between Foundation and Explanatory: "required"
- Between Explanatory and middle layer: "optional" (three branches)
- Between middle layer and Agential: "at least one required"
- Between Agential and Reflection: "inherits from Epistemic"

## Recommendations

### Implementation Approach

1. **Add TikZ libraries** in 00-Introduction.tex preamble area (after `\documentclass`):
   ```latex
   \usetikzlibrary{fit,backgrounds,positioning,calc}
   ```

2. **Define consistent styles** at start of `tikzpicture`:
   ```latex
   \begin{tikzpicture}[
     box/.style={rectangle, draw, rounded corners=4pt,
                 minimum width=10cm, minimum height=1cm,
                 text centered},
     smallbox/.style={rectangle, draw, rounded corners=3pt,
                      minimum width=2.5cm, minimum height=1.5cm,
                      text centered, font=\small},
     arrow/.style={->, thick, >=stealth},
     every node/.style={font=\small}
   ]
   ```

3. **Use relative positioning** with `positioning` library:
   - Use `below=1.5cm of <node>` instead of absolute coordinates
   - Ensures consistent spacing

4. **Apply background grouping** for middle extensions using `fit` and `backgrounds`

5. **Add ellipsis nodes** for extensibility indicators

6. **Use descriptive arrow labels** with `node[anchor=..., font=\footnotesize]` for clarity

### Style Recommendations

| Element | Style |
|---------|-------|
| Large boxes | `fill=white, draw=black, rounded corners=4pt` |
| Small boxes | `fill=white, draw=black, rounded corners=3pt` |
| Background box | `fill=gray!15, draw=gray!50, rounded corners=4pt` |
| Arrows | `thick, >=stealth` |
| Labels | `font=\footnotesize, near start` or `midway` |

## References

- [TikZ Fitting Library](https://tikz.dev/library-fit) - Official documentation for `fit` option
- [TikZ Backgrounds Library](https://tikz.dev/library-backgrounds) - Documentation for `pgfonlayer`
- [Overleaf Flowchart Tutorial](https://www.overleaf.com/learn/latex/LaTeX_Graphics_using_TikZ:_A_Tutorial_for_Beginners_(Part_3)%E2%80%94Creating_Flowcharts) - Node styles with rounded corners
- [TikZ/PGF Manual](https://tikz.dev/tikz-shapes) - Node shape options
- [LaTeX4technics - Ellipsis between nodes](https://www.latex4technics.com/?note=18RE) - Adding `$\cdots$` in diagrams

## Next Steps

1. Run `/plan 479` to create implementation plan with phased approach
2. Implementation should:
   - Phase 1: Add TikZ libraries and define styles
   - Phase 2: Restructure nodes to match README layout
   - Phase 3: Add background grouping and ellipses
   - Phase 4: Adjust arrows for clean paths
   - Phase 5: Add explanatory text below diagram
   - Phase 6: Verify LaTeX build compiles without errors

## Appendix: Source File Locations

| File | Path |
|------|------|
| TikZ diagram | `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` (lines 26-108) |
| Target structure | `/home/benjamin/Projects/ProofChecker/README.md` (lines 13-49) |
| Main LaTeX file | `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex` |
| Notation package | `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/assets/logos-notation.sty` |
| Formatting package | `/home/benjamin/Projects/ProofChecker/latex/formatting.sty` |
