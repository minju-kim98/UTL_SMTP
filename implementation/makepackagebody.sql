CREATE OR REPLACE PACKAGE BODY "CLONE_UTL_SMTP" AS

  /*
   * SMTP connection type
   */
  TYPE connection IS RECORD (
    host             VARCHAR2(255),       -- Host name of SMTP server
    port             PLS_INTEGER,         -- Port number of SMTP server
    tx_timeout       PLS_INTEGER,         -- Transfer time-out (in seconds)
    private_tcp_con  utl_tcp.connection,  -- For internal use only
    private_state    PLS_INTEGER          -- For internal use only
  );

  /*
   * SMTP reply structure
   */
  TYPE reply IS RECORD (
    code     PLS_INTEGER,                 -- 3-digit reply code
    text     VARCHAR2(508)                -- reply text
  );
  -- multiple reply lines
  TYPE replies IS TABLE OF reply INDEX BY BINARY_INTEGER;

  /*
   * Exceptions
   
  "INVALID_OPERATION" EXCEPTION;  -- OPERATION IS INVALID
  "TRANSIENT_ERROR"   EXCEPTION;  -- TRANSIENT SERVER ERROR IN 400 RANGE
  "PERMANENT_ERROR"   EXCEPTION;  -- PERMANENT SERVER ERROR IN 500 RANGE
  INVALID_OPERATION_ERRCODE CONSTANT PLS_INTEGER:= -14170;
  TRANSIENT_ERROR_ERRCODE   CONSTANT PLS_INTEGER:= -14171;
  PERMANENT_ERROR_ERRCODE   CONSTANT PLS_INTEGER:= -14172;

  
  PRAGMA EXCEPTION_INIT(INVALID_OPERATION, -14170);
  PRAGMA EXCEPTION_INIT(TRANSIENT_ERROR,   -14171);
  PRAGMA EXCEPTION_INIT(PERMANENT_ERROR,   -14172); */


  PROCEDURE WRITE_COMMAND_LINE(C IN OUT NOCOPY CONNECTION,
                               COMMAND IN VARCHAR2,
                               DATA IN VARCHAR2)
  IS
   rc PLS_INTEGER;
   msg VARCHAR2(100) := COMMAND || DATA;
  BEGIN
   rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, msg);
  END;

  FUNCTION GET_REPLY(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
   msg VARCHAR2(508);
   codeChar VARCHAR2(3);
   code PLS_INTEGER;
   rep reply;
  BEGIN
   msg := UTL_TCP.GET_LINE(C.private_tcp_con); 
   codeChar := SUBSTR(msg, 1, 3);
   code := TO_NUMBER(codeChar);
   msg := SUBSTR(msg, 5);
   rep.code := code;
   rep.text := msg;
   RETURN rep;
  EXCEPTION
   WHEN UTL_TCP.END_OF_INPUT THEN
    DBMS_OUTPUT.PUT_LINE('UTL_TCP.END_OF_INPUT ERROR');
   WHEN UTL_TCP.NETWORK_ERROR THEN
    DBMS_OUTPUT.PUT_LINE('UTL_TCP.NETWORK_ERROR');
  END;

  PROCEDURE GET_REPLY(C IN OUT NOCOPY CONNECTION)
  IS
   msg VARCHAR2(508);
  BEGIN
   msg := UTL_TCP.GET_LINE(C.private_tcp_con);
  EXCEPTION
   WHEN UTL_TCP.END_OF_INPUT THEN
    DBMS_OUTPUT.PUT_LINE('UTL_TCP.END_OF_INPUT ERROR');
   WHEN UTL_TCP.NETWORK_ERROR THEN
    DBMS_OUTPUT.PUT_LINE('UTL_TCP.NETWORK_ERROR');
  END;


  FUNCTION "OPEN_CONNECTION"(HOST       IN  VARCHAR2,
                             PORT       IN  PLS_INTEGER DEFAULT 25,
                             C          OUT CONNECTION,
                             TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL)
                             RETURN REPLY
  IS
   c_smtp connection;
   c_tcp UTL_TCP.connection;
  BEGIN
   c_tcp := UTL_TCP.OPEN_CONNECTION(HOST, PORT);
   c_smtp.host := HOST;
   c_smtp.port := PORT;
   c_smtp.tx_timeout := TX_TIMEOUT;
   c_smtp.private_tcp_con := c_tcp;
   c_smtp.private_state := NULL;
   C := c_smtp;
   RETURN GET_REPLY(C);
  END;


  FUNCTION "OPEN_CONNECTION"(HOST       IN  VARCHAR2,
                             PORT       IN  PLS_INTEGER DEFAULT 25,
                             TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL)
                             RETURN CONNECTION
  IS
   c_smtp connection;
   c_tcp UTL_TCP.connection;
  BEGIN
   c_tcp := UTL_TCP.OPEN_CONNECTION(HOST, PORT);
   c_smtp.host := HOST;
   c_smtp.port := PORT;
   c_smtp.tx_timeout := TX_TIMEOUT;
   c_smtp.private_tcp_con := c_tcp;
   c_smtp.private_state := NULL;
   GET_REPLY(c_smtp);
   RETURN c_smtp;
  END;


  FUNCTION "HELO"(C       IN OUT NOCOPY CONNECTION,
                  DOMAIN  IN            VARCHAR2) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'HELO ', DOMAIN);
   RETURN GET_REPLY(C);
  END;
  

  PROCEDURE "HELO"(C       IN OUT NOCOPY CONNECTION,
                   DOMAIN  IN            VARCHAR2)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'HELO ', DOMAIN);
   GET_REPLY(C);
  END;


  FUNCTION "MAIL"(C          IN OUT NOCOPY CONNECTION,
                  SENDER     IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'MAIL FROM: ', SENDER);
   RETURN GET_REPLY(C);
  END;


  PROCEDURE "MAIL"(C          IN OUT NOCOPY CONNECTION,
                   SENDER     IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'MAIL FROM: ', SENDER);
   GET_REPLY(C);
  END;


  FUNCTION "RCPT"(C          IN OUT NOCOPY CONNECTION,
                  RECIPIENT  IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY
  IS
  BEGIN
    WRITE_COMMAND_LINE(C, 'RCPT TO: ', RECIPIENT);
   RETURN GET_REPLY(C);
  END;


  PROCEDURE "RCPT"(C          IN OUT NOCOPY CONNECTION,
                   RECIPIENT  IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'RCPT TO: ', RECIPIENT);
   GET_REPLY(C);
  END;


  FUNCTION "OPEN_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY 
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'DATA', NULL);
   C.private_state := 1;
   RETURN GET_REPLY(C);
  END;
 
  PROCEDURE "OPEN_DATA"(C IN OUT NOCOPY CONNECTION)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'DATA', NULL);
   C.private_state := 1;
   GET_REPLY(C);
  END;

  PROCEDURE "WRITE_DATA"(C     IN OUT NOCOPY CONNECTION,
                         DATA  IN            VARCHAR2 )
  IS
   rc PLS_INTEGER;
  BEGIN
   IF C.private_state = 1 THEN 
    rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, DATA);
   ELSE
    DBMS_OUTPUT.PUT_LINE('ERROR: DATA NOT OPENED');
   END IF;
  END; 

  FUNCTION "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, '.', NULL);
   C.private_state := NULL;
   RETURN GET_REPLY(C);
  END;

  
  PROCEDURE "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, '.', NULL);
   C.private_state := NULL;
   GET_REPLY(C);
  END;


  FUNCTION "QUIT"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'QUIT', NULL);
   UTL_TCP.CLOSE_CONNECTION(C.private_tcp_con);
   RETURN GET_REPLY(C);
  END;

  PROCEDURE "QUIT"(C IN OUT NOCOPY CONNECTION)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'QUIT', NULL);
   UTL_TCP.CLOSE_CONNECTION(C.private_tcp_con);
   GET_REPLY(C);
  END;

