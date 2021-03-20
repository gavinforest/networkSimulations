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
    end

    return parse_args(s)
end

function makeWinsPlot(popsize)

	root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"

	frame = CSV.read("$root/data/nonRivalDefVisCoopWins$popsize.csv")

	averaged = by(frame, :epsilon, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
																fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
	winsMat = convert(Matrix, averaged[:, [:pwins,:fwins]])
	epsilons = unique(frame, :epsilon).epsilon
	# @show coops
	# @show winsMat
	s = "Cooperator Preference by Defector Visibility, N = $popsize"

	myplot = scatter(epsilons, winsMat, label= ["By payoff" "By fitness"], title = s);
	ylabel!(myplot, "Proportion of Cooperator Victories");
	xlabel!(myplot, "Cooperator Visibility");
	savefig(myplot, "$root/figs/nonRivalDefVisCoopWins$popsize.png");
end 

function main()
	parsed_args = parse_commandline()
	N = parsed_args["N"]
	# println("Called with N = $N")
	makeWinsPlot(N)
end
main()


