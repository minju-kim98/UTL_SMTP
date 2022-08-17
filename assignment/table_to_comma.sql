/*
	PROCEDURE "TABLE_TO_COMMA" (
		tab				    IN		UNCL_ARRAY,
		tablen				OUT		BINARY_INTEGER,
		list				OUT		VARCHAR2);

	PROCEDURE "TABLE_TO_COMMA" (
		tab				    IN		LNAME_ARRAY,
		tablen				OUT		BINARY_INTEGER,
		list				OUT		VARCHAR2);
*/

create or replace procedure TABLE_TO_COMMA(
  tab in DBMS_UTILITY.UNCL_ARRAY,
  tablen out BINARY_INTEGER,
  list out VARCHAR2
)
IS
begin
  tablen := tab.count;
  for i in 1..tablen loop
	list := list || tab(i) || ',';
  end loop;
  list := rtrim(list, ',');
end;
/


create or replace procedure TABLE_TO_COMMA(
  tab in DBMS_UTILITY.LNAME_ARRAY,
  tablen out BINARY_INTEGER,
  list out VARCHAR2
)
IS
begin
  tablen := tab.count;
  for i in 1..tablen loop
	list := list || tab(i) || ',';
  end loop;
  list := rtrim(list, ',');
end;
/
