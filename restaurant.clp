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
	))

(defrule init
	(initial-fact)
	=>
	(printout t "Initializing program" crlf)
	(assert (init restaurant)))