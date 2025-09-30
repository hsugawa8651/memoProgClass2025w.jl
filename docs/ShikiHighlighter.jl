module ShikiHighlighter

using Documenter

export shiki_html, add_shiki_assets

"""
    shiki_html(; theme="github-light", dark_theme="github-dark", languages=[...], kwargs...)

Returns Documenter.HTML() with Shiki highlighting functionality.
Supports all Documenter.HTML() options.

# Shiki-specific options
- `theme::String="github-light"`: Default theme
- `dark_theme::String="github-dark"`: Theme for dark mode
- `languages::Vector{String}`: List of supported languages
- `cdn_url::String="https://esm.sh"`: CDN URL for Shiki library
- `load_themes::Vector{String}=String[]`: List of themes to load

# Documenter.HTML options
All other keyword arguments are passed to Documenter.HTML().
"""
function shiki_html(;
    # Shiki-specific options
    theme="github-light",
    dark_theme="github-dark",
    languages=["julia", "javascript", "python", "bash", "json", "yaml", "toml"],
    cdn_url="https://esm.sh",
    load_themes=String[],
    # Basic Documenter.HTML options
    prettyurls=true,
    disable_git=false,
    edit_link=nothing,
    canonical=nothing,
    assets=String[],
    analytics="",
    collapselevel=2,
    sidebar_sitename=true,
    mathengine=Documenter.KaTeX(),
    footer=nothing,
    ansicolor=false,
    warn_outdated=true,
    prerender=true,  # Skip loading highlight.js
    highlights=String[],  # No additional languages
    kwargs... # Other Documenter.HTML options
)
    # If load_themes is empty, use theme and dark_theme
    if isempty(load_themes)
        load_themes = unique([theme, dark_theme])
    end

    # Add Shiki assets (loaded from root directory)
    shiki_assets = copy(assets)
    push!(shiki_assets, "shiki-plugin.css")
    push!(shiki_assets, "shiki-plugin.js")

    # Save Shiki configuration globally (used for asset generation)
    global SHIKI_CONFIG = (
        theme=theme,
        dark_theme=dark_theme,
        languages=languages,
        cdn_url=cdn_url,
        load_themes=load_themes
    )

    # Return standard Documenter.HTML()
    return Documenter.HTML(;
        prettyurls=prettyurls,
        disable_git=disable_git,
        edit_link=edit_link,
        canonical=canonical,
        assets=shiki_assets,
        analytics=analytics,
        collapselevel=collapselevel,
        sidebar_sitename=sidebar_sitename,
        mathengine=mathengine,
        footer=footer,
        ansicolor=ansicolor,
        warn_outdated=warn_outdated,
        prerender=prerender,
        highlights=highlights,
        kwargs...
    )
end

# Global configuration variable
SHIKI_CONFIG = nothing

"""
    add_shiki_assets(build_dir::String)

Adds Shiki CSS and JavaScript assets to the specified build directory.
Call this after makedocs().

# Usage example
```julia
makedocs(
    sitename="My Documentation",
    format=shiki_html(theme="github-dark"),
    pages=["Home" => "index.md"]
)
add_shiki_assets("docs/build")  # Add assets after build
```
"""
function add_shiki_assets(build_dir::String)
    if SHIKI_CONFIG === nothing
        @warn "Shiki configuration not found. Please use shiki_html() function first."
        return
    end

    # Create files in build directory root (where Documenter expects them)
    mkpath(build_dir)

    # Create CSS file
    css_content = generate_shiki_css()
    css_path = joinpath(build_dir, "shiki-plugin.css")
    write(css_path, css_content)

    # Create JavaScript file
    js_content = generate_shiki_javascript(SHIKI_CONFIG)
    js_path = joinpath(build_dir, "shiki-plugin.js")
    write(js_path, js_content)

    @info "📦 Created Shiki assets: $(css_path), $(js_path)"
end

