DECLARE
   t_host VARCHAR2(30) := 'localhost';
   t_port NUMBER := 25;
   t_domain VARCHAR2(30) := 'tmax.co.kr';

   t_from VARCHAR2(50) := 'tibero@tmax.co.kr';
   t_to VARCHAR2(50) := 'ducco705@naver.com';
   t_intro VARCHAR2(50) := 'This is mail from TMAX';
   l_encoded_username VARCHAR2(1000);
   l_encoded_password VARCHAR2(1000);
   c utl_smtp.connection;
   reply_rset utl_smtp.reply;
   reply_vrfy utl_smtp.reply;
   reply_help utl_smtp.replies;
   reply_command utl_smtp.reply;
   reply_command_replies utl_smtp.replies;
  BEGIN
    c := UTL_SMTP.OPEN_CONNECTION(t_host,t_port);
    reply_vrfy := utl_smtp.vrfy(c, 'ducco705@naver.com');
    reply_help := utl_smtp.help(c, 'HELP');
    reply_command := utl_smtp.command(c, 'AUTH LOGIN');
    reply_command_replies := utl_smtp.command_replies(c, 'AUTH','LOGIN');
    dbms_output.put_line('vrfy:'||reply_vrfy.code);
    dbms_output.put_line('vrfy:'||reply_vrfy.text);
    dbms_output.put_line('help:'||reply_help(reply_help.count).code);
    dbms_output.put_line('help:'||reply_help(reply_help.count).text);
    dbms_output.put_line('command:'||reply_command.code);
    dbms_output.put_line('command:'||reply_command.text);
    dbms_output.put_line('command_replies:'||reply_command_replies(
reply_command_replies.count).code);
    dbms_output.put_line('command_replies:'||reply_command_replies(
reply_command_replies.count).text);

    reply_rset := utl_smtp.rset(c);
    dbms_output.put_line('rset:'||reply_rset.code);
    dbms_output.put_line('rset:'||reply_rset.text);

    UTL_SMTP.HELO(c, t_domain); --UTL_SMTP.EHLO(c, t_domain);
    UTL_SMTP.NOOP(c);
    UTL_SMTP.MAIL(c, t_from);
    UTL_SMTP.RCPT(c, t_to);

    --reply_rset := utl_smtp.rset(c);
    --dbms_output.put_line('rset:'||reply_rset.code);
    --dbms_output.put_line('rset:'||reply_rset.text);

    UTL_SMTP.OPEN_DATA(c);
    UTL_SMTP.WRITE_DATA(c,'From:' || '"tibero" <tibero@tmax.co.kr>' || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(c,'To:' || '"ducco705" <ducco705@naver.com>' || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_RAW_DATA( c, UTL_RAW.CAST_TO_RAW(''|| t_intro||''|| UTL_TCP.CRLF));
    UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(c,'THIS IS SMTP_TEST1' || UTL_TCP.CRLF);
    UTL_SMTP.CLOSE_DATA(c);
    UTL_SMTP.QUIT(c);

  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        UTL_SMTP.QUIT(c);
      EXCEPTION
        WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR THEN
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
        c utl_smtp.connection;
      BEGIN
         c :=utl_smtp.open_connection(mailhost,25); 
         utl_smtp.helo(c,mailhost); 
         utl_smtp.mail(c,sender); 
         utl_smtp.rcpt(c,recipient); 
         utl_smtp.data(c,message); 
         utl_smtp.quit(c);
     END;
/

/*
SQL> exec send_email('tibero@tmax.co.kr','ducco705@naver.com', 'This sample is education purpose only');
*/
