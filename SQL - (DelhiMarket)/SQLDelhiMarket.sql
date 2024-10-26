-- Mission 1
-- Importation et visualisation des données-- afficher ce que contient chaque table pour mieux comprendre de quoi il s'agit 
select *
FROM DelhiMarket_list_of_orders
limit 10
;

select *
FROM DelhiMarket_order_details
limit 10
;

select *
FROM DelhiMarket_sales_target
limit 10
;

-- Mission 2
-- Analyse des ventes
-- Afin d’aider au mieux Stéphanie, vous devez comprendre quel est le volume d’affaires généré :
-- ● Pour cela, effectuez la jointure entre order_details et list_of_orders.
-- Y a-t-il des données manquantes, c’est-à-dire, y a-t-il des commandes
-- d’une table qui n’apparaissent pas dans l’autre table ? NON 
-- Indice : vous devez choisir vous-même le type de jointure le plus approprié
-- dans ce cas, en sachant que RIGHT JOIN et FULL OUTER JOIN ne sont pas
-- supportés sur SQLite. -- on peut faire du inner ou left join 

select *
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
; 

-- ● Calculez le chiffre d’affaires mensuel de la marketplace.
-- Y a-t-il une saisonnalité ?

-- faire une window function pour calculer le CA par mois plus pratique 
select *, SUM(od.Amount) over(PARTITION by o.Month) as amount_par_mois
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
; 

-- faire un group by pour voir le mois une fois dans la liste 
select month, amount_par_mois
from  (
        select *, SUM(od.amount) over(PARTITION by o.Month) as amount_par_mois
        from DelhiMarket_list_of_orders o
        left join DelhiMarket_order_details od
            ON o.Order_ID = od.Order_ID
         ) as tb1
 group by tb1.month
; -- voici le CA mensuelle de la marketplace
-- y  a til une saisonnalite ? reponse : oui il y a plus d'achat en debut d'annee mois 1,2,3 et en fin d'année mois 10, 11, 12 pour les fetes peut etre 

-- ● Calculez le chiffre d’affaires par catégorie. Quelle est la catégorie qui génère
-- le plus de chiffre d’affaires ?

select *
from DelhiMarket_order_details
;
-- faire le calcul du profit par category en utilisant les window function 
 select *, SUM(od.amount) over(PARTITION by od.category) as amount_par_category
 from DelhiMarket_order_details od
 ;
 -- pas possible dutiliser group by od.Category ici car ça fausse les resultats , utiliser le group by dans une sur requete
;
-- ajouter le group by pour avoir des resultats par categorie 
select category, amount_par_category
from 
      (
       select *, SUM(od.amount) over(PARTITION by od.category) as amount_par_category
       from DelhiMarket_order_details od
        ) as tb1
group by category
 ;
-- la categorie qui genere le plus de CA est le electronics

-- Mission 3
-- Identifier les meilleurs clients et calculer le panier moyen
-- ● Quel est le meilleur client en termes de nombre de commandes ? Shreya
-- En termes de chiffre d’affaires ? Le plus rentable ?

-- visualisation de la table list of orders 
select *
FROM DelhiMarket_list_of_orders
limit 10
;

-- classer les clients en fonction du nbre de order_id de chacun 

select  customername, count(order_id) over (partition by customername) as nbre_order_par_client, Order_id
FROM DelhiMarket_list_of_orders
order by nbre_order_par_client desc
;

