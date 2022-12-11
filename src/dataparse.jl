"""
    parseame20(amefile)

    Parse AME2020 masses file and return dictionary (A, Z) => (Δ, experimental)
    where Δ is mass defect, and experimental flag is true for real experimental
    data, and false for extrapolated values
"""
function parseame20(amefile)
    skipto = 37
    iline = 0
    data = Dict{Tuple{Int64, Int64}, NamedTuple{(:value, :ex), Tuple{Float64, Bool}}}()
    for line in readlines(amefile)
        iline += 1
        if iline < skipto
            continue
        end
        Z = parse(Int64, line[10:14])
        A = parse(Int64, line[15:19])
        d = line[29:42]
        experimental = true
        if occursin("#", d)
            experimental = false
            d = replace(d, "#" => "")
        end
        data[(A, Z)] = (value=parse(Float64, d), ex=experimental)
    end    
    data
end



"""
    parsehfb(hfbfile)

    Parse HFB-24 masses file and return dictionary (A, Z) => (Δ, experimental)
    where Δ is mass defect, and experimental flag is false
"""
function parsehfb(hfbfile)
    skipto = 4
    iline = 0
    data = Dict{Tuple{Int64, Int64}, NamedTuple{(:value, :ex), Tuple{Float64, Bool}}}()
    for line in readlines(hfbfile)
        iline += 1
        if iline < skipto
            continue
        end
        Z = parse(Int64, line[1:4])
        A = parse(Int64, line[6:8])
        d = parse(Float64, line[63:68]) * 1000.0
        data[(A, Z)] = (value=d, ex=false)
    end    
    data
end


"""
    generatedatabase(amefile, hfbfile)

    Merge experimental AME database and calculated HFB-24 nuclear masses data
"""
function generatedatabase(amefile, hfbfile)
    data = parsehfb(hfbfile)
    ame = parseame20(amefile)
    merge(data, ame)
end
