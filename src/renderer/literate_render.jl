# # Literate Render - Single Function PDF Generation
#
# Production-ready function for EconTools package
# Note: Literate is imported at the EconTools module level

"""
    find_project_root(start_path=pwd())

Find the main project root directory, prioritizing repository roots.

Searches upward from `start_path` and returns the highest-level project root,
with preference for Git repositories over Julia subprojects.

Priority order:
1. .git directory (marks main repository root)
2. Project.toml + Manifest.toml together (main Julia project)  
3. Other single project markers

This ensures we find the main project root (like GeneticObesitySavings) 
rather than stopping at subproject directories (like data/, EconTools.jl/, etc.).

Returns the main project root directory or `start_path` if none found.
"""
function find_project_root(start_path=pwd())
    current_dir = abspath(start_path)
    
    git_root = nothing
    highest_julia_project = nothing
    highest_any_project = nothing
    
    while true
        # Check for .git (highest priority - marks repository root)
        if ispath(joinpath(current_dir, ".git"))
            git_root = current_dir
        end
        
        # Check for Julia project (Project.toml + Manifest.toml)
        has_project = isfile(joinpath(current_dir, "Project.toml"))
        has_manifest = isfile(joinpath(current_dir, "Manifest.toml"))
        if has_project && has_manifest
            highest_julia_project = current_dir
        end
        
        # Check for any project marker 
        other_markers = ["Cargo.toml", "package.json", "setup.py", "pyproject.toml"]
        for marker in other_markers
            if isfile(joinpath(current_dir, marker))
                if isnothing(highest_any_project)
                    highest_any_project = current_dir
                end
                break
            end
        end
        
        # Move up one directory
        parent_dir = dirname(current_dir)
        if parent_dir == current_dir  # Reached filesystem root
            break
        end
        current_dir = parent_dir
    end
    
    # Return in priority order: Git > Julia Project > Any Project > Start Path
    if !isnothing(git_root)
        return git_root
    elseif !isnothing(highest_julia_project)
        return highest_julia_project  
    elseif !isnothing(highest_any_project)
        return highest_any_project
    else
        return abspath(start_path)
    end
end

