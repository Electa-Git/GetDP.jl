# Problem: defining the problem

using ..GetDP: add_raw_code, comment, code
using ..GetDP: Group, Function, Constraint, FunctionSpace, Jacobian, Integration
using ..GetDP: Formulation, Resolution, PostProcessing, PostOperation
using Dates

"""
    Problem

A classe principal de definição de problema que reúne todos os componentes.
"""
mutable struct Problem
    _GETDP_CODE::Vector{String}
    filename::Union{String,Nothing}
    group::Vector{Group}
    function_obj::Vector{Function}
    constraint::Vector{Constraint}
    functionspace::Vector{FunctionSpace}
    jacobian::Vector{Jacobian}
    integration::Vector{Integration}
    formulation::Vector{Formulation}
    resolution::Vector{Resolution}
    postprocessing::Vector{PostProcessing}
    postoperation::Vector{PostOperation}
    objects::Vector{String}

    function Problem(; gmsh_major_version=nothing)
        version = GetDP.VERSION
        _GETDP_CODE = ["// This code was created by GetDP.jl v$(version).\n"]

        group = Group[]
        function_obj = Function[]
        constraint = Constraint[]
        functionspace = FunctionSpace[]
        jacobian = Jacobian[]
        integration = Integration[]
        formulation = Formulation[]
        resolution = Resolution[]
        postprocessing = PostProcessing[]
        postoperation = PostOperation[]

        objects = [
            "group",
            "function_obj",
            "constraint",
            "functionspace",
            "jacobian",
            "integration",
            "formulation",
            "resolution",
            "postprocessing",
            "postoperation"
        ]

        new(
            _GETDP_CODE,
            nothing,
            group,
            function_obj,
            constraint,
            functionspace,
            jacobian,
            integration,
            formulation,
            resolution,
            postprocessing,
            postoperation,
            objects
        )
    end
end

"""
    get_code(problem::Problem)

Retorna o código GetDP formatado adequadamente.
"""
function get_code(problem::Problem)
    return join(problem._GETDP_CODE, "")
end

"""
    add_raw_code!(problem::Problem, raw_code, newline=true)

Adiciona código bruto ao objeto Problem.
"""
function add_raw_code!(problem::Problem, raw_code, newline=true)
    problem._GETDP_CODE = [add_raw_code(get_code(problem), raw_code, newline)]
end

"""
    add_comment!(problem::Problem, comment_text, newline=true)

Adiciona um comentário ao objeto Problem.
"""
function add_comment!(problem::Problem, comment_text, newline=true)
    add_raw_code!(problem, comment(comment_text; newline=false), newline)
end

"""
    make_file!(problem::Problem)

Gera o código GetDP para todos os objetos no Problem, incluindo apenas componentes não vazios.
"""
function make_file!(problem::Problem)
    for attr in problem.objects
        components = getfield(problem, Symbol(attr))
        if attr == "function_obj"
            for func in components
                if !isempty(func.content)
                    push!(problem._GETDP_CODE, code(func))
                end
            end
        elseif attr == "group"
            for grp in components
                if !isempty(grp.content)
                    push!(problem._GETDP_CODE, code(grp))
                end
            end
        elseif attr == "constraint"
            for constr in components
                if !isempty(constr.constraints)
                    push!(problem._GETDP_CODE, code(constr))
                end
            end
        elseif attr == "functionspace"
            for fs in components
                if !isempty(fs.content)
                    push!(problem._GETDP_CODE, code(fs))
                end
            end
        elseif attr == "jacobian"
            for jac in components
                if !isempty(jac.content)
                    push!(problem._GETDP_CODE, code(jac))
                end
            end
        elseif attr == "integration"
            for integ in components
                if !isempty(integ.content)
                    push!(problem._GETDP_CODE, code(integ))
                end
            end
        elseif attr == "formulation"
            for form in components
                if !isempty(form.items)
                    push!(problem._GETDP_CODE, code(form))
                end
            end
        elseif attr == "resolution"
            for res in components
                if !isempty(res.content)
                    push!(problem._GETDP_CODE, code(res))
                end
            end
        elseif attr == "postprocessing"
            for pp in components
                if !isempty(pp.content)
                    push!(problem._GETDP_CODE, code(pp))
                end
            end
        elseif attr == "postoperation"
            for po in components
                if !isempty(po.content)
                    push!(problem._GETDP_CODE, code(po))
                end
            end
        end
    end
end

"""
    write_file!(problem::Problem)

Escreve o código GetDP em um arquivo.
"""
function write_file!(problem::Problem)
    if problem.filename === nothing
        problem.filename = tempname()
    end

    open(problem.filename, "w") do f
        write(f, get_code(problem))
    end
end

"""
    include!(problem::Problem, incl_file)

Inclui outro arquivo GetDP.
"""
function include!(problem::Problem, incl_file)
    push!(problem._GETDP_CODE, "\nInclude \"$(incl_file)\";")
end

"""
    write_multiple_problems(problems::Vector{Problem}, filename::String)

Write the GetDP code for multiple Problem instances to a single file.
The version comment is included only once at the top, and each problem's code
is separated by a comment indicating its index.
"""
function write_multiple_problems(problems::Vector{Problem}, filename::String)
    if isempty(problems)
        error("No problems to write.")
    end

    # Define the version comment once, assuming GetDP.VERSION is accessible
    version = GetDP.VERSION
    version_comment = "// This code was created by GetDP.jl v$(version).\n"

    open(filename, "w") do f
        # Write the version comment at the top
        write(f, version_comment)
        
        # Process each problem
        for (i, problem) in enumerate(problems)
            # Generate the GetDP code for this problem
            make_file!(problem)
            # Skip the version comment (first element) and join the rest
            component_code = join(problem._GETDP_CODE[2:end], "")
            # Add a separator with problem index
            write(f, "\n// Problem $i\n")
            write(f, component_code)
        end
    end
end