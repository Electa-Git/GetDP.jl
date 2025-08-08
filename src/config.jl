using Pkg.Artifacts
using SHA
using Downloads
using Base.BinaryPlatforms

function generate_getdp_artifacts(; force::Bool=false)
    artifacts_toml_path = joinpath(@__DIR__, "..", "Artifacts.toml")

    if !force && isfile(artifacts_toml_path)
        println("Artifacts.toml already exists. Use force=true to overwrite.")
        return artifacts_toml_path
    end

    artifacts = [
        ("getdp", "https://getdp.info/bin/Linux/getdp-3.5.0-Linux64c.tgz", "Linux x86_64", Platform("x86_64", "linux")),
        ("getdp", "https://getdp.info/bin/Windows/getdp-3.5.0-Windows64c.zip", "Windows x86_64", Platform("x86_64", "windows")),
        ("getdp", "https://getdp.info/bin/MacOSX/getdp-3.5.0-MacOSXc.tgz", "macOS x86_64", Platform("x86_64", "macos"))
    ]

    successful_artifacts = String[]

    for (name, url, description, platform) in artifacts
        println("Creating $description artifact ($name)...")
        temp_file = tempname()

        try
            Downloads.download(url, temp_file)

            if !isfile(temp_file) || filesize(temp_file) == 0
                @error "Download failed or empty file for $url"
                continue
            end

            file_hash = bytes2hex(sha256(read(temp_file)))
            println("Downloaded $url, SHA256: $file_hash")

            artifact_hash = create_artifact() do dir
                archive_path = joinpath(dir, basename(url))
                cp(temp_file, archive_path)

                if endswith(url, ".tgz")
                    success(`tar -xzf $archive_path -C $dir --strip-components=1`) ||
                        error("Failed to extract $archive_path")
                    rm(archive_path)
                elseif endswith(url, ".zip")
                    success(`unzip $archive_path -d $dir`) ||
                        error("Failed to extract $archive_path")
                    rm(archive_path)

                    subdirs = filter(isdir, readdir(dir, join=true))
                    if length(subdirs) == 1
                        subdir = subdirs[1]
                        for item in readdir(subdir, join=true)
                            dest = joinpath(dir, basename(item))
                            mv(item, dest)
                        end
                        rm(subdir)
                    end
                end

                # Use os() function instead of .os field
                expected_exe = (os(platform) == "windows") ? "getdp.exe" : "getdp"
                exe_candidates = [
                    joinpath(dir, expected_exe),
                    joinpath(dir, "bin", expected_exe)
                ]

                found_exe = findfirst(isfile, exe_candidates)
                found_exe === nothing && error("GetDP executable not found in artifact")

                println("Found GetDP executable at: $(exe_candidates[found_exe])")
            end

            bind_artifact!(artifacts_toml_path, name, artifact_hash;
                platform=platform,
                download_info=[(url, file_hash)],
                lazy=true,
                force=true)

            # Use os() function here too
            push!(successful_artifacts, "$(name)_$(os(platform))")
            println("✓ Artifact $name for $(os(platform)) created successfully")

        catch e
            @error "Failed to create artifact $name for $(os(platform))" exception = e
            continue
        finally
            isfile(temp_file) && rm(temp_file; force=true)
        end
    end

    if isempty(successful_artifacts)
        error("Failed to create any artifacts")
    end

    println("Successfully created $(length(successful_artifacts)) artifacts: $(join(successful_artifacts, ", "))")
    return artifacts_toml_path
end

generate_getdp_artifacts(force=true)