CREATE OR REPLACE PROCEDURE send_mail (p_to   IN VARCHAR2,
             p_from  IN VARCHAR2,
             p_subject  IN VARCHAR2,
             p_text_msg IN VARCHAR2 DEFAULT NULL,
             p_attach_dir IN VARCHAR2 DEFAULT NULL,
             p_attach_name IN VARCHAR2 DEFAULT NULL,
             p_attach_mime IN VARCHAR2 DEFAULT NULL,
             p_smtp_host IN VARCHAR2,
             p_smtp_port IN NUMBER DEFAULT 25)
AS
    l_mail_conn CLONE_UTL_SMTP.connection;
    l_boundary VARCHAR2(50) := '----=*#tmaxSendmailBoundary#*=';
      
 
    vf_buffer RAW(32767);
    vf_raw    RAW(32767); --반환할 파일
    vf_type  UTL_FILE.FILE_TYPE;
      
BEGIN
    l_mail_conn := CLONE_UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
    CLONE_UTL_SMTP.helo(l_mail_conn, p_smtp_host);
    CLONE_UTL_SMTP.mail(l_mail_conn, p_from);
    CLONE_UTL_SMTP.rcpt(l_mail_conn, p_to);
 
    CLONE_UTL_SMTP.open_data(l_mail_conn);
 
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Content-Type: multipart/mixed; boundary="' || l_boundary || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
 
    IF p_text_msg IS NOT NULL THEN
    CLONE_UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/plain; charset="euc-kr"' || UTL_TCP.crlf || UTL_TCP.crlf);
 
    CLONE_UTL_SMTP.write_data(l_mail_conn, p_text_msg);
    CLONE_UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
    END IF;
 
    IF p_attach_name IS NOT NULL THEN
    CLONE_UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Content-Type: ' || p_attach_mime || '; name="' || p_attach_name || '"' || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
    CLONE_UTL_SMTP.write_data(l_mail_conn, 'Content-Disposition: attachment; filename="' || p_attach_name || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
 
 
      -- 파일을 바이트모드로 읽는다.
      -- p_dir : 디렉토리명, p_file : 파일명, rb: 바이트모드로 읽기
      vf_type := UTL_FILE.FOPEN ( p_attach_dir, p_attach_name, 'rb');
 
      -- 파일이 오픈됐는지 IS_OPEN 함수를 이용해 확인.
      IF UTL_FILE.IS_OPEN ( vf_type ) THEN
         -- 루프를 돌며 파일을 읽는다.
         LOOP
         BEGIN
           -- GET_RAW 프로시저로 파일을 읽어 vf_buffer 변수에 담는다.
           UTL_FILE.GET_RAW(vf_type, vf_buffer, 32767);
           -- 반환할 RAW 타입 변수에 vf_buffer를 할당.
           vf_raw := vf_raw || vf_buffer;
            -- BASE64 인코딩을 한 후 파일내용 첨부
            CLONE_UTL_SMTP.WRITE_RAW_DATA(l_mail_conn, UTL_ENCODE.BASE64_ENCODE ( vf_buffer));
            CLONE_UTL_SMTP.WRITE_DATA(l_mail_conn,  UTL_TCP.CRLF );
         EXCEPTION
             -- 더 이상 가져올 데이터가 없으면 루프를 빠져나간다.
               WHEN NO_DATA_FOUND THEN
               EXIT;
         END;
         END LOOP;
      END IF;
 
      -- 파일을 닫는다.
      UTL_FILE.FCLOSE(vf_type);
 
 
    CLONE_UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
    END IF;
 
    CLONE_UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || '--' || UTL_TCP.crlf);
    CLONE_UTL_SMTP.close_data(l_mail_conn);
 
    CLONE_UTL_SMTP.quit(l_mail_conn);
END;
/



begin
tibero.send_mail( 'example@test.com'
,'example@test.com'
,'첨부파일 테스트'
,'테스트 메일입니다. '
,'ATTACH_FILE'
,'test.txt'
,'application/octet-stream'
,'centos7',25);
end;
/