END;

/*
1. REPL
* reply 구조체를 가져오는 동작(tcp에서 get_line하는 동작을 통해 가져올 수 있습니다.)이 누락되어있습니다.
* REPLY가 오지 않아서 UTL_TCP.END_OF_INPUT나 UTL_TCP.NETWORK_ERROR 에러를 맞을 수 있는데 이에 대한 에러처리가 필요합니다.

2. (TODO) WRITE 동작 전에는 현재 DATA 상태가 어떤지 체크하는 로직을 넣었음 좋겠습니다.

3. 실제로 UTL_TCP.WRITE_LINE 에 넣는 데이터가 "COMMAND"+ " " + "내용" 요런 형태로 되어 있는데 이를 리팩토링해서 호출하는 프로시저 형태가 있음 좋겠습니다.

4. MAIL은 MAIL FROM: 요런 형태로 쓰셨는데, 내부적으론 MAIL 형태로 되어있네요 한번 찾아보심 좋을 것 같습니다.

5. WRITE_DATA만 많이 사용된 것 같은데, WRITE_TEXT 혹은 WRITE_LINE 등을 이용하는 방법도 있으니 비교해보면서 고민해보시면 좋을 것 같습니다.
   >> UTL_TCP에는 WRITE_DATA 함수가 없는데 중간부터 잠깐 착각했습니다. WRITE_TEXT보다는 WRITE_LINE이 적합하다고 생각하여 모두 이로 교체함.

참고: https://somahhh.tistory.com/213
*/