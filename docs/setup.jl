using Pkg

# Get main project's deps
main_toml = Pkg.TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
doc_deps = get(get(main_toml, "targets", Dict()), "docs", String[])

# Activate docs environment
Pkg.activate(@__DIR__)

# Add main package
try
    Pkg.develop(path=joinpath(@__DIR__, ".."))
    @info "Successfully added local package"
catch e
    @error "Failed to add local package" exception = e
    exit(1)  # Fail the CI build if this critical step fails
end

# Add doc deps
for dep in doc_deps
    @info "Adding $dep"
    Pkg.add(dep)
end

# Ensure everything is installed
Pkg.instantiate()
