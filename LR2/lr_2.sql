/*1.Предприятие арендовавшие наибольшое по площади место.(Условный)*/
SELECT company.name_co, place_for_rent.name_pl,square
FROM place_for_rent INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON place_for_rent.id_pl = rent_place.id_pl
WHERE square IN (((SELECT MAX(square) FROM place_for_rent)));

/*2.Вывести количество продукции представленной каждой компанией.(Итоговый)*/
SELECT DISTINCT company.name_co, Count(products.name_pro) 
FROM products INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON products.id_products = rent_place.id_products
GROUP BY company.name_co;

/*3.Вывести продукцию по ID выставочного места.(Параметрический)*/
SELECT DISTINCT name_pro
FROM products
WHERE id_products IN (SELECT id_products FROM rent_place WHERE id_pl = 3);

/*4.Общий список продукции на выставках с указанием количества и выставок с количеством предприятий.(На объединение)*/
SELECT DISTINCT products.name_pro AS Name, Count(products.name_pro) AS Kol
FROM products INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON products.id_products = rent_place.id_products
GROUP BY products.name_pro
UNION
SELECT DISTINCT exibitions.topic AS Name, Count(company.name_co) AS Kol
FROM exibitions INNER JOIN (company INNER JOIN rent_place ON company.id_co = rent_place.id_co) ON exibitions.id_ex = rent_place.id_ex
GROUP BY  exibitions.topic 

/*5.Количество выставок и общее количество товаров по годам.(Запрос по полю с типом дата)*/
SELECT Count(exibitions.topic) AS exibitions_and_products, to_char(end_date, 'YYYY') AS YEAR
FROM exibitions 
GROUP BY to_char(end_date, 'YYYY')
UNION
SELECT Count(products.id_products), to_char(end_date, 'YYYY') 
FROM products JOIN (exibitions INNER JOIN rent_place ON exibitions.id_ex = rent_place.id_ex) ON products.id_products = rent_place.id_products
GROUP BY to_char(end_date, 'YYYY')

/*6.Вывести предприятие и его представителя.(INNER JOIN).*/
SELECT fio,name_co
FROM delegate_co INNER JOIN company ON delegate_co.id_del=company.id_del

/*7.Проверка статуса всех мест для аренды.(FULL JOIN)*/
SELECT rent_place.id_pl,name_pl
FROM rent_place FULL JOIN place_for_rent
ON rent_place.id_pl = place_for_rent.id_pl

/*8.Продукция со стоимостью меньше 201.(IN)*/
SELECT name_pro
FROM products
WHERE id_products IN (SELECT id_products FROM rent_place WHERE id_pl IN(SELECT id_pl FROM place_for_rent WHERE cost_nm <=200));

/*9.Вывести только арендованные места.(ANY)*/
SELECT name_pl
FROM place_for_rent
WHERE id_pl = any(SELECT id_pl FROM rent_place )

/*10.Проверка: арендовано место или нет.(EXISTS)*/
SELECT *
FROM place_for_rent 
WHERE name_pl = 'Помещение № 10' AND EXISTS (SELECT id_pl FROM rent_place WHERE  place_for_rent.id_pl = rent_place.id_pl)
