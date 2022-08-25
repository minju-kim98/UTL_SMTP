DECLARE
    vv_host    VARCHAR2(30) := 'localhost';
    vn_port    NUMBER := 25;
    vv_domain  VARCHAR2(30) := 'tmax.co.kr';

    vv_from    VARCHAR2(50) := 'tibero@tmax.co.kr';
    vv_to      VARCHAR2(50) := 'ducco705@naver.com';

    c CLONE_UTL_SMTP.connection;


BEGIN
    c := CLONE_UTL_SMTP.OPEN_CONNECTION(
        HOST => vv_host, 
        PORT => vn_port,
        TX_TIMEOUT => 30);

    CLONE_UTL_SMTP.HELO(c, vv_domain);

    CLONE_UTL_SMTP.MAIL(c, vv_from);   -- 보내는사람
    CLONE_UTL_SMTP.RCPT(c, vv_to);     -- 받는사람

    CLONE_UTL_SMTP.OPEN_DATA(c); -- 메일 본문 작성 시작, SMTP의 data 명령어 역할
    -- 각 메시지는 <CR><LF>로 분리한다. 이는 UTL_TCP.CRLF 함수를 이용한다.
    CLONE_UTL_SMTP.WRITE_DATA(c,'From: ' || '"tibero" <tibero@tmax.co.kr>' || UTL_TCP.CRLF ); -- 보내는사람
    CLONE_UTL_SMTP.WRITE_DATA(c,'To: ' || '"minju" <ducco705@naver.com>' || UTL_TCP.CRLF );   -- 받는사람
    CLONE_UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF );                                                   -- 제목
    CLONE_UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );  -- 한 줄 띄우기
    CLONE_UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('Test Raw Data' || UTL_TCP.CRLF));
    CLONE_UTL_SMTP.WRITE_DATA(c,'THIS IS SMTP_TEST2 ' || UTL_TCP.CRLF );  -- 본문

    CLONE_UTL_SMTP.CLOSE_DATA(c); -- 메일 본문 작성 종료. SMTP 명령어의 “.” 역할

    -- 종료
    CLONE_UTL_SMTP.QUIT(c);


EXCEPTION
    WHEN CLONE_UTL_SMTP.INVALID_OPERATION THEN
        dbms_output.put_line(' Invalid Operation in Mail attempt using CLONE_UTL_SMTP.');
        dbms_output.put_line(sqlerrm);
        CLONE_UTL_SMTP.QUIT(c);
    WHEN CLONE_UTL_SMTP.TRANSIENT_ERROR THEN
        dbms_output.put_line(' Temporary e-mail issue - try again');
        CLONE_UTL_SMTP.QUIT(c);
    WHEN CLONE_UTL_SMTP.PERMANENT_ERROR THEN
        dbms_output.put_line(' Permanent Error Encountered.');
        dbms_output.put_line(sqlerrm);
        CLONE_UTL_SMTP.QUIT(c);
    WHEN OTHERS THEN
        dbms_output.put_line(sqlerrm);
        CLONE_UTL_SMTP.QUIT(c);
END;
/