-- ajouter un group by pour montrer qune seule fois chaque client (sans le detail des orders 
select *, tb1.customername, tb1.nbre_order_par_client
from 
      (
      select  customername, count(order_id) over (partition by customername) as nbre_order_par_client, Order_id
      FROM DelhiMarket_list_of_orders
      -- order by nbre_order_par_client desc
        ) as tb1
group by tb1.customername 
order by tb1.nbre_order_par_client desc
; -- ● Quel est le meilleur client en termes de nombre de commandes ? reponse : Shreya OK CORRECT 
  -- En termes de chiffre d’affaires ? Yaaniv -- Le plus rentable ?
  -- reponse : il faut classer les clients en fonction de leur CA 

select *
from  (
        select customername , SUM(od.profit) over(PARTITION by o.CustomerName) as profit_par_client
        from DelhiMarket_list_of_orders o
        left join DelhiMarket_order_details od
            ON o.Order_ID = od.Order_ID  
            ) as tb1
group by tb1.customername
order by tb1.profit_par_client desc
; -- reponse le client le plus rentable est Seema 
  
 -- en terme de CA : 
 
select *
from  (
        select customername , SUM(od.amount) over(PARTITION by o.CustomerName) as amount_par_client
        from DelhiMarket_list_of_orders o
        left join DelhiMarket_order_details od
            ON o.Order_ID = od.Order_ID  
            ) as tb1
group by tb1.customername
order by tb1.amount_par_client desc
; -- le meilleur client en terme de chiffre dafaire : Yaaniv
 
 

-- ● Faites les mêmes calculs en fonction des différents états indiens.
-- cad quel est le meilleur etat indiens en termes de commandes ? de chiffres d'affaires ? le plus rentable ? 

-- calcul du meilleur etat en terme de CA 
select *
from
         (
         select state, SUM(od.amount) over(PARTITION by o.State) as amount_par_state
                from DelhiMarket_list_of_orders o
                left join DelhiMarket_order_details od
                    ON o.Order_ID = od.Order_ID
        ) as tb1
group by tb1.state
order by tb1.amount_par_state desc
; -- meilleur etat en terme de chiffre daffaire est Madhya Pradesh 


-- calcul de l'etat le plus rentable 
select *
from
         (
         select state, SUM(od.profit) over(PARTITION by o.State) as profit_par_state
                from DelhiMarket_list_of_orders o
                left join DelhiMarket_order_details od
                    ON o.Order_ID = od.Order_ID
        ) as tb1
group by tb1.state
order by tb1.profit_par_state desc
;  -- reponse le meilleur etat indiens en termes de rentabilite : Maharashtra

-- calcul du meilleur etat en terme de Commande 

select *
from
         (
         select state, count(o.Order_ID) over(PARTITION by o.State) as commande_par_state
                from DelhiMarket_list_of_orders o
                left join DelhiMarket_order_details od
                    ON o.Order_ID = od.Order_ID
        ) as tb1
group by tb1.state
order by tb1.commande_par_state desc
;  -- le meilleur etat en terme de nbre de commande est Madhya Pradesh 

-- À l’aide de la table order details, calculez le montant total par commande, en
-- gardant les colonnes mois et année de la commande.

select o.Order_ID, o.day, o.month, sum(od.amount) over(partition by o.order_id) as amount_tot_par_commande
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
    
-- regarder la table order details 
select *
from DelhiMarket_order_details
; 
-- joindre order detail et list of orders 
select *
FROM
(
select o.Order_ID, o.year, o.month, sum(od.amount) over(partition by o.order_id) as amount_tot_par_commande
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID ) as tb1
group by tb1.order_ID
order  by amount_tot_par_commande desc
;


-- ● Visualisez ensuite l’évolution mensuelle du panier moyen
-- faire un WITH 

with tbb as 
(
          select *
          FROM
          (
          select o.Order_ID, o.year, o.month, sum(od.amount) over(partition by o.order_id) as amount_tot_par_commande
          from DelhiMarket_list_of_orders o
          left join DelhiMarket_order_details od
              ON o.Order_ID = od.Order_ID ) as tb1
          group by tb1.order_ID
         ---  order  by amount_tot_par_commande desc
) , tbb2 as (
select  tbb.year,tbb.month, round(avg(tbb.amount_tot_par_commande) over(partition by month),1) as avg_commande_mois
from tbb)
select *
from tbb2
group by month
order by tbb2.year
;
-- voir tableau excel pour voir levolution des resultats
-- Indice : il faut utiliser une CTE 


-- Mission 4
--Analyse de la rentabilité
--La stratégie de Stéphanie n’est pas une croissance agressive :
--elle préfère se concentrer sur la rentabilité plutôt que sur des investissements
--marketing démesurés.
--● Vous souhaitez savoir si le rachat de Delhi Market a eu un impact sur son
--résultat net.
-- 1)Pour cela, regardez l’évolution mensuelle des profits de la marketplace.
--Que concluez-vous ?
-- 2) Identifiez les sous-catégories qui ont généré une perte sur la période -
--Analysez maintenant l’évolution des profits mois par mois pour chaque
--sous-catégorie. Quelle est la sous-catégorie avec l’évolution la plus nette ?
--Vous pouvez pour cela copier-coller les résultats dans un tableur Excel
--pour faire de la dataviz, un TCD…

-- 1)Pour cela, regardez l’évolution mensuelle des profits de la marketplace
-- 
select *
from (
select o.year,o.month , sum(od.Profit) over(partition by o.year, o.month) as profittot_par_mois
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
        ON o.Order_ID = od.Order_ID
) as tb1
group by tb1.year, tb1.month 


-- 2) Identifiez les sous-catégories qui ont généré une perte sur la période -

