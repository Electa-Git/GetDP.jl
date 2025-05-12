push!(LOAD_PATH, joinpath(@__DIR__, "..", "src")) # hide
using GetDP

using Revise

# Force reload the module
Revise.retry()


# Create a Problem object
problem = Problem()

# FunctionSpace section
functionspace = FunctionSpace()
fs1 = add!(functionspace, "Hgrad_v_Ele", nothing, nothing, Type="Form0")
add_basis_function!(functionspace, "sn", "vn", "BF_Node"; Support="Domain_Ele", Entity="NodesOf[ All ]")
add_basis_function!(functionspace, "sn2", "vn2", "BF_Node_2E";
    Support="Domain_Ele",
    Entity="EdgesOf[ All ]",
    condition="If (Flag_Degree_v == 2)",
    endCondition="EndIf")

add_constraint!(functionspace, "vn", "NodesOf", "ElectricScalarPotential")
add_constraint!(functionspace, "vn2", "EdgesOf", "ZeroElectricScalarPotential";
    condition="If (Flag_Degree_v == 2)",
    endCondition="EndIf")

# problem.functionspace = functionspace
push!(problem.functionspace, functionspace)

# Formulation section
formulation = Formulation()
form = add!(formulation, "Electrodynamics_v", "FemEquation")
add_quantity!(form, "v", Type="Local", NameOfSpace="Hgrad_v_Ele")

eq = add_equation!(form)
add!(eq, "Galerkin", "[ sigma[] * Dof{d v} , {d v} ]", In="Domain_Ele", Jacobian="Vol", Integration="I1")
add!(eq, "Galerkin", "DtDof[ epsilon[] * Dof{d v} , {d v} ]", In="Domain_Ele", Jacobian="Vol", Integration="I1")

# problem.formulation = formulation
push!(problem.formulation, formulation)

# Resolution section
resolution = Resolution()
add!(resolution, "Electrodynamics", "Sys_Ele",
    NameOfFormulation="Electrodynamics_v",
    Type="Complex",
    Frequency="Freq",
    Operation=[
        "CreateDir[\"res\"]",
        "Generate[Sys_Ele]",
        "Solve[Sys_Ele]",
        "SaveSolution[Sys_Ele]",
        "PostOperation[Ele_Maps]",
        "PostOperation[Ele_Cuts]"
    ])

# problem.resolution = resolution
push!(problem.resolution, resolution)

## PostProcessing section
postprocessing = PostProcessing()
pp = add!(postprocessing, "EleDyn_v", "Electrodynamics_v")

q = add!(pp, "v")
add!(q, "Term", "{v}"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "e")
add!(q, "Term", "-{d v}"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "em")
add!(q, "Term", "Norm[-{d v}]"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "d")
add!(q, "Term", "-epsilon[] * {d v}"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "dm")
add!(q, "Term", "Norm[-epsilon[] * {d v}]"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "j")
add!(q, "Term", "-sigma[] * {d v}"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "jm")
add!(q, "Term", "Norm[-sigma[] * {d v}]"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "jtot")
add!(q, "Term", "-sigma[] * {d v}"; In="Domain_Ele", Jacobian="Vol")
add!(q, "Term", "-epsilon[] * Dt[{d v}]"; In="Domain_Ele", Jacobian="Vol")

q = add!(pp, "ElectricEnergy")
add!(q, "Integral", "0.5 * epsilon[] * SquNorm[{d v}]"; In="Domain_Ele", Jacobian="Vol", Integration="I1")

# V0
q = add!(pp, "V0")
add!(q, "Term", "V0 * F_Cos_wt_p[]{2*Pi*Freq, Pa}"; Type="Global", In="Ind_1")
add!(q, "Term", "V0 * F_Cos_wt_p[]{2*Pi*Freq, Pb}"; Type="Global", In="Ind_2")
add!(q, "Term", "V0 * F_Cos_wt_p[]{2*Pi*Freq, Pc}"; Type="Global", In="Ind_3")

# C_from_Energy
q = add!(pp, "C_from_Energy")
add!(q, "Term", "2*\$We/SquNorm[\$voltage]"; Type="Global", In="DomainDummy")

# problem.postprocessing = postprocessing
push!(problem.postprocessing, postprocessing)

# PostOperation section
postoperation = PostOperation()
add_comment!(postoperation, "Electric")
add_comment!(postoperation, "-------------------------------")
add_raw_code!(postoperation, "po0 = \"{01Capacitance/\";")

# Ele_Maps
po1 = add!(postoperation, "Ele_Maps", "EleDyn_v")
op1 = add_operation!(po1)
add_operation!(op1, "Print[ v, OnElementsOf Domain_Ele, File \"res/v.pos\" ]")
add_operation!(op1, "Print[ em, OnElementsOf Cable, Name \"|E| [V/m]\", File \"res/em.pos\" ]")
add_operation!(op1, "Print[ dm, OnElementsOf Cable, Name \"|D| [A/m²]\", File \"res/dm.pos\" ]")
add_operation!(op1, "Print[ e, OnElementsOf Cable, Name \"E [V/m]\", File \"res/e.pos\" ]")
add_operation!(op1, "Call Change_post_options")
add_operation!(op1, "Print[ ElectricEnergy[Domain_Ele], OnGlobal, Format Table, StoreInVariable \$We, SendToServer StrCat[po0,\"0Electric energy\"], File \"res/energy.dat\" ]")
add_operation!(op1, "Print[ V0, OnRegion Ind_1, Format Table, StoreInVariable \$voltage, SendToServer StrCat[po0,\"0U1\"], Units \"V\", File \"res/U.dat\" ]")
add_operation!(op1, "Print[ C_from_Energy, OnRegion DomainDummy, Format Table, StoreInVariable \$C1, SendToServer StrCat[po0,\"1Cpha\"], Units \"F/m\", File \"res/C.dat\" ]")

# Cable geometry
add_raw_code!(
    postoperation,
    """
// To adapt for your cable
  dist_cab = dc + 2*(ti+txlpe+to+tapl)+tps;
  h = dist_cab * Sin[Pi/3]; // height of equilateral triangle
  x0 = 0; y0 = 2*h/3;
  x1 = -dist_cab/2; y1 = -h/3;
  x2 =  dist_cab/2; y2 = -h/3;
"""
)

# Ele_Cuts
po2 = add!(postoperation, "Ele_Cuts", "EleDyn_v")
op2 = add_operation!(po2)
add_operation!(op2, "Print[ em, OnLine { {x2,y2,0} {x2+dc/2+ti+txlpe+to+tapl,y2,0} } {100}, Name \"|E| [V/m] cut in phase 2\", File \"res/em_cut.pos\" ]")
add_operation!(op2, "Echo[Str[\"View[PostProcessing.NbViews-1].Type = 4;\",\n        \"View[PostProcessing.NbViews-1].Axes = 3;\",\n        \"View[PostProcessing.NbViews-1].AutoPosition = 3;\",\n        \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n        \"View[PostProcessing.NbViews-1].LineWidth = 3;\",\n        \"View[PostProcessing.NbViews-1].NbIso = 5;\"],\n      File \"res/em_cut.opt\" ]")

# problem.postoperation = postoperation
push!(problem.postoperation, postoperation)

# Generate and write the .pro file
make_file!(problem)

# Write the code to a file
problem.filename = "electrodynamic_formulation_byjlgetdp.pro"
write_file(problem)
