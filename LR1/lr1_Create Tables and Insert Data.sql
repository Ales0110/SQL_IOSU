CREATE TABLE delegate_co(id_del INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1 NOCACHE ) PRIMARY KEY,
			fio VARCHAR(60) NOT NULL,
			work_phone CHAR(17) NOT NULL,
			home_phone CHAR(17) NOT NULL,
			    CONSTRAINT work_phone_pr
					CHECK(REGEXP_LIKE(work_phone, '\+375\d{2}\d{3}\d{2}\d{2}')),
                CONSTRAINT home_phone_pr
					CHECK(REGEXP_LIKE(home_phone, '\+375\d{2}\d{3}\d{2}\d{2}')));    
          
ALTER TABLE  delegate_co
    ADD CONSTRAINT work_phone_un UNIQUE(work_phone)

ALTER TABLE  delegate_co
    ADD CONSTRAINT home_phone_un UNIQUE(home_phone)

CREATE TABLE company(id_co INTEGER  NOT NULL PRIMARY KEY,
			name_co VARCHAR(30) NOT NULL,
			id_del INTEGER NOT NULL,
            code_unn CHAR(11) NOT NULL,
            adress VARCHAR(60) NOT NULL,
			    CONSTRAINT company_id_del
				    FOREIGN KEY(id_del)
				    REFERENCES delegate_co);

CREATE TABLE rent_place(id_co INTEGER NOT NULL,
			id_pl INTEGER NOT NULL,
			id_products INTEGER NOT NULL,
            id_ex INTEGER NOT NULL,
                PRIMARY KEY(id_co, id_pl, id_products, id_ex),
				CONSTRAINT id_co_rent_place
				    FOREIGN KEY(id_co) 
				    REFERENCES company,
			    CONSTRAINT id_pl_rent_place
				    FOREIGN KEY(id_pl) 
				    REFERENCES place_for_rent,
			    CONSTRAINT id_pro_rent_place
			    	FOREIGN KEY(id_products) 
				    REFERENCES products,
                CONSTRAINT id_ex_rent_place
				    FOREIGN KEY(id_ex) 
				    REFERENCES exibitions);

CREATE TABLE products(id_products INTEGER NOT NULL PRIMARY KEY,
			name_pro VARCHAR(40) NOT NULL,
			descr VARCHAR(60) NOT NULL,
			cost_pro NUMBER(7,2) NOT NULL);
            
CREATE SYNONYM id_pro FOR id_products;  

CREATE TABLE place_for_rent(id_pl INTEGER  NOT NULL PRIMARY KEY,
			flor VARCHAR(4) NOT NULL,
			name_pl VARCHAR(40) NOT NULL,
            cost_nm NUMBER(5,2) NOT NULL,
            square NUMBER(5,2) NOT NULL,
		        CONSTRAINT flor_pr 
                    CHECK(flor > 0 AND flor < 4));

CREATE TABLE exibitions(id_ex INTEGER  NOT NULL PRIMARY KEY,
			topic VARCHAR(50) NOT NULL,
			start_date DATE NOT NULL,
            end_date DATE NOT NULL);      
               
CREATE UNIQUE INDEX index_fio
ON delegate_co (fio);

CREATE INDEX index_co_foreing
ON company (id_del);



INSERT INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(1,1,1,1)
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Роман Кравцов Тимурович','+375335515881', '+375173555604');
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Полина Севастьянова Юрьевна','+375292889093', '+375172929742');
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Екатерина Белова Владимировна','+375334988733', '+375174849946');
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Дмитрий Широков Павлович','+375298794363', '+375172618587');
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Марк Окулов Андреевич','+375251430776', '+375179460350');
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Диана Яшин Дмитриевич','+375292554754', '+375175554459');
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Давид Мельников Александрович','+375291254663', '+375173756829');
INSERT INTO delegate_co(fio, work_phone, home_phone) VALUES('Артем Кириллов Игоревич','+375443187253', '+375179435720');

INSERT ALL
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(1, 'Агрострой ПТ', 1,'933546879','Фроликова 29-2')
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(2, 'Сиба-Вендинг', 3,'998765412','Казинца 13-25')
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(3, 'Промбай Абразив', 4,'925846135','Независимости 118-12')
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(4, 'Алмаз Протрейд', 5,'996374185','Чкалова 15-17')
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(5, 'Спецтех', 6,'931265497','Монтажников 7-2')
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(6, 'Велес-макс ЧТУП',7,'953764976','Некрасова 37/1-9')
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(7, 'Эсприт', 8,'937618244','Бехтерева 7-13')
    INTO company(id_co, name_co, id_del, code_unn, adress) VALUES(8, 'Амелик', 9,'968425796','Ботаническая 10-3')
SELECT * FROM dual;

INSERT ALL
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(1,'Замыкающий вентиль', 'Стройматериалы',115)
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(2,'Видеокарта', 'Комьютерная техника',650)
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(3,'Краска ПФ-115', 'Стройматериалы',32)
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(4,'Жесткий диск', 'Комьютерная техника',300)
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(5,'Микроскоп', 'Научная техника',9925)
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(6,'Трубы пластиковы', 'Стройматериалы',650)
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(7,'Центрифуга', 'Научная техника',5920)
    INTO products(id_products, name_pro, descr, cost_pro) VALUES(8,'Ноутбук', 'Комьютерная техника',2575)
SELECT * FROM dual;

INSERT ALL
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(1, '1', 'Помещение № 1',300,900)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(2, '1', 'Помещение № 2',300,900)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(3, '1', 'Помещение № 3',350,950)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(4, '2', 'Помещение № 4',250,800)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(5, '2', 'Помещение № 5',150,300)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(6, '2', 'Помещение № 6',250,800)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(7, '2', 'Помещение № 7',250,800)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(8, '3', 'Помещение № 8',120,550)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(9, '3', 'Помещение № 9',100,500)
    INTO place_for_rent(id_pl, flor, name_pl, cost_nm, square) VALUES(10,'3', 'Помещение № 10',150,700)
SELECT * FROM dual;

INSERT ALL
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(1,1,1,1)
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(2,3,2,3)
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(3,10,3,1)
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(4,9,4,3)
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(5,2,5,2)
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(6,6,6,1)
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(7,5,7,2)
    INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(8,7,8,3)
SELECT * FROM dual;

INSERT ALL
    INTO exibitions(id_ex, topic, start_date, end_date) VALUES(1, 'Строительная выставка',TO_DATE('01.09.2022', 'dd.mm.yyyy'),TO_DATE('20.10.2022', 'dd.mm.yyyy'))
    INTO exibitions(id_ex, topic, start_date, end_date) VALUES(2, 'Научная техника',TO_DATE('15.09.2022', 'dd.mm.yyyy'),TO_DATE('30.09.2022', 'dd.mm.yyyy'))
    INTO exibitions(id_ex, topic, start_date, end_date) VALUES(3, 'Комьютерная техника',TO_DATE('01.09.2022', 'dd.mm.yyyy'),TO_DATE('15.09.2022', 'dd.mm.yyyy'))
 SELECT * FROM dual;
