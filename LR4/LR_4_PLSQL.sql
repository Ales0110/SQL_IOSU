/*Процедура*/
CREATE OR REPLACE PROCEDURE V_1(pl IN NUMBER)  IS 
    CURSOR Cur IS
    SELECT   products.name_pro
    FROM rent_place
    INNER JOIN products  ON products.id_products = rent_place.id_products
    WHERE  id_pl = pl;
    vID VARCHAR(100);
    err_no_data EXCEPTION;
BEGIN
    OPEN Cur;
    LOOP
        FETCH Cur
        INTO vID;
        EXIT WHEN Cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Продукция: '||vID);
    END LOOP;
    CLOSE Cur;
    IF pl < 1 THEN
    RAISE err_no_data;
    END IF;
    EXCEPTION
		WHEN err_no_data THEN DBMS_OUTPUT.PUT_LINE('Номер выставочного места должен быть больше 0');
END;

BEGIN V_1(1); END;

/*Функция*/
CREATE OR REPLACE FUNCTION V_2
RETURN VARCHAR2  
IS 
    current_date TIMESTAMP;
    result_date INTERVAL DAY TO SECOND;
    a1 TIMESTAMP;
    a2 NUMBER;
    a3 VARCHAR(600);
BEGIN
SELECT max(end_date)
INTO a1  
FROM exibitions; 
current_date := SYSTIMESTAMP;
IF a1< current_date 
THEN  result_date:= current_date - a1;
    a3:=result_date;
    ELSIF a1 > current_date
    THEN  a3 := -1;
          END IF;
          RETURN ('Результат: '||a3);
EXCEPTION
WHEN TOO_MANY_ROWS THEN
DBMS_OUTPUT.PUT_LINE('Слишком много строк');
RETURN NULL;
END;    

BEGIN  DBMS_OUTPUT.PUT_LINE(V_2_EX); END;


/*Локальная процедура*/
CREATE OR REPLACE PROCEDURE local_F1(pl IN NUMBER)  IS 
  Update_price NUMBER;
    CURSOR Cur IS
    SELECT   products.NAME_PRO
    FROM rent_place
    INNER JOIN products  ON products.id_products = rent_place.id_products
    WHERE id_ex IN (SELECT id_ex FROM rent_place WHERE id_pl = pl);
    vID VARCHAR(100);
FUNCTION  vstavka (idpl IN NUMBER ) RETURN NUMBER  IS
   Old_price NUMBER;
	New_price NUMBER;
BEGIN
    SELECT COST_NM
	INTO Old_price
	FROM PLACE_FOR_RENT WHERE id_pl = idpl;
	New_price := 1.15 * Old_price;
	RETURN New_price;
END ;

BEGIN
    OPEN Cur;
    LOOP
        FETCH Cur
        INTO vID;
        EXIT WHEN Cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Продукция: '||vID);
    END LOOP;
    CLOSE Cur;
    Update_price := vstavka(pl);
	UPDATE PLACE_FOR_RENT SET COST_NM = Update_price WHERE id_pl = pl;
	COMMIT;
END;    


BEGIN local_F1(3); END;

/*Перегруженная функция*/
CREATE OR REPLACE PROCEDURE V_1(pl IN NUMBER, co IN NUMBER)  IS 
    CURSOR Cur IS
    SELECT   products.NAME_PRO
    FROM rent_place
    INNER JOIN products  ON products.id_products = rent_place.id_products
    WHERE  id_pl = pl AND id_co = co;
    vID VARCHAR(100);
BEGIN
    OPEN Cur;
    LOOP
        FETCH Cur
        INTO vID;
        EXIT WHEN Cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Продукция: '||vID);
    END LOOP;
    CLOSE Cur;
END;    

BEGIN V_1(6,6); END;

/*Пакет*/

CREATE OR REPLACE PACKAGE my_package IS
PROCEDURE V_1(pl IN NUMBER);
FUNCTION V_2 RETURN VARCHAR2;	
PROCEDURE local_F1(pl IN NUMBER);
PROCEDURE V_1(pl IN NUMBER, co IN NUMBER);
END my_package;
CREATE OR REPLACE PACKAGE BODY my_package IS

