using Thinkers
using Documenter

DocMeta.setdocmeta!(Thinkers, :DocTestSetup, :(using Thinkers); recursive=true)

makedocs(;
    modules=[Thinkers],
    authors="singularitti <singularitti@outlook.com> and contributors",
    repo="https://github.com/singularitti/Thinkers.jl/blob/{commit}{path}#{line}",
    sitename="Thinkers.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://singularitti.github.io/Thinkers.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => [
            "Installation guide" => "installation.md",
        ],
        "API Reference" => "public.md",
        "Developer Docs" => [
            "Contributing" => "developers/contributing.md",
            "Style Guide" => "developers/style-guide.md",
            "Design Principles" => "developers/design-principles.md",
        ],
        "Troubleshooting" => "troubleshooting.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/Thinkers.jl",
    devbranch="main",
)
