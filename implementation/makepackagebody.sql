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
   */
  "INVALID_OPERATION" EXCEPTION;  -- OPERATION IS INVALID
  "TRANSIENT_ERROR"   EXCEPTION;  -- TRANSIENT SERVER ERROR IN 400 RANGE
  "PERMANENT_ERROR"   EXCEPTION;  -- PERMANENT SERVER ERROR IN 500 RANGE
  INVALID_OPERATION_ERRCODE CONSTANT PLS_INTEGER:= -14170;
  TRANSIENT_ERROR_ERRCODE   CONSTANT PLS_INTEGER:= -14171;
  PERMANENT_ERROR_ERRCODE   CONSTANT PLS_INTEGER:= -14172;

  
  PRAGMA EXCEPTION_INIT(INVALID_OPERATION, -14170);
  PRAGMA EXCEPTION_INIT(TRANSIENT_ERROR,   -14171);
  PRAGMA EXCEPTION_INIT(PERMANENT_ERROR,   -14172); 


  PROCEDURE WRITE_COMMAND_LINE(C IN OUT NOCOPY CONNECTION,
                               COMMAND IN VARCHAR2,
                               DATA IN VARCHAR2)
  IS
   rc PLS_INTEGER;
   msg VARCHAR2(100);
  BEGIN
   IF DATA IS NULL THEN
    msg := COMMAND || DATA;
   ELSE
    msg := COMMAND || ' ' || DATA;
   END IF;
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
    RAISE_APPLICATION_ERROR(-20001, 'ERROR: REPLY DOES NOT EXIST');
   WHEN UTL_TCP.NETWORK_ERROR THEN
    RAISE_APPLICATION_ERROR(-20002, 'ERROR: NETWORK ERROR');
  END;

  PROCEDURE GET_REPLY(C IN OUT NOCOPY CONNECTION)
  IS
   msg VARCHAR2(508);
  BEGIN
   msg := UTL_TCP.GET_LINE(C.private_tcp_con);
  EXCEPTION
   WHEN UTL_TCP.END_OF_INPUT THEN
    RAISE_APPLICATION_ERROR(-20001, 'ERROR: REPLY DOES NOT EXIST');
   WHEN UTL_TCP.NETWORK_ERROR THEN
    RAISE_APPLICATION_ERROR(-20002, 'ERROR: NETWORK ERROR');
  END;

  PROCEDURE GET_REPLIES(C IN OUT NOCOPY CONNECTION, reps OUT REPLIES, repslen OUT BINARY_INTEGER) 
  IS
   i BINARY_INTEGER := 1;
   tmp VARCHAR2(508);
  BEGIN
   LOOP 
    tmp := UTL_TCP.GET_LINE(C.private_tcp_con, FALSE, TRUE);
    reps(i) := GET_REPLY(C);
    i := i + 1;
   END LOOP;
  EXCEPTION
   WHEN OTHERS THEN
    repslen := i - 1;
  END;
   
  FUNCTION GET_LAST_REPLY(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
   reps replies;
   repslen BINARY_INTEGER;
  BEGIN
   GET_REPLIES(C, reps, repslen);
   RETURN reps(repslen);
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
   c_tcp := UTL_TCP.OPEN_CONNECTION(HOST, PORT, TX_TIMEOUT);
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
   c_tcp := UTL_TCP.OPEN_CONNECTION(HOST, PORT, TX_TIMEOUT);
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
   WRITE_COMMAND_LINE(C, 'HELO', DOMAIN);
   RETURN GET_LAST_REPLY(C);
  END;
  

  PROCEDURE "HELO"(C       IN OUT NOCOPY CONNECTION,
                   DOMAIN  IN            VARCHAR2)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'HELO', DOMAIN);
   GET_REPLY(C);
  END;


  FUNCTION "EHLO"(C       IN OUT NOCOPY CONNECTION,
                  DOMAIN  IN            VARCHAR2) RETURN REPLIES
  IS
   reps replies;
   repslen BINARY_INTEGER;
  BEGIN
   WRITE_COMMAND_LINE(C, 'EHLO', DOMAIN);
   GET_REPLIES(C, reps, repslen);
   RETURN reps;
  END;
   

  PROCEDURE "EHLO"(C       IN OUT NOCOPY CONNECTION,
                   DOMAIN  IN            VARCHAR2)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'EHLO', DOMAIN);
   GET_REPLY(C);
  END;


  FUNCTION "MAIL"(C          IN OUT NOCOPY CONNECTION,
                  SENDER     IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'MAIL FROM:', SENDER);
   RETURN GET_LAST_REPLY(C);
  END;


  PROCEDURE "MAIL"(C          IN OUT NOCOPY CONNECTION,
                   SENDER     IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'MAIL FROM:', SENDER);
   GET_REPLY(C);
  END;


  FUNCTION "RCPT"(C          IN OUT NOCOPY CONNECTION,
                  RECIPIENT  IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY
  IS
  BEGIN
    WRITE_COMMAND_LINE(C, 'RCPT TO:', RECIPIENT);
   RETURN GET_LAST_REPLY(C);
  END;


  PROCEDURE "RCPT"(C          IN OUT NOCOPY CONNECTION,
                   RECIPIENT  IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'RCPT TO:', RECIPIENT);
   GET_REPLY(C);
  END;


  FUNCTION "DATA"(C     IN OUT NOCOPY CONNECTION,
                  "BODY"  IN            VARCHAR2 )
                  RETURN REPLY
  IS
   rc PLS_INTEGER;
   rep reply;
  BEGIN
   OPEN_DATA(C);
   rc := UTL_TCP.WRITE_TEXT(C.private_tcp_con, "BODY" || UTL_TCP.CRLF);
   CLOSE_DATA(C);
   rep := GET_LAST_REPLY(C);
   RETURN rep;
  END;


  PROCEDURE "DATA"(C     IN OUT NOCOPY CONNECTION,
                   "BODY"  IN            VARCHAR2 )
  IS
   rc PLS_INTEGER;
  BEGIN
   OPEN_DATA(C);
   rc := UTL_TCP.WRITE_TEXT(C.private_tcp_con, "BODY" || UTL_TCP.CRLF);
   CLOSE_DATA(C);
   GET_REPLY(C);
  END;


  FUNCTION "OPEN_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY 
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'DATA', NULL);
   C.private_state := 1;
   RETURN GET_LAST_REPLY(C);
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
    rc := UTL_TCP.WRITE_TEXT(C.private_tcp_con, DATA);
   ELSE
    RAISE_APPLICATION_ERROR(-20000, 'ERROR: DATA NOT OPENED');
   END IF;
  END; 

