# -------------- SIMULATION FUNCTIONS --------------
module simFuncs

using LightGraphs
using StatsBase

export generateFitnessFromGraphNonRival, simulateIntroductionAveragescores

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

function sigma(x)
    return 1 / (1 + exp(-x))
end

function simulateIntroductionAveragescores(N, K, numRounds, b, c, w, mutationRate; averagePeriod = 0.1, coopProp = 0.5)
    G1 = random_regular_graph(N,K)
    agentTypes = [0 for i in 1:N] #CHECK
    for i in 1:floor(Int,coopProp * N)
        agentTypes[i] = 1
    end
    agentScores = generateFitnessFromGraphNonRival(G1, agentTypes, b, c, w)

    averageFitnesses = [0.0 for i in 1:N]

    # gplot(G1, nodelabel=1:N)
    for n in 1:numRounds
        introNode = rand(1:N,1)[1]
        candidates = neighbors(G1,introNode)
        nCandidates = length(candidates)
        if (nCandidates > 0)
            toIntroduce  = sample(candidates, AnalyticWeights([1 for j in 1:nCandidates]),2)
            a = toIntroduce[1]
            c = toIntroduce[2]
            if (!has_edge(G1,a,c))
                introFitness = agentScores[introNode]
                aAvgFitness = mean([agentScores[j] for j in neighbors(G1,a)])
                cAvgFitness = mean([agentScores[j] for j in neighbors(G1,c)])
                pConnect = sigma(introFitness / aAvgFitness) * sigma(introFitness / cAvgFitness)
                if (rand() < pConnect) && (!has_edge(G1,a,c))
                    toRemove = collect(edges(G1))[rand(1:ne(G1))]
                    rem_edge!(G1, toRemove)
                    add_edge!(G1, a, c)
                end
                agentScores = generateFitnessFromGraphNonRival(G1, agentTypes, b, c, w)
            end
        end
        if rand() < mutationRate
            toCreate  = sample(1:N, AnalyticWeights([1 for j in 1:N]),2)
            toDestroy = collect(edges(G1))[rand(1:ne(G1))]
            if !has_edge(G1, toCreate[1], toCreate[2])
                add_edge!(G1,toCreate[1],toCreate[2])
                rem_edge!(G1,toDestroy)
            end
        end
        if (n > numRounds * (1-averagePeriod))
            averageFitnesses += agentScores / (numRounds * averagePeriod)
        end

    #     println("$n complete")
    end
#     myplot = plot(agentScores, [length(neighbors(G1,i)) for i in 1:N], seriestype=:scatter)
#     theplot = generalStatPlot(G1, agentScores)
    return G1, averageFitnesses, agentTypes
end

end

# ------------ ANALYSIS FUNCTIONS --------------

module analysisFuncs

using Distributed
using SharedArrays
using LightGraphs
using StatsBase


export segregationDistributionAveraged

function strategyPreferences(G, agentScores, types)
    N = length(agentScores)
    cooperatorNum = sum(types)
    defectorNum = N - cooperatorNum
    cooperatorConnections = 0
    defectorConnections = 0
    for i in 1:N
        outCooperators = sum([types[j] for j in outneighbors(G,i)])
        if types[i] == 1
            cooperatorConnections += outCooperators
        else
            defectorConnections += outCooperators
        end
    end
    cooperatorOutCoopProp = cooperatorConnections / cooperatorNum
    defectorOutCoopProp = defectorConnections / defectorNum

#     println("Cooperators connect to on average $cooperatorOutCoopProp cooperators")
#     println("Defectors connect to on average $defectorOutCoopProp cooperators")
    return cooperatorOutCoopProp, defectorOutCoopProp


end

function meanFitnessesCD(agentScores, types)\
    coopmean = mean([agentScores[j] for j in 1:length(agentScores) if types[j]==1])
    defmean = mean([agentScores[j] for j in 1:length(agentScores) if types[j]==0])
    return coopmean, defmean
end

function averageDegreesCD(graph, types)
    coopAvgDegree = mean([degree(graph,v) for v in 1:nv(graph) if types[v]==1])
    defectAvgDegree = mean([degree(graph,v) for v in 1:nv(graph) if types[v]==0])
    return coopAvgDegree, defectAvgDegree
end

function segregationDistributionAveraged(simulator, N, K, numRoundsPer, b, c, w, mutationRate;  numTrials = 30, coopPropRange = [0.5])
    resultsArray = []
    for coopP in coopPropRange
        results = SharedArray{Tuple{Float64,Float64}}(numTrials)
        @sync @distributed for n = 1:numTrials
            outgraph, outAgentScores, outAgentTypes = simulator(N,K,numRoundsPer,b,c,w,mutationRate, coopProp=coopP)
            coopConnects, defConnects = strategyPreferences(outgraph, outAgentScores, outAgentTypes)
            coopAvgDegree, defAvgDegree = averageDegreesCD(outgraph, outAgentTypes)
            coopPreference = coopConnects / coopAvgDegree
            defPreference = 1 - (defConnects / defAvgDegree) # going for same type preference
            u = coopPreference * coopP + defPreference * (1-coopP)

            coopFit, defFit = meanFitnessesCD(outAgentScores, outAgentTypes)
            f = coopFit / defFit

            results[n] = (f,u)
        end
        push!(resultsArray, sdata(results))
    end
    return resultsArray
end

end
