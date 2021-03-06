(deftemplate restaurant-data
	(slot name)
	(slot number (type INTEGER))
	(slot smoke)
	(slot minBudget (type NUMBER))
	(slot maxBudget (type NUMBER))
	(multislot dresscode)
	(slot hasWifi)
	(slot lat (type NUMBER))
	(slot lng (type NUMBER))
)

(deftemplate score-data
	(slot name)
	(slot score (type NUMBER))
	(slot rank (type NUMBER))
)
(deffacts populate-restaurant
	(restaurant-data 
		(name A)
		(number 1)
		(smoke true)
		(minBudget 1000)
		(maxBudget 2000)
		(dresscode casual)
		(hasWifi true)
		(lat -6.8922186)
		(lng 107.5886173) 
	)
	(restaurant-data
		(name B)
		(number 2)
		(smoke false)
		(minBudget 1200)
		(maxBudget 2500)
		(dresscode informal)
		(hasWifi true)
		(lat -6.224085)
		(lng 106.7859815)
	)

	(restaurant-data	
		(name C)
		(number 3)
		(smoke true)
		(minBudget 2000)
		(maxBudget 4000)
		(dresscode formal)
		(hasWifi false)
		(lat -6.2145285)
		(lng 106.8642591)
	)
		
	(restaurant-data	
		(name D)
		(number 4)
		(smoke false)
		(minBudget 500)
		(maxBudget 1400)
		(dresscode formal)
		(hasWifi false)
		(lat -6.9005363)
		(lng 107.6222191)
	)

	(restaurant-data	
		(name E)
		(number 5)
		(smoke true)
		(minBudget 1000)
		(maxBudget 2000)
		(dresscode informal casual)
		(hasWifi true)
		(lat -6.2055617)
		(lng 106.8001597)
	)

	(restaurant-data	
		(name F)
		(number 6)
		(smoke false)
		(minBudget 2500)
		(maxBudget 5000)
		(dresscode informal)
		(hasWifi true)
		(lat -6.9045679)
		(lng 107.6399745)
	)

	(restaurant-data	
		(name G)
		(number 7)
		(smoke true)
		(minBudget 1300)
		(maxBudget 3000)
		(dresscode casual)
		(hasWifi true)
		(lat -6.1881082)
		(lng 106.7844409)
	)

	(restaurant-data	
		(name H)
		(number 8)
		(smoke false)
		(minBudget 400)
		(maxBudget 1000)
		(dresscode informal)
		(hasWifi false)
		(lat -6.9525133)
		(lng 107.605290)
	)

	(restaurant-data	
		(name I)
		(number 9)
		(smoke false)
		(minBudget 750)
		(maxBudget 2200)
		(dresscode informal casual)
		(hasWifi true)
		(lat -6.9586985)
		(lng 107.7092281)
	)

	(restaurant-data	
		(name J)
		(number 10)
		(smoke false)
		(minBudget 1500)
		(maxBudget 2000)
		(dresscode casual)
		(hasWifi true)
		(lat -6.2769732)
		(lng 107.775133)
	)
)

(defrule populate-score-and-recommendable
	(restaurant-data (name ?X) (number ?Y))
	=>
	(assert 
		(score-data (name ?X) (score 0) (rank ?Y))
		(restaurant ?X recommendable not-recommended)
	))

// grade user preference
(defrule grade-smoke
	(user smoking ?Y)
	(restaurant-data (name ?X) (smoke ?Y))
	=>
	(assert (grade-restaurant ?X smoke))
)
(defrule grade-budget
	(user minBudget ?UMin)
	(user maxBudget ?UMax)
	(restaurant-data (name ?X) (minBudget ?RMin) (maxBudget ?RMax))
	(test (>= ?UMax ?RMin))
	=>
	(assert (grade-restaurant ?X budget))
)
(defrule grade-dresscode
	(user dresscode ?Y)
	(restaurant-data (name ?X) (dresscode $? ?Y $?))
	=>
	(assert (grade-restaurant ?X dresscode))
)

// If we don't need wifi, do we have to go to restaurant without wifi?
(defrule grade-wifi
	(user needWifi ?Y)
	(restaurant-data (name ?X) (hasWifi ?Y))
	=>
	(assert (grade-restaurant ?X wifi))
)

