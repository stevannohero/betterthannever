(deftemplate coba
	(slot name)
        (slot distance (type NUMBER))
        (slot peringkat (type NUMBER))
)
(deffacts init-coba
        (coba (name A) (distance 10) (peringkat 1))
        (coba (name B) (distance 1) (peringkat 2))
        (coba (name C) (distance 3) (peringkat 3))
        (coba (name D) (distance 8) (peringkat 4))
)
(defrule init
        (initial-fact)
        =>
        (assert
                (pertama)
                (kedua)
                (ketiga)
        )
)
(defrule pertama
        ?f1 <- (coba (name ?nameA) (distance ?A) (peringkat ?A1))
        ?f2 <- (coba (name ?nameB) (distance ?B) (peringkat ?B1))
        (test (< ?A ?B))
        (test (< ?B1 ?A1))
        =>
        (retract ?f1 ?f2)
        (assert
                (coba (name ?nameA) (distance ?A) (peringkat ?B1))
                (coba (name ?nameB) (distance ?B) (peringkat ?A1))
        )
        (printout t "Jalan 1" crlf)

)
(defrule kedua
        (kedua)
        =>
        (printout t "Jalan 2" crlf)
)
(defrule ketiga
        (ketiga)
        =>
        (printout t "Jalan 3" crlf)
)