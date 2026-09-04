# 7교시 연습 — 개인 목적형 Dashboard 제작

- 필수 권장 시간: 43분
- 선택 도전: 2분
- 제출 상태 확인: 5분
- 시작 기준: `dashboard-plan.md`의 질문 4개와 A/B/C 경로 확정
- 화면 순서: [Save as](../KIBANA_9_5_STEP_BY_STEP.md#142-개인본-만들기), [선택 확장 패널](../KIBANA_9_5_STEP_BY_STEP.md#16-선택-확장-패널)

## (개인·필수) 문제 1 — 공통 원본을 보존하고 개인본 만들기

공통 Dashboard를 `Save as` 또는 `Duplicate`하여 개인본을 만드세요. 공통 원본에 덮어쓰지 않습니다.

- 공통 원본 이름: `D4 공통 상품 Dashboard - (이름)`
- 개인본 이름 `D4 개인 미션 - 주제 - 이름`: `D4 개인 미션 - KBO 선수 성적 - (이름)`
- 사용한 복제 방법: Save as (Save as new + 새 제목, 원본 덮어쓰기 해제)
- 상단 제목이 개인본으로 바뀌었는가: 예
- Dashboard 목록에 원본과 개인본이 모두 있는가: 예 (공통 원본 유지)
- 캡처 파일: (개인본 저장 후 목록 화면 캡처 필요 — p04-p07-q01-saveas.png)

## (개인·필수) 문제 2 — 청사진대로 서로 다른 패널 4개 제작

질문 Q1~Q4를 답하는 패널을 최소 4개 만드세요. 공통 Dashboard와 비교해 field·집계·정렬·구간·제목 중 두 가지 이상을 개인 질문에 맞게 바꿉니다.

| 질문 | 패널 제목 | field | 계산·그룹 | 차트 | 실제 결과 | 완료 기준 통과 |
|---|---|---|---|---|---|---|
| Q1 | 현재 활동 중인 선수 규모 | STATUS | filter STATUS=현역, Count of records | Metric | 3,498 | 통과 |
| Q2 | 팀별 선수 수 분포 | TEAM_NM | Top values(10), Count | horizontal Bar | LG 512 · KT 518 … 키움 473 (전체 기준, 470~520 사이 균등) | 통과 |
| Q3 | 포지션별 평균 타율과 선수 수 | POSITION, AVG | Top values + Count + Average(AVG) | Table | 포수 0.2833(1,276) · 외야수 0.2820(1,278) · 내야수 0.2813(1,230) · 투수 0.2780(1,216) | 통과 |
| Q4 | 활동 시즌 구간별 선수 수 | SEASON | Histogram interval 5, Count | Bar | 1985:546 · 1990:567 · 2000:590 · 2015:595 · 2020:587 · 2025:116 | 통과 |

- 공통본에서 변경한 요소 2개 이상: ① field (category/brand/price → TEAM_NM/POSITION/SEASON) ② 집계 (Average of price → Average of AVG) ③ 구간 (가격 custom range → SEASON histogram interval 5) ④ 모든 패널 제목 교체
- 만들지 못한 패널과 이유: 없음 (4패널 모두 기존 field로 제작 가능)
- 사용한 대체 질문 또는 데이터 보강 계획: 월별 추이는 경기 일자 field가 없어 SEASON(연 단위) 분포로 대체 (period-06 문제 4의 `GAME_DATE` 보강 계획 참조)

## (개인·필수) 문제 3 — 제목과 배치만 보고 질문을 이해하게 만들기

각 제목을 `Bar`, `그래프`, `현황` 같은 차트 이름이 아니라 사용자가 알게 되는 내용으로 바꾸세요.

| 수정 전 제목 | 수정 후 제목 | 사용자가 알게 되는 것 |
|---|---|---|
| 선수 수 (Metric) | 현재 활동 중인 선수는 3,498명 | 데이터가 현역 선수 전체를 담고 있어 판단 근거로 충분 |
| 팀별 Bar 차트 | 팀별 선수 수는 470~520명으로 고르다 | 특정 팀 데이터 편중이 없다 |
| 포지션 Table | 포지션별 평균 타율은 0.278~0.283으로 근소하다 | 포수가 가장 높고 투수가 가장 낮다 |
| 시즌 Bar 차트 | 2010년대 중후반 활동 세대가 가장 두껍다 | 젊은 선수 유입(세대 교체)이 진행 중 |

- 가장 중요한 패널: 포지션별 평균 타율과 선수 수 Table — 포지션 보강 판단의 직접 근거
- 가장 크게 배치한 이유: 열이 3개(포지션·선수 수·평균 타율)라 폭이 필요하고, 사용자의 핵심 결정이 이 표에서 나온다
- 잘림·겹침을 수정한 패널: 팀별 Bar를 horizontal로 바꿔 팀명 label 겹침 해소
- 수정 후 전체 화면 캡처: `../evidence/day-04/personal-dashboard.png` (ES `kbo-players` 집계 결과 기반, 2026-09-04)

![개인 KBO Dashboard](../evidence/day-04/personal-dashboard.png)

## (개인·필수) 문제 4 — 개인 질문용 Control 또는 Filter

사용자가 반복해서 바꿀 조건 하나를 Control로 만들거나, 항상 유지할 조건 하나를 Filter로 추가하세요.

- 선택한 방식: Control
- field: `POSITION`
- label 또는 조건: `포지션 선택` (Options list)
- 이 조건이 필요한 사용자 행동: 특정 포지션 하나만 골라 팀별·시즌별 분포를 다시 보고, 그 포지션의 보강 우선순위를 판단
- 적용 전 핵심값: 현역 선수 3,498 (Metric)
- 적용 후 핵심값: `POSITION = 내야수` 선택 시 872 (현역 & 내야수)
- 함께 변한 다른 패널: 팀별 Bar(내야수만), 포지션 Table(내야수 행만), 시즌 Bar(내야수만)
- 해제 방법: Control을 `Any`로 되돌림
- 해제 후 복구값: 3,498
- 캡처 파일: `../evidence/day-04/personal-dashboard-filtered.png` (Control `POSITION=내야수` 적용 상태, 현역 내야수 872)

![Control POSITION=내야수 적용](../evidence/day-04/personal-dashboard-filtered.png)

## (선택 도전) 문제 5 — 확장 차트 하나의 필요성 심사

Gauge, Heatmap, Treemap, Tag cloud 중 하나가 자신의 질문에 정말 필요한지 먼저 판단하세요.

- 후보 차트: Heatmap
- 답하려는 질문: 팀 × 포지션 조합별 선수 수는 어떻게 다른가?
- 필요한 field: `TEAM_NM`, `POSITION`
- 기본 Bar/Table보다 나은 점: 10팀 × 4포지션 = 40칸을 색 농도로 한눈에 보여 주고, 값이 유난히 낮은 조합(보강 시급)을 즉시 찾을 수 있다
- 오해할 위험: 색이 절대 건수라서 팀 전체 규모 차이를 포지션 편중으로 착각할 수 있다 (행 정규화 필요)
- 추가/보류 결정: 보류 — 포지션이 4개뿐이라 grouped Bar나 Table로도 충분히 읽힌다
- 추가했다면 검증 결과: 해당 없음

질문에 필요하지 않으면 만들지 않는 것도 정상 답입니다.

## 교시 완료 신호

- GREEN: 개인본, 4패널, 의미 있는 제목·배치, 상호작용 1개 완료
- YELLOW: 3패널 또는 상호작용 검증 미완료
- RED: 개인 Dashboard 복제나 저장 불가
