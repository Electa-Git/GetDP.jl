using Test
using ReferenceTests
using GetDP

# Run tests without printing the full TestSet
result = @testset "All GetDP.jl Tests" begin
    include("test_formulation.jl")
    include("test_functionspace.jl")
    include("test_integration.jl")
    include("test_jacobian.jl")
    include("test_postoperation.jl")
    include("test_resolution.jl")
    include("test_group.jl")
    include("test_function.jl")
    include("test_constraint.jl")
end

# Calculate total passed tests by summing across all child testsets
total_passed = sum(ts.n_passed for ts in result.results)
println("Tests completed. Passed: $total_passed")