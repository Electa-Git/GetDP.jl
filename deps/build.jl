# deps/build.jl

println("Setting up GetDP...")

deps_dir = @__DIR__
getdp_dir = joinpath(deps_dir, "getdp")
mkpath(getdp_dir)

"""Run a Cmd object, returning the stdout & stderr contents plus the exit code

stolen from https://discourse.julialang.org/t/collecting-all-output-from-shell-commands/15592/2
"""
function execute(cmd::Cmd)
    out = Pipe()
    err = Pipe()

    process = run(pipeline(ignorestatus(cmd), stdout=out, stderr=err))
    close(out.in)
    close(err.in)

    stdout = String(read(out))
    stderr = String(read(err))
    code = process.exitcode
    return stdout, stderr, code
end


begin
    exe_name = "getdp"
    exe_path = Sys.which("getdp")

    if isexecutable(exe_path)
        out = execute(`$exe_path --version`)
        getdp_version = split(split(out[2], "-")[1], ".")
        major = tryparse(Int, getdp_version[1])
        minor = tryparse(Int, getdp_version[2])
        if major == 3 && minor >= 5
            println("GetDP already installed at $exe_path")
            return  # early begin block exit
        end
    end

    exe_name = Sys.iswindows() ? "getdp.exe" : joinpath("bin", "getdp")
    exe_path = joinpath(getdp_dir, exe_name)

    if isexecutable(exe_path)
        println("GetDP already installed at $exe_path")
    else
        import Pkg
        Pkg.add("Downloads")

        using Downloads
        # Pick the right URL
        url = if Sys.islinux()
            "https://getdp.info/bin/Linux/getdp-3.5.0-Linux64c.tgz"
        elseif Sys.iswindows()
            "https://getdp.info/bin/Windows/getdp-3.5.0-Windows64c.zip"
        elseif Sys.isapple()
            "https://getdp.info/bin/MacOSX/getdp-3.5.0-MacOSXc.tgz"
        else
            error("Unsupported OS")
        end

        try  # Download
            temp_file = tempname()
            Downloads.download(url, temp_file)

            # Extract
            if endswith(url, ".tgz")
                run(`tar -xzf $temp_file -C $getdp_dir --strip-components=1`)
            elseif endswith(url, ".zip")
                run(`unzip -o $temp_file -d $getdp_dir`)
                # Flatten if needed
                contents = readdir(getdp_dir)
                if length(contents) == 1 && isdir(joinpath(getdp_dir, contents[1]))
                    nested = joinpath(getdp_dir, contents[1])
                    for item in readdir(nested, join=true)
                        mv(item, joinpath(getdp_dir, basename(item)), force=true)
                    end
                    rm(nested, recursive=true)
                end
            end

            rm(temp_file)

            # Make executable
            !Sys.iswindows() && chmod(exe_path, 0o755)

            println("GetDP installed at $exe_path")
        catch e
            println("GetDP setup failed. Please try to install manually from $url\n")
            rethrow(e)
        end
    end
end
