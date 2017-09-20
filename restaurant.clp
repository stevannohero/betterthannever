(defrule populate-restaurant
	(init restaurant)
	=>
	(assert
		(restaurant A smooker)
		(restaurant A minBudget 1000)
		(restaurant A maxBudget 2000)
		(restaurant A casual)
		(restaurant A hasWifi)
		(restaurant A lat -6.8922186)
		(restaurant A lng 107.5886173)

		(restaurant B minBudget 1200)
		(restaurant B maxBudget 2500)
		(restaurant B informal)
		(restaurant B hasWifi)
		(restaurant B lat -6.224085)
		(restaurant B lng 106.7859815)

		(restaurant C smooker)
		(restaurant C minBudget 2000)
		(restaurant C maxBudget 4000)
		(restaurant C formal)
		(restaurant C lat -6.2145285)
		(restaurant C lng 106.8642591)
	))

(defrule init
	(initial-fact)
	=>
	(printout t "Initializing program" crlf)
	(assert (init restaurant)))