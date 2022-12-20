/*Триггер 1*/
CREATE TABLE LOG1(operacia CHAR(6),
		username VARCHAR2(50),
		colonca VARCHAR2(30),
		old_value VARCHAR2(70),
    		new_value VARCHAR2(70),
		er_date TIMESTAMP);

CREATE OR REPLACE PROCEDURE dobavlenie_LOG(
				operacia_par IN CHAR,
				colonca_par IN VARCHAR2,			
				old_value_par IN VARCHAR2,		    
				new_value_par IN VARCHAR2) IS	
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
IF old_value_par != new_value_par OR operacia_par IN ('INSERT','DELETE')
	THEN
INSERT INTO LOG1 (operacia, username, colonca, old_value, new_value, er_date)
	VALUES (operacia_par, USER, colonca_par, old_value_par, new_value_par, SYSTIMESTAMP);
COMMIT;
END IF;
END;


CREATE OR REPLACE TRIGGER products_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON PRODUCTS
FOR EACH ROW
DECLARE
oper CHAR(6);
BEGIN
   CASE
      WHEN INSERTING THEN
oper:= 'INSERT';
dobavlenie_LOG( oper,  'NAME_PRO', NULL, :NEW.NAME_PRO);
dobavlenie_LOG(oper, 'DESCR', NULL, :NEW.DESCR);
dobavlenie_LOG( oper,  'COST_PRO', NULL, :NEW.COST_PRO);

 WHEN UPDATING('NAME_PRO') OR UPDATING('DESCR') OR UPDATING('COST_PRO')  THEN 
oper:='UPDATE';
dobavlenie_LOG ( oper,  'NAME_PRO',:OLD.NAME_PRO, NULL);
dobavlenie_LOG (oper,  'DESCR', :OLD.DESCR, :NEW.DESCR);
dobavlenie_LOG ( oper,  'COST_PRO', :OLD.COST_PRO, :NEW.COST_PRO);
      WHEN DELETING THEN
oper:='DELETE';
dobavlenie_LOG ( oper,  'NAME_PRO', :OLD.NAME_PRO, NULL);
dobavlenie_LOG (oper,  'DESCR', :OLD.DESCR, NULL);
dobavlenie_LOG ( oper, 'COST_PRO', :OLD.COST_PRO, NULL);

   ELSE
null;
   END CASE;
END products_log_trigger;


UPDATE PRODUCTS
SET cost_pro = 115
WHERE cost_pro = 2575;

DELETE FROM PRODUCTS
WHERE cost_pro = 1151;
 
SELECT * FROM LOG1 
select ER_DATE from LOG1;

/*Триггер 2*/

CREATE TABLE LOG2(
    operacia VARCHAR2(6),
    table_name VARCHAR2(20),
    username VARCHAR2(20),
    operacia_date DATE
);

