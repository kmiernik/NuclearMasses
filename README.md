# NuclearMasses
This package provides nuclear masses (nuclides mass excess, i.e. difference
between A * u and mass of a neutral atom) based on the Atomic Mass Evaluation
2020 [1] and the HFB-24 model [2]. AME2020 is used for experimentally known
nuclides and short-range extrapolations as listed in tables in Ref. [1]. The
HFB-24 mass model is used beyond that.

## Nuclide
The main feature of the module is the `Nuclide` struct

```julia
struct Nuclide
    A::Int64
    Z::Int64
    element::String
    delta::Float64
    experimental::Bool
end
```
which holds mass number `A`, atomic number `Z`, element name, mass excess
`delta` in keV, and flag `experimental` for indication if the value was measured
experimentally or not.

There are number of convenience constructors for this struct, including
creating nuclide by A, Z, or name in format "element-A" e.g.

```julia-repl
julia> c12 = Nuclide(12, 6)
julia> he4 = Nuclide("He-4")
```
in these cases the mass excess will be automatically found in the databases.
In case the value is not in AME nor HFB-24, `Inf` will be used. 

Mass excess can be also specified manually in a constructor versions, 
the experimental flag is set by default to false, so if `true` value is
needed one has to specify it directly.

```julia-repl
julia> o16 = Nuclide(16, 8, -4737.00135, true)
julia> cf252 = Nuclide("Cf-252", -76035.0, true)
julia> og295 = Nuclide("Og-295", 203000.0)
```

`+` operator is defined which returns a nuclide being sum of terms. Mass
excess value is read automatically from tables.

```julia-repl
julia> c12 = he4 + he4 + he4
```

Data tables can be accessed by `NuclearMasses.data` dictionary and (A, Z)
tuple key.

```julia-repl
julia> NuclearMasses.data[(12, 6)]
(value = 0.0, ex = true)
```

If conversion to a DataFrame is needed the following code should work

```julia-repl
julia> df = DataFrame(A = [k[1] for k in keys(NuclearMasses.data)], 
                      Z = [k[2] for k in keys(NuclearMasses.data)], 
                      delta = [v.value for v in values(NuclearMasses.data)], 
                      exp = [v.ex for v in values(NuclearMasses.data)])
```

## References
* [1] Meng Wang et al 2021 Chinese Phys. C 45 030003
* [2] S. Goriely, N. Chamel, and J.M. Pearson (2013) Phys. Rev. C88, 061302

## Remark
Any work that will use this module should make reference to the original papers
listed above.
