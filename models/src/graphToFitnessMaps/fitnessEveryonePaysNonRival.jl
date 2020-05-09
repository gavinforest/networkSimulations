module fitnessEveryonePaysNonRival

using LightGraphs

export GtoFEveryonePaysNonRivalTemplate

function generateFitnessFromGraphNonRival(G, types, b, c, w)
    payoffs = [0 for i in 1:nv(G)]
    for v in vertices(G)
        for j in inneighbors(G,v)
            payoffs[v] += b * types[j]
        end
        payoffs[v] -= c
    end

    fitnesses = [exp(w * p) for p in payoffs]
    return fitnesses
end

function GtoFEveryonePaysNonRivalTemplate(b,c,w)
	f(g,types) = generateFitnessFromGraphNonRival(g,types,b,c,w)
    return f
end


end