/*
    PROCEDURE "COMMA_TO_TABLE" (
		list				IN		VARCHAR2,
		tablen				OUT		BINARY_INTEGER,
		tab				    OUT		UNCL_ARRAY);
	
    PROCEDURE "COMMA_TO_TABLE" (
		list				IN		VARCHAR2,
		tablen				OUT		BINARY_INTEGER,
		tab					OUT		LNAME_ARRAY);
*/

CREATE OR REPLACE PROCEDURE COMMA_TO_TABLE (
 list IN VARCHAR2,
 tablen OUT BINARY_INTEGER,
 tab OUT DBMS_UTILITY.uncl_array)
IS
 i BINARY_INTEGER := 1;
 index_start PLS_INTEGER := 1;
BEGIN
 WHILE INSTR(list, ',', 1, i) != 0 LOOP
  tab(i) := SUBSTR(list, index_start, INSTR(list, ',', 1, i) - index_start);
  index_start := INSTR(list, ',', 1, i) + 1;
  i := i + 1; 
  END LOOP;
 tab(i) := SUBSTR(list, index_start);
 tablen := i;
END;