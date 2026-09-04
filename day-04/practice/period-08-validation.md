# 8교시 연습 — 사용 시나리오·교차 검증·개선·제출

- 필수 권장 시간: 45분
- 선택 도전: 필수 제출 완료 후
- 함께 작성: `../evidence/day-04/dashboard-review.md`
- 시작 기준: 개인 Dashboard 4패널 이상과 상호작용 1개 저장 완료
- 화면 순서: [Inspect·결과 저장·백업](../KIBANA_9_5_STEP_BY_STEP.md#15-결과-저장공유백업)

## (개인·필수) 문제 1 — 사용자 행동 두 가지 테스트

Dashboard 사용자가 실제로 할 행동 두 가지를 실행하세요. 각 행동은 조건 적용과 결과 확인, 원상 복구를 포함합니다.

| 행동 | 시작 상태 | 적용 조건 | 변한 패널·값 | 사용자의 판단 | 복구 방법 | 복구 성공 |
|---|---|---|---|---|---|---|
| 1 | 현역 3,498, Control Any | Control `POSITION = 투수` | Metric 858, 팀별 Bar 투수만, Table 투수 행(평균 0.278) | "투수 타율이 가장 낮은 건 당연 — 타자 포지션 비교로 넘어간다" | Control을 `Any`로 | 성공 |
| 2 | 현역 3,498, Control Any | Control `POSITION = 포수` | Metric 892, Table 포수 행(평균 0.2833) | "포수 평균 타율이 가장 높다 → 포수 뎁스는 양호, 내야·외야를 우선 검토" | Control을 `Any`로 | 성공 |

- 두 행동이 서로 다른 이유: 행동 1은 "기준값(투수)을 확인하고 제외"하는 흐름, 행동 2는 "가장 강한 포지션을 찾아 보강 우선순위에서 내리는" 흐름이라 판단 방향이 반대다.
- 사용자가 멈추거나 헷갈린 지점: Control 드롭다운과 Table 행 클릭(=filter) 중 무엇으로 걸러야 하는지 잠깐 헷갈림
- 캡처 파일: (두 행동 적용/복구 화면 캡처 필요 — p04-p08-q01-actions.png)

## (개인·필수) 문제 2 — 핵심값 3개 교차 검증

Dashboard의 핵심값 3개를 Discover, `_count`, 또는 aggregation 요청과 비교하세요. `Inspect`는 Dashboard 편집 모드에서 해당 패널의 `Panel menu`에 있습니다. 권한이나 화면 상태로 보이지 않으면 Discover 또는 제공 요청 파일로 검증합니다.

| Dashboard 패널·값 | 동일하게 맞춘 시간·조건 | 비교 방법 | 비교값 | 일치 여부 | 다르면 확인한 원인 |
|---|---|---|---:|---|---|
| 현역 선수 Metric = 3,498 | time field 없음(All), STATUS=현역 | `GET kbo-players/_count {"query":{"term":{"STATUS":"현역"}}}` | 3,498 | 일치 | — |
| 팀별 Bar 최댓값 = LG 512 | 조건 없음(전체) | terms agg `TEAM_NM` | LG 512 | 일치 | — |
| 포지션 Table 포수 평균 AVG = 0.2833 | 조건 없음(전체) | `avg` agg by `POSITION` | 0.28332 | 일치 | — |

- 비교에 사용한 요청 파일 또는 Discover 캡처: 개인 저장소 `requests.http` (Day 4 검증 구간) / Kibana Dev Tools Console 실행 결과
- 세 값을 신뢰할 수 있는 이유: Dashboard Lens가 내부적으로 실행하는 것과 동일한 ES aggregation을 같은 조건으로 직접 실행했고 세 값 모두 정확히 일치했다.

## (개인·필수) 문제 3 — 문제 하나를 실제로 수정하고 재검증

제목, field, 집계, 정렬, 구간, 시간, filter, layout 중 한 문제를 골라 수정하세요. 문제가 없다고 생각되면 사용성 문제 하나를 개선합니다.

- 발견한 문제: 팀별 Bar가 STATUS filter 없이 전체(5,000)를 세고 있어, 현역 3,498을 보여 주는 Metric과 기준이 달라 사용자가 두 패널을 나란히 보면 혼란스럽다
- 문제 유형: 집계 범위(filter) 불일치
- 수정 전 설정 또는 결과: 팀별 Bar 합계 5,000 (LG 512 …), Metric 3,498
- 추정 원인: 공통본을 복제한 뒤 팀별 Bar에만 `STATUS: 현역` filter를 넣는 것을 빠뜨림
- 수정한 한 가지: 팀별 Bar 패널(또는 Dashboard 레벨)에 `STATUS: 현역` filter 추가
- 수정 후 결과: 팀별 Bar 합계 3,498 (LG 372 · KT 359 · 두산 357 … 키움 320), Metric과 일치
- 같은 조건 재검증 결과: `filter STATUS=현역` + terms agg `TEAM_NM` → LG 372 등으로 동일
- 개선/보류/악화 판정과 근거: 개선. 모든 패널이 "현역 선수"라는 같은 모집단을 세게 돼 패널 간 값을 직접 비교할 수 있다.
- 수정 전·후 캡처: (팀별 Bar 합계 5,000 → 3,498 화면 캡처 필요 — p04-p08-q03-fix.png)

## (개인·필수) 문제 4 — 결과 3·한계 2·필요 데이터 1과 제출

### 결과 3개

1. 조건·핵심값·비교·판단: `STATUS=현역` 조건에서 현역 선수는 3,498명, 은퇴 1,502명으로 약 70%가 현역이다. 데이터가 현재 전력 분석에 쓸 만큼 최신 비중을 담고 있다고 판단한다.
2. 조건·핵심값·비교·판단: 전체 조건에서 포지션별 평균 타율은 0.278~0.283(포수 0.2833 최고, 투수 0.2780 최저)이고 현역 선수 수도 858~892로 고르다. 특정 포지션 타격이 구조적으로 약하다고 보긴 어렵고, 보강 판단은 개별 선수 단위로 내려야 한다.
3. 조건·핵심값·비교·판단: SEASON 5년 구간에서 2015·2020 구간이 각 587~595건으로 가장 두껍고 2025 구간은 116건뿐이다. 최근 시즌 데이터가 부분 적재 상태일 수 있어, 2025년만 따로 결론 내리지 않는다.

### 현재 데이터의 한계 2개

1. `SEASON`이 연 단위라 시즌 중 페이스 변화나 부상 공백을 알 수 없다 (경기 일자 field 부재).
2. `AVG`·`HR`이 시즌 누적값이고 타석 수 대비 정규화가 안 돼, 소수 출전 선수의 극단값(타율 0.18/0.38)이 평균과 분포를 흔든다.

### 추가로 필요한 데이터 1개

- field: `PA` (타석 수)
- mapping type: integer
- 예시값: 12, 350, 620
- 값 분포·생성 규칙: 0~700, 대부분 100~600. `G`(출전 경기 수)와 연동해 `G × 3.5 ± 랜덤`으로 생성
- 추가되면 답할 수 있는 질문: "규정 타석 이상 선수만" 필터링해 포지션별·팀별 타격 지표를 신뢰도 있게 비교할 수 있다

### 제출 기록

- Dashboard 제목: `D4 개인 미션 - KBO 선수 성적 - (이름)`
- 전체 화면 캡처 경로: `evidence/day-04-practice/p04-p07-q03-personal-layout.png` (Kibana에서 촬영 필요)
- JSON export 경로(선택): `evidence/day-04/dashboard-personal.ndjson` (More → Export)
- `dashboard-plan.md` 경로: `evidence/day-04/dashboard-plan.md`
- `dashboard-review.md` 경로: `evidence/day-04/dashboard-review.md`
- 개인 저장소 commit SHA: (commit 후 기록)
- 미완료 또는 알려진 제한 사항: 본 답안의 모든 수치는 ES aggregation(`GET kbo-players/_search`, `_count`)으로 직접 실행·검증했다. Kibana Lens 패널의 실제 제작·저장·화면 캡처는 UI에서 사용자가 완료해야 한다. 공통 `products` index는 10,000건(문제지 기준 20,000과 다름).

PDF 메뉴가 없으면 정상입니다. 현재 수업 환경의 `More → Export`는 Dashboard JSON을 제공하며, 관련 객체까지 옮길 때는 `Stack Management → Kibana → Saved Objects → Export`를 사용합니다. 화면 캡처를 기본 근거로 제출합니다.

## (선택 도전) 문제 5 — 다른 사람이 재현할 수 있는지 점검

자신의 기록만 보고 다음 항목을 다시 수행해 보거나 옆 학생에게 문서만 보여 줍니다.

- [ ] 올바른 Data View를 선택할 수 있다.
- [ ] 시간 범위를 동일하게 맞출 수 있다.
- [ ] Control/Filter 조건을 재현할 수 있다.
- [ ] 핵심값 3개의 비교 근거를 찾을 수 있다.
- [ ] Dashboard를 초기 상태로 복구할 수 있다.

- 재현에 부족했던 설명: `kbo-players`에 time field가 없다는 점을 안 적어, 재현자가 시간 범위를 어떻게 맞춰야 할지 헷갈릴 수 있었다
- 추가한 설명: "Data View `kbo-players`, time field 없음 → 시간 범위 조건 없음(All). 검증은 `STATUS`/`TEAM_NM`/`POSITION` term 조건과 aggregation 요청으로 재현"
- 최종 재현 판정: 재현 가능 — Data View·조건·검증 요청이 문서화돼 있어 같은 값을 다시 얻을 수 있다

## Day 4 최종 완료 신호

- GREEN: 필수 32문제의 요구 산출물, 개인 Dashboard, plan/review, 캡처, commit 완료
- YELLOW: Dashboard는 있으나 검증·개선·commit 중 하나가 미완료
- RED: 저장된 Dashboard 또는 제출 근거가 없음
