using GetDP
using Documenter

DocMeta.setdocmeta!(GetDP, :DocTestSetup, :(using GetDP); recursive=true)

makedocs(;
    modules=[GetDP],
    authors="Amauri Martins",
    sitename="GetDP.jl",
    format=Documenter.HTML(;
        canonical="https://Electa-Git.github.io/GetDP.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Electa-Git/GetDP.jl",
    devbranch="main",
)
