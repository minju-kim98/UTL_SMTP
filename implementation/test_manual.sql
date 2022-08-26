SET SERVEROUTPUT ON

DECLARE
   t_host VARCHAR2(30) := 'localhost';
   t_port NUMBER := 25;
   t_domain VARCHAR2(30) := 'tmax.co.kr';

   t_from VARCHAR2(50) := 'tibero@tmax.co.kr';
   t_to VARCHAR2(50) := 'ducco705@snu.ac.kr';
   t_intro VARCHAR2(50) := 'This is mail from TMAX';
   l_encoded_username VARCHAR2(1000);
   l_encoded_password VARCHAR2(1000);
   c CLONE_UTL_SMTP.connection;
   reply_rset CLONE_UTL_SMTP.reply;
   reply_vrfy CLONE_UTL_SMTP.reply;

  BEGIN
    c := CLONE_UTL_SMTP.OPEN_CONNECTION(
      HOST => t_host,
      PORT => t_port,
      TX_TIMEOUT => 2);
    reply_vrfy := CLONE_UTL_SMTP.vrfy(c, 'ducco705@snu.ac.kr');

    dbms_output.put_line('vrfy:'||reply_vrfy.code);
    dbms_output.put_line('vrfy:'||reply_vrfy.text);

    reply_rset := CLONE_UTL_SMTP.rset(c);
    dbms_output.put_line('rset:'||reply_rset.code);
    dbms_output.put_line('rset:'||reply_rset.text);

    CLONE_UTL_SMTP.HELO(c, t_domain);
    CLONE_UTL_SMTP.NOOP(c);
    CLONE_UTL_SMTP.MAIL(c, t_from);
    CLONE_UTL_SMTP.RCPT(c, t_to);

    CLONE_UTL_SMTP.OPEN_DATA(c);
    CLONE_UTL_SMTP.WRITE_DATA(c,'From:' || '"tibero" <tibero@tmax.co.kr>' || UTL_TCP.CRLF);
    CLONE_UTL_SMTP.WRITE_DATA(c,'To: ' || '"minju_kim" <ducco705@snu.ac.kr>' || UTL_TCP.CRLF);
    CLONE_UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF);
    CLONE_UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF);
    CLONE_UTL_SMTP.WRITE_DATA(c,'THIS IS SMTP_TEST1' || UTL_TCP.CRLF);
    CLONE_UTL_SMTP.WRITE_RAW_DATA( c, UTL_RAW.CAST_TO_RAW(''|| t_intro||''|| UTL_TCP.CRLF));
    CLONE_UTL_SMTP.CLOSE_DATA(c);
    CLONE_UTL_SMTP.QUIT(c);

  EXCEPTION
    WHEN CLONE_UTL_SMTP.transient_error OR CLONE_UTL_SMTP.permanent_error THEN
      BEGIN
        CLONE_UTL_SMTP.QUIT(c);
      EXCEPTION
        WHEN CLONE_UTL_SMTP.TRANSIENT_ERROR OR CLONE_UTL_SMTP.PERMANENT_ERROR THEN
          NULL;
      END;
      raise_application_error(-20000,
        'Failed to send mail due to the following error: ' || sqlerrm);
  END;
  /


CREATE OR REPLACE PROCEDURE send_email
      ( sender    IN VARCHAR2,
        recipient IN VARCHAR2,
        message   IN VARCHAR2)
      AS      
        mailhost VARCHAR2(100) := 'localhost';
        c CLONE_UTL_SMTP.connection;
      BEGIN
         c := CLONE_UTL_SMTP.open_connection(
          HOST => mailhost,
          PORT => 25,
          TX_TIMEOUT => 2); 
         CLONE_UTL_SMTP.helo(c,mailhost); 
         CLONE_UTL_SMTP.mail(c,sender); 
         CLONE_UTL_SMTP.rcpt(c,recipient); 
         CLONE_UTL_SMTP.data(c, message); 
         CLONE_UTL_SMTP.quit(c);

     END;
/


exec send_email('tibero@tmax.co.kr','ducco705@snu.ac.kr', 'THIS IS SMTP_TEST2');

