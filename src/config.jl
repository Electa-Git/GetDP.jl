using Pkg.Artifacts
using SHA
using Downloads
using Base.BinaryPlatforms
using Tar
using CodecZlib

"""
Generate GetDP artifacts for different platforms and bind them to Artifacts.toml.
"""
function generate_getdp_artifacts(; force::Bool=false)
    artifacts_toml_path = joinpath(@__DIR__, "..", "Artifacts.toml")

    if !force && isfile(artifacts_toml_path)
        println("Artifacts.toml already exists. Use force=true to overwrite.")
        return artifacts_toml_path
    end

    # Clear any existing broken artifacts.toml
    if isfile(artifacts_toml_path)
        rm(artifacts_toml_path)
        println("Removed existing Artifacts.toml")
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
            # Download with proper error handling
            println("Downloading $url...")
            Downloads.download(url, temp_file)

            if !isfile(temp_file) || filesize(temp_file) == 0
                @error "Download failed or empty file for $url"
                continue
            end

            file_hash = bytes2hex(sha256(read(temp_file)))
            println("Downloaded $url, SHA256: $file_hash")

            # Create artifact with consistent extraction
            artifact_hash = create_artifact() do dir
                archive_path = joinpath(dir, basename(url))
                cp(temp_file, archive_path)

                if endswith(url, ".tgz")
                    # Use Julia's Tar.jl for consistent extraction across platforms
                    println("Extracting with Julia Tar.jl for consistency...")
                    # Extract to a temp directory first, then move contents
                    temp_extract_dir = mktempdir()
                    try
                        open(archive_path, "r") do io
                            Tar.extract(GzipDecompressorStream(io), temp_extract_dir)
                        end
                        rm(archive_path)

                        # Move extracted contents to artifact directory
                        extracted_items = readdir(temp_extract_dir, join=true)
                        if length(extracted_items) == 1 && isdir(extracted_items[1])
                            # Single top-level directory, move its contents
                            for item in readdir(extracted_items[1], join=true)
                                mv(item, joinpath(dir, basename(item)))
                            end
                        else
                            # Multiple items at top level, move all
                            for item in extracted_items
                                mv(item, joinpath(dir, basename(item)))
                            end
                        end
                    finally
                        rm(temp_extract_dir, recursive=true, force=true)
                    end

                    # Find and flatten the extracted directory structure
                    entries = readdir(dir)
                    # Already flattened above, no need to do it again

                elseif endswith(url, ".zip")
                    # For Windows zip files, use system unzip but normalize
                    println("Extracting ZIP file...")
                    run(`unzip -q $archive_path -d $dir`)
                    rm(archive_path)

                    # Normalize directory structure for Windows
                    entries = readdir(dir)
                    if length(entries) == 1 && isdir(joinpath(dir, entries[1]))
                        # Single top-level directory, flatten it
                        extracted_dir = joinpath(dir, entries[1])
                        for item in readdir(extracted_dir, join=true)
                            dest = joinpath(dir, basename(item))
                            mv(item, dest)
                        end
                        rm(extracted_dir)
                    end
                end

                # Verify and fix executable permissions
                expected_exe = (os(platform) == "windows") ? "getdp.exe" : "getdp"
                exe_candidates = [
                    joinpath(dir, expected_exe),
                    joinpath(dir, "bin", expected_exe),
                    joinpath(dir, "GetDP", expected_exe),  # Sometimes it's in a GetDP subdir
                ]

                # Find the executable
                found_exe_path = nothing
                for candidate in exe_candidates
                    if isfile(candidate)
                        found_exe_path = candidate
                        break
                    end
                end

                if found_exe_path === nothing
                    # List directory contents for debugging
                    println("Directory contents:")
                    for (root, dirs, files) in walkdir(dir)
                        for file in files
                            println("  $(joinpath(root, file))")
                        end
                    end
                    error("GetDP executable '$expected_exe' not found in artifact")
                end

                # Make executable on Unix systems
                if !Sys.iswindows() && found_exe_path !== nothing
                    chmod(found_exe_path, 0o755)
                end

                println("Found GetDP executable at: $found_exe_path")

                # Verify the executable location is normalized
                # Move to expected location if needed
                expected_path = if os(platform) == "windows"
                    joinpath(dir, "getdp.exe")
                else
                    # Ensure bin directory exists
                    bin_dir = joinpath(dir, "bin")
                    !isdir(bin_dir) && mkdir(bin_dir)
                    joinpath(bin_dir, "getdp")
                end

                if found_exe_path != expected_path
                    # Create directory if needed
                    mkpath(dirname(expected_path))
                    # Move to expected location
                    mv(found_exe_path, expected_path)
                    println("Moved executable to standard location: $expected_path")
                end
            end

            # Bind artifact to Artifacts.toml
            bind_artifact!(artifacts_toml_path, name, artifact_hash;
                platform=platform,
                download_info=[(url, file_hash)],
                lazy=false,
                force=true)

            push!(successful_artifacts, "$(name)_$(os(platform))")
            println("✓ Artifact $name for $(os(platform)) created successfully")
            println("  Hash: $artifact_hash")

        catch e
            @error "Failed to create artifact $name for $(os(platform))" exception = e
            # Print full stack trace for debugging
            showerror(stderr, e, catch_backtrace())
            continue
        finally
            isfile(temp_file) && rm(temp_file; force=true)
        end
    end

    if isempty(successful_artifacts)
        error("Failed to create any artifacts")
    end

    println("\n" * "="^60)
    println("SUCCESS: Created $(length(successful_artifacts)) artifacts")
    println("Artifacts: $(join(successful_artifacts, ", "))")
    println("Artifacts.toml location: $artifacts_toml_path")
    println("="^60)

    # Verify the Artifacts.toml was created properly
    if isfile(artifacts_toml_path)
        println("\nArtifacts.toml contents:")
        println(read(artifacts_toml_path, String))
    end

    return artifacts_toml_path
