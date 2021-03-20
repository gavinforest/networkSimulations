using Plots
using CSV
using DataFrames
using ArgParse
# using Statistics

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
    end

    return parse_args(s)
end

function makeWinsPlot(popsize, judger, fName)
    root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"

    if fName == "classicalDefCost"
        baseFName = "classical"
    else
        baseFName = fName
    end

    baseFrame = CSV.read("$root/data/base$(baseFName)CoopWins$popsize.csv")

    averaged = by(baseFrame, :coop, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
                                                                fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
    winsMat = averaged.fwins
    coops = unique(baseFrame, :coop).coop
    # @show coops
    # @show winsMat
    s = "Cooperator Preference in Randomly Intialized Graphs, N = $popsize"
    myplot = scatter(coops, winsMat, label= "Baseline", title = s, dpi = 250);
    ylabel!(myplot, "Proportion of Cooperator Victories");
    xlabel!(myplot, "Proportion Cooperators in Population");

    for c_def in [0.1,0.2,0.3,0.4,0.5]
        k = 5
        if k == 1
    	   frame = CSV.read("$root/data/$(fName)$(judger)DefCost$(round(Int, c_def * 10))CoopWins$popsize.csv")
        else
            frame = CSV.read("$root/data/$(fName)$(judger)DefCost$(round(Int, c_def * 10))k$(round(Int,k))CoopWins$popsize.csv")
        end

	   averaged = by(frame, :coop, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
																fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
	   winsMat = averaged.fwins
	   coops = unique(frame, :coop).coop
	# @show coops
	# @show winsMat

	   scatter!(coops, winsMat, label= "c_def = $c_def", dpi=250);
    end

	savefig(myplot, "$root/figs/$(fName)$(judger)FullCoopWins$popsize.png");   
end 

function main()
	parsed_args = parse_commandline()
	N = parsed_args["N"]
    judger = parsed_args["judger"]
    fName = parsed_args["fitness"]
	# println("Called with N = $N")
	makeWinsPlot(N, judger, fName)
end
main()