/*Процедура*/
PROCEDURE V_1(pl IN NUMBER)  IS 
    CURSOR Cur IS
    SELECT   products.name_pro
    FROM rent_place
    INNER JOIN products  ON products.id_products = rent_place.id_products
    WHERE  id_pl = pl;
    vID VARCHAR(100);
    err_no_data EXCEPTION;
BEGIN
    OPEN Cur;
    LOOP
        FETCH Cur
        INTO vID;
        EXIT WHEN Cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Продукция: '||vID);
    END LOOP;
    CLOSE Cur;
    IF pl < 1 THEN
    RAISE err_no_data;
    END IF;
    EXCEPTION
		WHEN err_no_data THEN DBMS_OUTPUT.PUT_LINE('Номер выставочного места должен быть больше 0');
END;


/*Функция*/
FUNCTION V_2
RETURN VARCHAR2  
IS 
    current_date TIMESTAMP;
    result_date INTERVAL DAY TO SECOND;
    a1 TIMESTAMP;
    a2 NUMBER;
    a3 VARCHAR(600);
BEGIN
SELECT max(end_date)
INTO a1  
FROM exibitions  ; 
current_date := SYSTIMESTAMP;
IF a1< current_date 
THEN  result_date:= current_date - a1;
    a3:=result_date;
    ELSIF a1>current_date
    THEN  a3 := -1;
          END IF;
          RETURN ('Результат: '||a3);
EXCEPTION
WHEN TOO_MANY_ROWS THEN
DBMS_OUTPUT.PUT_LINE('Слишком много строк');
RETURN NULL;
END;    


/*Локальная процедура*/
PROCEDURE local_F1(pl IN NUMBER)  IS 
  Update_price NUMBER;
    CURSOR Cur IS
    SELECT   products.NAME_PRO
    FROM rent_place
    INNER JOIN products  ON products.id_products = rent_place.id_products
    WHERE id_ex IN (SELECT id_ex FROM rent_place WHERE id_pl = pl);
    vID VARCHAR(100);
FUNCTION  vstavka (idpl IN NUMBER ) RETURN NUMBER  IS
   Old_price NUMBER;
	New_price NUMBER;
BEGIN
    SELECT COST_NM
	INTO Old_price
	FROM PLACE_FOR_RENT WHERE id_pl = idpl;
	New_price := 1.15 * Old_price;
	RETURN New_price;
END ;

BEGIN
    OPEN Cur;
    LOOP
        FETCH Cur
        INTO vID;
        EXIT WHEN Cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Продукция: '||vID);
    END LOOP;
    CLOSE Cur;
    Update_price := vstavka(pl);
	UPDATE PLACE_FOR_RENT SET COST_NM = Update_price WHERE id_pl = pl;
	COMMIT;
END;    

/*Перегруженная функция*/
 PROCEDURE V_1(pl IN NUMBER, co IN NUMBER)  IS 
    CURSOR Cur IS
    SELECT   products.NAME_PRO
    FROM rent_place
    INNER JOIN products  ON products.id_products = rent_place.id_products
    WHERE  id_pl = pl AND id_co = co;
    vID VARCHAR(100);
BEGIN
    OPEN Cur;
    LOOP
        FETCH Cur
        INTO vID;
        EXIT WHEN Cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Продукция: '||vID);
    END LOOP;
    CLOSE Cur;
END;    
END my_package;

/*Анонимный блок*/
BEGIN
DBMS_OUTPUT.PUT_LINE('--------------------ПРОЦЕДУРА-----------------------------');
my_package.V_1(3);
DBMS_OUTPUT.PUT_LINE('------------ошибка-----------');
my_package.V_1(0);
DBMS_OUTPUT.PUT_LINE('--------------------ФУНКЦИЯ-------------------------------'); 
DBMS_OUTPUT.PUT_LINE(my_package.V_2);
DBMS_OUTPUT.PUT_LINE('------------ошибка-----------');
DBMS_OUTPUT.PUT_LINE(V_2_EX);
DBMS_OUTPUT.PUT_LINE('--------------------ЛОКАЛЬНАЯ ФУНКЦИЯ-------------------');
my_package.local_F1(8);
DBMS_OUTPUT.PUT_LINE('--------------------ПЕРЕГРУЖЕННАЯ ПРОЦЕДУРА---------------');
my_package.V_1(6,6);
--my_package.V_1(6,2);
END;