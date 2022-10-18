/*1.Предприятие арендовавшее наибольшое по площади место.(Условный)*/
SELECT company.name_co, place_for_rent.name_pl,square
FROM place_for_rent 
INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON place_for_rent.id_pl = rent_place.id_pl
WHERE square IN (((SELECT MAX(square) FROM place_for_rent)));

/*2.Вывести количество продукции представленной каждой компанией.(Итоговый)*/
SELECT DISTINCT company.name_co, Count(products.name_pro) 
FROM products 
INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON products.id_products = rent_place.id_products
GROUP BY company.name_co;

/*3.Вывести продукцию по ID выставочного места.(Параметрический)*/
SELECT  name_pro
FROM products
WHERE id_products IN (SELECT id_products FROM rent_place WHERE id_pl = 3);-----

/*4.Общий список продукции на выставках с указанием количества и предприятий с количеством выставок(На объединение)*/
SELECT products.name_pro AS Name, Count(products.name_pro) AS Kol
FROM products 
INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON products.id_products = rent_place.id_products
GROUP BY products.name_pro
UNION
SELECT  company.name_co AS Name, Count(exibitions.topic ) AS Kol
FROM exibitions 
INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON exibitions.id_ex = rent_place.id_ex
GROUP BY  company.name_co 

/*5.Количество выставок и общее количество товаров по годам.(Запрос по полю с типом дата)*/
SELECT Count(exibitions.topic) AS exibitions_and_products, to_char(end_date, 'YYYY') AS YEAR
FROM exibitions 
GROUP BY to_char(end_date, 'YYYY')
UNION ALL
SELECT Count(products.id_products), to_char(end_date, 'YYYY') 
FROM products 
JOIN (exibitions INNER JOIN rent_place ON exibitions.id_ex = rent_place.id_ex) ON products.id_products = rent_place.id_products
GROUP BY to_char(end_date, 'YYYY')

/*6.Вывести предприятие и его представителя.(INNER JOIN).*/
SELECT fio,name_co
FROM delegate_co 
INNER JOIN company ON delegate_co.id_del=company.id_del
ORDER BY fio

/*7.Проверка статуса всех мест для аренды.(RIGHT JOIN)*/
SELECT name_pl, id_co
FROM rent_place 
RIGHT JOIN place_for_rent
ON rent_place.id_pl = place_for_rent.id_pl
ORDER BY name_pl

/*8.Продукция выставляемая на арендном месте со стоимостью места меньше 200.(IN)*/
SELECT name_pro
FROM products
WHERE id_products IN (SELECT id_products FROM rent_place WHERE id_pl IN(SELECT id_pl FROM place_for_rent WHERE cost_nm <200))
ORDER BY name_pro

/*9.Вывод самой дорогой продукции и ID ее компании.(ALL)*/
SELECT name_pro, cost_pro, id_co
FROM products
INNER JOIN rent_place USING (id_products)
WHERE products.cost_pro >= ALL(SELECT cost_pro FROM products);

/*10.Вывод неарендованных мест.(EXISTS)*/
SELECT * 
FROM place_for_rent  
WHERE NOT EXISTS (SELECT 1 FROM rent_place
WHERE  place_for_rent.id_pl = rent_place.id_pl)
ORDER BY name_pl

/*11.Обновить одной командой информацию о стоимости выставочных мест, уменьшив араенду на втором и третьем этаже  на 5 %, а на первом увеличить на 7 %.(UPDATE)*/
UPDATE place_for_rent
SET cost_nm = CASE WHEN flor < 2
THEN cost_nm * 1.07
ELSE cost_nm * 0.95
END;

/*12Предпритие арендовавшее максимальное количество мест на одной выставке и участвовало в не менее одной выставке */
SELECT   Company, Counts, max(Place) FROM
(SELECT  Company, Counts, Place  FROM
(SELECT   count(company.name_co)  AS Counts,company.name_co as Company,  exibitions.topic,  count( rent_place.id_pl) AS Place
FROM exibitions 
INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON exibitions.id_ex = rent_place.id_ex
GROUP BY  company.name_co, exibitions.topic)
GROUP BY Company, Counts, Place)
HAVING (Counts)>1 AND (Place)>1
GROUP BY Company, Counts, Place