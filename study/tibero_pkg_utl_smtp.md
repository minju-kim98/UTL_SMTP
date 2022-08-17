# spec of UTL_SMTP
## Overview
UTL_STMP sends an e-mail using SMTP (Simple Mail Transfer Protocol)

## types
**1. connection**</br>
STMP 연결의 설명

* Prototype<br/>
```
  TYPE connection IS RECORD (
    host             VARCHAR2(255),    
    port             PLS_INTEGER,        
    tx_timeout       PLS_INTEGER,         
    private_tcp_con  utl_tcp.connection,  
    private_state    PLS_INTEGER          
  );
```

* Fields

| name              | Description                     |
| ----------------- | ------------------------------- |
| host              | Host name of the SMTP server    |
| port              | Port number of the SMTP server  |
| tx_timeout        | Transfer time-out (in seconds)  |
| private_tcp_con   | For internal use only           |
| private_state     | For internal use only           |

**2. reply**</br>
STMP 응답 라인

* Prototype
```
  TYPE reply IS RECORD (
    code     PLS_INTEGER,    
    text     VARCHAR2(508)   
  );
```

* Fields

| name              | Description                   |
| ----------------- | ----------------------------- |
| code              | 3-digit reply code            |
| text              | reply text                    |

**3. replies**</br>
* Prototype
```
TYPE replies IS TABLE OF reply INDEX BY BINARY_INTEGER;
```

## Functions and Procedures
**1. CLOSE_DATA** </br>
이메일 메시지를 종료
* Prototype
```
UTL_SMTP.CLOSE_DATA
(
  C IN OUT NOCOPY CONNECTION
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.CLOSE_DATA
(
  C IN OUT NOCOPY CONNECTION
);
```
```C```: 닫을 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**2.  COMMAND** </br>
SMTP 명령을 실행
* Prototype
```
UTL_SMTP.COMMAND
(
  C    IN OUT NOCOPY CONNECTION,
  CMD  IN            VARCHAR2,
  ARG  IN            VARCHAR2 DEFAULT NULL
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.COMMAND
(
  C     IN OUT NOCOPY CONNECTION,
  CMD   IN            VARCHAR2,
  ARG   IN            VARCHAR2 DEFAULT NULL
);
```
```C```: 명령이 전송되는 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```CMD```: 처리할 SMTP 명령을 지정하는 유형 VARCHAR2의 입력 인수 </br>
```ARG```: SMTP 명령에 대한 인수를 지정하는 유형 VARCHAR2의 선택적 입력인수, 기본값은 NULL </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**3.  COMMAND_REPLIES** </br>
여러 응답 라인이 예상되는 SMTP 명령을 실행
* Prototype
```
UTL_SMTP.COMMAND_REPLIES
(
  C     IN OUT NOCOPY CONNECTION,
  CMD   IN            VARCHAR2,
  ARG   IN            VARCHAR2 DEFAULT NULL
)
RETURN REPLIES;
```
```C```: 명령이 전송되는 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```CMD```: 처리할 SMTP 명령을 지정하는 유형 VARCHAR2의 입력 인수 </br>
```ARG```: SMTP 명령에 대한 인수를 지정하는 유형 VARCHAR2의 선택적 입력인수, 기본값은 NULL </br>
```REPLIES```: SMTP 서버에서 여러 응답 라인을 리턴하는 유형 REPLIES의 선택적 출력 인수 </br>

**4.  DATA** </br>
이메일 메시지의 본문을 지정
* Prototype
```
UTL_SMTP.DATA
(
  C     IN OUT NOCOPY CONNECTION,
  "BODY"  IN            VARCHAR2 
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.DATA
(
  C     IN OUT NOCOPY CONNECTION,
  "BODY"  IN            VARCHAR2 
);
```
```C```: 명령이 전송되는 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```BODY```: 전송될 이메일 메시지의 본문을 지정하는 유형 VARCHAR2의 입력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**5.  EHLO** </br>
SMTO 서버와의 초기 핸드쉐이킹을 수행하고 확장된 정보를 리턴 </br>
EHLO를 통해 클라이언트가 SMTP 서버에 대해 자체적으로 식별할 수 있다. HELO는 동등한 기능을 수행하지만, 서버에 대한 정보를 더 적게 리턴한다.
* Prototype
```
UTL_SMTP.EHLO
(
  C       IN OUT NOCOPY CONNECTION,
  DOMAIN  IN            VARCHAR2
)
RETURN REPLIES;
```
* Prototype
```
UTL_SMTP.EHLO
(
  C       IN OUT NOCOPY CONNECTION,
  DOMAIN  IN            VARCHAR2
);
```
```C```: 핸드쉐이킹을 수행할 SMTP 서버에 대한 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```DOMAIN```: 전송 호스트의 도메인 이름을 지정하는 유형 VARCHAR의 입력 인수 </br>
```REPLIES```: SMTP 서버에서 여러 응답 라인을 리턴하는 유형 REPLIES의 선택적 출력 인수 </br>

