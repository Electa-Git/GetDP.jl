# deps/build.jl

# -- helpers ------------------------------------------------------------------

# Ensure Downloads is available (stdlib in 1.6+, but be defensive)
try
    @eval using Downloads
catch
    import Pkg
    Pkg.add("Downloads")
    @eval using Downloads
end

# Extract a .zip on Windows with PowerShell; fall back to .NET ZipFile or tar.
function extract_zip_windows(zip::AbstractString, dest::AbstractString)
    mkpath(dest)
    ps = Sys.which("powershell")
    if ps !== nothing
        # Prefer Expand-Archive (present on Win10/11 and Server 2016+)
        try
            run(`$ps -NoProfile -ExecutionPolicy Bypass -Command Expand-Archive -LiteralPath $zip -DestinationPath $dest -Force`)
            return
        catch
            # Fallback: .NET ZipFile API (works even if Expand-Archive is blocked)
            run(`$ps -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('$zip', '$dest')"`)
            return
        end
    end
    # Final fallback: Windows ships tar nowadays; bsdtar handles zip, too.
    if Sys.which("tar") !== nothing
        run(`tar -xf $zip -C $dest`)
        return
    end
    error("No unzip capability found on Windows (PowerShell/tar missing).")
end

# If extraction created a single top-level folder, move its contents up one level.
function flatten_singleton_dir!(root::AbstractString)
    entries = readdir(root; join=true)
    if length(entries) == 1 && isdir(entries[1])
        sub = entries[1]
        for item in readdir(sub; join=true)
            mv(item, joinpath(root, basename(item)); force=true)
        end
        rm(sub; recursive=true, force=true)
    end
    return nothing
end

# Find the GetDP executable under `root`, trying common locations first.
function find_getdp_exe(root::AbstractString)
    exe_name = Sys.iswindows() ? "getdp.exe" : "getdp"
    candidates = Sys.iswindows() ?
                 [joinpath(root, exe_name), joinpath(root, "bin", exe_name)] :
                 [joinpath(root, "bin", exe_name), joinpath(root, exe_name)]

    for c in candidates
        isfile(c) && return c
    end
    # Fallback: scan (bounded by the small deps tree)
    for (dirpath, _, files) in walkdir(root)
        if exe_name in files
            return joinpath(dirpath, exe_name)
        end
    end
    return nothing
end

# -- main ---------------------------------------------------------------------

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

# Already installed?
if (existing = find_getdp_exe(getdp_dir)) !== nothing
    # Ensure exec bit on *nix (some zips/tars lose it)
    if !Sys.iswindows()
        try
            chmod(existing, 0o755)
        catch
        end
    end
    println("GetDP already installed at $existing")
    return
end

# Download to a temp file with a matching extension (some tools care)
temp_file = tempname() * (endswith(url, ".zip") ? ".zip" : ".tgz")
Downloads.download(url, temp_file)

# Extract
if endswith(url, ".tgz")
    # Works on GNU tar and bsdtar (macOS); strip top-level folder
    run(`tar -xzf $temp_file -C $getdp_dir --strip-components=1`)
elseif endswith(url, ".zip")
    if Sys.iswindows()
        extract_zip_windows(temp_file, getdp_dir)
    else
        if Sys.which("unzip") !== nothing
            run(`unzip -o $temp_file -d $getdp_dir`)
        else
            # bsdtar/gtar can handle .zip
            run(`tar -xf $temp_file -C $getdp_dir`)
        end
    end
    flatten_singleton_dir!(getdp_dir)
end

rm(temp_file; force=true)

# Locate the binary and finalize perms
exe_path = find_getdp_exe(getdp_dir)
exe_path === nothing && error("GetDP binary not found after extraction in $getdp_dir")

if !Sys.iswindows()
    chmod(exe_path, 0o755)
end

println("GetDP installed at $exe_path")