end

# Cleanup function to remove any broken artifacts
function clean_artifacts()
    artifacts_toml_path = joinpath(@__DIR__, "..", "Artifacts.toml")
    if isfile(artifacts_toml_path)
        rm(artifacts_toml_path)
        println("Removed Artifacts.toml")
    else
        println("No Artifacts.toml to remove")
    end
end

# Test function to verify artifacts work
function test_getdp_artifacts()
    try
        # This should work after generation
        artifact_dir = artifact"getdp"
        executable = Sys.iswindows() ? joinpath(artifact_dir, "getdp.exe") : joinpath(artifact_dir, "bin", "getdp")

        if isfile(executable)
            println("✓ GetDP artifact test PASSED: $executable")
            return true
        else
            println("✗ GetDP artifact test FAILED: executable not found at $executable")
            return false
        end
    catch e
        println("✗ GetDP artifact test FAILED with exception: $e")
        return false
    end
end

using Pkg.Artifacts
using Pkg
using SHA

"""
Simulate what CI will do - clear cache and download fresh
"""
function simulate_ci_environment()
    println("🚀 Simulating fresh CI environment...")

    # Find all getdp artifacts in your cache
    artifacts_dir = joinpath(first(DEPOT_PATH), "artifacts")

    if !isdir(artifacts_dir)
        println("No artifacts directory found - already clean")
        return
    end

    # Find getdp-related artifacts by checking the Artifacts.toml hashes
    artifacts_toml_path = joinpath(@__DIR__, "..", "Artifacts.toml")
    if !isfile(artifacts_toml_path)
        error("Artifacts.toml not found!")
    end

    # Parse the TOML to get the hashes
    artifacts_dict = Pkg.Artifacts.load_artifacts_toml(artifacts_toml_path)
    getdp_hashes = []

    if haskey(artifacts_dict, "getdp")
        for variant in artifacts_dict["getdp"]
            if isa(variant, Dict) && haskey(variant, "git-tree-sha1")
                push!(getdp_hashes, variant["git-tree-sha1"])
            end
        end
    end

    println("Found GetDP artifact hashes: $(getdp_hashes)")

    # Remove these specific artifacts to simulate fresh environment
    removed_count = 0
    for hash in getdp_hashes
        artifact_path = joinpath(artifacts_dir, hash)
        if isdir(artifact_path)
            println("🗑️  Removing cached artifact: $hash")
            rm(artifact_path, recursive=true, force=true)
            removed_count += 1
        end
    end

    if removed_count == 0
        println("No GetDP artifacts found in cache - already clean")
    else
        println("✅ Removed $removed_count cached GetDP artifacts")
    end
