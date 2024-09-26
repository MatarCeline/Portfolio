#regarder la table rides 
SELECT *
FROM rides
LIMIT 40

#regarder le nbre de trajets qui commencent de villes differentes 
select count(distinct starting_city_id)
from rides 

#regarder la date de debut des departs
select MIN(departure_date) 
from rides 

#regarder la date de fin des départs
select MAX(departure_date) 
from rides 

#regarder les villes 
SELECT *
FROM cities


#joindre les 3 tables members, member_car, rides pour avoir les noms des 
select *
from members m 
join member_car mc 
on m.member_id = mc.member_id 
join rides r 
on mc.member_car_id = r.member_car_id 
join cities c
on  c.city_id = r.starting_city_id 
limit 40
; 

#regarder que les conducteurs
select * #, count(mc.member_car_id), count(r.ride_id)
from members m 
join member_car mc 
on m.member_id = mc.member_id 
join rides r 
on mc.member_car_id = r.member_car_id 
where is_ride_owner = 1
limit 40
; 


#creation des cohort : classer les inscrits en fonction des villes de départ et calculer le nbre de depart par ville 

select *
from poetic-tesla-431207-k5.BlablaVoiture.cars


select c.city_name as starting_city, count(ride_id) as nbr_trajet_parville, count(distinct mc.member_car_id) as nbre_cond_actif_parville, count(distinct mc.member_car_id)/count(ride_id) as taux_de_retention
from poetic-tesla-431207-k5.BlablaVoiture.members  m 
join poetic-tesla-431207-k5.BlablaVoiture.member_car mc 
on m.member_id = mc.member_id 
join poetic-tesla-431207-k5.BlablaVoiture.rides r 
on mc.member_car_id = r.member_car_id 
join poetic-tesla-431207-k5.BlablaVoiture.cities c
on  c.city_id = r.starting_city_id 
group by  starting_city 
order by starting_city DESC 
;



SELECT extract(`month` from m.inscription_date) as month, c.city_name as starting_city, count(ride_id) as nbr_trajet_parville, count(distinct mc.member_car_id) as nbre_cond_actif_parville, count(distinct mc.member_car_id)/count(ride_id) as taux_de_retention
from poetic-tesla-431207-k5.BlablaVoiture.members m  
join poetic-tesla-431207-k5.BlablaVoiture.member_car mc 
on m.member_id = mc.member_id 
join poetic-tesla-431207-k5.BlablaVoiture.rides r 
on mc.member_car_id = r.member_car_id 
join poetic-tesla-431207-k5.BlablaVoiture.cities c
on  c.city_id = r.starting_city_id 
where c.city_name IN ("Tour", "Paris", "Marseille", "Bruxelles" , "Orléans", "Lyon", "Versailles")
group by month, starting_city 
order by month DESC , starting_city DESC 
; 

#repartition par ville 
with tb1 as 
(
select extract(`month` from m.inscription_date) as mois_inscription , c.city_name as starting_city, count(ride_id) as nbr_trajet_parville, count(distinct mc.member_car_id) as nbre_cond_actif_parville, AVG(r.contribution_per_passenger) as prix_moyen_trajet
from poetic-tesla-431207-k5.BlablaVoiture.members m 
join poetic-tesla-431207-k5.BlablaVoiture.member_car mc 
on m.member_id = mc.member_id 
join poetic-tesla-431207-k5.BlablaVoiture.rides r 
on mc.member_car_id = r.member_car_id 
join poetic-tesla-431207-k5.BlablaVoiture.cities c
on  c.city_id = r.starting_city_id 
where c.city_name = "Tour"
group by mois_inscription, c.city_name 
)
select *,nbre_cond_actif_parville/(select SUM(nbre_cond_actif_parville) from tb1)*100 as taux_de_retention
from tb1
;