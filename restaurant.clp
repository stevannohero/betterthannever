(defrule grade-smooke
	(user smooking ?Y)
	(restaurant ?X smooke ?Y)
	=>
	(assert (grade-restaurant ?X smooke)))

// what is user min budget mean?
(defrule grade-budget
	(user minBudget ?UMin)
	(user maxBudget ?UMax)
	(restaurant ?X minBudget ?RMin)
	(restaurant ?X maxBudget ?RMax)
	(test (>= ?UMax ?RMin))
	// (test (>= ?UMin ?RMin))
	// (test (<= ?UMax ?RMax))
	=>
	(assert (grade-restaurant ?X budget)))

(defrule grade-dresscode
	(user dresscode ?Y)
	(restaurant ?X dresscode ?Y)
	=>
	(assert (grade-restaurant ?X dresscode)))

// If we don't need wifi, do we have to go to restaurant without wifi?
(defrule grade-wifi
	(user needWifi ?Y)
	(restaurant ?X hasWifi ?Y)
	=>
	(assert (grade-restaurant ?X wifi)))

(defrule count-distance
	(user lat ?ULat)
	(user lng ?ULng)
	(restaurant ?X lat ?RLat)
	(restaurant ?X lng ?RLng)
	=>
	(if (and (neq ?ULat -) (neq ?ULng -))
		then
		(assert (restaurant ?X distance (sqrt (+ (** (abs (- ?ULat ?RLat)) 2) (** (abs (- ?ULng ?RLng)) 2)))))
		else
		(assert (restaurant ?X distance 0))
	)
)

(defrule update-score
	?f <- (score ?X ?Y ?A)
	?g <- (grade-restaurant ?X ?Z)
	=>
	(retract ?f)
	(retract ?g)
	(assert (score ?X (+ ?Y 1) ?A)))

(defrule update-recommendable-very-recommended
	?f <- (restaurant ?X recommendable ~very-recommended)
	(score ?X 4 ?A)
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable very-recommended)))

(defrule update-recommendable-recommended
	?f <- (restaurant ?X recommendable ~recommended)
	(score ?X 2|3 ?A)
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable recommended)))

(defrule update-recommendable-not-recommended
	?f <- (restaurant ?X recommendable ~not-recommended)
	(score ?X 0|1 ?A)
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable not-recommended)))

(defrule populate-restaurant
	?f <- (init restaurant)
	=>
	(retract ?f)
	(assert
		(restaurant A 1)
		(restaurant A smooke true)
		(restaurant A minBudget 1000)
		(restaurant A maxBudget 2000)
		(restaurant A dresscode casual)
		(restaurant A hasWifi true)
		(restaurant A lat -6.8922186)
		(restaurant A lng 107.5886173)

		(restaurant B 2)
		(restaurant B smooke false)
		(restaurant B minBudget 1200)
		(restaurant B maxBudget 2500)
		(restaurant B dresscode informal)
		(restaurant B hasWifi true)
		(restaurant B lat -6.224085)
		(restaurant B lng 106.7859815)

		(restaurant C 3)
		(restaurant C smooke true)
		(restaurant C minBudget 2000)
		(restaurant C maxBudget 4000)
		(restaurant C dresscode formal)
		(restaurant C hasWifi false)
		(restaurant C lat -6.2145285)
		(restaurant C lng 106.8642591)
		
		(restaurant D 4)
		(restaurant D smooke false)
		(restaurant D minBudget 500)
		(restaurant D maxBudget 1400)
		(restaurant D dresscode formal)
		(restaurant D hasWifi false)
		(restaurant D lat -6.9005363)
		(restaurant D lng 107.6222191)

		(restaurant E 5)
		(restaurant E smooke true)
		(restaurant E minBudget 1000)
		(restaurant E maxBudget 2000)
		(restaurant E dresscode informal)
		(restaurant E dresscode casual)
		(restaurant E hasWifi true)
		(restaurant E lat -6.2055617)
		(restaurant E lng 106.8001597)

		(restaurant F 6)
		(restaurant F smooke false)
		(restaurant F minBudget 2500)
		(restaurant F maxBudget 5000)
		(restaurant F dresscode informal)
		(restaurant F hasWifi true)
		(restaurant F lat -6.9045679)
		(restaurant F lng 107.6399745)

		(restaurant G 7)
		(restaurant G smooke true)
		(restaurant G minBudget 1300)
		(restaurant G maxBudget 3000)
		(restaurant G dresscode casual)
		(restaurant G hasWifi true)
		(restaurant G lat -6.1881082)
		(restaurant G lng 106.7844409)

		(restaurant H 8)
		(restaurant H smooke false)
		(restaurant H minBudget 400)
		(restaurant H maxBudget 1000)
		(restaurant H dresscode informal)
		(restaurant H hasWifi false)
		(restaurant H lat -6.9525133)
		(restaurant H lng 107.605290)

		(restaurant I 9)
		(restaurant I smooke false)
		(restaurant I minBudget 750)
		(restaurant I maxBudget 2200)
		(restaurant I dresscode informal)
		(restaurant I dresscode casual)
		(restaurant I hasWifi true)
		(restaurant I lat -6.9586985)
		(restaurant I lng 107.7092281)

		(restaurant J 10)
		(restaurant J smooke false)
		(restaurant J minBudget 1500)
		(restaurant J maxBudget 2000)
		(restaurant J dresscode casual)
		(restaurant J hasWifi true)
		(restaurant J lat -6.2769732)
		(restaurant J lng 107.775133)
	))

