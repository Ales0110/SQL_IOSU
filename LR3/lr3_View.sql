/*1.Горизонтальное обновляемое представление*/
CREATE OR REPLACE VIEW product_cost AS
SELECT * 
FROM products
WHERE cost_pro >= 1000
WITH CHECK OPTION;

Проверка:
INSERT INTO  product_cost(id_products, name_pro, descr, cost_pro) VALUES(11,'Замыкающий вент4иль', 'Строймате4риалы',115)


/*2.Вертикальное необновляемое представление.*/
CREATE OR REPLACE VIEW delegate_company AS
SELECT fio, work_phone, home_phone, name_co
FROM delegate_co
JOIN company USING (id_del);

Проверки:
UPDATE delegate_company
SET work_phone = '+375173924298'
WHERE work_phone = '+375298794363';

INSERT INTO delegate_company(fio, work_phone, home_phone) VALUES('Роман Кравцо1в Тимурович','+375355515881', '+375173555004');

DELETE FROM delegate_company WHERE fio='Давид Мельников Александрович';


/*3.Представление, работающее в определённые дни недели и время.*/
CREATE OR REPLACE VIEW place_cost_time AS  
SELECT square
FROM place_for_rent
WHERE to_number(to_char(sysdate, 'hh24')) between 9 and 17 and to_number(to_char(SYSDATE, 'd')) between 2 and 6 
WITH CHECK OPTION;

Проверка:
SELECT square
FROM place_cost_time;