using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")




@testset "Integration Generation" begin
    # Initialize Integration
    integ = Integration()
    i1 = add!(integ, "I1")

    case = add!(i1)

    geo_case = add_nested_case!(case; type="Gauss")

    add!(geo_case; GeoElement="Point", NumberOfPoints=1)
    add!(geo_case; GeoElement="Line", NumberOfPoints=4)
    add!(geo_case; GeoElement="Triangle", NumberOfPoints=4)
    add!(geo_case; GeoElement="Quadrangle", NumberOfPoints=4)
    add!(geo_case; GeoElement="Triangle2", NumberOfPoints=7)

    generated_code = code(integ)
    # Test against reference file
    @test_reference "references/integration.txt" generated_code by=normalize_exact
end