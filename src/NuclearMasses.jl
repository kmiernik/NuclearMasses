module NuclearMasses

include("dataparse.jl")

ame20 = parseame20(pkgdir(NuclearMasses, "data", "ame2020.dat"))
hfb24 = parsehfb(pkgdir(NuclearMasses, "data", "hfb24.dat"))
frdm12 = parsefrdm(pkgdir(NuclearMasses, "data", "frdm2012.dat"))

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
    uncertainty::Float64
    experimental::Bool
end

"""
    Nuclide(A::Int64, Z::Int64, delta; uncertainty=0.0, experimental=false)
    
    Resolves name of element.
"""
function Nuclide(A::Int64, Z::Int64, delta; uncertainty=0.0, experimental=false)
    @assert A >= Z
    if 1 <= Z <= length(elements)
        name = elements[Z]
    elseif Z == 0
        name = "n"
    elseif Z > length(elements)
        name = "$Z"
    else
        throw(ArgumentError("Element Z = $Z is not valid"))
    end
    Nuclide(A, Z, name, delta, uncertainty, experimental)
end


"""
    Nuclide(A::Int64, Z::Int64; model=ame20)
    
    Search for data on nuclide A, Z in model (database). If not found
    delta=uncertainty=Inf, experimental=false
"""
function Nuclide(A::Int64, Z::Int64; model=ame20)
    id = filter(i->model.A[i] == A && model.Z[i] == Z, eachindex(model.A))
    if length(id) > 0
        Nuclide(A, Z, model.delta[id[1]], 
                experimental=model.experimental[id[1]], 
                uncertainty=model.uncertainty[id[1]])
    else
        Nuclide(A, Z, Inf; uncertainty=Inf, experimental=false)
    end
end


"""
    Nuclide(A::Int64, element::String; model=ame20)
    
    Find Z of element by name (e.g. "C", "Pb", "HG", "he"). 
    Calls Nuclude(A, Z, model)
"""
Nuclide(A::Int64, element::String; model=ame20) = Nuclide(A, atomicZ(element);
                                                         model=model)

"""
    Nuclide(A::Int64, element::String, delta; experimental=false, uncertainty=0.0) 

    Find Z of element by name, manually assing delta (and other fields)
"""
Nuclide(A::Int64, element::String, delta; experimental=false, uncertainty=0.0) = Nuclide(A, atomicZ(element), delta; uncertainty=uncertainty,  experimental=experimental)

"""
    Nuclide(name::String, delta)

    Names in format "Au-197", "AU-197", "au-197" are accepted, manually
    assing delta (and other fields)
"""
function Nuclide(name::String, delta; uncertainty=0.0, experimental=false)
    @assert length(split(name, "-")) == 2 "Nuclide name $name format is not supported"
    e, A = split(name, "-")
    A = parse(Int64, A)
    Nuclide(A, atomicZ(String(e)), delta; uncertainty=uncertainty,
            experimental=experimental)
end


"""
    Nuclide(name::String)

    Names in format "Au-197", "AU-197", "au-197" are accepted.
    Search for data on nuclide A, Z in model (database).
"""
function Nuclide(name::String; model=ame20)
    @assert length(split(name, "-")) == 2 "Nuclide name $name format is not supported"
    e, A = split(name, "-")
    A = parse(Int64, A)
    Nuclide(A, atomicZ(String(e)); model=model)
end


Base.:+(x::Nuclide, y::Nuclide) = Nuclide(x.A + y.A, x.Z + y.Z)


function Base.show(io::IO, e::Nuclide)
    print(io, e.element, "-", e.A)
end


export Nuclide, elements, atomicZ

end #module
