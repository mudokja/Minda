# Minda

<img src="readme_image/logo.png" width="150px"/>

<br/>

## 소개

일기 감정 추출 및 분석, 조언 제공 어플리케이션

<br/>

## 기술 스택

### FrontEnd

![Flutter](https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/android-%2334A853?style=for-the-badge&logo=android&logoColor=white)
![html5](https://img.shields.io/badge/html5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![JavaScript](https://img.shields.io/badge/javascript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

### BackEnd

![FastAPI](https://img.shields.io/badge/fastapi-%23009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![SpringBoot](https://img.shields.io/badge/springboot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)
![Postgresql](https://img.shields.io/badge/postgresql-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/redis-%23DC382D?style=for-the-badge&logo=redis&logoColor=white)
![MongoDB](https://img.shields.io/badge/mongodb-%2347A248?style=for-the-badge&logo=MongoDB&logoColor=white)

### Infra

![NGinx Proxy Manager](https://img.shields.io/badge/nginx%20proxy%20manager-%23F15833?style=for-the-badge&logo=nginxproxymanager&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-%23009639?style=for-the-badge&logo=nginx)
![Jenkins](https://img.shields.io/badge/Jenkins-%23D24939?style=for-the-badge&logo=jenkins&logoColor=black&color=white)
![SonarQube](https://img.shields.io/badge/sonarqube-%234E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)
![AWS](https://img.shields.io/badge/aws-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Kafka](https://img.shields.io/badge/apache%20kafka-%23231F20?style=for-the-badge&logo=apachekafka&logoColor=white)

### AI

![Pytorch](https://img.shields.io/badge/pytorch-%23EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white)

### 협업 툴

![Jira](https://img.shields.io/badge/jira-%230A0FFF.svg?style=for-the-badge&logo=jira&logoColor=white)
![Figma](https://img.shields.io/badge/figma-%23F24E1E.svg?style=for-the-badge&logo=figma&logoColor=white)
![GitLab](https://img.shields.io/badge/gitlab-FC6D26?style=for-the-badge&logo=gitlab&logoColor=#FC6D26)
![Notion](https://img.shields.io/badge/notion-000000?style=for-the-badge&logo=notion&logoColor=#000000)
![Mattermost](https://img.shields.io/badge/mattermost-0058CC?style=for-the-badge&logo=mattermost&logoColor=#0058CC")
![Discode](https://img.shields.io/badge/discode-5865F2?style=for-the-badge&logo=discord&logoColor=white)
<img src="https://img.shields.io/badge/git-F05032?style=for-the-badge&logo=git&logoColor=white"/>

<br /><br />

# 목차

1. [개요](#개요)
2. [주요 기능](#주요-기능)
3. [서비스 화면](#서비스-화면)
4. [협업 환경](#협업-환경)
5. [기술 소개](#기술-소개)
6. [팀원 소개](#팀원-소개)

<br /><br />

## 개요

프로젝트 개발기간

**_2024.04.08 ~ 2024.05.20 (7주)_**

프로젝트 개요

- 작성한 일기를 더 가치 있게, 시각화 및 조언을 받으며 의미 있는 과거 성찰을 진행해봐요.

## 주요 기능

- 기본 일기 작성 기능(날짜에 따른 일기 작성 및 확인)<br />
- AI 일기 분석 및 통계 기능<br />
- Kobert 모델을 이용한 감정 분석 기능<br />
- 조언 기능(일기 분석 내용을 기반으로 조언 생성)<br />
- KoGPT2를 이용한 챗봇
- Dall-E AI 이미지 생성, 워드 클라우드 기능을 통한 다양한 시각화 기능<br />

<br />

## 서비스 화면

<table width="100%" border-style="non" cellspacing="0" cellpadding="100">
  <tr>
    <td align="center"><img src="readme_image/main.gif" alt="main_page" width="200"></td>
    <td align="center"><img src="readme_image/intro.gif" alt="intro_page" width="200"></td>
    <td align="center"><img src="readme_image/write.gif" alt="write_page" width="200"></td>
  </tr>
  <tr>
    <td align="center"><img src="readme_image/list.gif" alt="diary_list" width="200"></td>
    <td align="center"><img src="readme_image/profile.gif" alt="profile_page" width="200"></td>
    <td align="center"><img src="readme_image/analysis.gif" alt="analyze_page" width="200"></td>
  </tr>
</table>

<br/><br/>

## 협업 환경

### JIRA

매주 월요일 오전 9시 30분 스프린트 회의를 통해 그 전주의 이슈를 공유하고 이번주 목표를 세우고 목표 달성을 위한 구체적인 작업을 정리합니다.

공통적인 일정 관리와 파트별 회의, 개인 개발 일정까지 모두 공유하며 구체적으로 이슈를 관리합니다.

이를 위해 사용된 요소들은 다음과 같습니다.

- Epic : `FE`, `BE`, `INFRA`<br />
  각 에픽에 맞게 스토리 및 태스크를 작성하였습니다.
- 번다운 차트
  ![JIRA](readme_image/burndown.PNG)

### GIT

컨벤션 설정을 통해 규칙을 정하고 GERRIT을 함께 활용하여 서로의 코드에 코멘트를 남겨 보완할 수 있도록 합니다.

- GIT 컨벤션
  ![GIT 컨벤션](readme_image/Git.png)

### Notion

`기능명세서`, `일정`, `이슈 발생 상황`, `환경설정 메뉴얼 ` 등 프로젝트 문서들을 공유 공간에서 통합적으로 관리하고 효과적으로 의사소통합니다.

<br/><br/>

### 시스템 구성도

![시스템구성도](readme_image/diagram.PNG)

<br/>

### ERD

![ERD](readme_image/erd.png)

<br /><br />

# 팀원 소개

**FRONTEND**

` 한지원` : 디자인 및 일기 목록, 확인 구현 <br/>
`강보훈(Team 리더 ,FE 리더)`: Flutter 레이아웃 및 유저 기능 구현 <br/>
`윤건웅` : 일기 분석 페이지 구현 <br/>

**BACKEND**

`이효재`: (BE 리더) | Spring API | AI | FastAPI(Python) API | DB 아키텍쳐 설계 <br/>
`김소연` : Spring API | 외부 API 호출 비동기 처리 및 비즈니스 로직 구현 <br/>
`정지훈` : Infra | Spring API | AI | System 아키텍처 설계 | Security | CI/CD

# 배포 주소

**안드로이드 앱 : [구글 드라이브](https://drive.google.com/file/d/1p53AnhI4_Ye-H5iEMpogTAOo3zGVZWHP/view?usp=drive_link)**

**웹사이트 : [coldiary.co.kr](https://coldiary.co.kr)**
