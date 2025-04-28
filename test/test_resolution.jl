using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")


@testset "Resolution Generation" begin
    
    resolution = Resolution()

    # Add a resolution
    add!(resolution, "Darwin", "Sys_Mag",
        Type="Complex", Frequency="Freq",
        Operation=[
            "CreateDir[\"res\"]",
            "InitSolution[Sys_Mag]",
            "Generate[Sys_Mag]", 
            "Solve[Sys_Mag]", 
            "SaveSolution[Sys_Mag]",
            "PostOperation[Mag_Maps]",
            "PostOperation[Mag_Global]"
        ])

    generated_code = code(resolution)
    # Test against reference file
    @test_reference "references/resolution.txt" generated_code by=normalize_exact
end