using DataFrames
using ArgParse
using ProgressMeter
using Distributed
import CSV


PROCS = 5
toAdd = PROCS - nprocs()
addedProcs = addprocs(toAdd)

@everywhere begin
    root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
	push!(LOAD_PATH, root)
	# println("LOAD_PATH is $LOAD_PATH")
end

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "-N"
            help = "an option with an argument"
            arg_type = Int
      		required = true
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
@eval @everywhere N = $(parsed_args["N"])
@eval @everywhere fName = $(parsed_args["fitness"])
@eval @everywhere k = $(parsed_args["k"])

@everywhere begin
	import models
	using LightGraphs

	using models.simulateIntroductionModel
	using models.judgerEgoDefectorVis
	using models.fitnessNonRival
	using models.fitnessClassical
	using models.fitnessDivisible
	using models.mutateUniform
	using models.segregationDistributionAveraged

	sampleInt = 5000
	numRounds = 500000
	if N < 50
		numRounds = 100000
	end

	numSamples = ceil(Int, numRounds/sampleInt)
	epsilons = [0.05 * i for i in 0:20]
	simulators = []
	for e in epsilons
		function mySimulator(;coopProp = 0.5, intensity = 0.01)
			G = random_regular_graph(N,5)
			nCoops = floor(Int, coopProp * nv(G))
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
			judge = makeJudgeEgoDefVis(e)
			mut = makeMutator(0.01)
			return simulateIntroModel(G,types,numRounds,judge, fitFunc, mut, sampleInterval = sampleInt, fitUpdater! = updater, k = k)
		end
		push!(simulators, mySimulator)
	end
end
nTrials = 50 #just for debug!
nPer = nTrials 
results = DataFrame(epsilon = Float64[], coop = Float64[], fitDiff = Float64[], payoffDiff = Float64[], u = Float64[])
series = DataFrame(epsilon = Float64[], id = Int[], n = Int[], fcoop = Float64[], fdef = Float64[], 
                        pcoop = Float64[], pdef = Float64[], u = Float64[])
@showprogress for (sim,e) in zip(simulators,epsilons)
	resultDf, seriesDf = segDistAvg(sim, numTrials = nTrials, numSamples = numSamples)
	resultDf[!,:epsilon] .= e
	seriesDf[!,:epsilon] .= e
	i = round(Int,e * 20)
	seriesDf.id = map(x -> nPer * i + x, seriesDf.id)
	# resultsDf = join(results, resultsDf)
	# series = join(series, seriesDf)
	append!(results, resultDf)
	append!(series, seriesDf)
end



if k != 1.0
	CSV.write("$root/data/$(fName)DefVisk$(round(Int,k))CoopWins$N.csv", results)
	CSV.write("$root/data/$(fName)DefVisk$(round(Int,k))CoopWins$(N)TS.csv", series)
else
	CSV.write("$root/data/$(fName)DefVisCoopWins$N.csv", results)
	CSV.write("$root/data/$(fName)DefVisCoopWins$(N)TS.csv", series)
end



# outgraph, outAvgFits, outTypes, outSamples = simulateIntroModel(G,types,1000000,judge, fitFunc, mut, sampleInterval = 50000)
# println(resultArray)
# rmprocs(addedProcs)
