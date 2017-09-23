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
	(test (>= ?UMin ?RMin))
	(test (<= ?UMax ?RMax))
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
	(assert (restaurant ?X distance (sqrt (+ (** (abs (- ?ULat ?RLat)) 2) (** (abs (- ?ULng ?RLng)) 2))))))

(defrule update-score
	?f <- (score ?X ?Y)
	?g <- (grade-restaurant ?X ?Z)
	=>
	(retract ?f)
	(retract ?g)
	(assert (score ?X (+ ?Y 1))))

(defrule update-recommendable-very-recommended
	?f <- (restaurant ?X recommendable ~very-recommended)
	(score ?X 4)
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable very-recommended)))

(defrule update-recommendable-recommended
	?f <- (restaurant ?X recommendable ~recommended)
	(score ?X 2|3)
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable recommended)))

(defrule update-recommendable-not-recommended
	?f <- (restaurant ?X recommendable ~not-recommended)
	(score ?X 0|1)
	=>
	(retract ?f)
	(assert (restaurant ?X recommendable not-recommended)))

(defrule populate-restaurant
	?f <- (init restaurant)
	=>
	(retract ?f)
	(assert
		(restaurant A)
		(restaurant A smooke true)
		(restaurant A minBudget 1000)
		(restaurant A maxBudget 2000)
		(restaurant A dresscode casual)
		(restaurant A hasWifi true)
		(restaurant A lat -6.8922186)
		(restaurant A lng 107.5886173)

		(restaurant B)
		(restaurant B smooke false)
		(restaurant B minBudget 1200)
		(restaurant B maxBudget 2500)
		(restaurant B dresscode informal)
		(restaurant B hasWifi true)
		(restaurant B lat -6.224085)
		(restaurant B lng 106.7859815)

		(restaurant C)
		(restaurant C smooke true)
		(restaurant C minBudget 2000)
		(restaurant C maxBudget 4000)
		(restaurant C dresscode formal)
		(restaurant C hasWifi false)
		(restaurant C lat -6.2145285)
		(restaurant C lng 106.8642591)
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
	(restaurant ?X)
	=>
	(assert 
		(score ?X 0)
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