using Distributed
using DataFrames
using ArgParse
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
      	"--defcost"
      		help = "Cost for defectors under classicalDefCost"
      		arg_type = Float64
      		default = 0.2
    end

    return parse_args(s)
end


parsed_args = parse_commandline()
@eval @everywhere N = $(parsed_args["N"])
@eval @everywhere fName = $(parsed_args["fitness"])
@eval @everywhere c_def = $(parsed_args["defcost"])


@everywhere begin
	import models
	using LightGraphs

	using models.simulateIntroductionModel
	using models.judgerSigmaEgo
	using models.judgerSigmaMean
	using models.fitnessNonRival
	using models.fitnessClassical
	using models.fitnessDivisible
	using models.fitnessAveraged
	using models.fitnessClassicalDefCost
	using models.mutateUniform
	using models.segregationDistributionAveraged

	numRounds = 0

	fitFunc = GtoFNonRivalTemplate(5,1,intensity)
	if fName == "classical"
		println("Using classical payments")
		fitFunc = GtoFClassicalTemplate(5,1,intensity)
	elseif fName == "divisible"
		println("Using divisible payments")
		fitFunc = GtoFDivisibleTemplate(5,1, intensity)
	elseif fName == "averaged"
		println("using averaged payments")
		fitFunc = GtoFAveragedTemplate(5,1,intensity)
	elseif fName == "classicalDefCost"
		fitFunc = GtoFClassicalDefCostTemplate(5,1,c_def,intensity)
	end

	function mySimulator(;coopProp = 0.5, intensity = 0.01)
		G = random_regular_graph(N,5)
		nCoops = floor(Int, coopProp * nv(G))
		types = [0 for i in 1:nv(G)]
		for j in 1:nCoops
			types[j] = 1
		end
		
		judge = judgeSigmaEgo


		mut = makeMutator(0.01)
		return simulateIntroModel(G,types,numRounds,judge, fitFunc, mut)
	end
end
coopPropRange = [0.01 * i for i in 1:99]
nTrials = 10000
@time resultDf, seriesDf = segDistAvg(mySimulator, numTrials = nTrials, coopPropRange = coopPropRange)

if fname == "classicalDefCost"
	CSV.write("$root/data/base$(fName)DefCost$(round(Int, c_def))CoopWins$(N).csv", resultDf)
else
	CSV.write("$root/data/base$(fName)CoopWins$(N).csv", resultDf)
end



# outgraph, outAvgFits, outTypes, outSamples = simulateIntroModel(G,types,1000000,judge, fitFunc, mut, sampleInterval = 50000)
# println(resultArray)
rmprocs(addedProcs)
println("Done")
