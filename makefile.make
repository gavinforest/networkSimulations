judgers := Ego Mean EgoDefAccept
payoffs := classical divisible averaged nonRival
ks := 1 2 3 4 5
Ns := 100

define GEN_EFFECT_RULES
data/$(payoff)$(judger)k$(k)CoopWins$(N).csv : experiments/coopWins.jl
	cd $(<D); julia $(<F) -N $(N) --judger $(judger) --fitness $(payoff) -k $k
endef

define BASE_RULES
data/base$(payoff)CoopWins$(N).csv : experiments/baseCoopWins.jl
	cd $(<D); julia $(<F) -N $(N) --fitness $(payoff)
endef

define FIG_RULES
figs/$(payoff)$(judger)FullCoopWins$(N).png : data$(payoff)$(judger)$N plotters/fullWinsPlot.jl
	cd plotters; julia fullWinsPlot.jl --judger $(judger) --fitness $(payoff) -N $N
endef


$(foreach payoff,$(payoffs), \
  $(foreach judger,$(judgers), \
  	$(foreach k, $(ks), \
  		$(foreach N, $(Ns), \
  			$(eval $(GEN_EFFECT_RULES))
  		)
     )
  )
)

$(foreach payoff,$(payoffs), \
	$(foreach N, $(Ns), \
		$(eval $(BASE_RULES))
	)
)


$(foreach payoff,$(payoffs), \
	$(foreach N, $(Ns), \
		$(foreach judger, $(judgers)
			$(eval $(FIG_RULES))
		)
	)
)