end

"""
Test downloading artifacts from scratch (like CI does)
"""
function test_fresh_artifact_download()
    println("\n🧪 Testing fresh artifact download...")

    try
        # This should trigger a download since we cleared the cache
        println("Calling artifact\"getdp\"...")
        artifact_dir = artifact"getdp"

        println("✅ Artifact downloaded successfully!")
        println("📁 Location: $artifact_dir")

        # Verify the executable exists
        expected_exe = Sys.iswindows() ? "getdp.exe" : "getdp"
        exe_candidates = [
            joinpath(artifact_dir, expected_exe),
            joinpath(artifact_dir, "bin", expected_exe)
        ]

        found_exe = nothing
        for candidate in exe_candidates
            if isfile(candidate)
                found_exe = candidate
                break
            end
        end

        if found_exe !== nothing
            println("✅ GetDP executable found: $found_exe")

            # Try to get version info (if possible)
            try
                result = read(`$found_exe --version`, String)
                println("📋 Version info: $(strip(result))")
            catch
                println("ℹ️  Could not get version info (normal for some platforms)")
            end

            return true
        else
            println("❌ GetDP executable not found in artifact!")
            println("📁 Artifact contents:")
            for (root, dirs, files) in walkdir(artifact_dir)
                for file in files
                    println("  $(relpath(joinpath(root, file), artifact_dir))")
                end
            end
            return false
        end

    catch e
        println("❌ Artifact download failed!")
        println("🔥 Error: $e")

        if isa(e, Pkg.Artifacts.ArtifactException)
            println("This is the same error CI would get!")
        end

        return false
    end
end

"""
Full CI simulation test
"""
function full_ci_simulation()
    println("="^60)
    println("🎭 FULL CI SIMULATION")
    println("="^60)

    # Step 1: Clear cache
    simulate_ci_environment()

    # Step 2: Test fresh download
    success = test_fresh_artifact_download()

    println("\n" * "="^60)
    if success
        println("🎉 CI SIMULATION PASSED!")
        println("Your artifacts should work perfectly in CI.")
    else
        println("💥 CI SIMULATION FAILED!")
        println("DO NOT PUSH - fix the artifacts first.")
    end
    println("="^60)

    return success
end

"""
Quick test without clearing cache (just verify current state)
"""
function quick_test()
    println("🏃‍♂️ Quick artifact test...")

    try
        artifact_dir = artifact"getdp"
        executable = Sys.iswindows() ? joinpath(artifact_dir, "getdp.exe") : joinpath(artifact_dir, "bin", "getdp")

        if isfile(executable)
            println("✅ GetDP artifact works: $executable")
            return true
        else
            println("❌ GetDP executable not found: $executable")
            return false
        end
    catch e
        println("❌ Artifact test failed: $e")
        return false
    end
end

println("Available functions:")
println("  generate_getdp_artifacts(force=true)  - Generate new artifacts")
println("  clean_artifacts()                     - Remove broken artifacts")
println("  test_getdp_artifacts()               - Test if artifacts work")

println("Available test functions:")
println("  full_ci_simulation()  - Complete simulation (clears cache, tests download)")
println("  quick_test()          - Quick test with current cache")
println("  simulate_ci_environment()  - Just clear the artifact cache")