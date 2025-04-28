using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")


@testset "PostOperation Generation" begin

    # PostOperation section
    postoperation = PostOperation()

    # Add post-operation items
    po1 = add!(postoperation, "Mag_Maps", "Darwin_a_2D")
    po2 = add!(postoperation, "Mag_Global", "Darwin_a_2D")

    # Add operations for maps
    op1 = add_operation!(po1)  # Creates a POBase_ for po1

    add_operation!(op1, "Print[ az, OnElementsOf Domain_Mag, //Smoothing 1\n        Name \"flux lines: Az [T m]\", File \"res/az.pos\" ];")
    add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].NbIso = 25;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 1;\" // isolines\n    ], File \"res/maps.opt\"];")
    add_operation!(op1, "Print[ b, OnElementsOf Domain_Mag, //Smoothing 1,\n        Name \"B [T]\", File \"res/b.pos\" ];")
    add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
    add_operation!(op1, "Print[ bm, OnElementsOf Domain_Mag,\n        Name \"|B| [T]\", File \"res/bm.pos\" ];")
    add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
    add_operation!(op1, "Print[ jz, OnElementsOf Region[{DomainC_Mag, DomainS_Mag}],\n        Name \"jz [A/m^2] Conducting domain\", File \"res/jz_inds.pos\" ];")
    add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
    add_operation!(op1, "Print[ rhoj2, OnElementsOf Region[{DomainC_Mag, DomainS_Mag}],\n        Name \"Power density\", File \"res/rhoj2.pos\" ];")
    add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
    add_operation!(op1, "Print[ jm, OnElementsOf DomainC_Mag,\n        Name \"|j| [A/m^2] Conducting domain\", File \"res/jm.pos\" ];")
    add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
    add_operation!(op1, "Print[ dm, OnElementsOf DomainC_Mag,\n        Name \"|D| [A/m²]\", File \"res/dm.pos\" ];")
    add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")

    add_raw_code!(po1, "po = \"{01Losses/\";")
    add_raw_code!(po1, "po2 = \"{02PU-parameters/\";")

    op2 = add_operation!(po2)  # Creates a POBase_ for po2
    add_operation!(op2, "Print[ JouleLosses[DomainC_Mag], OnGlobal, Format Table,\n    SendToServer StrCat[po,\"0Total conducting domain\"],\n    Units \"W/m\", File \"res/losses_total.dat\" ];", comment=" You may restrict DomainC_Mag to part of it")
    add_operation!(op2, "Print[ JouleLosses[Inds], OnGlobal, Format Table,\n    SendToServer StrCat[po,\"3Source (stranded OR massive)\"],\n    Units \"W/m\", File \"res/losses_inds.dat\" ];")
    add_operation!(op2, "Print[ R, OnRegion Ind_1, Format Table,\n    SendToServer StrCat[po2,\"0R\"],\n    Units \"Ω\", File \"res/Rinds.dat\" ];", comment=" Region to adapt according to your cable")
    add_operation!(op2, "Print[ L, OnRegion Ind_1, Format Table,\n    SendToServer StrCat[po2,\"1L\"],\n    Units \"H\", File \"res/Linds.dat\" ];")
    add_operation!(op2, "Print[ Zs[DomainC_Mag], OnRegion Inds, Format Table,\n    SendToServer StrCat[po2,\"2re(Zs)\"] {0},\n    Units \"Ω\", File \"res/Zsinds_C_Mag.dat\" ];")


    generated_code = code(postoperation)
    # Test against reference file
    @test_reference "references/postoperation.txt" generated_code by=normalize_exact
end