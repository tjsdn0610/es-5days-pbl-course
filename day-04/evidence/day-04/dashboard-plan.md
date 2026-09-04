# Day 4 개인 Dashboard 설계

## 1. 사용자와 목적

- 내 주제: KBO 프로야구 선수 시즌 성적 데이터 (`kbo-players` index, 5,000건)
- 이 Dashboard를 볼 사람: OO구단 전력분석 담당자
- Dashboard를 보고 결정하거나 행동할 것: 어느 포지션에 일정 성적(타율 0.28 이상) 이상의 현역 선수가 부족한지 보고, 부족한 포지션의 영입·트레이드 후보 리스트업을 스카우트팀에 요청
- 사용할 index / Data View: `kbo-players` (time field 없음)

## 2. 데이터 준비 경로

- [x] A: 개인 데이터로 제작
- [ ] B: 공통 products로 제작하며 개인 데이터 보강 규칙 작성
- [ ] C: 공통 Dashboard를 완성하고 개인 청사진에 집중

선택 이유: 전체 규모·그룹 비교·정확한 값·시간 분포 4개 질문 유형이 모두 기존 `kbo-players` field(STATUS, TEAM_NM, POSITION, AVG, HR, SEASON)로 답이 되고 값 분포도 충분하다.

## 3. 질문-데이터-차트 청사진

| 번호 | 분석 질문 | 필요한 field | 현재 존재? | mapping type | 계산·그룹 방식 | 차트 | filter/control | 확인 기준 |
|---|---|---|---|---|---|---|---|---|
| Q1 전체 규모 | 현재 활동 중인 선수는 몇 명인가? | STATUS | O | keyword | filter STATUS=현역, Count | Metric | 없음 | 값 3,498 |
| Q2 그룹 비교 | 팀별 선수 수는 어떻게 다른가? | TEAM_NM | O | keyword | Top values(10), Count | horizontal Bar | POSITION Control | 10팀, 470~520 균등 |
| Q3 분포/정확한 값 | 포지션별 평균 타율과 선수 수는? | POSITION, AVG | O | keyword, float | Top values + Count + Avg(AVG) | Table | POSITION Control | 4행, 평균 0.278~0.283 |
| Q4 상태/시간 | 활동 시즌 구간별 선수 수 분포는? | SEASON | O | integer | Histogram interval 5, Count | Bar | 없음 | 1982~2025, 구간별 330~595 |

## 4. 데이터 부족 분석

- 현재 데이터로 답할 수 없는 질문: 시즌 중 월별 타격 페이스는 어떻게 변하는가?
- 부족한 field: `GAME_DATE` (경기 일자)
- 필요한 mapping type: date
- 필요한 값의 범위·범주·비율: 정규시즌 3~10월
- 날짜가 필요하다면 기간과 단위: 3~10월, 월 또는 주 단위
- 한 문서가 의미할 사건 또는 대상: 선수 1명의 한 경기 기록 (선수-경기 단위)
- 생성 또는 수집 방법: 현재 "선수-시즌" 문서를 경기 단위로 분해, 경기별 타수·안타를 시즌 최종 AVG에 수렴하도록 분배 (seed 고정)
- 데이터 수가 충분하다고 판단할 기준: 경기 단위 안타/타수 합으로 계산한 타율이 원본 시즌 AVG와 ±0.005 이내

## 5. 제작 순서

1. 공통 Dashboard를 Save as로 복제 → `D4 개인 미션 - KBO 선수 성적 - (이름)`
2. Q1 Metric(현역 선수 수) → Q2 팀별 Bar → Q3 포지션 Table → Q4 시즌 Bar 순서로 패널 교체
3. POSITION Options list Control 추가, 패널 제목을 "무엇을 알 수 있는가" 문장으로 변경
4. 저장 후 재열기, 핵심값 3개를 `_count`·aggregation과 교차 검증

## 6. 완료 예상 화면

- Dashboard 제목: `D4 개인 미션 - KBO 선수 성적 - (이름)`
- 필수 패널 수: 4
- 사용할 control/filter: POSITION Options list Control, (선택) 패널별 STATUS=현역 filter
- 저장할 캡처 파일명: p04-p07-q03-personal-layout.png

### 실제 완성 화면 (ES 집계 결과 기반, 2026-09-04)

![개인 KBO Dashboard](personal-dashboard.png)

Q1 Metric 3,498 · Q2 팀별 Bar(470~520) · Q3 포지션 Table(평균 타율 .278~.283) · Q4 시즌 Bar(330~595). 상세 테스트·검증은 `dashboard-review.md` 참조.
