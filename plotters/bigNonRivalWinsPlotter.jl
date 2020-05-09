using Plots
using CSV
using DataFrames
using ArgParse
# using Statistics

popsizes = [10,100,300]

function makeWinsPlot()

	root = "/Users/gavin/Documents/Stay_Loose/Research/Evolutionary_Dynamics/networkSimulations"

    theplot = Nothing

    for popsize in popsizes

    	frame = CSV.read("$root/data/nonRivalCoopWins$popsize.csv")

    	averaged = by(frame, :coop, [:payoffDiff, :fitDiff] =>  x -> (pwins = sum([1.0 for i in x.payoffDiff if i > 0.0])/length(x.payoffDiff), 
    																fwins = sum([1.0 for i in x.fitDiff if i > 0.0])/length(x.fitDiff)))
    	winsMat = averaged.fwins
    	coops = unique(frame, :coop).coop
    	# @show coops
    	# @show winsMat
    	s = "Cooperator Preference by Proportion, After Process"
        if theplot == Nothing
    	   theplot = scatter(coops, winsMat, label= "N = $popsize", title = s);
        else
            scatter!(coops,winsMat, label= ["N = $popsize"])
        end

    end
    ylabel!(theplot, "Proportion of Cooperator Victories");
    xlabel!(theplot, "Proportion Cooperators in Population");
    
	savefig(theplot, "$root/figs/bigNonRivalCoopWins.png");
end 

function main()
	# println("Called with N = $N")
	makeWinsPlot()
end
main()


