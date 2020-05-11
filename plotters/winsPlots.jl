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
        "-k"
            help = "Shape parameter for judger"
            arg_type = Float64
            default = 1.0
    end

    return parse_args(s)
end

function makeWinsPlot(popsize, judger, fName,k)

	root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"
    if k == 1.0
	   frame = CSV.read("$root/data/$(fName)$(judger)CoopWins$popsize.csv")
    else
        frame = CSV.read("$root/data/$(fName)$(judger)k$(round(Int,k))CoopWins$popsize.csv")
    end

	averaged = by(frame, :coop, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
																fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
	winsMat = convert(Matrix, averaged[:, [:pwins,:fwins]])
	coops = unique(frame, :coop).coop
	# @show coops
	# @show winsMat
	s = "Cooperator Preference by Proportion, N = $popsize"

	myplot = scatter(coops, winsMat, label= ["By payoff" "By fitness"], title = s, dpi=250);
	ylabel!(myplot, "Proportion of Cooperator Victories");
	xlabel!(myplot, "Proportion Cooperators in Population");
    if k == 1.0
	   savefig(myplot, "$root/figs/$(fName)$(judger)CoopWins$popsize.png");
    else
       savefig(myplot, "$root/figs/$(fName)$(judger)k$(round(Int, k))CoopWins$popsize.png");
   end
end 

function main()
	parsed_args = parse_commandline()
	N = parsed_args["N"]
    judger = parsed_args["judger"]
    fName = parsed_args["fitness"]
    k = parsed_args["k"]
	# println("Called with N = $N")
	makeWinsPlot(N, judger, fName,k)
end
main()


