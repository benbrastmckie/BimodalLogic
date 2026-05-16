---
description: Convert documents between formats (PDF/DOCX to Markdown, Markdown to PDF, PPTX to Beamer/Polylux/Touying)
allowed-tools: Skill, Bash(jq:*), Bash(test:*), Bash(dirname:*), Bash(basename:*), Read
argument-hint: SOURCE_PATH [OUTPUT_PATH] [--format beamer|polylux|touying] [--theme NAME]
---

# /convert Command

Convert documents between formats by delegating to the filetypes skill/agent chain. Handles general document conversion (PDF, DOCX, XLSX, HTML, images <-> Markdown) and PowerPoint-to-slide-format conversion (PPTX -> Beamer, Polylux, Touying) via the presentation skill.

## Arguments

- `$1` - Source file path (required)
- `$2` - Output file path (optional, inferred from source if not provided)
- `--format` - Output format for slide conversion: `beamer`, `polylux`, or `touying` (only used when source is `.pptx`/`.ppt`)
- `--theme` - Theme name (optional, only used with `--format`)

## Usage Examples

```bash
# PDF to Markdown (output inferred)
/convert document.pdf                    # -> document.md

# DOCX to Markdown with explicit output
/convert report.docx notes.md            # -> notes.md

# Markdown to PDF
/convert README.md README.pdf            # -> README.pdf

# HTML to Markdown
/convert page.html page.md               # -> page.md

# Absolute paths
/convert /path/to/file.pdf /output/dir/result.md

# PPTX to Beamer (default slide format)
/convert presentation.pptx --format beamer               # -> presentation.tex

# PPTX to Polylux (Typst)
/convert deck.pptx slides.typ --format polylux

# PPTX to Touying (Typst)
/convert talk.pptx talk.typ --format touying

# PPTX to Beamer with theme
/convert conference.pptx conf.tex --format beamer --theme metropolis

# PPTX to Markdown (no --format flag, uses markitdown)
/convert deck.pptx deck.md
```

## Supported Conversions

| Source | Target | Notes |
|--------|--------|-------|
| PDF | Markdown | Uses markitdown or pandoc |
| DOCX | Markdown | Uses markitdown or pandoc |
| XLSX | Markdown | Uses markitdown (tables) |
| PPTX | Markdown | Uses markitdown |
| PPTX | Beamer | Uses python-pptx + pandoc (via `--format beamer`) |
| PPTX | Polylux | Uses python-pptx -> Typst (via `--format polylux`) |
| PPTX | Touying | Uses python-pptx -> Typst (via `--format touying`) |
| HTML | Markdown | Uses markitdown or pandoc |
| Images | Markdown | Uses markitdown (OCR if available) |
| Markdown | PDF | Uses pandoc or typst |

**Note**: For spreadsheet-to-table conversions, use `/table`. Research-talk task creation (distinct from slide file conversion) uses `/slides` in the present extension.

## Slide Output Formats

### Beamer (LaTeX)
- Traditional academic presentation format
- Wide theme support (metropolis, Madrid, etc.)
- Supports overlays and animations
- Speaker notes via `\note{}` command

### Polylux (Typst)
- Typst-native slide package
- Simple, clean syntax
- Easy customization
- Good for quick slides

### Touying (Typst)
- Feature-rich Typst slide framework
- Multiple themes (simple, dewdrop, university)
- Advanced animations
- Better for complex presentations

