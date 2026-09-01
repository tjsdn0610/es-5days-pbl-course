# Day 2 데이터 준비 결과

> 예시 문장을 복사하지 말고 자신의 실제 실행 결과를 작성합니다.
> 실행하지 않은 항목은 완료로 표시하지 않습니다.

## 1. Index와 문서

- Index 이름: kbo-player
- 문서 한 건의 의미: 한 선수의 한 시즌 기록
- 실제 색인 건수:5,000
- Mapping의 `dynamic` 설정:

## 2. 최종 Field

| Field | Type | 검색에서 사용할 목적 |
P_ID	keyword	선수 고유 ID, 정확 일치·식별
P_NM	text (+keyword)	선수명 자유 입력 검색(match), 정렬
TEAM_NM	keyword	팀 정확 일치 필터, 팀별 집계
P_TYPE	keyword	타자/투수 구분 필터
POSITION	keyword	포지션 필터, 포지션별 집계
STATUS	keyword	현역/은퇴 필터
SEASON	integer	연도 정확 일치·범위·정렬
G	integer	경기 수
AVG	float	타율 범위·정렬
HR	integer	홈런 범위 필터(≥20)·정렬
RBI	integer	타점
SB	integer	도루
OPS	float	타자 종합 지표 정렬
ERA	float	투수 방어율 범위·정렬
W	integer	승
SV	integer	세이브
SO	integer	삼진/탈삼진
WHIP	float	투수 종합 지표
profile	text	선수 소개 자유 입력 검색(match)

필요한 만큼 행을 추가합니다.

## 3. 대량 데이터 생성·색인 결과

- 생성 건수: 5000건
- 로컬 검증 결과:
- Bulk 색인 결과:
- ES 실제 `_count`:{
  "count": 5000,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  }
}
- 분류·숫자·boolean 분포 확인 결과:
- {
  "took": 12384,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 5000,
      "relation": "eq"
    },
    "max_score": null,
    "hits": []
  },
  "aggregations": {
    "팀별_인원": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 0,
      "buckets": [
        {
          "key": "KT",
          "doc_count": 518
        },
        {
          "key": "LG",
          "doc_count": 512
        },
        {
          "key": "SSG",
          "doc_count": 505
        },
        {
          "key": "한화",
          "doc_count": 505
        },
        {
          "key": "KIA",
          "doc_count": 504
        },
        {
          "key": "롯데",
          "doc_count": 503
        },
        {
          "key": "NC",
          "doc_count": 500
        },
        {
          "key": "삼성",
          "doc_count": 496
        },
        {
          "key": "두산",
          "doc_count": 484
        },
        {
          "key": "키움",
          "doc_count": 473
        }
      ]
    },
    "포지션별_인원": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 0,
      "buckets": [
        {
          "key": "외야수",
          "doc_count": 1278
        },
        {
          "key": "포수",
          "doc_count": 1276
        },
        {
          "key": "내야수",
          "doc_count": 1230
        },
        {
          "key": "투수",
          "doc_count": 1216
        }
      ]
    },
    "유형별_인원": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 0,
      "buckets": [
        {
          "key": "hitter",
          "doc_count": 2980
        },
        {
          "key": "pitcher",
          "doc_count": 2020
        }
      ]
    }
  }
}

## 4. Day 3 연결

- 검색 질문 기준: `docs/data-model.md`의 사용자 질문 3개

## 5. 결과 파일 위치

- Mapping:
- 실행 요청:
- 대표 문서:
- 데이터 생성 설정:
- 생성 표본:
- 생성 요약:

## 6. Pipeline 적용 판단

- 적용 / 미적용 / 보류:
- 판단 이유:

## 7. 미완료·오류

- 없음 또는 현재 상태:
- 다음에 할 작업:
