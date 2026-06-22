# Folder Structure Automation

`Input` 폴더에 넣은 `.md`, `.txt`, `.docx`, `.hwpx` 파일을 읽어서 바탕화면에 같은 이름의 폴더 구조를 생성하는 프로그램입니다.

명시적인 디렉토리 트리가 있으면 그 구조를 그대로 사용합니다. 트리가 없는 보고서형 문서는 제목, 번호 제목, Word 제목 스타일을 기준으로 폴더 구조를 추론합니다.

예:

```text
Input\documentary.md   -> 바탕화면\documentary
Input\documentary.txt  -> 바탕화면\documentary
Input\documentary.docx -> 바탕화면\documentary
Input\documentary.hwpx -> 바탕화면\documentary
```

## 사용 방법

cmd 파일 실행:

```powershell
.\run_folder_builder.cmd
```

PowerShell 스크립트 직접 실행:

```powershell
powershell -ExecutionPolicy Bypass -File .\logic\folder_builder.ps1
```

## 코드 구조

```text
logic\folder_builder.ps1        # 실행 진입점
logic\functions\load.ps1        # 함수 파일 연결
logic\functions\*.ps1           # 기능별 함수 파일
```

`folder_builder.ps1`는 입력/출력 경로 처리와 실행 흐름만 담당합니다. 실제 파싱, 보고서 텍스트 추출, 구조 생성, 파일 저장 기능은 `logic\functions` 폴더의 함수 파일로 분리되어 있습니다.

`run_folder_builder.cmd`는 바탕화면에 폴더 구조 생성이 성공한 뒤 `Input` 폴더의 지원 파일을 삭제해서 초기화합니다. 실패하면 `Input` 파일은 삭제하지 않습니다.

생성된 결과 폴더에는 원본 입력 파일이 `directory` 이름으로 함께 저장됩니다.

```text
Input\documentary.md   -> 바탕화면\documentary\directory.md
Input\documentary.txt  -> 바탕화면\documentary\directory.txt
Input\documentary.docx -> 바탕화면\documentary\directory.docx
Input\documentary.hwpx -> 바탕화면\documentary\directory.hwpx
```

## 생성될 경로만 확인

```powershell
.\run_folder_builder.cmd --dry-run
```

dry-run은 바탕화면에 폴더를 만들거나 Input을 초기화하지 않고 생성 예정 경로만 출력합니다.

## 명시적 구조 예시

```text
documentary/ # 다큐멘터리 작업 루트
├── source/ # 원본 자료
│   └── video/ # 영상 원본
├── edit/ # 편집 파일
└── README.md # 설명 파일
```

```text
- documentary/ # 다큐멘터리 작업 루트
  - source/ # 원본 자료
    - video/ # 영상 원본
  - edit/ # 편집 파일
  - README.md # 설명 파일
```

## 보고서형 구조 예시

명시적 트리가 없는 문서는 아래 같은 제목 구조를 폴더로 추론합니다.

```text
1. 인증 관리
1.1 로그인
1.2 로그아웃
2. 사용자 관리
2.1 프로필
2.2 권한
```

생성 결과:

```text
바탕화면\파일명\인증 관리
바탕화면\파일명\인증 관리\로그인
바탕화면\파일명\인증 관리\로그아웃
바탕화면\파일명\사용자 관리
바탕화면\파일명\사용자 관리\프로필
바탕화면\파일명\사용자 관리\권한
```

## 동작 규칙

- 명시적 트리/목록 구조가 있으면 그 구조를 우선합니다.
- 명시적 구조가 없으면 보고서 제목 구조를 폴더로 추론합니다.
- 지원 보고서 제목: Markdown 제목, `1.`, `1.1`, 로마 숫자, 한글 `가.` 형식, Word 제목 스타일.
- `.docx`는 Word XML에서 본문 텍스트를 추출합니다.
- `.hwpx`는 HWPX XML에서 본문 텍스트를 추출합니다.
- `.doc` 같은 구형 Word 바이너리 파일은 지원하지 않습니다. `.docx`로 저장해서 사용해야 합니다.
- 원본 입력 파일은 결과 폴더 안에 `directory.<원본확장자>`로 복사됩니다.
- 절대 경로, `..`, Windows에서 사용할 수 없는 문자는 거부합니다.