CREATE OR REPLACE PROCEDURE dobavlenie_LOG2(
    						operacia_par IN CHAR,
    						table_name_par IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
IF operacia_par IN ('CREATE','ALTER','DROP')
THEN
INSERT INTO LOG2(operacia, table_name, username, operacia_date)
VALUES(operacia_par, table_name_par, USER, SYSDATE);
COMMIT;
END IF;
END;

CREATE OR REPLACE TRIGGER LOG2_TRIGGER
BEFORE CREATE OR ALTER OR DROP
ON SCHEMA
DECLARE
oper VARCHAR2(6);
sysevent_par VARCHAR(10);
table_par VARCHAR(20);
BEGIN 
IF to_number(to_char(SYSDATE, 'hh24')) BETWEEN 1 AND 20
THEN
    RAISE_APPLICATION_ERROR(
        NUM => -20000,
        MSG => 'В это время недоступно');
ELSE
SELECT ORA_SYSEVENT INTO sysevent_par FROM dual;
SELECT ORA_DICT_OBJ_NAME INTO table_par FROM dual;
IF (sysevent_par  = 'CREATE')
THEN
dobavlenie_LOG2(sysevent_par, table_par);
ELSE NULL;
END IF;
IF (sysevent_par = 'ALTER')
THEN
dobavlenie_LOG2(sysevent_par, table_par);
ELSE NULL;
END IF;
IF (sysevent_par = 'DROP')
THEN
dobavlenie_LOG2(sysevent_par, table_par);
ELSE NULL;
END IF;
END IF;
END LOG2_TRIGGER;


/*Триггер 3*/
CREATE TABLE LOG3(
    username VARCHAR2(20),
    acivnost VARCHAR2(20),
    oper_date DATE,
    rows_kolvo INTEGER);

CREATE OR REPLACE PROCEDURE dobavlenie_LOG3(
    activnost_par IN VARCHAR2)
    IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    rows_amount NUMBER;
    BEGIN
        SELECT COUNT(*) INTO rows_amount FROM delegate_co;
        INSERT INTO LOG3
        VALUES(USER, activnost_par, SYSDATE, rows_amount);
        COMMIT;
    END;


CREATE OR REPLACE TRIGGER LOG3_IN_TRIGGER 
AFTER LOGON ON SCHEMA
BEGIN
    dobavlenie_LOG3(ORA_SYSEVENT);
END;


CREATE OR REPLACE TRIGGER LOG3_OUT_TRIGGER 
BEFORE LOGOFF ON SCHEMA
BEGIN
    dobavlenie_LOG3(ORA_SYSEVENT);
END;

SELECT * FROM LOG3


/*Триггер 4*/
/*1)При вставке данных в таблицу «RENT_PLACE» проверяет, не занято ли уже выставочное место на выбранной выставке в настоящее время*/
CREATE OR REPLACE TRIGGER control_place_ex
BEFORE INSERT
ON rent_place
FOR EACH ROW
DECLARE 
	place1 VARCHAR(100);
CURSOR Cur IS SELECT id_pl
FROM rent_place  
WHERE id_ex=:NEW.id_ex;  
BEGIN
OPEN Cur;
loop
FETCH Cur INTO place1;
IF (:NEW.id_pl = place1) THEN
		RAISE_APPLICATION_ERROR (num => -20008,msg => 'Место занято!');
      	END IF;
        EXIT WHEN Cur%NOTFOUND;
        END LOOP;
        CLOSE Cur;
END control_place_ex;


/*2)Контролировать даты проведения выставок: количество дней выставки не менее трех и время между выставками не менее трех дней.*/
CREATE OR REPLACE TRIGGER control_exibitions
BEFORE INSERT
ON exibitions
FOR EACH ROW
DECLARE 
	result_date INTERVAL DAY TO SECOND;
    a1 date;
 
BEGIN
SELECT max(end_date)
INTO a1  
FROM exibitions  ; 
IF  :NEW.END_DATE - :NEW.START_DATE <3 THEN
		RAISE_APPLICATION_ERROR (num => -20008,msg => 'Ваша выставка длится слишком мало времени. Минимальная длительность - 3 дня!');
ELSIF   :NEW.START_DATE - a1 <3 THEN
		RAISE_APPLICATION_ERROR (num => -20008,msg => 'Ещё не прошло три дня!');     
      	END IF;
END control_exibitions;




/*3)В дополнительной таблице обновлять информацию о количестве выставок по месячным интервалам.*/
месяц
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
  job_name => 'ydalenie_v_arhiv_JOB2',
  job_type => 'STORED_PROCEDURE',
  job_action => 'ydalenie_v_arhiv',
  start_date => TO_DATE('16.11.2022 12:00:00', 'DD.MM.YYYY HH24:MI:SS'),
  repeat_interval => 'FREQ=monthly; INTERVAL = 1;  BYmonthDAY=1',
  end_date => SYSTIMESTAMP + INTERVAL '24' MONTH,
  enabled => TRUE);
end;

CREATE TABLE uptable1
( Start_MN number(10) not null,
  End_MN number(10) not null,
  Count_ENT number(10) not null
);
минута
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
  job_name => 'up_date_table_MN',
  job_type => 'STORED_PROCEDURE',
  job_action => 'up_date_table',
  start_date => TO_DATE('11.12.2022 12:00:00', 'DD.MM.YYYY HH24:MI:SS'),
  repeat_interval => 'FREQ=MINUTELY; INTERVAL = 2',
  end_date => SYSTIMESTAMP + INTERVAL '24' MONTH,
  enabled => TRUE);
end;

CREATE OR REPLACE PROCEDURE up_date_table IS 
BEGIN
DELETE FROM uptable1;
INSERT INTO uptable1 (Start_MN, End_MN, Count_ENT)
(SELECT DAT,BAT, count(ex)
 From
(SELECT EXTRACT(MONTH FROM start_date) AS DAT, id_ex AS ex, EXTRACT(MONTH FROM end_date) AS BAT
FROM exibitions)
GROUP BY DAT, BAT);
END up_date_table;


/*Триггер 5*/
CREATE OR REPLACE TRIGGER update_cena_place
FOR UPDATE OF COST_PRO ON PRODUCTS
COMPOUND TRIGGER
    bUpdSalary boolean;
BEFORE EACH ROW IS
BEGIN
IF :new.COST_PRO = :old.COST_PRO * 1.15 AND :old.DESCR = 'Стройматериалы' THEN
    bUpdSalary := true;
END IF;
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
  IF bUpdSalary THEN
    UPDATE PRODUCTS
    SET COST_PRO = COST_PRO * 1.2
    WHERE DESCR = 'Научная техника';