(defrule count-distance
	(user lat ?ULat)
	(user lng ?ULng)
	(restaurant-data (name ?X) (lat ?RLat) (lng ?RLng))
	=>
	(if (and (neq ?ULat -) (neq ?ULng -))
		then
		(assert
			(restaurant ?X distance (sqrt (+ (** (abs (- ?ULat ?RLat)) 2) (** (abs (- ?ULng ?RLng)) 2))))
		)
		else
		(assert (restaurant ?X distance 0))
	)
)

// update score
(defrule update-score
	?f <- (score-data (name ?X) (score ?Y))
	?g <- (grade-restaurant ?X ?Z)
	=>
	(retract ?g)
	(bind ?v (+ ?Y 1))
	(modify ?f (score ?v))
	)

(defrule update-recommendable-very-recommended
	?f <- (restaurant ?X recommendable ~very-recommended)
	(criteria ?i)
	(score-data (name ?X) (score ?i) (rank ?A))
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable very-recommended)))

(defrule update-recommendable-recommended
	?f <- (restaurant ?X recommendable ~recommended)
	(criteria ?i)
	(score-data (name ?X) (score ?t))
	(test (or (eq ?t (- ?i 1)) (eq ?t (- ?i 2))))
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable recommended)))

(defrule update-recommendable-not-recommended
	?f <- (restaurant ?X recommendable ~not-recommended)
	(criteria ?i)
	(score-data (name ?X) (score ?t))
	(test (or (eq ?t (- ?i 3)) (eq ?t (- ?i 4))))
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable not-recommended)))

// just dummy data, use stdin to populate this
(defrule populate-user
	?f <- (init user)
	?g <- (criteria ?count)
	=>
	(retract ?f)
	(printout t "What is your name? ")
	(bind ?inputname (read))
	(assert (user name ?inputname))

	(printout t "Do you smoke?(yes|no) ")
	(bind ?inputsmoke (read))
	(lowcase ?inputsmoke)
	(if (or (eq ?inputsmoke yes) (eq ?inputsmoke no))
		then
		(retract ?g)
		(assert (criteria (+ ?count 1)))
		(if (eq ?inputsmoke yes)
			then 
				(assert (user smoking true))
			else
				(assert (user smoking false))
		)
		else
			(assert (user smoking -))
	)

	(printout t "What is your minimum budget?[0-9999] ")
	(bind ?inputmin (read))

	(printout t "What is your maximum budget?[0-9999] ")
	(bind ?inputmax (read))

	(if (and (integerp ?inputmin) (integerp ?inputmax))
		then
			(retract ?g)
			(assert (criteria (+ ?count 1)))
			(assert (user minBudget ?inputmin))
			(assert (user maxBudget ?inputmax))
		else 
			(assert (user minBudget 0))
			(assert (user maxBudget 0))
	)

	(printout t "What clothes are you wearing?(casual|informal|formal) ")
	(bind ?inputdc (read))
	(lowcase ?inputdc)
	(if (or (or (eq ?inputdc informal) (eq ?inputdc formal)) (eq ?inputdc casual))
		then
			(retract ?g)
			(assert (criteria (+ ?count 1)))
			(assert (user dresscode ?inputdc))
		else
			(assert (user dresscode -))
	)

	(printout t "Do you want restaurant with wifi?(yes|no) ")
	(bind ?inputwifi (read))
	(lowcase ?inputwifi)
	(if (or (eq ?inputwifi yes) (eq ?inputwifi no))
		then
		(retract ?g)
		(assert (criteria (+ ?count 1)))
		(if (eq ?inputwifi yes)
			then 
				(assert (user needWifi true))
			else
				(assert (user needWifi false))
		)
		else
			(assert (user needWifi -))
	)

	(printout t "What are your lat. coordinate? ")
	(bind ?inputlat (read))

	(printout t "What are your long. coordinate? ")
	(bind ?inputlon (read))

	(if (or (and (integerp ?inputlon) (integerp ?inputlat)) (and (floatp ?inputlon) (floatp ?inputlat)))
		then	
			(assert (user lat ?inputlat))	
			(assert (user lng ?inputlon))
		else 
			(assert (user lat -))	
			(assert (user lng -))
	)	
)

