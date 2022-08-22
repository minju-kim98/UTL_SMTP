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

  FUNCTION "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY;
  PROCEDURE "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION);


  FUNCTION "QUIT"(C IN OUT NOCOPY CONNECTION) RETURN REPLY;
  PROCEDURE "QUIT"(C IN OUT NOCOPY CONNECTION);

END;