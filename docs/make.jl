using Documenter
using Pkg

function get_project_toml()
    # Get the current active environment (docs)
    docs_env = Pkg.project().path

    # Path to the main project (one level up from docs)
    main_project_path = joinpath(dirname(docs_env), "..")

    # Parse the main project's TOML
    project_toml = Pkg.TOML.parsefile(joinpath(main_project_path, "Project.toml"))

    return project_toml
end

function open_in_default_browser(url::AbstractString)::Bool
    try
        if Sys.isapple()
            Base.run(`open $url`)
            true
        elseif Sys.iswindows()
            Base.run(`powershell.exe Start "'$url'"`)
            true
        elseif Sys.islinux()
            Base.run(`xdg-open $url`, devnull, devnull, devnull)
            true
        else
            false
        end
    catch ex
        false
    end
end

# Get project data
PROJECT_TOML = get_project_toml()
PROJECT_VERSION = PROJECT_TOML["version"]
NAME = PROJECT_TOML["name"]
AUTHORS = join(PROJECT_TOML["authors"], ", ") * " and contributors."
GITHUB = PROJECT_TOML["git_url"]

@eval using $(Symbol(NAME))
main_module = @eval $(Symbol(NAME))

DocMeta.setdocmeta!(
    main_module,
    :DocTestSetup,
    :(using $(Symbol(NAME)));
    recursive=true,
)

mathengine = MathJax3(
    Dict(
        :loader => Dict("load" => ["[tex]/physics"]),
        :tex => Dict(
            "inlineMath" => [["\$", "\$"], ["\\(", "\\)"]],
            "tags" => "ams",
            "packages" => ["base", "ams", "autoload", "physics"],
        ),
        :chtml => Dict(
            :scale => 1.1,
        ),
    ),
)

makedocs(
    modules=[main_module],
    sitename="$NAME.jl",
    format=Documenter.HTML(;
        mathengine=mathengine,
        edit_link="main",
        prettyurls=get(ENV, "CI", "false") == "true",
        ansicolor=true,
        collapselevel=1,
        footer="[$NAME.jl]($GITHUB) v$PROJECT_VERSION supported by the Etch Competence Hub of EnergyVille, financed by the Flemish Government.",
        size_threshold=nothing,
    ),
    pages=[
        "API reference" => "index.md",
    ],
    clean=true,
    checkdocs=:exports,
    pagesonly=true,
    warnonly=false,
)

if haskey(ENV, "CI")
    deploydocs(
        repo="github.com/Electa-Git/GetDP.jl.git",
        devbranch="main",
        versions=["stable" => "v^", "dev" => "main"],
        branch="gh-pages",
    )
else
    open_in_default_browser(
        "file://$(abspath(joinpath(@__DIR__, "build", "index.html")))",
    ) ||
        println("Failed to open the documentation in the browser.")
end

@info "Finished docs build." # Good to know the script completed

