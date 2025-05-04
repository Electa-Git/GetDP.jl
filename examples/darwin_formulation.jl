# This file contains the Darwin formulation originally implemented in Onelab by prof. Ruth Sabariego (ruth.sabariego@kuleuven.be)

push!(LOAD_PATH, joinpath(@__DIR__, "..", "src")) # hide
using GetDP

# Create a Problem object
problem = Problem()

# Create a new Problem instance
functionspace = FunctionSpace()

# FunctionSpace section
fs1 = add!(functionspace, "Hcurl_a_Mag_2D", nothing, nothing, Type="Form1P")
add_basis_function!(functionspace, "se", "ae", "BF_PerpendicularEdge"; Support="Domain_Mag", Entity="NodesOf[ All ]")
add_basis_function!(functionspace, "se2", "ae2", "BF_PerpendicularEdge_2E";
    Support="Domain_Mag",
    Entity="EdgesOf[ All ]",
    condition="If (Flag_Degree_a == 2)",
    endCondition="EndIf")

add_constraint!(functionspace, "ae", "NodesOf", "MagneticVectorPotential_2D")
add_constraint!(functionspace, "ae2", "EdgesOf", "MagneticVectorPotential_2D";
    comment=" Only OK if homogeneous BC, otherwise specify zero-BC",
    condition="If (Flag_Degree_a == 2)",
    endCondition="EndIf")


fs2 = add!(functionspace, "Hregion_i_2D", nothing, nothing, Type="Vector")
add_basis_function!(functionspace, "sr", "ir", "BF_RegionZ"; Support="DomainS_Mag", Entity="DomainS_Mag")
add_global_quantity!(functionspace, "Is", "AliasOf"; NameOfCoef="ir")
add_global_quantity!(functionspace, "Us", "AssociatedWith"; NameOfCoef="ir")
add_constraint!(functionspace, "Us", "Region", "Voltage_2D")
add_constraint!(functionspace, "Is", "Region", "Current_2D")


fs3 = add!(functionspace, "Hregion_u_Mag_2D", nothing, nothing, Type="Form1P", comment=" Gradient of Electric scalar potential (2D)")
add_basis_function!(functionspace, "sr", "ur", "BF_RegionZ"; Support="DomainC_Mag", Entity="DomainC_Mag")
add_global_quantity!(functionspace, "U", "AliasOf"; NameOfCoef="ur")
add_global_quantity!(functionspace, "I", "AssociatedWith"; NameOfCoef="ur")
add_constraint!(functionspace, "U", "Region", "Voltage_2D")
add_constraint!(functionspace, "I", "Region", "Current_2D")

problem.functionspace = functionspace

# Define Formulation
formulation = GetDP.Formulation()

form = add!(formulation, "Darwin_a_2D", "FemEquation"; comment=" Magnetodynamics + displacement current, no coupling")
add_quantity!(form, "a", Type="Local", NameOfSpace="Hcurl_a_Mag_2D")
add_quantity!(form, "ur", Type="Local", NameOfSpace="Hregion_u_Mag_2D", comment=" massive conductors (source or not)")
add_quantity!(form, "I", Type="Global", NameOfSpace="Hregion_u_Mag_2D [I]")
add_quantity!(form, "U", Type="Global", NameOfSpace="Hregion_u_Mag_2D [U]")
add_quantity!(form, "ir", Type="Local", NameOfSpace="Hregion_i_2D", comment=" stranded conductors (source)")
add_quantity!(form, "Us", Type="Global", NameOfSpace="Hregion_i_2D[Us]")
add_quantity!(form, "Is", Type="Global", NameOfSpace="Hregion_i_2D[Is]")

eq = add_equation!(form)