select tb1.sub_category ,  tb1.profittot_par_sous_cate
            FROM
                 (select o.Order_ID, o.month, od.category, od.Sub_Category, sum(od.Profit) over(partition by od.sub_category) as profittot_par_sous_cate
                  from DelhiMarket_list_of_orders o
                  left join DelhiMarket_order_details od
                      ON o.Order_ID = od.Order_ID ) as tb1
           group by tb1.sub_category
           order  by profittot_par_sous_cate  ; -- les sous categories qui ont geners des pertes sont les Tables et les Electronic games 

--3) Analysez maintenant l’évolution des profits mois par mois pour chaque
--sous-catégorie. Quelle est la sous-catégorie avec l’évolution la plus nette ?
--Vous pouvez pour cela copier-coller les résultats dans un tableur Excel
--pour faire de la dataviz, un TCD…

-- visualiser le tableau details des commandes 
select*
from DelhiMarket_order_details

-- construire le tableau evolution profit des sous categories par mois 
            select * -- tb1.sub_category , tb1.year,  tb1.month ,  tb1.Profittot_par_sous_cate -- tb1.sub_category ,  tb1.profittot_par_sous_cate
            FROM
                 (select od.Category , od.Sub_Category, o.year, o.Month, sum(od.Profit) over(partition by od.sub_category, o.year, o.month) as Profittot_par_sous_cate
                  from DelhiMarket_list_of_orders o
                  left join DelhiMarket_order_details od
                      ON o.Order_ID = od.Order_ID ) as tb1
           group by tb1.Profittot_par_sous_cate
           order  by tb1.sub_category, tb1.year, tb1.month  ;
           
 --pour faire de la dataviz, un TCD (tableau croise dynamique)  voir fichier excel       


--Mission 5
--1) Analyse des objectifs
--2) Pour chaque catégorie, vérifiez l’écart entre les objectifs et le volume d’affaires
--3) effectivement réalisé pour chaque mois de la période.

-- 1)Analyse des objectifs, faire 3 jointures pour avoir les annees, les mois, les category et les target ensembles 
    
select *
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
left join DelhiMarket_sales_target st
	ON od.Category = st.Category
  ; 

-- selectionner que ce qui nous interesse dans la table 
with tb1 as (
select o.Order_ID, o.Year, o.month, od.Category, st.Target, od.Amount, od.Quantity
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
left join DelhiMarket_sales_target st
	ON od.Category = st.Category
group by o.Order_ID),
tb2 as (
select tb1.Year, tb1.month, tb1.Category, tb1.Target, tb1.Amount, sum(tb1.Amount*tb1.quantity) over (partition by tb1.Category, tb1.year, tb1.month) as CA_par_category_par_mois
from tb1  -- faire la somme des amounts en regroupant les orders
)
select tb2.Year, tb2.month, tb2.Category, tb2.Target, tb2.CA_par_category_par_mois
from tb2
group by tb2.CA_par_category_par_mois
order by tb2.Category, tb2.year, tb2.month  ;  
 
--2) Pour chaque catégorie, vérifiez l’écart entre les objectifs et le volume d’affaires 
-- creer une nouvelle colonne avec la diff entre target et CA par category par mois 

with tb1 as (
select o.Order_ID, o.Year, o.month, od.Category, st.Target, od.Amount, od.Quantity
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
left join DelhiMarket_sales_target st
	ON od.Category = st.Category
group by o.Order_ID),
tb2 as (
select tb1.Year, tb1.month, tb1.Category, tb1.Target, tb1.Amount, sum(tb1.Amount*quantity) over (partition by tb1.Category, tb1.year, tb1.month) as CA_par_category_par_mois
from tb1  -- faire la somme des amounts en regroupant les orders
)
select tb2.Year, tb2.month, tb2.Category, tb2.Target, tb2.CA_par_category_par_mois, tb2.CA_par_category_par_mois-tb2.Target as diff_CA_target
from tb2
group by tb2.CA_par_category_par_mois
order by tb2.Category, tb2.year, tb2.month  ; 


-- faire un tableau sur excel avec les résulatts TCD (voir mission 5)


-- 3) Rajoutez une nouvelle colonne qui suit les règles suivantes :
--● Si les ventes atteignent les objectifs, à plus ou moins 3%, la variable
--affichera « on_target »
--● Si les ventes dépassent les objectifs de plus de 3%, elle affichera «
--above_target »
--● Si les ventes sont en dessous des objectifs avec un écart de plus de 3%,
--elle affichera « below_target »