"""
    literate_render(input_file::String;
                   format="pdf",
                   execute=true,
                   notebook_subdir="notebooks",
                   quarto_config=nothing,
                   cleanup_temp=true,
                   verbose=true)

Render a Literate.jl script to PDF (or other formats) with automatic project organization.

This function provides a complete workflow:
1. Auto-detects project root (looks for Project.toml, .git, etc.)
2. Resolves relative paths from project root (works from any directory!)
3. Creates a 'notebooks' subdirectory in the script's directory (if needed)
4. Converts .jl → .ipynb using Literate.jl
5. Converts .ipynb → .pdf (or other format) using Quarto
6. Cleans up temporary files (.quarto folders, .gitignore, etc.)
7. Returns paths to all generated files

# Arguments
- `input_file::String`: Path to input .jl file (relative to project root OR absolute)

# Keyword Arguments
- `format::String="pdf"`: Output format (pdf, html, docx, etc.)
- `execute::Bool=true`: Execute notebook cells during conversion
- `notebook_subdir::String="notebooks"`: Subdirectory name for outputs (relative to input file's directory)
- `quarto_config::Union{String,Nothing}=nothing`: Path to custom _quarto.yml file (searches parent dirs if not provided)
- `cleanup_temp::Bool=true`: Remove temporary files (.quarto folders, .gitignore, etc.)
- `verbose::Bool=true`: Print progress messages

# Returns
- Named tuple: `(notebook=..., output=..., dir=...)`
  - `notebook`: Path to generated .ipynb file
  - `output`: Path to generated PDF/HTML/etc file
  - `dir`: Path to notebooks directory

# Path Resolution
**NEW: Project-root-aware path resolution!**

Relative paths are resolved from the detected project root:
- Project root automatically detected (searches for Project.toml, .git, etc.)
- Works from ANY directory within the project
- No need to worry about `pwd()` or absolute paths

# Directory Structure
Given project structure:
```
MyProject/                          (← Project root: has Project.toml)
├── Project.toml
├── scripts/analysis.jl
├── tmp/test.jl
└── data/notebook.jl
```

**All these work from ANY directory within MyProject:**
```julia
# From MyProject/ root
literate_render("scripts/analysis.jl")  # ✅ Works
literate_render("tmp/test.jl")          # ✅ Works

# From MyProject/scripts/
literate_render("../tmp/test.jl")       # ✅ Works (relative to project root)  
literate_render("tmp/test.jl")          # ✅ Works (relative to project root)

# Absolute paths work from anywhere
literate_render("/full/path/to/file.jl") # ✅ Always works
```

Generated structure (for `tmp/test.jl`):
```
MyProject/
├── Project.toml
└── tmp/
    ├── test.jl                     (original script)
    └── notebooks/
        ├── test.ipynb              (generated notebook)
        └── test.pdf                (generated PDF)
    └── analysis.tex               (LaTeX intermediate, if kept)
```

# Quarto Configuration
The function searches for `_quarto.yml` in this order:
1. If `quarto_config` is provided, uses that path
2. Searches in input file's directory
3. Searches in parent directories (up to 3 levels)
4. Searches in EconTools package directory (if using EconTools)
5. If not found, uses Quarto's default configuration

# Examples
```julia
# ===== Basic Usage (from any directory in project) =====
# All these work from anywhere within the project:

literate_render("tmp/test_interpolation.jl")          # Relative to project root
literate_render("data/stylized_facts/hrs/hrs.jl")     # Relative to project root  
literate_render("scripts/analysis.jl")               # Relative to project root

# ===== Advanced Options =====

# Convert to HTML instead of PDF  
literate_render("tmp/test.jl"; format="html")

# Don't execute cells (useful for long-running analyses)
literate_render("analysis.jl"; execute=false)

# Use custom output directory name
literate_render("analysis.jl"; notebook_subdir="output")

# Specify custom Quarto config
literate_render("analysis.jl"; quarto_config="/path/to/_quarto.yml")

# Keep temporary files for debugging
literate_render("analysis.jl"; cleanup_temp=false)

# ===== Batch Processing =====
# Process all .jl files in a directory
project_root = find_project_root()
scripts_dir = joinpath(project_root, "scripts")
for file in readdir(scripts_dir; join=false)
    if endswith(file, ".jl")
        script_path = joinpath("scripts", file)  # Relative to project root
        literate_render(script_path)
    end
end

# Integration with Workflows
```julia
# ===== Typical Research Project Workflow =====
# EconTools is installed as a registry package:
# ] add EconTools

using EconTools

# These work from anywhere within your research project:
literate_render("tmp/test_interpolation.jl")         # From project root
literate_render("tmp/test_interpolation.jl")         # From any subdirectory  
literate_render("data/analysis/notebook.jl")         # Nested directories
literate_render("scripts/figures.jl")                # Multiple script locations

# ===== Project Structure (GeneticObesitySavings example) =====
# GeneticObesitySavings/                    ← Git repo root (detected as project root)
# ├── .git/
# ├── Project.toml                          ← Main project
# ├── Manifest.toml  
# ├── src/                                  ← Source code
# ├── data/                                 ← May have own Project.toml (ignored)
# │   ├── Project.toml                      ← Subproject (ignored)  
# │   └── stylized_facts/hrs/hrs.jl
# ├── tmp/test_interpolation.jl             ← Test scripts
# └── scripts/analysis.jl                   ← Analysis scripts

# Function finds GeneticObesitySavings/ as project root (via .git)
# All relative paths resolve from that main directory
```

# Integration with EconTools
After adding to EconTools, use as:
```julia
using EconTools

# Single command to go from .jl to PDF
literate_render("my_analysis.jl")
```
"""
function literate_render(input_file::String;
                        format::String="pdf",
                        execute::Bool=true,
                        notebook_subdir::String="notebooks",
                        quarto_config::Union{String,Nothing}=nothing,
                        cleanup_temp::Bool=true,
                        verbose::Bool=true)

    # ===== Input Validation with Project Root Support =====
    
    # Detect project root for relative path resolution
    project_root = find_project_root()
    
    # Handle relative vs absolute paths
    if isabspath(input_file)
        input_path = input_file
    else
        # For relative paths, resolve from project root
        input_path = joinpath(project_root, input_file)
    end
    
    # Convert to absolute path and validate
    input_path = abspath(input_path)
    if !isfile(input_path)
        relative_path = relpath(input_path, project_root)
        error("Input file does not exist: $input_path\n" *
              "  (Project root: $project_root)\n" *
              "  (Relative path tried: $relative_path)")
    end
    if !endswith(input_path, ".jl")
        error("Input file must have .jl extension: $input_path")
    end
    
    verbose && println("Project root: $project_root")
    verbose && println("Input file: $input_path")

    # ===== Directory Setup =====
    input_dir = dirname(input_path)
    input_basename = splitext(basename(input_path))[1]
    notebooks_dir = joinpath(input_dir, notebook_subdir)

    # Create notebooks directory if it doesn't exist
    if !isdir(notebooks_dir)
        verbose && println("Creating output directory: $notebooks_dir")
        mkpath(notebooks_dir)
    end

    # ===== Find Quarto Config =====
    quarto_yml = find_quarto_config(input_dir, quarto_config)
    if !isnothing(quarto_yml) && verbose
        println("Using Quarto config: $quarto_yml")
    end

    # ===== Step 1: Convert .jl to .ipynb =====
    verbose && println("\n" * "="^60)
    verbose && println("Step 1: Converting .jl → .ipynb")
    verbose && println("="^60)
    verbose && println("Input:  $input_path")
    verbose && println("Output: $notebooks_dir")

    try
        Literate.notebook(
            input_path,
            notebooks_dir;
            execute=execute,
            documenter=false
        )
    catch e
        error("Literate.jl conversion failed: $e")
    end

    notebook_path = joinpath(notebooks_dir, input_basename * ".ipynb")
    if !isfile(notebook_path)
        error("Expected notebook file not found: $notebook_path")
    end

    verbose && println("✓ Notebook created: $notebook_path")

    # ===== Step 2: Convert .ipynb to output format =====
    verbose && println("\n" * "="^60)
    verbose && println("Step 2: Converting .ipynb → $format")
    verbose && println("="^60)

    # Build Quarto command with output directory
    cmd = `quarto render $notebook_path --to $format --output-dir $notebooks_dir`

    # Add Quarto config if found
    if !isnothing(quarto_yml)
        # Copy quarto config to notebooks dir temporarily for Quarto to find it
        temp_quarto = joinpath(notebooks_dir, "_quarto.yml")
        cp(quarto_yml, temp_quarto; force=true)
    end

    # Run Quarto
    try
        run(cmd)
    catch e
        error("Quarto conversion failed: $e")
    end

    # ===== Determine Output File =====
    output_ext = format_to_extension(format)
    output_path = joinpath(notebooks_dir, input_basename * output_ext)

    if !isfile(output_path)
        error("Expected output file not found: $output_path")
    end

    verbose && println("✓ $format file created: $output_path")

    # ===== Step 3: Cleanup =====
    if cleanup_temp
        verbose && println("\n" * "="^60)
        verbose && println("Step 3: Cleaning up temporary files")
        verbose && println("="^60)

        cleanup_paths = [
            joinpath(notebooks_dir, ".quarto"),
            joinpath(notebooks_dir, "_quarto.yml"),
            joinpath(notebooks_dir, ".gitignore"),
            joinpath(input_dir, ".quarto")
        ]

        for path in cleanup_paths
            if ispath(path)
                verbose && println("Removing: $path")
                rm(path; recursive=true, force=true)
            end
        end

        verbose && println("✓ Cleanup complete")
    end

    # ===== Summary =====
    if verbose
        println("\n" * "="^60)
        println("Conversion Complete!")
        println("="^60)
        println("Notebook: $notebook_path")
        println("Output:   $output_path")
        println("="^60)
    end

    return (notebook=notebook_path, output=output_path, dir=notebooks_dir)