add!(eq, "Galerkin", "[ nu[] * Dof{d a} , {d a} ]", In="Domain_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "DtDof [ sigma[] * Dof{a} , {a} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "[ sigma[] * Dof{ur}, {a} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "DtDof [ sigma[] * Dof{a} , {ur} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "[ sigma[] * Dof{ur}, {ur}]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "DtDtDof [ epsilon[] * Dof{a} , {a}]", In="DomainC_Mag", Jacobian="Vol", Integration="I1", comment=" Added term => Darwin approximation")
add!(eq, "Galerkin", "DtDof[ epsilon[] * Dof{ur}, {a} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "DtDtDof [ epsilon[] * Dof{a} , {ur}]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "DtDof[ epsilon[] * Dof{ur}, {ur} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "GlobalTerm", "[ Dof{I} , {U} ]", In="DomainCWithI_Mag")
add!(eq, "Galerkin", "[ -js0[] , {a} ]", In="DomainS0_Mag", Jacobian="Vol", Integration="I1", comment=" Either you impose directly the function js0[]")
add!(eq, "Galerkin", "[ -Ns[]/Sc[] * Dof{ir}, {a} ]", In="DomainS_Mag", Jacobian="Vol", Integration="I1", comment=" or you use the constraints => allows accounting for sigma[]")
add!(eq, "Galerkin", "DtDof [ Ns[]/Sc[] * Dof{a}, {ir} ]", In="DomainS_Mag", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "[ Ns[]/Sc[] / sigma[] * Ns[]/Sc[]* Dof{ir} , {ir}]", In="DomainS_Mag", Jacobian="Vol", Integration="I1", comment=" resistance term")
add!(eq, "GlobalTerm", "[ Dof{Us}, {Is} ]", In="DomainS_Mag")

# Add the formulation to the problem
problem.formulation = formulation

# Define Resolution
resolution = Resolution()

# Add a resolution
add!(resolution, "Darwin", "Sys_Mag",
    NameOfFormulation="Darwin_a_2D", 
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

# Add the resolution to the problem
problem.resolution = resolution

# PostProcessing section
postprocessing = PostProcessing()

pp = add!(postprocessing, "Darwin_a_2D", "Darwin_a_2D")
q = add!(pp, "a")
add!(q, "Term", "{a}"; In="Domain_Mag", Jacobian="Vol")
q = add!(pp, "az")
add!(q, "Term", "CompZ[{a}]"; In="Domain_Mag", Jacobian="Vol")
q = add!(pp, "b")
add!(q, "Term", "{d a}"; In="Domain_Mag", Jacobian="Vol")
q = add!(pp, "bm")
add!(q, "Term", "Norm[{d a}]"; In="Domain_Mag", Jacobian="Vol")

# Multi-term entries
q = add!(pp, "j")
add!(q, "Term", "-sigma[]*(Dt[{a}]+{ur})"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "js0[]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "Ns[]/Sc[]*{ir}"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp, "jz")
add!(q, "Term", "CompZ[-sigma[]*(Dt[{a}]+{ur})]"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "CompZ[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "CompZ[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp, "jm")
add!(q, "Term", "Norm[-sigma[]*(Dt[{a}]+{ur})]"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "Norm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "Norm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp, "d")
add!(q, "Term", "epsilon[] * Dt[Dt[{a}]+{ur}]"; In="DomainC_Mag", Jacobian="Vol")
q = add!(pp, "dz")
add!(q, "Term", "CompZ[epsilon[] * Dt[Dt[{a}]+{ur}]]"; In="DomainC_Mag", Jacobian="Vol")
q = add!(pp, "dm")
add!(q, "Term", "Norm[epsilon[] * Dt[Dt[{a}]+{ur}]]"; In="DomainC_Mag", Jacobian="Vol")

q = add!(pp, "rhoj2")
add!(q, "Term", "0.5*sigma[]*SquNorm[Dt[{a}]+{ur}]"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "0.5/sigma[]*SquNorm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "0.5/sigma[]*SquNorm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp, "JouleLosses")
add!(q, "Integral", "0.5*sigma[]*SquNorm[Dt[{a}]]"; In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(q, "Integral", "0.5/sigma[]*SquNorm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol", Integration="I1")
add!(q, "Integral", "0.5/sigma[]*SquNorm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol", Integration="I1")

q = add!(pp, "U")
add!(q, "Term", "{U}"; In="DomainC_Mag")
add!(q, "Term", "{Us}"; In="DomainS_Mag")

q = add!(pp, "I")
add!(q, "Term", "{I}"; In="DomainC_Mag")
add!(q, "Term", "{Is}"; In="DomainS_Mag")

q = add!(pp, "S")
add!(q, "Term", "{U}*Conj[{I}]"; In="DomainC_Mag")
add!(q, "Term", "{Us}*Conj[{Is}]"; In="DomainS_Mag")

q = add!(pp, "R")
add!(q, "Term", "-Re[{U}/{I}]"; In="DomainC_Mag")
add!(q, "Term", "-Re[{Us}/{Is}]"; In="DomainS_Mag")

q = add!(pp, "L")
add!(q, "Term", "-Im[{U}/{I}]/(2*Pi*Freq)"; In="DomainC_Mag")
add!(q, "Term", "-Im[{Us}/{Is}]/(2*Pi*Freq)"; In="DomainS_Mag")

q = add!(pp, "R_per_km"; comment=" For convenience... possible scaling")
add!(q, "Term", "-Re[{U}/{I}]*1e3"; In="DomainC_Mag")
add!(q, "Term", "-Re[{Us}/{Is}]*1e3"; In="DomainS_Mag")

q = add!(pp, "mL_per_km")
add!(q, "Term", "-1e6*Im[{U}/{I}]/(2*Pi*Freq)"; In="DomainC_Mag")
add!(q, "Term", "-1e6*Im[{Us}/{Is}]/(2*Pi*Freq)"; In="DomainS_Mag")

q = add!(pp, "Zs")
add!(q, "Term", "-{U}/{I}"; In="DomainC_Mag")
add!(q, "Term", "-{Us}/{Is}"; In="DomainS_Mag")

problem.postprocessing = postprocessing

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

# Add the post-operation to the problem
problem.postoperation = postoperation

# Generate and write the .pro file
make_file!(problem)

# Write the code to a file
problem.filename = "darwin_formulation.pro"
write_file!(problem)