"""
    generate_shiki_css()

Generates CSS styles for Shiki.
"""
function generate_shiki_css()
    return """
/* Shiki Highlighter Plugin Styles */

/* Default code block styles (before Shiki is applied) */
pre code {
    color: inherit !important;
    background: transparent !important;
}

html.theme--dark pre code,
html.theme--documenter-dark pre code {
    color: #c9d1d9 !important;
}

.shiki-loading {
    position: relative;
    background: #f6f8fa;
    border-radius: 6px;
    padding: 16px;
    font-family: 'JetBrains Mono', 'Fira Code', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    font-size: 14px;
    line-height: 1.5;
    border: 1px solid #e1e4e8;
    margin: 1em 0;
}

.shiki-loading::after {
    content: "⚡ Loading syntax highlighting...";
    color: #666;
    font-style: italic;
    opacity: 0.7;
    animation: pulse 1.5s ease-in-out infinite alternate;
}

@keyframes pulse {
    from { opacity: 0.4; }
    to { opacity: 0.8; }
}

.shiki {
    background-color: transparent !important;
    border-radius: 6px;
    padding: 16px;
    overflow-x: auto;
    font-family: 'JetBrains Mono', 'Fira Code', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    font-size: 14px;
    line-height: 1.5;
    border: 1px solid #e1e4e8;
    margin: 1em 0;
    position: relative;
}

.shiki code {
    background: none !important;
    padding: 0 !important;
    border-radius: 0 !important;
    font-weight: inherit;
    color: inherit;
    font-size: inherit;
}

.shiki pre {
    margin: 0;
    padding: 0;
    background: transparent;
    overflow: visible;
    font-size: inherit;
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
    .shiki-loading {
        background: #0d1117;
        border-color: #30363d;
        color: #c9d1d9;
    }
    
    .shiki {
        border-color: #30363d;
    }
}

/* Integration with Documenter themes */

/* Light theme */
html.theme--light .shiki,
html.theme--documenter-light .shiki {
    color: #000000;  /* Default text color to black */
}

/* Dark theme */
html.theme--dark .shiki-loading,
html.theme--documenter-dark .shiki-loading {
    background: #0d1117;
    border-color: #30363d;
    color: #c9d1d9;
}

html.theme--dark .shiki,
html.theme--documenter-dark .shiki {
    border-color: #30363d;
    color: #ffffff;  /* Default text color to white */
}

/* Use colors provided by Shiki theme as-is - keywords and numbers unchanged */
/* Only override variable names (common identifiers like i, j, etc.) */

/* Light theme: make variable names black */
html.theme--light .shiki span[style*="color:#383A42"],
html.theme--light .shiki span[style*="color:#383a42"] {
    color: #000000 !important;
}

/* Dark theme: make variable names white */
html.theme--dark .shiki span[style*="color:#383A42"],
html.theme--dark .shiki span[style*="color:#383a42"],
html.theme--documenter-dark .shiki span[style*="color:#383A42"],
html.theme--documenter-dark .shiki span[style*="color:#383a42"] {
    color: #ffffff !important;
}

/* Darken light text in light theme */
html.theme--light .shiki span[style*="color:#6F42C1"],
html.theme--light .shiki span[style*="color:#6f42c1"] {
    color: #5a32a3 !important;  /* Darker purple */
}

html.theme--light .shiki span[style*="color:#032F62"],
html.theme--light .shiki span[style*="color:#032f62"] {
    color: #022543 !important;  /* Darker blue */
}

/* Darken comments in light theme */
html.theme--light .shiki span[style*="color:#A0A1A7"],
html.theme--light .shiki span[style*="color:#a0a1a7"],
html.theme--light .shiki span[style*="color:#969896"],
html.theme--light .shiki span[style*="color:#8E908C"] {
    color: #5a5d62 !important;  /* Darker gray */
}

/* Darken light gray text in light theme */
html.theme--light .shiki span[style*="color:#383A42"],
html.theme--light .shiki span[style*="color:#383a42"] {
    color: #000000 !important;  /* Pure black */
}

/* Make identifiers (gray text) same darkness as comments in light theme */
html.theme--light .shiki span[style*="color:#959DA5"],
html.theme--light .shiki span[style*="color:#959da5"],
html.theme--light .shiki span[style*="color:#6A737D"],
html.theme--light .shiki span[style*="color:#6a737d"] {
    color: #5a5d62 !important;  /* Same dark gray as comments */
}

/* Darken default color identifiers in light theme */
html.theme--light .shiki span[style*="color:#24292E"],
html.theme--light .shiki span[style*="color:#24292e"] {
    color: #000000 !important;  /* Pure black */
}

/* Darken variable/function names in light theme */
html.theme--light .shiki span[style*="color:#E45649"],
html.theme--light .shiki span[style*="color:#e45649"] {
    color: #d73a49 !important;  /* Darker red */
}

html.theme--light .shiki span[style*="color:#4078F2"],
html.theme--light .shiki span[style*="color:#4078f2"] {
    color: #0366d6 !important;  /* Darker blue */
}

/* Darken light pink in light theme */
html.theme--light .shiki span[style*="color:#F97583"],
html.theme--light .shiki span[style*="color:#f97583"] {
    color: #000000 !important;  /* Pure black (identifier) */
}

/* Darken light blue in light theme */
html.theme--light .shiki span[style*="color:#79B8FF"],
html.theme--light .shiki span[style*="color:#79b8ff"],
html.theme--light .shiki span[style*="color:#79B8ff"] {
    color: #000000 !important;  /* Pure black (identifier) */
}

/* Darken light gray in light theme */
html.theme--light .shiki span[style*="color:#E1E4E8"],
html.theme--light .shiki span[style*="color:#e1e4e8"],
html.theme--light .shiki span[style*="color:#E1E4e8"] {
    color: #000000 !important;  /* Pure black */
}

/* Darken light green in light theme */
html.theme--light .shiki span[style*="color:#85E89D"],
html.theme--light .shiki span[style*="color:#85e89d"] {
    color: #22863a !important;  /* Dark green */
}

/* Darken light purple in light theme (one-light theme) */
html.theme--light .shiki span[style*="color:#B392F0"],
html.theme--light .shiki span[style*="color:#b392f0"] {
    color: #6f42c1 !important;  /* Dark purple */
}

/* Line number support */
.shiki .line {
    min-height: 1.5em;
}

/* Scrollbar styling */
.shiki::-webkit-scrollbar {
    height: 8px;
}

.shiki::-webkit-scrollbar-track {
    background: transparent;
}

.shiki::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,0.2);
    border-radius: 4px;
}

.shiki::-webkit-scrollbar-thumb:hover {
    background: rgba(0,0,0,0.3);
}

/* Copy button */
.shiki .copy-button {
    position: absolute;
    top: 8px;
    right: 8px;
    opacity: 0;
    transition: opacity 0.2s;
    background: rgba(255,255,255,0.9);
    border: 1px solid #e1e4e8;
    border-radius: 4px;
    padding: 4px 8px;
    font-size: 12px;
    cursor: pointer;
    font-family: inherit;
    z-index: 10;
}

.shiki:hover .copy-button {
    opacity: 1;
}

.shiki .copy-button:hover {
    background: rgba(255,255,255,1);
}

html.theme--dark .shiki .copy-button ,
html.theme--documenter-dark .shiki .copy-button {
    background: rgba(13,17,23,0.9);
    border-color: #30363d;
    color: #c9d1d9;
}

html.theme--dark .shiki .copy-button:hover ,
html.theme--documenter-dark .shiki .copy-button:hover {
    background: rgba(13,17,23,1);
}

/* Highlighted line styles - Level 1 (yellow) */
.shiki .highlighted,
.shiki .line.highlighted,
.shiki .highlight-level-1 {
    background-color: rgba(255, 255, 0, 0.1);
    position: relative;
}

.shiki .highlighted::before,
.shiki .line.highlighted::before,
.shiki .highlight-level-1::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(255, 255, 0, 0.1);
    z-index: -1;
}

/* Level 2 (red) */
.shiki .highlight-level-2 {
    background-color: rgba(255, 100, 100, 0.15);
    position: relative;
}

/* Apply normal text color rules even for highlighted lines */

.shiki .highlight-level-2::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(255, 100, 100, 0.15);
    z-index: -1;
}

/* Level 3 (green) */
.shiki .highlight-level-3 {
    background-color: rgba(100, 255, 100, 0.15);
    position: relative;
}

.shiki .highlight-level-3::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(100, 255, 100, 0.15);
    z-index: -1;
}

/* Level 4 (blue) */
.shiki .highlight-level-4 {
    background-color: rgba(100, 150, 255, 0.15);
    position: relative;
}

.shiki .highlight-level-4::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(100, 150, 255, 0.15);
    z-index: -1;
}

/* Highlights in dark mode - background color for entire line */
html.theme--dark .shiki .highlighted,
html.theme--dark .shiki .line.highlighted,
html.theme--dark .shiki .highlight-level-1 ,
html.theme--documenter-dark .shiki .highlight-level-1 {
    /* Level 1: yellowish - light background for entire line */
    background-color: rgba(200, 180, 0, 0.15);
    position: relative;
}

html.theme--dark .shiki .highlighted::before,
html.theme--dark .shiki .line.highlighted::before,
html.theme--dark .shiki .highlight-level-1::before ,
html.theme--documenter-dark .shiki .highlight-level-1::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(200, 180, 0, 0.15);
    z-index: -1;
}

/* Use normal color rules for highlighted lines (no filter) */

html.theme--dark .shiki .highlight-level-2 ,
html.theme--documenter-dark .shiki .highlight-level-2 {
    /* Level 2: reddish - light background for entire line */
    background-color: rgba(200, 80, 80, 0.15);
    position: relative;
}

html.theme--dark .shiki .highlight-level-2::before ,
html.theme--documenter-dark .shiki .highlight-level-2::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(200, 80, 80, 0.15);
    z-index: -1;
}


html.theme--dark .shiki .highlight-level-3 ,
html.theme--documenter-dark .shiki .highlight-level-3 {
    /* Level 3: greenish - light background for entire line */
    background-color: rgba(80, 180, 100, 0.15);
    position: relative;
}

html.theme--dark .shiki .highlight-level-3::before ,
html.theme--documenter-dark .shiki .highlight-level-3::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(80, 180, 100, 0.15);
    z-index: -1;
}


html.theme--dark .shiki .highlight-level-4 ,
html.theme--documenter-dark .shiki .highlight-level-4 {
    /* Level 4: bluish - light background for entire line */
    background-color: rgba(80, 140, 200, 0.15);
    position: relative;
}

html.theme--dark .shiki .highlight-level-4::before ,
html.theme--documenter-dark .shiki .highlight-level-4::before {
    content: '';
    position: absolute;
    left: -16px;
    right: -16px;
    top: 0;
    bottom: 0;
    background-color: rgba(80, 140, 200, 0.15);
    z-index: -1;
}


/* Diff display styles (optional) */
.shiki .diff.add {
    background-color: rgba(46, 160, 67, 0.15);
}

.shiki .diff.remove {
    background-color: rgba(248, 81, 73, 0.15);
}

html.theme--dark .shiki .diff.add ,
html.theme--documenter-dark .shiki .diff.add {
    background-color: rgba(46, 160, 67, 0.2);
}

html.theme--dark .shiki .diff.remove ,
html.theme--documenter-dark .shiki .diff.remove {
    background-color: rgba(248, 81, 73, 0.2);
}

/* Hide Catppuccin themes from settings menu */
#documenter-themepicker option[value="catppuccin-latte"],
#documenter-themepicker option[value="catppuccin-frappe"],
#documenter-themepicker option[value="catppuccin-macchiato"],
#documenter-themepicker option[value="catppuccin-mocha"] {
    display: none;
}
"""
end

