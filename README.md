# 디빛 for iOS
[![view on appstore](http://www.leechy.ru/inn/appstore-en.png)](https://itunes.apple.com/us/app/dibich-siganpyoaeb/id982776253?l=ko&ls=1&mt=8)

![Appstore](http://i.imgur.com/rcSoLLT.png)


* 2015 04 ~
  * iOS 8부터 지원하는 Today Extension(a.k.a Widget)을 이용하여 사용자들이 잠금화면에서부터 시간표를 확인할 수 있는 아이폰 앱입니다.

![AppStore](http://i.imgur.com/rcSoLLT.png)

  * 누적 사용자 수 **약 3만 4천명**, 최고 월 활성 사용자(Monthly Active User) **2만명**, 최고 일일 활성 사용자 수(Daily Active User) **5천 5백명**, **앱스토어 라이프스타일 부문 무료 앱 18위** 등의 기록을 보유하고 있습니다.

![User](http://i.imgur.com/23OELsc.png)

![Active User](http://i.imgur.com/vXL76dQ.png)

  * Skills
    * Objective-C
    * Cocoapods
    * [Realm](https://realm.io/kr/)
    * [Masonry](https://cocoapods.org/pods/Masonry)
    * [AFNetworking](https://cocoapods.org/pods/AFNetworking)


# Database Scheme

### iOS
#### ServerSemesterObject
##### 종합강의 시간표를 관리하기 위한 학기 테이블
| Property        |          Type         | Comment                                                    |
|-----------------|:---------------------:|------------------------------------------------------------|
| semesterVersion | Int                   | 학기별 종합강의시간표 버전                                 |
| semesterID      | Int                   | 학기별 종합강의시간표 ID                                   |
| semesterKey     | String                | eClass로 얻은 학기 고유 키 (ex. CORS_14080810313693080d9e) |
| semesterName    | String                | 사용자에게 보여질 시간표 이름                              |
| serverLectures  | [ServerLectureObject] | 종합강의시간표 내용 (배열)                                 |

#### ServerLectureObject
##### 종합강의 시간표에 포함된 강의 테이블
| Property        |  Type  | Comment                                                                                                                   |
|-----------------|:------:|---------------------------------------------------------------------------------------------------------------------------|
| semesterID      | Int    | 해당 강의를 포함하는 학기 ID                                                                                              |
| lectureName     | String | 강의 이름                                                                                                                 |
| lectureKey      | String | 학수번호                                                                                                                  |
| lectureProf     | String | 교수이름                                                                                                                  |
| lectureLocation | String | 강의실 정보 (ex. 401-6122(신공학관(기숙사) 6122 정보통신공학 실습실),401-6122(신공학관(기숙사) 6122 정보통신공학 실습실)) |
| lectureDaytime  | String | 강의 시간 (ex. 월7.0-8.5/15:00-17:00,수7.0-8.5/15:00-17:00)                                                               |
| lectureCourse   | String | 강의 교과과정 (ex. 전공, 일반교양, 핵심교양)                                                                              |
| lectureType     | String | 강의 타입 (ex. 외국어강의, 혹은 비어있음)                                                                                 |
| lectureEtc      | String | 비고 (ex. 행정및부속기관, 공과대학, 문과대학)                                                                             |
| lectureLanguage | String | 강의 언어 (ex. 영어, 중국어, 혹은 비어있음)                                                                               |
| lecturePoint    | Int    | 강의 학점                                                                                                                 |
| lectureCampus   | Int    | 강의 캠퍼스 (0: 서울, 1: 일산)                                                                                            |
| serverLectureID | Int    |                                                                                                                           |

#### TimeTableObject
##### 사용자가 추가한 시간표 테이블
| Property             |         Type         |                                      Comment                                      |
|----------------------|:--------------------:|---------------------------------------------------------------------------------|
| utid                 |          Int         | 시간표 고유 ID                                                                    |
| timeTableName        |        String        | 시간표 이름                                                                       |
| timeStart            |          Int         | 시간표 내 강의 중 가장 빨리 강의시작하는 시간 (ex. 8시 30분 시작 = 830, 24시간제) |
| timeEnd              | Int                  | 시간표 내 강의 중 가장 늦게 강의가 끝나는 시간 (ex. 21시 끝 = 2100, 24시간제)     |
| active               | Boolean              | 활성화된 시간표인지 확인                                                          |
| workAtWeekend        | Boolean              | 주말에 강의시간이 추가되었는지 확인                                               |
| serverSemesterObject | ServerSemesterObject | 서버 시간표를 사용할 경우 해당 서버시간표 객체                                    |
| lectures             | [LectureObject]      | 사용자가 시간표에 추가한 LectureObject (배열)                                     |

#### LectureObject
##### 사용자가 시간표에 추가한 강의 테이블
| Property       |          Type         |                                                  Comment                                                 |
|----------------|:---------------------:|--------------------------------------------------------------------------------------------------------|
| ulid           |          Int          | 강의 고유 id                                                                                             |
| lectureDetails | [LectureDetailObject] | 강의가 포함하고 있는 LectureDetail 객체 (각 LectureDetail은 강의 시간, 강의실 등을 포함하고 있음) (배열) |
| lectureName    |         String        | 강의 이름                                                                                                |
| theme          | Int                   | 해당 강의가 가질 테마 색깔                                                                               |

#### LectureDetailObject
##### 강의별 강의실, 강의 시작시간, 종료시간, 강의요일 테이블
| Property        |  Type  |                                      Comment                                      |
|-----------------|:------:|---------------------------------------------------------------------------------|
| ulid            |   Int  | 해당 LectureDetail을 가진 강의 고유 id                                            |
| lectureLocation | String | 가공된 강의실 정보 (ex. 401-10144(신공학관(기숙사) 10144 컴퓨터공학과 세미나실2)) |
| timeStart       |   Int  | 강의 시작시간 (ex. 오후 2시 30분 = 1430, 24시간제)                                |
| timeEnd         | Int    | 강의 종료시간 (ex. 오후 4시 30분 = 1630, 24시간제)                                |
| day             | Int    | 강의 요일 (월:0 ~ 일:6)                                                           |
