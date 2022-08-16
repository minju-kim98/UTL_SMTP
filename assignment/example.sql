SET SERVEROUTPUT ON
DECLARE
  l_list1   VARCHAR2(50) := 'A,B,C,D,E,F,G,H,I,J';
  l_list2   VARCHAR2(50);
  l_tablen  BINARY_INTEGER;
  l_tab     DBMS_UTILITY.uncl_array;
BEGIN
  DBMS_OUTPUT.put_line('l_list1 : ' || l_list1);

  DBMS_UTILITY.comma_to_table (
     list   => l_list1,
     tablen => l_tablen,
     tab    => l_tab);

  FOR i IN 1 .. l_tablen LOOP
    DBMS_OUTPUT.put_line(i || ' : ' || l_tab(i));
  END LOOP;

  DBMS_UTILITY.table_to_comma (
     tab    => l_tab,
     tablen => l_tablen,
     list   => l_list2);

  DBMS_OUTPUT.put_line('l_list2 : ' || l_list2);
END;
/