// just dummy data, use stdin to populate this
(defrule populate-user
	?f <- (init user)
	=>
	(retract ?f)
	
	(printout t "What is your name? ")
	(assert (user name (read stdin)))

	(printout t "Do you smoke?(true|false) ")
	(assert (user smooking (read stdin)))

	(printout t "What is your minimum budget?[0-9999] ")
	(assert (user minBudget (read stdin)))

	(printout t "What is your maximum budget?[0-9999] ")
	(assert (user maxBudget (read stdin)))

	(printout t "What clothes are you wearing?(casual|informal|formal) ")
	(assert (user dresscode (read stdin)))

	(printout t "Do you want restaurant with wifi?(true|false) ")
	(assert (user needWifi (read stdin)))

	(printout t "What are your lat. coordinate? ")
	(assert (user lat (read stdin)))

	(printout t "What are your long. coordinate? ")
	(assert (user lng (read stdin))))

(defrule populate-score-and-recommendable
	(init score)
	(restaurant ?X ?Y)
	=>
	(assert 
		(score ?X 0 ?Y)
		(restaurant ?X recommendable not-recommended)
	))

(defrule init
	?f <- (initial-fact)
	=>
	(retract ?f)
	(printout t "Initializing program" crlf)
	(assert
		(init restaurant)
		(init user)
		(init score)
	))

(defrule sort
	(user name ?uname)
	(user smooking ?usmoke)
	(user minBudget ?uminb)
	(user maxBudget ?umaxb)
	(user dresscode ?udc)
	(user needWifi ?uwifi)
	(user lat ?ulat)
	(user lng ?ulng)	

	?F1 <- (score ?N1 ?S1 ?P1)
	(restaurant ?N1 smooke ?smoke1)
	(restaurant ?N1 minBudget ?minb1)
	(restaurant ?N1 maxBudget ?maxb1)
	(restaurant ?N1 dresscode ?dc1)
	(restaurant ?N1 hasWifi ?w1)
	(restaurant ?N1 distance ?j1)
	
	?F2 <- (score ?N2 ?S2 ?P2)
	(restaurant ?N2 smooke ?smoke2)
	(restaurant ?N2 minBudget ?minb2)
	(restaurant ?N2 maxBudget ?maxb2)
	(restaurant ?N2 dresscode ?dc2)
	(restaurant ?N2 hasWifi ?w2)
	(restaurant ?N2 distance ?j2)
	
	(test (> ?P1 ?P2))
	=>
	(if (> ?S1 ?S2)
		then 
		(retract ?F1 ?F2)
		(assert 
			(score ?N1 ?S1 ?P2)
			(score ?N2 ?S2 ?P1))

		else
		(if (eq ?S1 ?S2)
			then
			(if (< ?j1 ?j2)
				then
				(retract ?F1 ?F2)
				(assert 
					(score ?N1 ?S1 ?P2)
					(score ?N2 ?S2 ?P1))
				else
				(if (eq ?j1 ?j2)
					then
					(if (and (eq ?w1 true) (eq ?w2 false))
						then
						(retract ?F1 ?F2)
						(assert 
							(score ?N1 ?S1 ?P2)
							(score ?N2 ?S2 ?P1))
						else
						(if (eq ?w1 ?w2)
							then
							(if (< ?minb1 ?minb2)
								then
								(retract ?F1 ?F2)
								(assert
									(score ?N1 ?S1 ?P2)
									(score ?N2 ?S2 ?P1))
								else
								(if (= ?minb1 ?minb2)
									then
									(if (and (eq ?dc1 casual) (neq ?dc2 casual))
										then 
										(retract ?F1 ?F2)
										(assert 
											(score ?N1 ?S1 ?P2)
											(score ?N2 ?S2 ?P1))
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

(defrule print-result
	(finish)
	?f1 <- (score ?X1 ?Y1 1)
	?f2 <- (score ?X2 ?Y2 2)
	?f3 <- (score ?X3 ?Y3 3)
	?f4 <- (score ?X4 ?Y4 4)
	?f5 <- (score ?X5 ?Y5 5)
	?f6 <- (score ?X6 ?Y6 6)
	?f7 <- (score ?X7 ?Y7 7)
	?f8 <- (score ?X8 ?Y8 8)
	?f9 <- (score ?X9 ?Y9 9)
	?f10 <- (score ?X10 ?Y10 10)
	(restaurant ?X1 recommendable ?Z1)
	(restaurant ?X2 recommendable ?Z2)
	(restaurant ?X3 recommendable ?Z3)
	(restaurant ?X4 recommendable ?Z4)
	(restaurant ?X5 recommendable ?Z5)
	(restaurant ?X6 recommendable ?Z6)
	(restaurant ?X7 recommendable ?Z7)
	(restaurant ?X8 recommendable ?Z8)
	(restaurant ?X9 recommendable ?Z9)
	(restaurant ?X10 recommendable ?Z10)
	=>
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X1 ?Z1 ?Y1)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X2 ?Z2 ?Y2)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X3 ?Z3 ?Y3)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X4 ?Z4 ?Y4)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X5 ?Z5 ?Y5)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X6 ?Z6 ?Y6)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X7 ?Z7 ?Y7)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X8 ?Z8 ?Y8)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X9 ?Z9 ?Y9)
	(format t "Restaurant %-2s : %-12s | %-3d%n" ?X10 ?Z10 ?Y10)
	)

(defrule finish
	=>
	(printout t "Finish" crlf)
	(assert
		(finish)
	))