# using Pkg.Artifacts
# using SHA
# using Downloads
# using Base.BinaryPlatforms

# function platform_matches(p::Platform)
#     return (Sys.iswindows() && os(p) == "windows") ||
#            (Sys.islinux() && os(p) == "linux") ||
#            (Sys.isapple() && os(p) == "macos")
# end

# function generate_getdp_artifacts(; force::Bool=false)
#     artifacts_toml_path = joinpath(@__DIR__, "..", "Artifacts.toml")

#     if !force && isfile(artifacts_toml_path)
#         println("Artifacts.toml already exists. Use force=true to overwrite.")
#         return artifacts_toml_path
#     end

#     artifacts = [
#         ("getdp", "https://getdp.info/bin/Linux/getdp-3.5.0-Linux64c.tgz", "Linux x86_64", Platform("x86_64", "linux")),
#         ("getdp", "https://getdp.info/bin/Windows/getdp-3.5.0-Windows64c.zip", "Windows x86_64", Platform("x86_64", "windows")),
#         ("getdp", "https://getdp.info/bin/MacOSX/getdp-3.5.0-MacOSXc.tgz", "macOS x86_64", Platform("x86_64", "macos"))
#     ]

#     successful_artifacts = String[]

#     for (name, url, description, platform) in filter(a -> platform_matches(a[4]), artifacts)
#         println("Creating $description artifact ($name)...")
#         temp_file = tempname()

#         try
#             Downloads.download(url, temp_file)

#             if !isfile(temp_file) || filesize(temp_file) == 0
#                 @error "Download failed or empty file for $url"
#                 continue
#             end

#             file_hash = bytes2hex(sha256(read(temp_file)))
#             println("Downloaded $url, SHA256: $file_hash")

#             artifact_hash = create_artifact() do dir
#                 archive_path = joinpath(dir, basename(url))
#                 cp(temp_file, archive_path)

#                 if endswith(url, ".tgz")
#                     run(`tar -xzf $archive_path -C $dir --strip-components=1`)
#                 elseif endswith(url, ".zip")
#                     run(`unzip -q $archive_path -d $dir`)
#                     rm(archive_path; force=true)

#                     subdirs = filter(isdir, readdir(dir, join=true))
#                     if length(subdirs) == 1
#                         for item in readdir(subdirs[1], join=true)
#                             mv(item, joinpath(dir, basename(item)))
#                         end
#                         rm(subdirs[1]; recursive=true)
#                     end
#                 else
#                     error("Unknown archive format: $url")
#                 end

#                 exe_name = os(platform) == "windows" ? "getdp.exe" : "getdp"
#                 exe_path = joinpath(dir, exe_name)
#                 if !isfile(exe_path)
#                     exe_path = joinpath(dir, "bin", exe_name)
#                     isfile(exe_path) || error("GetDP executable not found")
#                 end

#                 println("✔ Found GetDP executable at: $exe_path")
#             end

#             bind_artifact!(
#                 artifacts_toml_path,
#                 name,
#                 artifact_hash;
#                 platform=platform,
#                 download_info=[(url, file_hash)],
#                 lazy=false,
#                 force=true
#             )

#             push!(successful_artifacts, "$(name)_$(os(platform))")
#             println("✓ Artifact $name for $(os(platform)) created successfully")

#         catch e
#             @error "Failed to create artifact $name for $(os(platform))" exception = e
#         finally
#             isfile(temp_file) && rm(temp_file; force=true)
#         end
#     end

#     isempty(successful_artifacts) && error("Failed to create any artifacts")

#     println("✅ Created artifacts: $(join(successful_artifacts, ", "))")
#     return artifacts_toml_path
# end


# generate_getdp_artifacts(force=true)

using SHA
using Downloads

function generate_getdp_artifacts()
    artifacts_content = """
    # Auto-generated Artifacts.toml for GetDP
    """

    platforms = [
        ("linux", "x86_64", "https://getdp.info/bin/Linux/getdp-3.5.0-Linux64c.tgz"),
        ("windows", "x86_64", "https://getdp.info/bin/Windows/getdp-3.5.0-Windows64c.zip"),
        ("macos", "x86_64", "https://getdp.info/bin/MacOSX/getdp-3.5.0-MacOSXc.tgz"),
    ]

    for (os, arch, url) in platforms
        println("Getting SHA256 for $os...")
        temp = tempname()
        try
            Downloads.download(url, temp)
            sha = bytes2hex(sha256(read(temp)))

            artifacts_content *= """

            [[getdp]]
            arch = "$arch"
            os = "$os"
            lazy = true

                [[getdp.download]]
                url = "$url"
                sha256 = "$sha"
            """
        finally
            rm(temp, force=true)
        end
    end

    write("Artifacts.toml", artifacts_content)
    println("✅ Artifacts.toml generated successfully")
end

# Run this once to generate Artifacts.toml
generate_getdp_artifacts()