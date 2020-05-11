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
        "--fitness"
            help = "The fitness function"
            arg_type = String
            default = "nonRival"
    end

    return parse_args(s)
end

function makeWinsPlot()
    parsed_args = parse_commandline()
    popsize = parsed_args["N"]
    fName = parsed_args["fitness"]

	root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"

	frame = CSV.read("$root/data/base$(fName)CoopWins$popsize.csv")

	averaged = by(frame, :coop, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
																fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
	winsMat = convert(Matrix, averaged[:, [:pwins,:fwins]])
	coops = unique(frame, :coop).coop
	# @show coops
	# @show winsMat
    s = "Cooperator Preference in Randomly Intialized Graphs, N = $popsize"
	myplot = scatter(coops, winsMat, label= ["By payoff" "By fitness"], title = s);
	ylabel!(myplot, "Proportion of Cooperator Victories");
	xlabel!(myplot, "Proportion Cooperators in Population");
	savefig(myplot, "$root/figs/base$(fName)CoopWins$popsize.png");
end 

makeWinsPlot()