## Execution

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   source_path="$1"
   output_path=""
   output_format=""
   theme=""

   # Parse remaining arguments
   shift
   while [[ $# -gt 0 ]]; do
     case "$1" in
       --format)
         output_format="$2"
         shift 2
         ;;
       --theme)
         theme="$2"
         shift 2
         ;;
       *)
         if [ -z "$output_path" ]; then
           output_path="$1"
         fi
         shift
         ;;
     esac
   done

   # Validate source path provided
   if [ -z "$source_path" ]; then
     echo "Error: Source path required"
     echo "Usage: /convert SOURCE_PATH [OUTPUT_PATH] [--format beamer|polylux|touying] [--theme NAME]"
     exit 1
   fi

   # Convert to absolute path if relative
   if [[ "$source_path" != /* ]]; then
     source_path="$(pwd)/$source_path"
   fi
   ```

3. **Validate Source File Exists**
   ```bash
   if [ ! -f "$source_path" ]; then
     echo "Error: Source file not found: $source_path"
     exit 1
   fi
   ```

4. **Determine Output Path** (if not provided)
   ```bash
   if [ -z "$output_path" ]; then
     source_dir=$(dirname "$source_path")
     source_base=$(basename "$source_path" | sed 's/\.[^.]*$//')
     source_ext="${source_path##*.}"

     # When slide format is set and source is pptx/ppt, infer slide output extension
     if [ -n "$output_format" ] && { [ "$source_ext" = "pptx" ] || [ "$source_ext" = "ppt" ]; }; then
       case "$output_format" in
         beamer|latex|tex) output_path="${source_dir}/${source_base}.tex" ;;
         polylux|touying|typst|typ) output_path="${source_dir}/${source_base}.typ" ;;
         pptx) output_path="${source_dir}/${source_base}_generated.pptx" ;;
         *) output_path="${source_dir}/${source_base}.tex" ;;
       esac
     else
       case "$source_ext" in
         pdf|docx|xlsx|pptx|html|htm|png|jpg|jpeg)
           output_path="${source_dir}/${source_base}.md"
           ;;
         md|markdown)
           output_path="${source_dir}/${source_base}.pdf"
           ;;
         *)
           echo "Error: Cannot infer output format for .$source_ext"
           echo "Please specify output path explicitly"
           exit 1
           ;;
       esac
     fi
   fi

   # Convert output to absolute path if relative
   if [[ "$output_path" != /* ]]; then
     output_path="$(pwd)/$output_path"
   fi
   ```

5. **Validate Output Format** (if specified)
   ```bash
   if [ -n "$output_format" ]; then
     case "$output_format" in
       beamer|latex|polylux|touying|typst|pptx)
         ;; # Valid slide format
       *)
         echo "Error: Unknown output format: $output_format"
         echo "Supported formats: beamer, polylux, touying"
         exit 1
         ;;
     esac
   fi
   ```

**ABORT** if source file does not exist or format is unsupported.

**On GATE IN success**: Arguments validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Dispatch logic**: If the source file is a PowerPoint (`.pptx`/`.ppt`) AND `--format` is one of `beamer|polylux|touying`, route to `skill-presentation`. Otherwise route to the general `skill-filetypes` converter.

```bash
source_ext="${source_path##*.}"
if { [ "$source_ext" = "pptx" ] || [ "$source_ext" = "ppt" ]; } && \
   [ -n "$output_format" ] && \
   { [ "$output_format" = "beamer" ] || [ "$output_format" = "polylux" ] || [ "$output_format" = "touying" ]; }; then
  use_presentation_skill=true
else
  use_presentation_skill=false
fi
```

**If presentation skill applies**, invoke the Skill tool NOW with:
```
skill: "skill-presentation"
args: "source_path={source_path} output_path={output_path} output_format={output_format} theme={theme} session_id={session_id}"
```

**Otherwise**, invoke the Skill tool NOW with:
```
skill: "skill-filetypes"
args: "source_path={source_path} output_path={output_path} session_id={session_id}"
```

The selected skill will spawn the appropriate agent (presentation-agent for slides, filetypes-router-agent otherwise).

**On DELEGATE success**: Conversion attempted. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts. For slide dispatch path, `metadata.slide_count` is also expected.

2. **Verify Output File Exists**
   ```bash
   if [ ! -f "$output_path" ]; then
     echo "Warning: Output file not created"
     # Return skill error details
   fi
   ```

3. **Verify Output Non-Empty**
   ```bash
   if [ ! -s "$output_path" ]; then
     echo "Warning: Output file is empty"
   fi
   ```

**On GATE OUT success**: Output verified.

### CHECKPOINT 3: COMMIT

Git commit is **optional** for standalone conversions.

Only commit if:
- User explicitly requests it
- Conversion is part of a task workflow

```bash
# Only if commit requested
git add "$output_path"
git commit -m "$(cat <<'EOF'
convert: {source_filename} -> {output_filename}

Session: {session_id}
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

**Success** (general conversion):
```
Conversion complete!

Source: {source_path}
Output: {output_path}
Tool:   {tool_used from metadata}
Size:   {output_size}

Status: converted
```

**Success** (slide conversion):
```
Slide conversion complete!

Source: {source_path}
Output: {output_path}
Format: {output_format}
Slides: {slide_count}
Notes:  {has_speaker_notes ? "Included" : "None"}

Tool used: {tool from metadata}

Status: converted
```

**Partial (empty output)**:
```
Conversion completed with warnings.

Source: {source_path}
Output: {output_path}
Warning: Output may be incomplete or require manual review.

Status: extracted
```

**Failed**:
```
Conversion failed.

Source: {source_path}
Error: {error_message}

Recommendation: {recommendation from error}
```

## Error Handling

### GATE IN Failure

**Source not found**:
```
Error: Source file not found: {path}

Please verify the file path and try again.
```

**Unsupported format**:
```
Error: Cannot infer output format for .{ext}

Supported source formats: pdf, docx, xlsx, pptx (with --format for slide output), html, md
Please specify output path explicitly: /convert source.{ext} output.md
```

**Invalid slide output format**:
```
Error: Unknown output format: {format}

Supported slide formats: beamer, polylux, touying
```

### DELEGATE Failure

**Tool not available (general conversion)**:
```
Error: No conversion tools available.

Required tools (install one):
  - markitdown: pip install markitdown
  - pandoc: apt install pandoc (or brew install pandoc)

Then retry: /convert {source_path}
```

**Tool not available (slide conversion)**:
```
Error: Required tools not available for presentation conversion.

Install with:
  pip install python-pptx

For Beamer output, also install:
  apt install pandoc  (or brew install pandoc)

Then retry: /convert {source_path} --format {output_format}
```

**Conversion error**:
```
Error: Conversion failed.

Details: {error_message from agent}
Recommendation: {recommendation from agent}
```

**Corrupted PPTX file**:
```
Error: Failed to open PPTX file.

The file may be corrupted or not a valid PowerPoint file.
Try re-saving the file from PowerPoint.
```

### GATE OUT Failure

**Output not created**:
```
Warning: Output file was not created.

The conversion tool may have failed silently.
Check the source file for issues (encrypted, corrupted, etc.)
```
