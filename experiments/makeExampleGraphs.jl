# using Distributed
# using DataFrames
using ArgParse
# import CSV
using Compose
using Cairo
using GraphPlot
using Plots

# PROCS = 5
# toAdd = PROCS - nprocs()
# addedProcs = addprocs(toAdd)

# @everywhere begin
    root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
	push!(LOAD_PATH, root)
# 	# println("LOAD_PATH is $LOAD_PATH")
# end

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "-N"
            help = "population size"
            arg_type = Int
      		required = true
      	"-C"
      		help = "number of cooperators in population"
      		arg_type = Int
      		required = true
      	"-i"
      		help = "How many to make"
      		arg_type = Int
      		required = true
      	"--judger"
      		help = "The judger to be used"
      		arg_type = String
      		default = "ego"
      	"--fitness"
      		help = "The fitness function"
      		arg_type = String
      		default = "nonRival"
      	"-k"
      		help = "Shape parameter for judger"
      		arg_type = Float64
      		default = 1.0
    end

    return parse_args(s)
end


parsed_args = parse_commandline()
N = parsed_args["N"]
coopP = parsed_args["C"] / (1.0 * N)
judgerName = parsed_args["judger"]
fName = parsed_args["fitness"]
k = parsed_args["k"]


import models
using LightGraphs

using models.simulateIntroductionModel
using models.judgerSigmaEgo
using models.judgerSigmaMean
using models.fitnessNonRival
using models.fitnessClassical
using models.fitnessDivisible
using models.mutateUniform
using models.segregationDistributionAveraged


sampleInt = 5000
numRounds = 100000
numSamples = ceil(Int, numRounds/sampleInt)
function mySimulator(;coopProp = 0.5, intensity = 0.01)
	G = random_regular_graph(N,5)
	# println("Graph has $(ne(G)) edges in simulator initialization")
	nCoops = floor(Int, coopP * nv(G))
	types = [0 for i in 1:nv(G)]
	for j in 1:nCoops
		types[j] = 1
	end

	fitFunc = GtoFNonRivalTemplate(5,1,intensity)
	updater = fitUpdaterTemplateNonRival(5,1,intensity)
	if fName == "classical"
		fitFunc = GtoFClassicalTemplate(5,1,intensity)
		updater = fitUpdaterTemplateClassical(5,1,intensity)
	elseif fName == "divisible"
		fitFunc = GtoFDivisibleTemplate(5,1, intensity)
		updater = Nothing
	end
	
	judge = judgeSigmaEgo
	if judgerName == "Mean"
		judge = judgerSigmaMean
	end

	mut = makeMutator(0.01)
	return simulateIntroModel(G,types,numRounds,judge, fitFunc, mut, sampleInterval = sampleInt, fitUpdater! = updater, k= k)
end

for ID in 1:parsed_args["i"]
	outgraph, averageFitnesses, outtypes, samples = mySimulator()
	# println("Graph has $(ne(outgraph)) edges")
	fitnesses = GtoFNonRivalTemplate(5,1,0.01)(outgraph, outtypes)
	payoffs = map(x -> round(log(x) / 0.01), fitnesses)
	nodeColors = map(x -> x == 1 ? colorant"green" : colorant"red", outtypes)
	layout=(args...)->spring_layout(args...; C=15)
	p = gplot(outgraph, nodelabel = map(string, payoffs), nodefillc = nodeColors, layout=layout)
	C = parsed_args["C"]
	if k != 1.0
		draw(PNG("$root/figs/example_graphs/$(C)c$(N)pop$(fName)$(judgerName)k$(round(Int,k))example$(ID).png", 12cm, 12cm, dpi=250), p)
	else
		draw(PNG("$root/figs/example_graphs/$(C)c$(N)pop$(fName)$(judgerName)example$(ID).png", 12cm, 12cm, dpi=250), p)
	end
end
# nTrials = 1 #just for debug!
# results = DataFrame(epsilon = Float64[], coop = Float64[], fitDiff = Float64[], payoffDiff = Float64[], u = Float64[])
# series = DataFrame(epsilon = Float64[], id = Int[], n = Int[], fcoop = Float64[], fdef = Float64[], 
#                         pcoop = Float64[], pdef = Float64[], u = Float64[])
# @showprogress for (sim,e) in zip(simulators,epsilons)
# 	resultDf, seriesDf = segDistAvg(sim, numTrials = nTrials, numSamples = numSamples)
# 	resultDf[:epsilon] = e
# 	seriesDf[:epsilon] = e
# 	resultsDf = join(results, resultsDf)
# 	series = join(series, seriesDf)
# 	push!(results, resultDf)
# 	push!(series, seriesDf)
# end




# CSV.write("$root/data/nonRivalDefVisCoopWins$N.csv", resultDf)
# CSV.write("$root/data/nonRivalDefVisCoopWins$(N)TS.csv", seriesDf)



# outgraph, outAvgFits, outTypes, outSamples = simulateIntroModel(G,types,1000000,judge, fitFunc, mut, sampleInterval = 50000)
# println(resultArray)
# rmprocs(addedProcs)
