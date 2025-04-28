# # Integration: defining integration methods

# using ..GetDP: comment, make_args


# function code(item::SimpleItem)
#     return item.code
# end

# # IntegrationItemCase for nested Case blocks (e.g., Case { { Type Gauss; Case { ... } } })
# mutable struct IntegrationItemCase
#     items::Vector{Union{SimpleItem,IntegrationItemCase}}
#     comment::String

#     function IntegrationItemCase(; comment="")
#         new(SimpleItem[], comment)
#     end
# end

# function add!(case::IntegrationItemCase; kwargs...)
#     item = SimpleItem(; kwargs...)
#     push!(case.items, item)
#     return case
# end

# function add_nested_case!(case::IntegrationItemCase; kwargs...)
#     nested_case = IntegrationItemCase(; kwargs...)
#     push!(case.items, nested_case)
#     return nested_case
# end

# function code(case::IntegrationItemCase)
#     case_codes = join([code(item) for item in case.items], "\n")
#     _code = "Case {\n" * case_codes * "\n}"
#     if !isempty(case.comment)
#         _code *= " " * GetDP.comment(case.comment)
#     end
#     return _code
# end

# # IntegrationItem for each { Name I1; ... } block
# mutable struct IntegrationItem
#     name::String
#     comment::String
#     cases::Vector{IntegrationItemCase}

#     function IntegrationItem(name; comment=nothing)
#         new(name, comment !== nothing ? comment : "", IntegrationItemCase[])
#     end
# end

# function add!(item::IntegrationItem; kwargs...)
#     case = IntegrationItemCase(; kwargs...)
#     push!(item.cases, case)
#     return case
# end

# function code(item::IntegrationItem)
#     case_codes = join([code(case) for case in item.cases], "\n")
#     _code = "{ Name $(item.Name); " * case_codes * " }"
#     if !isempty(item.comment)
#         _code *= " " * GetDP.comment(item.comment)
#     end
#     return _code
# end

# # Integration struct
# mutable struct Integration <: AbstractGetDPObject
#     name::String
#     items::Vector{IntegrationItem}
#     comment::Union{String,Nothing}

#     function Integration()
#         new("Integration", IntegrationItem[], nothing)
#     end
# end

# function add!(integration::Integration, name::String; comment=nothing, kwargs...)
#     item = IntegrationItem(name; comment)
#     push!(integration.items, item)
#     return item
# end

# function code(integration::Integration)
#     code_lines = ["Integration{"]
#     if !isempty(integration.items)
#         for item in integration.items
#             for line in split(code(item), '\n')
#                 push!(code_lines, "  " * line)
#             end
#         end
#     end
#     push!(code_lines, "}")
#     if integration.comment !== nothing
#         return comment(integration.comment) * "\n" * join(code_lines, "\n")
#     else
#         return join(code_lines, "\n")
#     end
# end

# function add_raw_code!(integration::Integration, raw_code, newline=true)
#     integration.content = add_raw_code(integration.content, raw_code, newline)
# end

# function add_comment!(integration::Integration, comment_text, newline=true)
#     integration.comment = comment_text
# end

# Integration: defining integration methods

using ..GetDP: comment, make_args

function code(item::SimpleItem)
    return item.code
end

# IntegrationItemCase for nested Case blocks (e.g., Case { { Type Gauss; Case { ... } } })
mutable struct IntegrationItemCase
    items::Vector{Union{SimpleItem,IntegrationItemCase}}
    comment::String

    function IntegrationItemCase(; comment="")
        new(SimpleItem[], comment)
    end
end

function add!(case::IntegrationItemCase; kwargs...)
    item = SimpleItem(; kwargs...)
    push!(case.items, item)
    return case
end

function add_nested_case!(case::IntegrationItemCase; kwargs...)
    nested_case = IntegrationItemCase(; kwargs...)
    push!(case.items, nested_case)
    return nested_case
end

function code(case::IntegrationItemCase)
    case_codes = join([code(item) for item in case.items], "\n")
    _code = "Case {\n" * case_codes * "\n}"
    if !isempty(case.comment)
        _code *= " " * GetDP.comment(case.comment)
    end
    return _code
end

# IntegrationItem for each { Name I1; ... } block
mutable struct IntegrationItem
    name::String
    comment::String
    cases::Vector{IntegrationItemCase}

    function IntegrationItem(name; comment=nothing)
        new(name, comment !== nothing ? comment : "", IntegrationItemCase[])
    end
end

function add!(item::IntegrationItem; kwargs...)
    case = IntegrationItemCase(; kwargs...)
    push!(item.cases, case)
    return case
end

function code(item::IntegrationItem)
    case_codes = join([code(case) for case in item.cases], "\n")
    _code = "{ Name $(item.name); " * case_codes * " }"  # Fixed item.Name to item.name
    if !isempty(item.comment)
        _code *= " " * GetDP.comment(item.comment)
    end
    return _code
end

# Integration struct
mutable struct Integration <: AbstractGetDPObject
    name::String
    content::String
    items::Vector{IntegrationItem}
    comment::Union{String,Nothing}

    function Integration()
        new("Integration", "", IntegrationItem[], nothing)
    end
end

function add!(integration::Integration, name::String; comment=nothing, kwargs...)
    item = IntegrationItem(name; comment)
    push!(integration.items, item)
    update_content!(integration)  # Update content when adding an item
    return item
end

function update_content!(integration::Integration)
    content = ""
    for item in integration.items
        content *= code(item) * "\n"
    end
    integration.content = rstrip(content)
end

function code(integration::Integration)
    code_lines = ["\nIntegration{"]
    if !isempty(integration.items)
        for item in integration.items
            for line in split(code(item), '\n')
                push!(code_lines, "  " * line)
            end
        end
    elseif !isempty(integration.content)
        for line in split(integration.content, '\n')
            push!(code_lines, "  " * line)
        end
    end
    push!(code_lines, "}")
    if integration.comment !== nothing
        return comment(integration.comment) * "\n" * join(code_lines, "\n")
    else
        return join(code_lines, "\n")
    end
end

function add_raw_code!(integration::Integration, raw_code, newline=true)
    integration.content = add_raw_code(integration.content, raw_code, newline)
end

function add_comment!(integration::Integration, comment_text, newline=true)
    integration.comment = comment_text
end