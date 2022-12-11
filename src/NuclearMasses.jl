module NuclearMasses

include("dataparse.jl")

data = generatedatabase(pkgdir(NuclearMasses, "data", "mass_1.mas20"), 
                        pkgdir(NuclearMasses, "data", "hfb24-dat"))

elements = ("H" ,  "He",  "Li",  "Be",  "B" ,
            "C" ,   "N",   "O",   "F",  "Ne",
            "Na",  "Mg",  "Al",  "Si",   "P",
            "S" ,  "Cl",  "Ar",   "K",  "Ca",
            "Sc",  "Ti",   "V",  "Cr",  "Mn",
            "Fe",  "Co",  "Ni",  "Cu",  "Zn",
            "Ga",  "Ge",  "As",  "Se",  "Br",
            "Kr",  "Rb",  "Sr",   "Y",  "Zr",
            "Nb",  "Mo",  "Tc",  "Ru",  "Rh",
            "Pd",  "Ag",  "Cd",  "In",  "Sn",
            "Sb",  "Te",   "I",  "Xe",  "Cs",
            "Ba",  "La",  "Ce",  "Pr",  "Nd",
            "Pm",  "Sm",  "Eu",  "Gd",  "Tb",
            "Dy",  "Ho",  "Er",  "Tm",  "Yb",
            "Lu",  "Hf",  "Ta",   "W",  "Re",
            "Os",  "Ir",  "Pt",  "Au",  "Hg",
            "Tl",  "Pb",  "Bi",  "Po",  "At",
            "Rn",  "Fr",  "Ra",  "Ac",  "Th",
            "Pa",   "U",  "Np",  "Pu",  "Am",
            "Cm",  "Bk",  "Cf",  "Es",  "Fm",
            "Md",  "No",  "Lr",  "Rf",  "Db",
            "Sg",  "Bh",  "Hs",  "Mt",  "Ds",
            "Rg",  "Cn",  "Nh",  "Fl",  "Mc",
            "Lv",  "Ts",  "Og")


"""
    atomicZ(name)

    Get element atomic number Z from name. Lower and uppercases are accepted.
"""
function atomicZ(name::String)
    frmname = uppercase(name[1]) * lowercase(name[2:end])
    @assert !isnothing(findfirst(x->x==frmname, elements)) "Element name $name is not known"
    findfirst(x->x==frmname, elements)
end

"""
    Structure holding information on nuclide:
    A, Z, element name, mass excess (Δ) `delta` and if it is experimental or
    theoretical 
"""
struct Nuclide
    A::Int64
    Z::Int64
    element::String
    delta::Float64
    experimental::Bool
end


function Nuclide(A::Int64, Z::Int64, delta, ex=false)
    if 1 <= Z <= length(elements)
        name = elements[Z]
    elseif Z == 0
        name = "n"
    elseif Z > length(elements)
        name = "$Z"
    else
        throw(ArgumentError("Element Z = $Z is not valid"))
    end
    Nuclide(A, Z, name, delta, ex)
end


function Nuclide(A::Int64, Z::Int64)
    if haskey(data, (A, Z))
        Nuclide(A, Z, data[(A, Z)].value, data[(A, Z)].ex)
    else
        Nuclide(A, Z, Inf, false)
    end
end

Nuclide(A::Int64, element::String) = Nuclide(A, atomicZ(element))
Nuclide(A::Int64, element::String, delta, ex=false) = Nuclide(A, atomicZ(element), element, delta, ex)

"""
    Nuclide(name::String, delta)

    Names in format "Au-197", "AU-197", "au-197" are accepted
"""
function Nuclide(name::String, delta, ex=false)
    @assert length(split(name, "-")) == 2 "Nuclide name $name format is not supported"
    e, A = split(name, "-")
    A = parse(Int64, A)
    Nuclide(A, atomicZ(String(e)), delta, ex)
end


"""
    Nuclide(name::String)

    Names in format "Au-197", "AU-197", "au-197" are accepted
"""
function Nuclide(name::String)
    @assert length(split(name, "-")) == 2 "Nuclide name $name format is not supported"
    e, A = split(name, "-")
    A = parse(Int64, A)
    Nuclide(A, atomicZ(String(e)))
end

Base.:+(x::Nuclide, y::Nuclide) = Nuclide(x.A + y.A, x.Z + y.Z)

function Base.show(io::IO, e::Nuclide)
    print(io, e.element, "-", e.A)
end

export Nuclide, elements, atomicZ

end #module
