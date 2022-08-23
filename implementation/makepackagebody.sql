CREATE OR REPLACE PACKAGE "CLONE_UTL_SMTP" BODY AUTHID CURRENT_USER AS

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
   */
  "INVALID_OPERATION" EXCEPTION;  -- OPERATION IS INVALID
  "TRANSIENT_ERROR"   EXCEPTION;  -- TRANSIENT SERVER ERROR IN 400 RANGE
  "PERMANENT_ERROR"   EXCEPTION;  -- PERMANENT SERVER ERROR IN 500 RANGE
  INVALID_OPERATION_ERRCODE CONSTANT PLS_INTEGER:= -14170;
  TRANSIENT_ERROR_ERRCODE   CONSTANT PLS_INTEGER:= -14171;
  PERMANENT_ERROR_ERRCODE   CONSTANT PLS_INTEGER:= -14172;

  /* TODO */
  PRAGMA EXCEPTION_INIT(INVALID_OPERATION, -14170);
  PRAGMA EXCEPTION_INIT(TRANSIENT_ERROR,   -14171);
  PRAGMA EXCEPTION_INIT(PERMANENT_ERROR,   -14172); 

  FUNCTION "OPEN_CONNECTION"(HOST       IN  VARCHAR2,
                             PORT       IN  PLS_INTEGER DEFAULT 25,
                             C          OUT CONNECTION,
                             TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL)
                             RETURN REPLY
  IS
   c_smtp CLONE_UTL_SMTP.connection
   c_tcp UTL_TCP.connection
  BEGIN
   c_tcp := UTL_TCP.OPEN_CONNECTION(HOST, PORT);
   c_smtp := connection(
    host => HOST,
    port => PORT,
    tx_timeout => TX_TIMEOUT,
    private_tcp_con => c_tcp,
    private_state => NULL
   )
   C := c_smtp;
   /*TODO*/
   RETURN NULL;
  END;


  FUNCTION "OPEN_CONNECTION"(HOST       IN  VARCHAR2,
                             PORT       IN  PLS_INTEGER DEFAULT 25,
                             TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL)
                             RETURN CONNECTION
  IS
   c_smtp CLONE_UTL_SMTP.connection
   c_tcp UTL_TCP.connection
  BEGIN
   c_tcp := UTL_TCP.OPEN_CONNECTION(HOST, PORT);
   c_smtp := connection(
    host => HOST,
    port => PORT,
    tx_timeout => TX_TIMEOUT,
    private_tcp_con => c_tcp,
    private_state => NULL
   )
   RETURN c_smtp;
  END;


  FUNCTION "HELO"(C       IN OUT NOCOPY CONNECTION,
                  DOMAIN  IN            VARCHAR2) RETURN REPLY
  IS
   msg VARCHAR2(100) := 'HELO ';
   rc PLS_INTEGER;
  BEGIN
   msg := msg || DOMAIN;
   rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, msg);
   /*TODO*/
   RETURN NULL;
  END;
  

  PROCEDURE "HELO"(C       IN OUT NOCOPY CONNECTION,
                   DOMAIN  IN            VARCHAR2)
  IS
   msg VARCHAR2(100) := 'HELO ';
   rc PLS_INTEGER;
  BEGIN
   msg := msg || DOMAIN;
   rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, msg);
  END;


  FUNCTION "MAIL"(C          IN OUT NOCOPY CONNECTION,
                  SENDER     IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY
  IS
   msg VARCHAR2(100) := 'MAIL FROM: ';
   rc PLS_INTEGER;
  BEGIN
   msg := msg || SENDER;
   rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, msg);
   /*TODO*/
   RETURN NULL;
  END;


  PROCEDURE "MAIL"(C          IN OUT NOCOPY CONNECTION,
                   SENDER     IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL)
  IS
   msg VARCHAR2(100) := 'MAIL FROM: ';
   rc PLS_INTEGER;
  BEGIN
   msg := msg || SENDER;
   rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, msg);
  END;


  FUNCTION "RCPT"(C          IN OUT NOCOPY CONNECTION,
                  RECIPIENT  IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY
  IS
   msg VARCHAR2(100) := 'RCPT TO: ';
   rc PLS_INTEGER;
  BEGIN
   msg := msg || RECIPIENT;
   rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, msg);
   /*TODO*/
   RETURN NULL;
  END;


  PROCEDURE "RCPT"(C          IN OUT NOCOPY CONNECTION,
                   RECIPIENT  IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL)
  IS
   msg VARCHAR2(100) := 'RCPT TO: ';
   rc PLS_INTEGER;
  BEGIN
   msg := msg || RECIPIENT;
   rc := UTL_TCP.WRITE_LINE(C.private_tcp_con, msg);
  END;


  FUNCTION "OPEN_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY 
  IS
   rc PLS_INTEGER;
  BEGIN
   rc := UTL_TCP.WRITE_DATA(C.private_tcp_con, 'DATA');
   C.private_state := 1;
   /*TODO*/
   RETURN NULL;
  END;
 
  PROCEDURE "OPEN_DATA"(C IN OUT NOCOPY CONNECTION)
  IS
   rc PLS_INTEGER;
  BEGIN
   rc := UTL_TCP.WRITE_DATA(C.private_tcp_con, 'DATA');
   C.private_state := 1;
  END;

  PROCEDURE "WRITE_DATA"(C     IN OUT NOCOPY CONNECTION,
                         DATA  IN            VARCHAR2 )
  IS
   rc PLS_INTEGER;
  BEGIN
   IF C.private_state = 1 THEN 
    rc := UTL_TCP.WRITE_DATA(C.private_tcp_con, DATA);
   ELSE
    /*TODO*/
   END IF;
  END; 

  FUNCTION "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
   rc PLS_INTEGER;
  BEGIN
   rc := UTL_TCP.WRITE_DATA(C.private_tcp_con, '.');
   C.private_state := NULL;
   /*TODO*/
   RETURN NULL;
  END;

  
  PROCEDURE "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION)
  IS
   rc PLS_INTEGER;
  BEGIN
   rc := UTL_TCP.WRITE_DATA(C.private_tcp_con, '.');
   C.private_state := NULL;
  END;


  FUNCTION "QUIT"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
   rc PLS_INTEGER;
  BEGIN
   rc := UTL_TCP.WRITE_DATA(C.private_tcp_con, 'QUIT');
   UTL_TCP.CLOSE_CONNECTION(C.private_tcp_con);
   /*TODO*/
   RETURN NULL;
  END;

  PROCEDURE "QUIT"(C IN OUT NOCOPY CONNECTION)
  IS
   rc PLS_INTEGER;
  BEGIN
   rc := UTL_TCP.WRITE_DATA(C.private_tcp_con, 'QUIT');
   UTL_TCP.CLOSE_CONNECTION(C.private_tcp_con);
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

참고: https://somahhh.tistory.com/213
*/