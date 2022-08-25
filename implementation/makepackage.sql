CREATE OR REPLACE PACKAGE "CLONE_UTL_SMTP" AUTHID CURRENT_USER AS

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

  
 

  FUNCTION "OPEN_CONNECTION"(HOST       IN  VARCHAR2,
                             PORT       IN  PLS_INTEGER DEFAULT 25,
                             C          OUT CONNECTION,
                             TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL)
                             RETURN REPLY;
  FUNCTION "OPEN_CONNECTION"(HOST       IN  VARCHAR2,
                             PORT       IN  PLS_INTEGER DEFAULT 25,
                             TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL)
                             RETURN CONNECTION;

  /*FUNCTION "COMMAND"(C    IN OUT NOCOPY CONNECTION,
                     CMD  IN            VARCHAR2,
                     ARG  IN            VARCHAR2 DEFAULT NULL)
                     RETURN REPLY;
  PROCEDURE "COMMAND"(C     IN OUT NOCOPY CONNECTION,
                      CMD   IN            VARCHAR2,
                      ARG   IN            VARCHAR2 DEFAULT NULL);
 
  FUNCTION "COMMAND_REPLIES"(C     IN OUT NOCOPY CONNECTION,
                             CMD   IN            VARCHAR2,
                             ARG   IN            VARCHAR2 DEFAULT NULL)
                             RETURN REPLIES;*/

  FUNCTION "HELO"(C       IN OUT NOCOPY CONNECTION,
                  DOMAIN  IN            VARCHAR2) RETURN REPLY;
  PROCEDURE "HELO"(C       IN OUT NOCOPY CONNECTION,
                   DOMAIN  IN            VARCHAR2);

  FUNCTION "EHLO"(C       IN OUT NOCOPY CONNECTION,
                  DOMAIN  IN            VARCHAR2) RETURN REPLIES;
  PROCEDURE "EHLO"(C       IN OUT NOCOPY CONNECTION,
                   DOMAIN  IN            VARCHAR2);

  FUNCTION "MAIL"(C          IN OUT NOCOPY CONNECTION,
                  SENDER     IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY;
  PROCEDURE "MAIL"(C          IN OUT NOCOPY CONNECTION,
                   SENDER     IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL);

  FUNCTION "RCPT"(C          IN OUT NOCOPY CONNECTION,
                  RECIPIENT  IN            VARCHAR2,
                  PARAMETERS IN            VARCHAR2 DEFAULT NULL) RETURN REPLY;
  PROCEDURE "RCPT"(C          IN OUT NOCOPY CONNECTION,
                   RECIPIENT  IN            VARCHAR2,
                   PARAMETERS IN            VARCHAR2 DEFAULT NULL);

  /*FUNCTION "DATA"(C     IN OUT NOCOPY CONNECTION,
                  "BODY"  IN            VARCHAR2 )
                  RETURN REPLY;
  PROCEDURE "DATA"(C     IN OUT NOCOPY CONNECTION,
                   "BODY"  IN            VARCHAR2 );*/

  FUNCTION "OPEN_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY;
 
  PROCEDURE "OPEN_DATA"(C IN OUT NOCOPY CONNECTION);

  PROCEDURE "WRITE_DATA"(C     IN OUT NOCOPY CONNECTION,
                         DATA  IN            VARCHAR2 );
  /*PROCEDURE "WRITE_RAW_DATA"(C     IN OUT NOCOPY CONNECTION,
                             DATA  IN            RAW);*/

  FUNCTION "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION) RETURN REPLY;
  PROCEDURE "CLOSE_DATA"(C IN OUT NOCOPY CONNECTION);

  FUNCTION "RSET"(C IN OUT NOCOPY CONNECTION) RETURN REPLY;
  PROCEDURE "RSET"(C IN OUT NOCOPY CONNECTION);

  FUNCTION "VRFY"(C          IN OUT NOCOPY CONNECTION,
                  RECIPIENT  IN            VARCHAR2) RETURN REPLY;

  FUNCTION "HELP"(C        IN OUT NOCOPY CONNECTION,
                  COMMAND  IN            VARCHAR2 DEFAULT NULL) RETURN REPLIES;

  FUNCTION "NOOP"(C IN OUT NOCOPY CONNECTION) RETURN REPLY;
  PROCEDURE "NOOP"(C IN OUT NOCOPY CONNECTION);

  FUNCTION "QUIT"(C IN OUT NOCOPY CONNECTION) RETURN REPLY;
  PROCEDURE "QUIT"(C IN OUT NOCOPY CONNECTION);

END;
/