with tb1 as (
select o.Order_ID, o.Year, o.month, od.Category, st.Target, od.Amount, od.Quantity
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
left join DelhiMarket_sales_target st
	ON od.Category = st.Category
group by o.Order_ID),
tb2 as (
select tb1.Year, tb1.month, tb1.Category, tb1.Target, tb1.Amount, sum(tb1.Amount*quantity) over (partition by tb1.Category, tb1.year, tb1.month) as CA_par_category_par_mois
from tb1  -- faire la somme des amounts en regroupant les orders
), 
tb3 as (
select tb2.Year, tb2.month, tb2.Category, tb2.Target, tb2.CA_par_category_par_mois, tb2.CA_par_category_par_mois-tb2.Target as diff_CA_target
from tb2
group by tb2.CA_par_category_par_mois
order by tb2.Category, tb2.year, tb2.month)
select *, 
	case 
    when tb3.diff_CA_target between (select -(2.8/100)*tb3.Target from tb3) and (select (3.2/100)*tb3.Target from tb3) then 'On_Target'
    when tb3.diff_CA_target > (select (3.2/100)*tb3.Target from tb3) then 'Above_Target' 
    else 'Below_Target' 
    end as Target_yes_no
from tb3 ; 


--4) Calculez ensuite le nombre de mois au-dessus des objectifs, en dessous des
--objectifs, égaux aux objectifs. Qu’en concluez-vous ?
-- test -question n:4- FAUX !!!! beaucoup trop de sous requettes et de group by et order by, il est possible de faire tout à la suite avec un sum puis order by de 4 variables succesives 
with tb1 as (
select o.Order_ID, o.Year, o.month, od.Category, st.Target, od.Amount, od.Quantity
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
left join DelhiMarket_sales_target st
	ON od.Category = st.Category
group by o.Order_ID),
tb2 as (
select tb1.Year, tb1.month, tb1.Category, tb1.Target, tb1.Amount, sum(tb1.Amount*quantity) over (partition by tb1.Category, tb1.year, tb1.month) as CA_par_category_par_mois
from tb1  -- faire la somme des amounts en regroupant les orders
), 
tb3 as (
select tb2.Year, tb2.month, tb2.Category, tb2.Target, tb2.CA_par_category_par_mois, tb2.CA_par_category_par_mois-tb2.Target as diff_CA_target
from tb2
group by tb2.CA_par_category_par_mois
order by tb2.Category, tb2.year, tb2.month), tb4 as (
select *, 
	case 
    when tb3.diff_CA_target between (select -(2.8/100)*tb3.Target from tb3) and (select (3.2/100)*tb3.Target from tb3) then 'On_Target'
    when tb3.diff_CA_target > (select (3.2/100)*tb3.Target from tb3) then 'Above_Target' 
    else  'Below_Target' 
    end as Target_yes_no
from tb3), tb5 as 
(select tb4.category, tb4.Year, tb4.Target_yes_no , *
from tb4 
order by tb4.category, tb4.year), tb6 as 
-- (select *, count(tb5.month) over(partition by tb5.Category, tb5.year, tb5.Target_yes_no) as nbre_mois_par_typetarget 
(select *, count(tb5.month) over(partition by tb5.Category,tb5.Target_yes_no) as nbre_mois_par_category 
from tb5)  
select Category, Target_Yes_No, nbre_mois_par_category 
from tb6
-- group by  Category -- , tb6.year,Target_yes_no 
-- group by  Category, tb6.year,Target_yes_no 
group by  Category, Target_yes_no 

-- Correction 
with tb1 as (
select od.Category,o.Year, o.month,  st.Target, sum(od.Amount) as total_sales
from DelhiMarket_list_of_orders o
left join DelhiMarket_order_details od
	ON o.Order_ID = od.Order_ID
left join DelhiMarket_sales_target st
	ON od.Category = st.Category  -- triple clé de jointure pour éviter que les lignes soient multipliés, très important 
  	AND o.Month = st.Month
  	AND o.Year = st.Year
group by 1,2,3,4) , tb2 as (
  select *, 
	case 
    when tb1.total_sales between (select 0.97*tb1.Target from tb1) and (select 1.03*tb1.Target from tb1) then 'On_Target'
    when tb1.total_sales > (select 1.03*tb1.Target from tb1) then 'Above_Target' 
    else  'Below_Target' 
    end as Target_yes_no
from tb1)
select category, Target_yes_no, count(*) as nb_months
from tb2
group by 1,2



--Mission 6
--Présentation des données
--Préparez une présentation dans laquelle vous montrerez les résultats de
--votre analyse. 3