END IF;
END AFTER STATEMENT;
END update_cena_place;



    
ALTER TRIGGER products_log_trigger ENABLE;
ALTER TRIGGER LOG2_TRIGGER ENABLE;
ALTER TRIGGER control_exibitions ENABLE;
ALTER TRIGGER control_place_ex ENABLE;
ALTER TRIGGER update_cena_place ENABLE;
ALTER TRIGGER update_delegate_company ENABLE;

/*Триггер 6*/

CREATE OR REPLACE VIEW delegate_company AS
SELECT fio, work_phone, home_phone, name_co
FROM delegate_co
JOIN company USING (id_del);


CREATE OR REPLACE TRIGGER update_delegate_company
INSTEAD OF UPDATE OR INSERT OR DELETE
ON delegate_company
FOR EACH ROW
BEGIN
    CASE
         WHEN DELETING THEN
        DELETE FROM delegate_co WHERE fio =:old.fio;
        WHEN UPDATING('fio') THEN
        IF :new.FIO <> :old.FIO THEN
        UPDATE delegate_co
        SET FIO = :new.FIO
        WHERE FIO = :old.FIO;
        END IF;
        WHEN UPDATING('work_phone') THEN
        IF :new.work_phone <> :old.work_phone THEN
            UPDATE delegate_co
            SET work_phone =:new.work_phone
            WHERE work_phone =:old.work_phone;
        END IF;
        WHEN UPDATING('home_phone') THEN
        IF :new.home_phone <> :old.home_phone THEN
            UPDATE delegate_co
            SET home_phone =:new.home_phone
            WHERE home_phone =:old.home_phone;
        END IF; 
    END CASE;
END;






/*Триггер 1 DML-триггер, регистрирующий изменение данных.*/
SELECT * FROM LOG1

INSERT INTO PRODUCTS (id_products, NAME_PRO, DESCR, COST_PRO) VALUES (102,'Дрель','Инструмент',500);

/*Триггер 2 DDL-триггер, протоколирующий действия пользователей по созданию, из-менению и удалению таблиц.*/
SELECT * FROM LOG2

CREATE TABLE test_2
( Start_MN number(10) not null,
  End_MN number(10) not null,
  Count_ENT number(10) not null
);

/*Триггер 3 Системный триггер, добавляющий запись во вспомогательную таблицу LOG3, когда пользователь подключается или отключается.*/
SELECT * FROM LOG3

/*Триггер 4.1 При вставке данных в таблицу «RENT_PLACE» проверяет, не занято ли уже выставочное место на выбранной выставке в настоящее время*/
SELECT * FROM rent_place

INSERT INTO rent_place(id_co, id_pl, id_products, id_ex) VALUES(5,3,2,1);

/*Триггер 4.2 Контролировать даты проведения выставок: количество дней выставки не менее трех и время между выставками не менее трех дней.*/
SELECT * FROM exibitions

INSERT INTO exibitions(id_ex, topic, start_date, end_date) VALUES(4, 'Строитеerльная выerставка',TO_DATE('25.11.2023', 'dd.mm.yyyy'),TO_DATE('27.11.2023', 'dd.mm.yyyy'));
INSERT INTO exibitions(id_ex, topic, start_date, end_date) VALUES(5, 'Строитеerльная выerставка',TO_DATE('22.11.2022', 'dd.mm.yyyy'),TO_DATE('28.11.2022', 'dd.mm.yyyy'));

/*Триггер 4.3 В дополнительной таблице обновлять информацию о количестве выставок по месячным интервалам.*/
SELECT * FROM uptable1

BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
  job_name => 'up_date_table_MC',
  job_type => 'STORED_PROCEDURE',
  job_action => 'up_date_table',
  start_date => TO_DATE('11.12.2022 12:00:00', 'DD.MM.YYYY HH24:MI:SS'),
  repeat_interval => 'FREQ=MINUTELY; INTERVAL = 1',
  end_date => SYSTIMESTAMP + INTERVAL '24' MONTH,
  enabled => TRUE);
end;

INSERT INTO exibitions(id_ex, topic, start_date, end_date) VALUES(6, 'Выставка новая',TO_DATE('25.11.2035', 'dd.mm.yyyy'),TO_DATE('28.11.2035', 'dd.mm.yyyy'));

/*Триггер 5 COMPAUND*/
SELECT * FROM PRODUCTS

UPDATE PRODUCTS
SET COST_PRO = COST_PRO * 1.15
WHERE DESCR = 'Стройматериалы';

/*Триггер 6 INSTEAD OF*/
SELECT * FROM  DELEGATE_CO
Проверки:
UPDATE delegate_company  SET fio = 'Роман Кравwe222wrцович Тимурович' where fio = 'Роман Кравwe22wrцович Тимурович';
UPDATE delegate_company  SET home_phone = '+375172929742' where home_phone = '+375172929749';
DELETE FROM delegate_company WHERE fio='Артем Кириллов Игоревич';