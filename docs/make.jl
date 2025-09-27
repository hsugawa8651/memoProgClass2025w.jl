using memoProgClass2025w
using Documenter

include("./ShikiHighlighter.jl")
using .ShikiHighlighter

DocMeta.setdocmeta!(memoProgClass2025w, :DocTestSetup, :(using memoProgClass2025w); recursive=true)

ENV["PLOTS_TEST"] = "true"
ENV["GKSwstype"] = "100"

makedocs(;
    modules=[memoProgClass2025w],
    authors="Hiroharu Sugawara <hsugawa@gmail.com>",
    sitename="memoProgClass2025w.jl",
    remotes=nothing,
    format=shiki_html(;
        theme="github-light",
        dark_theme="github-dark",
        canonical="https://hsugawa8651.github.io/memoProgClass2025w.jl",
        edit_link="main",
        assets=String[],
        size_threshold=nothing,
        example_size_threshold=1000000000,
        size_threshold_warn=1000000000,
    ),
    pages=[
        "Home" => "index.md",
        "LICENSE.md",
	    "LICENSEja.md",
	 	"ch00.md",
	    "ch01.md",
		"ch02.md",
		"ch03.md",
		"ch04.md",
		"ch05.md",
		"ch06.md",
		"ch07.md",
		"ch08.md",
	    "ch09.md",
		"ch10.md",
		"ch11.md",
		"ch12.md",
		"ch13.md",
		"ch14.md",
    ],
)

deploydocs(;
    repo="github.com/hsugawa8651/memoProgClass2025w.jl",
    devbranch="main",
)