"""
    generate_shiki_javascript(config)

Generates JavaScript code for Shiki.
"""
function generate_shiki_javascript(config)
    themes_json = join(["\"$theme\"" for theme in config.load_themes], ", ")
    languages_json = join(["\"$lang\"" for lang in config.languages], ", ")

    return """
// Shiki Highlighter for Documenter.jl
(function() {
    'use strict';
    
    const SHIKI_CONFIG = {
        theme: '$(config.theme)',
        darkTheme: '$(config.dark_theme)',
        languages: [$(languages_json)],
        themes: [$(themes_json)],
        cdnUrl: '$(config.cdn_url)'
    };
    
    let shikiHighlighter = null;
    let isLoading = false;
    let loadingPromise = null;
    
    console.log('🎨 ShikiHighlighter initialized');
    console.log('📋 Config:', SHIKI_CONFIG);
    
    // Variable to store transformers
    let shikiTransformers = null;

    // Dynamic import of Shiki
    async function loadShiki() {
        if (shikiHighlighter) return shikiHighlighter;
        if (isLoading) return loadingPromise;
        
        isLoading = true;
        
        loadingPromise = (async () => {
            try {
                console.log('📦 Loading Shiki highlighter and transformers...');
                
                // Load Shiki and Transformers in ES Modules format
                const shiki = await import(`\${SHIKI_CONFIG.cdnUrl}/shiki@1.22.2`);
                const transformersModule = await import(`\${SHIKI_CONFIG.cdnUrl}/@shikijs/transformers@1.22.2`);

                // Save transformers
                shikiTransformers = transformersModule;
                
                shikiHighlighter = await shiki.createHighlighter({
                    themes: SHIKI_CONFIG.themes,
                    langs: SHIKI_CONFIG.languages
                });
                
                console.log('✅ Shiki highlighter and transformers loaded successfully');
                return shikiHighlighter;
                
            } catch (error) {
                console.error('❌ Failed to load Shiki:', error);
                return null;
            } finally {
                isLoading = false;
            }
        })();
        
        return loadingPromise;
    }
    
    // Theme detection
    function getCurrentTheme() {
        // Check Documenter theme
        const htmlElement = document.documentElement;

        // Check multiple dark theme classes
        const isDark = htmlElement.classList.contains('theme--dark') ||
                      htmlElement.classList.contains('theme--documenter-dark') ||
                      htmlElement.classList.contains('documenter-dark') ||
                      htmlElement.getAttribute('data-theme') === 'dark' ||
                      htmlElement.getAttribute('data-theme') === 'documenter-dark';

        console.log(`🌓 Theme detection: isDark=\${isDark}, classes=\${htmlElement.className}`);

        // Use dark theme if dark theme is selected
        const selectedTheme = isDark ? SHIKI_CONFIG.darkTheme : SHIKI_CONFIG.theme;

        console.log(`🎨 Using theme: \${selectedTheme} (isDark=\${isDark})`);

        return selectedTheme;
    }
    
    // Parse range string: "1,3-4" -> [1, 3, 4]
    function parseHighlightRanges(rangeStr) {
        const ranges = [];
        rangeStr.split(',').forEach(part => {
            part = part.trim();
            if (part.includes('-')) {
                const [start, end] = part.split('-').map(s => parseInt(s.trim()));
                for (let i = start; i <= end; i++) {
                    ranges.push(i);
                }
            } else {
                const num = parseInt(part);
                if (!isNaN(num)) {
                    ranges.push(num);
                }
            }
        });
        return ranges;
    }
    
    // Add highlight class to specific lines (with level support)
    function addHighlightToLines(preElement, lineHighlights) {
        const codeElement = preElement.querySelector('code');
        if (!codeElement) return;

        // Get each line <span> generated by Shiki
        const lines = codeElement.querySelectorAll('.line');

        // If lineHighlights is an array (backward compatibility)
        if (Array.isArray(lineHighlights)) {
            lineHighlights.forEach(lineNum => {
                const lineIndex = lineNum - 1;
                if (lines[lineIndex]) {
                    lines[lineIndex].classList.add('highlighted');
                }
            });
        } 
        // If lineHighlights is an object (with levels)
        else if (typeof lineHighlights === 'object') {
            Object.entries(lineHighlights).forEach(([lineNum, level]) => {
                const lineIndex = parseInt(lineNum) - 1;
                if (lines[lineIndex]) {
                    lines[lineIndex].classList.add(`highlight-level-\${level}`);
                }
            });
        }
    }
    
    // Highlight code block
    async function highlightCodeBlock(codeBlock) {
        const pre = codeBlock.parentElement;

        // Save original code (use from data attribute if stored)
        let code = pre.dataset.originalCode || codeBlock.textContent;

        // Save original code and language on first render
        if (!pre.dataset.originalCode) {
            pre.dataset.originalCode = code;
            const langClass = Array.from(codeBlock.classList).find(cls => cls.startsWith('language-'));
            if (langClass) {
                pre.dataset.originalLang = langClass;
            }
        }
        
        const langClass = Array.from(codeBlock.classList).find(cls => cls.startsWith('language-'));
        const lang = langClass ? langClass.replace('language-', '') : 'text';
        
        // Detect @highlight: format
        let customHighlightLines = {};
        const lines = code.split('\\n');
        let filteredLines = [];
        let highlightStack = []; // Stack for nesting levels
        let lineOffset = 0;

        // Process each line
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];

            // @highlight: 1,3-4 format
            if (i === 0 && line.match(/^\\s*[#\\/\\/]\\s*@highlight:\\s*([\\d,-]+)/)) {
                const match = line.match(/^\\s*[#\\/\\/]\\s*@highlight:\\s*([\\d,-]+)/);
                const ranges = parseHighlightRanges(match[1]);
                ranges.forEach(lineNum => {
                    customHighlightLines[lineNum] = 1;
                });
                console.log(`📌 Custom highlight detected: lines \$\${ranges.join(', ')}`);
                lineOffset++;
                continue; // Skip this line
            }

            // Process @highlight-end at line end first
            if (line.match(/[#\\/\\/]\\s*@highlight-end\\s*\$/)) {
                // Apply current highlight level (before processing @highlight-end)
                if (highlightStack.length > 0) {
                    const currentLevel = highlightStack[highlightStack.length - 1];
                    customHighlightLines[i - lineOffset + 1] = currentLevel;
                    console.log(`   📍 Line \$\${i - lineOffset + 1} will be highlighted with level \$\${currentLevel} (before end)`);
                }
                console.log(`🔚 Found @highlight-end at line \$\${i + 1}`);
                highlightStack.pop();
                // Remove directive and keep line
                const cleanedLine = line.replace(/\\s*[#\\/\\/]\\s*@highlight-end\\s*\$/, '');
                filteredLines.push(cleanedLine);
                continue;
            }

            // @highlight-start[level] format (at line start or end)
            const startMatch = line.match(/^\\s*[#\\/\\/]\\s*@highlight-start(?:\\[(\\d+)\\])?|[#\\/\\/]\\s*@highlight-start(?:\\[(\\d+)\\])?\\s*\$/);
            if (startMatch) {
                const level = startMatch[1] || startMatch[2] || 1;
                const levelNum = typeof level === 'string' ? parseInt(level) : 1;
                console.log(`🔥 Found @highlight-start[\$\${levelNum}] at line \$\${i + 1}`);
                highlightStack.push(levelNum);
                // If @highlight-start at line start, skip entire line
                if (line.match(/^\\s*[#\\/\\/]\\s*@highlight-start/)) {
                    lineOffset++;
                    continue;
                }
                // If @highlight-start at line end, remove directive and keep line
                const cleanedLine = line.replace(/\\s*[#\\/\\/]\\s*@highlight-start(?:\\[(\\d+)\\])?\\s*\$/, '');
                filteredLines.push(cleanedLine);
                continue;
            }
            
            // @highlight-end at line start
            if (line.match(/^\\s*[#\\/\\/]\\s*@highlight-end/)) {
                console.log(`🔚 Found @highlight-end at line \$\${i + 1}`);
                highlightStack.pop();
                lineOffset++;
                continue; // Skip this line
            }

            // Apply current highlight level
            if (highlightStack.length > 0) {
                // Use deepest level (last element)
                const currentLevel = highlightStack[highlightStack.length - 1];
                customHighlightLines[i - lineOffset + 1] = currentLevel;
                console.log(`   📍 Line \$\${i - lineOffset + 1} will be highlighted with level \$\${currentLevel}`);
            }
            
            filteredLines.push(line);
        }
        
        // フィルタリング後のコードを使用
        code = filteredLines.join('\\n');
        
        // サポートされていない言語の場合はスキップ
        if (!SHIKI_CONFIG.languages.includes(lang) && lang !== 'text') {
            console.log(`⚠️  Skipping unsupported language: \${lang}`);
            return;
        }
        
        try {
            const highlighter = await loadShiki();
            if (!highlighter) {
                console.warn('⚠️  Highlighter not available, skipping...');
                return;
            }
            
            const theme = getCurrentTheme();
            console.log(`🎨 Highlighting \${lang} code with theme: \${theme}`);
            
            // Transformersを使用してハイライト
            const transformers = [];
            if (shikiTransformers) {
                // メタデータによるハイライト {1,3-4} 形式
                if (shikiTransformers.transformerMetaHighlight) {
                    transformers.push(shikiTransformers.transformerMetaHighlight());
                }
                // コメント記法によるハイライト [!code highlight]
                if (shikiTransformers.transformerNotationHighlight) {
                    transformers.push(shikiTransformers.transformerNotationHighlight({
                        matchAlgorithm: 'v3'  // コメント行の次の行からカウント
                    }));
                }
                // 差分表示用のtransformer（オプション）
                if (shikiTransformers.transformerNotationDiff) {
                    transformers.push(shikiTransformers.transformerNotationDiff({
                        matchAlgorithm: 'v3'
                    }));
                }
            }
            
            const html = highlighter.codeToHtml(code, { 
                lang, 
                theme,
                transformers: transformers
            });
            
            // 新しいShiki要素を作成
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = html;
            const shikiPre = tempDiv.querySelector('pre');
            
            if (shikiPre) {
                // カスタムハイライト行がある場合は適用
                if (Object.keys(customHighlightLines).length > 0) {
                    console.log(`✨ Applying highlights:`, customHighlightLines);
                    addHighlightToLines(shikiPre, customHighlightLines);
                }
                
                // コピーボタンを追加
                const copyButton = document.createElement('button');
                copyButton.className = 'copy-button';
                copyButton.textContent = 'Copy';
                copyButton.onclick = (e) => {
                    e.preventDefault();
                    navigator.clipboard.writeText(code).then(() => {
                        copyButton.textContent = 'Copied!';
                        setTimeout(() => copyButton.textContent = 'Copy', 2000);
                    }).catch(() => {
                        // フォールバック: テキストエリアを使用
                        const textarea = document.createElement('textarea');
                        textarea.value = code;
                        document.body.appendChild(textarea);
                        textarea.select();
                        document.execCommand('copy');
                        document.body.removeChild(textarea);
                        copyButton.textContent = 'Copied!';
                        setTimeout(() => copyButton.textContent = 'Copy', 2000);
                    });
                };
                shikiPre.appendChild(copyButton);
                
                // 元の要素を置き換え
                const parentPre = codeBlock.closest('pre');
                if (parentPre && parentPre.parentNode) {
                    parentPre.parentNode.replaceChild(shikiPre, parentPre);
                } else if (codeBlock.parentNode) {
                    codeBlock.parentNode.replaceChild(shikiPre, codeBlock);
                }
            }
            
        } catch (error) {
            console.error('❌ Error highlighting code:', error.message || error);
        }
    }
    
    // 全てのコードブロックを処理
    async function highlightAllCodeBlocks() {
        // 既に処理中の場合はスキップ
        if (highlightAllCodeBlocks.isRunning) {
            console.log('⏳ Highlight already in progress, skipping...');
            return;
        }
        highlightAllCodeBlocks.isRunning = true;
        
        try {
            // highlight.jsのクラスも含めて、全てのコードブロックを選択
            // hljs クラスが付いていても処理する
            // julia-repl と nohighlight は除外（Documenterが既に処理済み）
            const codeBlocks = document.querySelectorAll('pre:not(.shiki) code[class*="language-"]:not(.language-julia-repl):not(.nohighlight), pre:not(.shiki) code.hljs:not(.language-julia-repl):not(.nohighlight), pre:not(.shiki) code:not([class])');

            if (codeBlocks.length === 0) {
                console.log('📄 No unprocessed code blocks found');
                return;
            }
            
            console.log(`🔍 Found \${codeBlocks.length} code blocks to highlight`);
            
            // ローディング状態を表示
            codeBlocks.forEach(block => {
                const pre = block.closest('pre');
                if (pre && !pre.classList.contains('shiki')) {
                    pre.classList.add('shiki-loading');
                }
            });
            
            // バッチ処理で同時実行数を制限
            const BATCH_SIZE = 5;
            const codeBlocksArray = Array.from(codeBlocks);
            
            for (let i = 0; i < codeBlocksArray.length; i += BATCH_SIZE) {
                const batch = codeBlocksArray.slice(i, i + BATCH_SIZE);
                await Promise.all(batch.map(highlightCodeBlock));
            }
            
            // ローディング状態を削除
            document.querySelectorAll('.shiki-loading').forEach(el => {
                el.classList.remove('shiki-loading');
            });
            
            console.log(`🎉 Successfully highlighted \${codeBlocks.length} code blocks with Shiki`);
        } finally {
            highlightAllCodeBlocks.isRunning = false;
        }
    }
    
    // テーマ変更の監視
    function observeThemeChanges() {
        const observer = new MutationObserver(async (mutations) => {
            for (const mutation of mutations) {
                if (mutation.type === 'attributes' && 
                    (mutation.attributeName === 'class' || mutation.attributeName === 'data-theme')) {
                    console.log('🎨 Theme changed, re-highlighting...');
                    
                    // Reset highlighter instance
                    highlighterInstance = null;
                    
                    // Restore existing Shiki blocks to original state
                    const blocks = document.querySelectorAll('pre.shiki');
                    for (const pre of blocks) {
                        const codeElement = pre.querySelector('code');
                        if (codeElement && pre.dataset.originalCode) {
                            // Restore original code
                            codeElement.textContent = pre.dataset.originalCode;
                            // Remove Shiki class to allow reprocessing
                            pre.classList.remove('shiki');
                            // Maintain original class
                            const langClass = pre.dataset.originalLang;
                            if (langClass && !codeElement.classList.contains(langClass)) {
                                codeElement.classList.add(langClass);
                            }
                        }
                    }
                    
                    // Wait a bit before re-highlighting
                    await new Promise(resolve => setTimeout(resolve, 200));
                    await highlightAllCodeBlocks();
                    break;
                }
            }
        });

        observer.observe(document.documentElement, {
            attributes: true,
            attributeFilter: ['class', 'data-theme']
        });

        // Also monitor prefers-color-scheme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', async () => {
            console.log('🌙 System theme changed, re-highlighting...');

            // Reset highlighter instance
            highlighterInstance = null;

            // Restore existing Shiki blocks to original state
            const blocks = document.querySelectorAll('pre.shiki');
            for (const pre of blocks) {
                const codeElement = pre.querySelector('code');
                if (codeElement && pre.dataset.originalCode) {
                    // Restore original code
                    codeElement.textContent = pre.dataset.originalCode;
                    // Remove Shiki class to allow reprocessing
                    pre.classList.remove('shiki');
                    // Maintain original class
                    const langClass = pre.dataset.originalLang;
                    if (langClass && !codeElement.classList.contains(langClass)) {
                        codeElement.classList.add(langClass);
                    }
                }
            }
            
            // Wait a bit before re-highlighting
            await new Promise(resolve => setTimeout(resolve, 200));
            await highlightAllCodeBlocks();
        });
    }

    // Execute when DOM is ready
    function initialize() {
        // Start monitoring theme changes first
        observeThemeChanges();

        // Try highlighting at multiple timings
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                highlightAllCodeBlocks();
            });
        } else {
            // Execute immediately
            highlightAllCodeBlocks();
        }

        // Wait for Documenter initialization to complete
        setTimeout(() => {
            highlightAllCodeBlocks();
        }, 250);

        // Re-execute with more delay (fallback)
        setTimeout(() => {
            highlightAllCodeBlocks();
        }, 1000);
    }

    // Execute initialization
    initialize();

    // Also execute after full page load
    window.addEventListener('load', () => {
        setTimeout(highlightAllCodeBlocks, 100);
    });

    // Expose globally (for debugging)
    window.ShikiHighlighter = {
        rehighlight: highlightAllCodeBlocks,
        config: SHIKI_CONFIG,
        getCurrentTheme: getCurrentTheme
    };
    
})();
"""
end

end # module