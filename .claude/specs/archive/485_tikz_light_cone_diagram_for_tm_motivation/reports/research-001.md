# Research Report: Task #485

**Task**: Create TikZ light-cone diagram for TM motivation
**Date**: 2026-01-13
**Session**: sess_1768341730_95fdbb
**Focus**: TikZ techniques for light-cone diagrams with S-shaped worldline and branching paths

## Summary

Research identified comprehensive TikZ techniques for creating professional light-cone diagrams. The key elements required are: (1) S-shaped curved paths using Bezier controls, (2) filled light-cone regions with opacity, (3) dotted past/counterfactual paths, and (4) proper 45-degree angles for light boundaries. Existing project TikZ patterns provide style conventions to follow.

## Findings

### 1. Task Requirements Analysis

From the task description in TODO.md, the diagram needs:

1. **Curvy S-shaped arrow**: Main worldline from left-to-right, slightly upward
2. **Marked point with dot**: A specific point along the S-curve
3. **Light-cone from point**: Emanating in both past and future directions
4. **Intersecting arrows within cones**: Other paths extending from marked point
5. **Dotted past portions**: Past/counterfactual paths shown dotted

### 2. Target File Context

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/00-Introduction.tex`

The file currently has minimal content (32 lines). The diagram should be inserted after line 12 (after the paragraph about world histories) and before the Project Structure section (line 15).

The Bimodal document:
- Uses `bimodal-notation.sty` for notation macros
- Already imports TikZ via the main `BimodalReference.tex`
- Uses `\nec`, `\allpast`, `\allfuture` for modal/temporal operators

### 3. TikZ Light Cone Techniques

From [TikZ.net - Minkowski Diagrams](https://tikz.net/relativity_minkowski_diagram/):

**Light cone boundaries** are drawn at 45-degree angles:
```latex
\draw[photon] (0,0) -- (2,2);   % Future light cone edge
\draw[photon] (0,0) -- (-2,2);  % Future light cone edge
\draw[photon] (0,0) -- (2,-2);  % Past light cone edge
\draw[photon] (0,0) -- (-2,-2); % Past light cone edge
```

**Filled regions** with semi-transparency:
```latex
\fill[orange!70!red,opacity=0.15]
  (0,0) -- (2,2) -- (-2,2) -- cycle;  % Future cone
\fill[blue!50,opacity=0.15]
  (0,0) -- (2,-2) -- (-2,-2) -- cycle; % Past cone
```

**Required libraries**:
```latex
\usetikzlibrary{calc}
\usetikzlibrary{decorations.markings}
\usetikzlibrary{arrows.meta}
```

### 4. S-Shaped Curved Paths

From [TikZ arrows tutorials](https://latexdraw.com/exploring-tikz-arrows/) and [Tom Wawer's curved arrows guide](https://tomwawer.com/2025/04/06/creating-a-custom-fancy-arrow-in-latex-with-tikz/):

**Bezier curves** for S-shapes:
```latex
% S-curve using two control points
\draw (-3,0) .. controls (-1,1) and (1,-1) .. (3,0.5);
```

**Alternative using `out/in` angles**:
```latex
\draw (-3,0) to[out=30,in=210] (0,0.5) to[out=30,in=150] (3,1);
```

### 5. Dotted/Dashed Lines for Counterfactual Paths

For past/counterfactual paths:
```latex
% Dotted line style
\draw[dotted, thick] (0,0) -- (-1,-1);

% Dashed alternative
\draw[dashed, gray] (0,0) -- (-1.5,-1.5);
```

### 6. Project Style Conventions

From `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` (the TikZ diagram at lines 25-125):

**Style definitions**:
```latex
box/.style={rectangle, draw, text centered, rounded corners=4pt, ...}
arrow/.style={->, thick, >=stealth}
```

**Color usage**: The project uses subtle colors with descriptive names (gray!15 for backgrounds).

**Professional elements**:
- Rounded corners for boxes
- Consistent arrow styles
- Semi-transparent fills for regions
- Clear labels

### 7. Light Cone Physical Interpretation for TM Logic

The light cone diagram motivates TM logic by showing:
- **S-curve worldline**: The actual path through state space (one world history)
- **Light cone**: Boundaries of what is possible from any point
- **Past cone**: What could have led to this point (modal accessibility)
- **Future cone**: What could follow from this point
- **Counterfactual paths (dotted)**: Alternative histories that branch off

This visualization explains why `\nec` (necessity) quantifies over all histories while `\allpast`/`\allfuture` quantify along a single history.

### 8. Diagram Layout Proposal

```
          Future Light Cone
              /    \
             /      \
            /   ...  \  (alternative futures in cone)
           /    ...   \
          /     ...    \
         +------P-------+  <- Marked point on S-curve
        /       |        \
       /   (dotted past)  \
      /         |          \
     /_________↓____________\
          Past Light Cone

    S-curve:  ~~~~~~~~~~~P~~~~~~~~~~~~>
              (left)   (point)  (right)
```

## Recommendations

### Implementation Approach

1. **Use existing TikZ libraries**: The project already imports TikZ; add `calc`, `decorations.markings`, `arrows.meta` libraries
2. **Match project styling**: Use similar arrow styles and colors as the Logos extension diagram
3. **Create reusable styles**: Define styles for `worldline`, `lightcone`, `counterfactual`
4. **Keep diagram compact**: Target ~8cm width to fit single column

### Suggested TikZ Structure

```latex
\begin{center}
\usetikzlibrary{calc,decorations.markings,arrows.meta}
\begin{tikzpicture}[
  worldline/.style={->, thick, >=stealth, blue!60!black},
  lightcone/.style={gray!40, opacity=0.3},
  counterfactual/.style={dotted, thick, gray!60}
]
  % S-shaped main worldline
  % Marked point P
  % Light cone regions (filled)
  % Alternative paths within cone
  % Dotted past paths
\end{tikzpicture}
\end{center}
```

### Key Design Decisions

1. **Scale**: Use relative coordinates (3-4 units each direction)
2. **Colors**:
   - Blue for actual worldline
   - Gray/orange for light cone regions
   - Gray dotted for counterfactuals
3. **Labels**: Minimal text; let visual structure convey meaning
4. **Orientation**: Time flows upward (standard physics convention)

## References

### External Resources
- [TikZ.net - Minkowski Diagrams](https://tikz.net/relativity_minkowski_diagram/) - Light cone source code
- [TikZ.net - Penrose Diagrams](https://tikz.net/relativity_penrose_diagram/) - Conformal diagram techniques
- [GitHub - TikZ Spacetime Diagrams](https://gist.github.com/a1ip/b3c0bb87bdebf6ca1751) - Programmatic approaches
- [TikZ Arrows Blog](https://latexdraw.com/exploring-tikz-arrows/) - Arrow styling
- [Custom Curved Arrows](https://tomwawer.com/2025/04/06/creating-a-custom-fancy-arrow-in-latex-with-tikz/) - Bezier techniques

### Project Files Referenced
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Target file
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex` - TikZ style reference
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/assets/bimodal-notation.sty` - Notation macros

## Next Steps

1. Run `/plan 485` to create implementation plan with phases for:
   - Phase 1: Basic diagram structure with S-curve and marked point
   - Phase 2: Light cone regions with proper shading
   - Phase 3: Branching paths and counterfactual dotted lines
   - Phase 4: Labels and final polish
2. Implementation will modify `00-Introduction.tex` to insert the diagram
3. Verify compilation with `pdflatex` or `latexmk`
