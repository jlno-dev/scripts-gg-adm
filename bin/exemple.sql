CREATE OR REPLACE PACKAGE test_api AS
  TYPE t_tab IS TABLE OF emp%ROWTYPE
    INDEX BY BINARY_INTEGER;

  PROCEDURE test1;
END;
/

CREATE OR REPLACE PACKAGE BODY test_api AS

  PROCEDURE test1 IS
    l_tab1 t_tab;
  BEGIN
    SELECT *
    BULK COLLECT INTO l_tab1
    FROM   emp
    WHERE  deptno = 10;

    DBMS_OUTPUT.put_line('Loop Through Collection');
    FOR cur_rec IN (SELECT *
                    FROM   TABLE(l_tab1))
    LOOP
      DBMS_OUTPUT.put_line(cur_rec.empno || ' : ' || cur_rec.ename);
    END LOOP;
  END;

END;
/