end


"""
    find_quarto_config(start_dir::String, explicit_path::Union{String,Nothing})

Search for _quarto.yml configuration file.

Searches in order:
1. Explicit path (if provided)
2. start_dir
3. Parent directories (up to 3 levels up)
4. EconTools package directory (if available)

Returns path to _quarto.yml or nothing if not found.
"""
function find_quarto_config(start_dir::String, explicit_path::Union{String,Nothing})
    # If explicit path provided, use it
    if !isnothing(explicit_path)
        explicit_path = abspath(explicit_path)
        if isfile(explicit_path)
            return explicit_path
        else
            @warn "Specified quarto_config not found: $explicit_path"
            return nothing
        end
    end

    # Search in current directory and up to 3 parent levels
    search_dir = start_dir
    for _ in 1:4  # Current + 3 parents
        quarto_file = joinpath(search_dir, "_quarto.yml")
        if isfile(quarto_file)
            return quarto_file
        end

        # Move up one directory
        parent = dirname(search_dir)
        if parent == search_dir  # Reached filesystem root
            break
        end
        search_dir = parent
    end

    # Try to find EconTools package directory
    econtools_config = find_econtools_config()
    if !isnothing(econtools_config)
        return econtools_config
    end

    return nothing
end


"""
    find_econtools_config()

Get path to _quarto.yml in the EconTools/renderer/ directory.

Since this function is part of EconTools, we can directly reference @__DIR__.
Returns path to _quarto.yml or nothing if not found.
"""
function find_econtools_config()
    # Since this file is in EconTools/src/renderer/literate_render.jl,
    # @__DIR__ gives us the renderer directory where _quarto.yml lives
    quarto_file = joinpath(@__DIR__, "_quarto.yml")

    if isfile(quarto_file)
        return quarto_file
    end

    return nothing
