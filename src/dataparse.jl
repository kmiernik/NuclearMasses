"""
    parseame20(amefile)

    Parse AME2020 masses file and return NamedTuple
    (Z, A, delta, experimental, uncertainty) 
    where experimental flag is true for real experimental data, and false for
    extrapolated values
"""
function parseame20(amefile)
    skipto = 37
    iline = 0
    Zs = Int64[]
    As = Int64[]
    ds = Float64[]
    us = Float64[]
    exps = Bool[]
    for line in readlines(amefile)
        iline += 1
        if iline < skipto
            continue
        end
        d = line[29:42]
        experimental = true
        if occursin("#", d)
            experimental = false
            d = replace(d, "#" => "")
        end
        push!(Zs, parse(Int64, line[10:14]))
        push!(As, parse(Int64, line[15:19]))
        push!(ds, parse(Float64, d))
        push!(us, parse(Float64, replace(line[44:54], "#" => "")))
        push!(exps, experimental)
    end    
    (Z=Zs, A=As, delta=ds, experimental=exps, uncertainty=us) 
end


"""
    parsehfb(hfbfile)

    Parse HFB-24 masses file and return dictionary (A, Z) => (Δ, experimental)
    where Δ is mass defect, and experimental flag is false
"""
function parsehfb(hfbfile)
    skipto = 4
    iline = 0
    Zs = Int64[]
    As = Int64[]
    ds = Float64[]
    for line in readlines(hfbfile)
        iline += 1
        if iline < skipto
            continue
        end
        push!(Zs, parse(Int64, line[1:4]))
        push!(As, parse(Int64, line[6:8]))
        push!(ds, parse(Float64, line[63:68]) * 1000.0)
    end    
    (Z=Zs, A=As, delta=ds, experimental=zeros(Bool, length(Zs)), 
     uncertainty=zeros(length(Zs)))
end


"""
    parsefrdm(frdmfile)

    Parse FRDM-2012 file and return NamedTuple (Z, A, delta)
"""
function parsefrdm(frdmfile)
    Zs = Int64[]
    As = Int64[]
    ds = Float64[]
    for line in readlines(frdmfile)
        push!(Zs, parse(Int64, line[1:5]))
        push!(As, parse(Int64, line[12:15]))
        push!(ds, parse(Float64, line[129:135]) * 1000.0)
    end    
    (Z=Zs, A=As, delta=ds, experimental=zeros(Bool, length(Zs)), 
     uncertainty=zeros(length(Zs)))
end
