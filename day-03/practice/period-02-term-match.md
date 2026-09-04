# 2교시 실습 — term과 match

## (공통) 문제 1 — 제공 코드로 정확 조건 확인

```http
GET /products/_search
{
  "size": 5,
  "query": { "term": { "category": "전자기기" } }
}
```

### 결과 입력

- `hits.total.value`: 1250
- 상위 3개 문서 ID: P-00009, P-00025, P-00081
- 상위 3개 문서의 category: 전자기기, 전자기기, 전자기기
- 모든 확인 문서가 정확 조건을 만족하는가: 예. 반환 문서의 `_source.category`가 모두 정확히 `전자기기`.
- `term`을 선택한 mapping 근거: `category`가 `keyword` type이라 분석 없이 값 전체가 하나의 token으로 색인된다. 정확히 `전자기기`와 일치하는 문서만 찾으므로 분석·부분 매칭이 없는 `term`이 적합하다.

## (공통) 문제 2 — text 전문 검색 직접 구현

`products` index에서 상품명 `name`에 `무선`이라는 검색 의도가 있는 문서를 찾으세요. text 전문 검색에 적합한 query를 선택해 최대 5건을 반환하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "match": {
      "name": "무선"
    }
  }
}
```

### 결과 입력

- 선택한 query와 이유: `match`. `name`이 `text`(analyzer: korean_search) type이라 색인·검색 모두 token 단위로 분석된다. 검색어 `무선`도 분석되어 색인된 token과 비교되므로 전문 검색에는 `match`가 적합하다.
- `hits.total.value`: 505
- 상위 3개 ID·name: P-00025 / MobiCore 컴팩트 무선 이어폰, P-00042 / CleanMate 실속형 무선 청소기, P-00129 / Auralis 스마트 무선 이어폰

## (공통) 문제 3 — 부적절한 조합 비교

같은 `name` field와 `무선` 검색어에 `term` query를 사용한 API를 직접 작성하세요. 문제 2와 결과를 비교하고, 차이를 mapping 또는 분석된 token 관점에서 설명하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "term": {
      "name": "무선"
    }
  }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: 505 / 505
- 공통으로 나온 문서 ID: P-00025, P-00042, P-00129, P-00153, P-00209 (상위 5건이 동일)
- 달라진 이유: 이 경우엔 결과가 달라지지 않았다. `name`이 분석될 때 `무선 이어폰` → `무선`, `이어폰`처럼 공백 단위 token으로 쪼개지므로 색인에 `무선`이라는 단일 token이 존재한다. `term`은 이 token을 그대로 조회하고, 검색어 `무선`도 한 token이라 `match`와 같은 결과가 나온다. 만약 검색어가 `무선 이어폰`(공백 포함)이면 `term`은 분석하지 않아 `"무선 이어폰"` token을 찾다가 0건이 된다.
- `term`은 text에서 항상 0건인가? 실제 근거: 아니다. 여기서 `term:{"name":"무선"}`은 505건이 나왔다. text field라도 검색어가 색인된 token과 정확히 같으면 매칭된다. 다만 검색어가 분석 전 원문(대소문자·공백·복합어)과 다르면 0건이 되기 쉽다.

## (개인) 문제 4 — 자기 정확 조건 검색

자기 mapping에서 값 전체가 정확히 일치해야 하는 `keyword` 또는 `boolean` field 하나를 선택해 정확 조건 검색을 구현하세요.

### 역할·검증 기준

- 실제 존재하는 field와 값을 사용합니다.
- 반환 문서의 `_source`에서 조건을 직접 확인합니다.
- 왜 전문 검색이 아니라 정확 비교인지 설명합니다.

### API와 결과 입력

```http
GET kbo-players/_search
{
  "size": 3,
  "_source": ["P_ID", "P_NM", "TEAM_NM"],
  "query": {
    "term": {
      "TEAM_NM": "삼성"
    }
  }
}
```

- field / type / 값: `TEAM_NM` / `keyword` / `삼성`
- 사용자 질문: "삼성 소속 선수만 보여줘"
- 상위 3개 ID와 실제 값: PLAYER-00002(삼성), PLAYER-00003(삼성), PLAYER-00006(삼성) — `hits.total.value` 496
- 통과/실패와 근거: 통과. 반환 문서의 `_source.TEAM_NM`이 모두 정확히 `삼성`. `TEAM_NM`은 `keyword`라 값 전체가 한 token으로 색인되고 부분 일치·분석이 없어야 하므로 전문 검색이 아니라 정확 비교(`term`)가 맞다.

## (개인) 문제 5 — 자기 전문 검색

자기 mapping의 `text` field 하나와 사용자가 입력할 검색어를 정해 전문 검색 API를 구현하세요.

### 역할·검증 기준

- field가 실제 `text`인지 mapping으로 확인합니다.
- 상위 3개 결과를 관련/보류/무관으로 판정합니다.
- 정확 조건 문제와 query 선택 이유가 달라야 합니다.

### API와 결과 입력

```http
GET kbo-players/_search
{
  "size": 3,
  "_source": ["P_ID", "P_NM", "profile"],
  "query": {
    "match": {
      "profile": "포수"
    }
  }
}
```

- field / type / 검색어: `profile` / `text` (mapping에서 `"profile": {"type": "text"}` 확인) / `포수`
- 상위 3개 ID: PLAYER-00003, PLAYER-00015, PLAYER-00020 — `hits.total.value` 1276
- 관련/보류/무관과 이유: 세 건 모두 **관련**. `profile`이 각각 "삼성 소속 포수 선수입니다.", "키움 소속 포수 선수입니다.", "KIA 소속 포수 선수입니다."로 검색 의도(포수)와 직접 연결된다.
- 완료 판정: 통과. 정확 조건 문제(문제 4)는 `keyword`에 `term`을 썼지만, 여기서는 자연어 문장 field라 분석된 token으로 매칭하는 `match`를 선택했다 — query 선택 이유가 서로 다르다.
