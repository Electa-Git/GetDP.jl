# deps/build.jl
import Pkg
Pkg.add("Downloads")

using Downloads

println("Setting up GetDP...")

deps_dir = @__DIR__
getdp_dir = joinpath(deps_dir, "getdp")
mkpath(getdp_dir)

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

exe_name = Sys.iswindows() ? "getdp.exe" : joinpath("bin", "getdp")
exe_path = joinpath(getdp_dir, exe_name)

# Already there? Done.
if isfile(exe_path)
    println("GetDP already installed at $exe_path")
else
    # Download
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
end

