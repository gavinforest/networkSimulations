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
@eval @everywhere N = $(parsed_args["N"])
@eval @everywhere judgerName = $(parsed_args["judger"])
@eval @everywhere fName = $(parsed_args["fitness"])
@eval @everywhere k = $(parsed_args["k"])

@everywhere begin
	import models
	using LightGraphs

	using models.simulateIntroductionModel
	using models.judgerSigmaEgo
	using models.judgerSigmaMean
	using models.judgerEgoDefAccept
	using models.fitnessNonRival
	using models.fitnessClassical
	using models.fitnessDivisible
	using models.mutateUniform
	using models.degreeDistributionAveraged
	sampleInt = 5000
	numRounds =10000000
	numSamples = ceil(Int, numRounds/sampleInt)
	function mySimulator(;coopProp = 0.5, intensity = 0.01)
		G = random_regular_graph(N,floor(Int,sqrt(N)/2))
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
		
		judge = judgeSigmaEgo
		if judgerName == "Mean"
			judge = judgerSigmaMean
		elseif judgerName == "EgoDefAccept"
			judge = judgeEgoDefAccept
		end

		mr = 0.01

		if N > 5000
			mr = 1.0
		end
		mut = makeMutator(mr)
		return simulateIntroModel(G,types,numRounds,judge, fitFunc, mut, fitUpdater! = updater, k= k)
	end
end
nTrials = 20
println("Starting the degree dist farmer")
@time resultDf = degDistAvg(mySimulator, numTrials = nTrials, N = N)

if k == 1.0
	CSV.write("$root/data/$(fName)$(judgerName)DegDist$(N).csv", resultDf)
else
	CSV.write("$root/data/$(fName)$(judgerName)k$(round(Int,k))DegDist$(N).csv", resultDf)
end




# outgraph, outAvgFits, outTypes, outSamples = simulateIntroModel(G,types,1000000,judge, fitFunc, mut, sampleInterval = 50000)
# println(resultArray)
rmprocs(addedProcs)
println("Done")