(defrule init
	?f <- (initial-fact)
	=>
	(retract ?f)
	(printout t "Initializing program" crlf)
	(assert
		(finish)
		(init restaurant)
		(criteria 0)
		(init user)
		(init score)
	))

(defrule sort
	(user smoking ?usmoke)
	(user dresscode ?udc)

	?F1 <- (score-data (name ?N1) (score ?S1) (rank ?P1))
	(restaurant-data (name ?N1) (smoke ?smoke1) (minBudget ?minb1) (maxBudget ?maxb1) (dresscode $? ?dc1 $?) (hasWifi ?w1))
	(restaurant ?N1 distance ?j1)
	
	?F2 <- (score-data (name ?N2) (score ?S2) (rank ?P2))
	(restaurant-data (name ?N2) (smoke ?smoke2) (minBudget ?minb2) (maxBudget ?maxb2) (dresscode $? ?dc2 $?) (hasWifi ?w2))
	(restaurant ?N2 distance ?j2)
	
	(test (> ?P1 ?P2))
	=>
	(if (> ?S1 ?S2)
		then 
		(modify ?F1 (score ?S1) (rank ?P2))
		(modify ?F2 (score ?S2) (rank ?P1))
		else
		(if (eq ?S1 ?S2)
			then
			(if (< ?j1 ?j2)
				then
				(modify ?F1 (score ?S1) (rank ?P2))
				(modify ?F2 (score ?S2) (rank ?P1))
				else
				(if (eq ?j1 ?j2)
					then
					(if (and (eq ?w1 true) (eq ?w2 false))
						then
						(modify ?F1 (score ?S1) (rank ?P2))
						(modify ?F2 (score ?S2) (rank ?P1))
						else
						(if (eq ?w1 ?w2)
							then
							(if (< ?minb1 ?minb2)
								then
								(modify ?F1 (score ?S1) (rank ?P2))
								(modify ?F2 (score ?S2) (rank ?P1))
								else
								(if (= ?minb1 ?minb2)
									then
									(if (and (eq ?dc1 ?udc) (neq ?dc2 ?udc))
										then 
										(modify ?F1 (score ?S1) (rank ?P2))
										(modify ?F2 (score ?S2) (rank ?P1))
										else
										(if (and (neq ?dc1 ?udc) (neq ?dc2 ?udc))
											then
											(if (and (eq ?dc1 casual) (neq ?dc2 casual))
												then 
												(modify ?F1 (score ?S1) (rank ?P2))
												(modify ?F2 (score ?S2) (rank ?P1))
												else
												(if (and (neq ?dc1 casual) (neq ?dc2 casual))
													then
													(if (and (eq ?smoke1 ?usmoke) (neq ?smoke2 ?usmoke))
														then
														(modify ?F1 (score ?S1) (rank ?P2))
														(modify ?F2 (score ?S2) (rank ?P1))
														else
														(if (and (neq ?smoke1 ?usmoke) (neq ?smoke2 ?usmoke))
															then
															(if (and (eq ?smoke1 false) (neq ?smoke2 false))
																then
																(modify ?F1 (score ?S1) (rank ?P2))
																(modify ?F2 (score ?S2) (rank ?P1))
															)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)				
			)
		)
	)	
)


(defrule check-sort-finish
	?f1 <- (finish)
	=>
	(retract ?f1)
	(assert (print-result))
	)

(defrule print-result
	(print-result)
	?f1 <- (score-data (name ?X1) (score ?Y1) (rank 1))
	?f2 <- (score-data (name ?X2) (score ?Y2) (rank 2))
	?f3 <- (score-data (name ?X3) (score ?Y3) (rank 3))
	(restaurant ?X1 recommendable ?Z1)
	(restaurant ?X2 recommendable ?Z2)
	(restaurant ?X3 recommendable ?Z3)
	(restaurant ?X1 distance ?D1)
	(restaurant ?X2 distance ?D2)
	(restaurant ?X3 distance ?D3)
	=>
	(format t "%nHere’s our recommendation:%n")
	(format t "Restaurant %-2s : %-12s (distance: %f)%n" ?X1 ?Z1 ?D1)
	(format t "Restaurant %-2s : %-12s (distance: %f)%n" ?X2 ?Z2 ?D2)
	(format t "Restaurant %-2s : %-12s (distance: %f)%n" ?X3 ?Z3 ?D3)
	)