**6.  HELO** </br>
SMTP 서버와의 초기 핸드쉐이킹을 수행 </br>
HELO를 통해 클라이언트가 SMTP 서버에 대해 자체적으로 식별할 수 있다. EHLO는 동등한 기능을 수행하지만, 서버에 대한 정보를 더 많이 리턴한다.
* Prototype
```
UTL_SMTP.HELO
(
  C       IN OUT NOCOPY CONNECTION,
  DOMAIN  IN            VARCHAR2
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.HELO
(
  C       IN OUT NOCOPY CONNECTION,
  DOMAIN  IN            VARCHAR2
);
```
```C```: 핸드쉐이킹을 수행할 SMTP 서버에 대한 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```DOMAIN```: 전송 호스트의 도메인 이름을 지정하는 유형 VARCHAR의 입력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**7. HELP**</br>
HELP 명령을 전송
* Prototype
```
UTL_SMTP.HELP
(
  C        IN OUT NOCOPY CONNECTION,
  COMMAND  IN            VARCHAR2 DEFAULT NULL
)
RETURN REPLIES;
```
```C```: 명령이 전송되는 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```COMMAND```: 도움말이 요청되는 명령을 지정하는 유형 VARCHAR의 선택적 입력 인수 </br>
```REPLIES```: SMTP 서버에서 여러 응답 라인을 리턴하는 유형 REPLIES의 선택적 출력 인수 </br>