end


"""
    format_to_extension(format::String)

Convert Quarto format name to file extension.
"""
function format_to_extension(format::String)
    format_map = Dict(
        "pdf" => ".pdf",
        "html" => ".html",
        "docx" => ".docx",
        "revealjs" => ".html",
        "beamer" => ".pdf",
        "markdown" => ".md",
        "gfm" => ".md"
    )

    return get(format_map, lowercase(format), ".$format")
end


"""
    literate_render_batch(input_files::Vector{String}; kwargs...)

Batch process multiple Literate.jl files.

# Arguments
- `input_files`: Vector of .jl file paths
- `kwargs...`: Arguments passed to `literate_render()` for each file

# Returns
- Vector of named tuples with results for each file: (file, success, result/error)

# Example
```julia
# Find all .jl files and convert them
scripts = filter(f -> endswith(f, ".jl"), readdir("analysis"; join=true))
results = literate_render_batch(scripts)

# Check for failures
failures = filter(r -> !r.success, results)
if !isempty(failures)
    println("Failed files:")
    for f in failures
        println("  - ", basename(f.file), ": ", f.error)
    end
end
```
"""
function literate_render_batch(input_files::Vector{String}; kwargs...)
    results = []

    for (i, file) in enumerate(input_files)
        println("\n\n")
        println("#"^70)
        println("Processing file $i of $(length(input_files)): $(basename(file))")
        println("#"^70)

        try
            result = literate_render(file; kwargs...)
            push!(results, (file=file, success=true, result=result))
        catch e
            @warn "Failed to convert $file" exception=e
            push!(results, (file=file, success=false, error=e))
        end
    end

    # Summary
    println("\n\n")
    println("="^70)
    println("Batch Conversion Summary")
    println("="^70)

    success_count = sum(r.success for r in results)
    println("✓ Successful: $success_count / $(length(input_files))")

    failures = filter(r -> !r.success, results)
    if !isempty(failures)
        println("\n✗ Failed files:")
        for r in failures
            println("  - $(basename(r.file))")
        end
    end

    println("="^70)

    return results
end


# Export functions
export literate_render, literate_render_batch
