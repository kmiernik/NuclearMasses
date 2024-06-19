# NuclearMasses
This package provides nuclear masses in the form of mass excess, defined as

$$M(A, Z) = A\times u + \Delta(A, Z)$$

Experimental values are from Atomic Mass Evaluation 2020 [1],  
theoretical models HFB-24 [2] and FRDM2012 [3] are also included. 

## Nuclide
The main feature of the module is the `Nuclide` struct

```julia
struct Nuclide
    A::Int64
    Z::Int64
    element::String
    delta::Float64
    uncertainty::Float64
    experimental::Bool
end
```
which holds mass number `A`, atomic number `Z`, element name, mass excess
`delta` and its `uncertainty` in keV, flag `experimental` for indication if 
the value was measured experimentally or not (notice that AME2020 includes
also extrapolations).
There are several convenience constructors for this struct, including
creating nuclide by A, Z, or name in the format "element-A" e.g.
in these cases, the mass excess will be automatically found in the databases.
The default database is the AME2020. For other models indicate the database by the named parameter `model``

```julia-repl
julia> sn132 = Nuclide(132, 50, model=NuclearMasses.hfb24)
```

Mass excess can be also specified manually in a constructor version, the experimental flag is set then by default to false, and `uncertainty` to 0.0,
so if other values are needed one has to specify it directly.

```julia-repl
julia> o16 = Nuclide(16, 8, -4737.00135, experimental=true, uncertainty=0.0005)
julia> cf252 = Nuclide("Cf-252", -76035.0, experimental=true, uncertainty=0.5)
julia> og295 = Nuclide("Og-295", 203000.0)
```

Operator `+` is defined which returns a nuclide being the sum of terms $$(A_1 + A_2,
Z_1 + Z_2)$$ taking resulting nuclide data from AME. If another database is needed
it can be created based on the name of the resulting nuclide

```julia-repl
julia> c12 = he4 + he4 + he4
julia> cn = Nuclide("$(sn132 + he4)", model=NuclearMasses.hfb24)
```

Data tables can be accessed by `NuclearMasses.ame20, NuclearMasses.hfb24, and
NuclearMasses.frdm12` named tuples of vectors A (Int64), Z (Int64), delta
(Float64), experimental (Bool), uncertainty (Float64). Search can be performed
by filter function e.g.

```julia-repl
julia> idx = filter(i->NuclearMasses.ame20.A[i] == 208 && 
            NuclearMasses.ame20.Z[i] == 82, eachindex(NuclearMasses.ame20.A))
```

But perhaps, it is better to convert the NamedTuples to DataFrames, which
is straightforward, and use DataFrames powers instead.

A new mass model can be introduced by creating an appropriate NamedTuple, with
at least the `(Z, A, d, experimental, uncertainty)` fields.

```julia-repl
julia> dummy = (Z=[6], A=[12], d=[0.0], experimental=[true], uncertainty=[0.0], foo=[1])
julia> c12 = Nuclide("C-12", model=dummy)
```

The module can be extended for parsing the new model by placing the parser in `src`/parsedata.jl`, and loading the data in `src/NuclearModel.jl`.

## References
* [1] Meng Wang et al 2021 Chinese Phys. C 45 030003
* [2] S. Goriely, N. Chamel, and J.M. Pearson (2013) Phys. Rev. C88, 061302
* [3] P. Moller et al., Atomic Data and Nuclear Data Tables 109-110 (2016) 1-203 

## Notice
Any work that will use this module should make references to the original papers
listed above.