PROCEDURE "WRITE_RAW_DATA"(C     IN OUT NOCOPY CONNECTION,
                            DATA  IN            RAW)
IS
   rc PLS_INTEGER;
  BEGIN
   IF C.private_state = 1 THEN 
    rc := UTL_TCP.WRITE_RAW(C.private_tcp_con, DATA);
   ELSE
    RAISE_APPLICATION_ERROR(-20000, 'ERROR: DATA NOT OPENED');
   END IF;
  END; 

  FUNCTION "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
  BEGIN
   IF C.private_state = 1 THEN
    WRITE_COMMAND_LINE(C, '.' ||  UTL_TCP.CRLF, NULL);
    C.private_state := NULL;
    RETURN GET_LAST_REPLY(C);
   ELSE
    RAISE_APPLICATION_ERROR(-20000, 'ERROR: DATA NOT OPENED');
    RETURN NULL;
   END IF;
  END;

  
  PROCEDURE "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION)
  IS
  BEGIN
   IF C.private_state = 1 THEN
    WRITE_COMMAND_LINE(C, '.' ||  UTL_TCP.CRLF, NULL);
    C.private_state := NULL;
    GET_REPLY(C);
   ELSE
    RAISE_APPLICATION_ERROR(-20000, 'ERROR: DATA NOT OPENED');
   END IF;
  END;


  FUNCTION "RSET"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'RSET', NULL);
   RETURN GET_LAST_REPLY(C);
  END;


  PROCEDURE "RSET"(C IN OUT NOCOPY CONNECTION)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'RSET', NULL);
   GET_REPLY(C);
  END;


  FUNCTION "VRFY"(C          IN OUT NOCOPY CONNECTION,
                  RECIPIENT  IN            VARCHAR2) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'VRFY', RECIPIENT);
   RETURN GET_LAST_REPLY(C);
  END;
   

  FUNCTION "NOOP"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'NOOP', NULL);
   RETURN GET_LAST_REPLY(C);
  END;


  PROCEDURE "NOOP"(C IN OUT NOCOPY CONNECTION)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'NOOP', NULL);
   GET_REPLY(C);
  END;


  FUNCTION "QUIT"(C IN OUT NOCOPY CONNECTION) RETURN REPLY
  IS
   rep reply;
  BEGIN
   WRITE_COMMAND_LINE(C, 'QUIT', NULL);
   rep := GET_LAST_REPLY(C);
   UTL_TCP.CLOSE_CONNECTION(C.private_tcp_con);
   RETURN rep;
  END;


  PROCEDURE "QUIT"(C IN OUT NOCOPY CONNECTION)
  IS
  BEGIN
   WRITE_COMMAND_LINE(C, 'QUIT', NULL);
   GET_REPLY(C);
   UTL_TCP.CLOSE_CONNECTION(C.private_tcp_con);
  END;

END;
/