**8.  MAIL** </br>
메일 트랜잭션을 시작 </br>
(PL/SQL 지정 명령문에서 함수 호출 구문을 사용하여 MAIL 시작 가능)
* Prototype
```
UTL_SMTP.MAIL
(
  C          IN OUT NOCOPY CONNECTION,
  SENDER     IN            VARCHAR2,
  PARAMETERS IN            VARCHAR2 DEFAULT NULL
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.MAIL
(
  C          IN OUT NOCOPY CONNECTION,
  SENDER     IN            VARCHAR2,
  PARAMETERS IN            VARCHAR2 DEFAULT NULL
);
```
```C```: 메일 트랜잭션을 시작할 SMTP 서버에 대한 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```SENDER```: 보내는 사람의 이메일 주소를 지정하는 유형 VARCHAR의 입력 인수 </br>
```PARAMETERS```: key = value 형식의 선택적 메일 명령 매개변수를 지정하는 유형 VARCHAR의 선택적 입력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**9. NOOP** </br>
널(NULL) 명령을 전송; NOOP은 성공적인 응답을 가져오는 것 이외에 서버에 영향을 미치지 않음.
* Prototype
```
UTL_SMTP.NOOP
(
  C IN OUT NOCOPY CONNECTION
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.NOOP
(
  C IN OUT NOCOPY CONNECTION
);
```
```C```: 명령을 전송할 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**10.  OPEN_CONNECTION** </br>
SMTP 서버에 연결 핸들을 리턴
* Prototype
```
UTL_SMTP.OPEN_CONNECTION
(
  HOST       IN  VARCHAR2,
  PORT       IN  PLS_INTEGER DEFAULT 25,
  TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL
)
RETURN CONNECTION;
```
SMTP 서버에 대한 연결을 열기
* Prototype
```
UTL_SMTP.OPEN_CONNECTION
(
  HOST       IN  VARCHAR2,
  PORT       IN  PLS_INTEGER DEFAULT 25,
  C          OUT CONNECTION,
  TX_TIMEOUT IN  PLS_INTEGER DEFAULT NULL
)
RETURN REPLY;
```
```HOST```: SMTP 서버의 이름을 지정하는 유형 VARCHAR의 입력 인수 </br>
```PORT```: SMTP 서버가 청취하는 포트 번호를 지정하는 유형 INTEGER의 입력 인수 </br>
```TX_TIMEOUT```: 시간종료 값(초)을 지정하는 유형 INTEGER의 입력 인수. 프로시저가 대기하지 않도록 지시하려면 이 값을 0으로 지정하고, 프로시저가 무기한 대기하도록 지시하려면 이 값을 NULL로 설정. </br>
```CONNECTION```: SMTP 서버에연결 핸들을 리턴하는 유형 CONNECTION의 출력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**11.  OPEN_DATA** </br>
DATA 명령을 전송
* Prototype
```
UTL_SMTP.OPEN_DATA
(
  C IN OUT NOCOPY CONNECTION
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.OPEN_DATA
(
  C IN OUT NOCOPY CONNECTION
);
```
```C```: 명령을 전송할 SMTP 연결을 지정하는 유형 CONNECTION의 입력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**12. QUIT** </br>
STMP 세션을 종료하고 연결을 끊기
* Prototype
```
UTL_SMTP.QUIT
(
  C IN OUT NOCOPY CONNECTION
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.QUIT
(
  C IN OUT NOCOPY CONNECTION
);
```
```C```: 명령을 전송할 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**13.  RCPT** </br>
이메일 메시지의 수신인 지정 </br>
여러 수신처를 스케줄하려면 RCPT 프로시저를 여러 번 호출하면 된다.
* Prototype
```
UTL_SMTP.RCPT
(
  C          IN OUT NOCOPY CONNECTION,
  RECIPIENT  IN            VARCHAR2,
  PARAMETERS IN            VARCHAR2 DEFAULT NULL
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.RCPT
(
  C          IN OUT NOCOPY CONNECTION,
  RECIPIENT  IN            VARCHAR2,
  PARAMETERS IN            VARCHAR2 DEFAULT NULL
);
```
```C```: 수신인을 추가할 SMTP 연결을 지정하는 CONNECTION의 입력 또는 출력 인수 </br>
```RECIPIENT```: 수신인의 이메일 주소를 지정하는 유형 VARCHAR의 입력 인수 </br>
```PARAMETERS```: key = value 형식의 메일 명령 매개변수를 지정하는 유형 VARCHAR의 선택적 입력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**14. RSET** </br>
현재 메일 트랜잭션을 종료
* Prototype
```
UTL_SMTP.RSET
(
  C IN OUT NOCOPY CONNECTION
)
RETURN REPLY;
```
* Prototype
```
UTL_SMTP.RSET
(
  C IN OUT NOCOPY CONNECTION
);
```
```C```: 메일 트랜잭션을 취소할 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 선택적 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**15. VRFY** </br>
이메일 주소를 유효성 확인하고 검증. 유효한 경우 수신인의 전체 이름 및 완전한 메일함이 리턴됨
* Prototype
```
UTL_SMTP.VRFY이메일 메시지를 종료
(
  C          IN OUT NOCOPY CONNECTION,
  RECIPIENT  IN            VARCHAR2
)
RETURN REPLY;
```
```C```: 이메일 주소를 검증할 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```RECIPIENT```: 검증될 이메일 주소를 지정하는 유형 VARCHAR의 입력 인수 </br>
```REPLY```: SMTP 서버에서 단일 응답 라인을 리턴하는 유형 REPLY의 출력 인수; SMTP 서버에서 여러 응답 라인이 리턴되는 경우 마지막 응답 라인 </br>

**16. WRITE_DATA** </br>
이메일 메시지에 데이터를 추가. 데이터를 추가하기 위해 반복적으로 호출 가능.
* Prototype
```
UTL_SMTP.WRITE_DATA
(
  C     IN OUT NOCOPY CONNECTION,
  DATA  IN            VARCHAR2 
);
```
```C```: 데이터를 추가할 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```DATA```: 이메일 메시지에 추가될 데이터를 지정하는 유형 VARCHAR의 입력 인수 </br>

**17. WRITE_RAW_DATA**</br>
RAW 데이터로 구성된 이메일 메시지의 분할 영역을 쓴다
* Prototype
```
UTL_SMTP.WRITE_RAW_DATA
(
  C     IN OUT NOCOPY CONNECTION,
  DATA  IN            RAW
);
```
```C```: 데이터를 추가할 SMTP 연결을 지정하는 유형 CONNECTION의 입력 또는 출력 인수 </br>
```DATA```: 이메일 메시지에 추가될 데이터를 지정하는 유형 RAW의 입력 인수 </br>
