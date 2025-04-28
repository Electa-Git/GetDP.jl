function normalize_exact(s::String)
    stripped_lines = strip.(split(s, '\n'))
    normalized = join(stripped_lines, '\n')
    return strip(normalized)
end

function normalize_exact(reference::String, actual::String)
    return normalize_exact(reference) == normalize_exact(actual)
end

