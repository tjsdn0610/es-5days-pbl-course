# 6교시 실습 — 정렬·highlight

## (공통) 문제 1 — 제공 코드로 1·2차 정렬 확인

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "price", "rating", "in_stock"],
  "query": { "match": { "name": "무선" } },
  "sort": [
    { "rating": "desc" },
    { "price": "asc" }
  ]
}
```

### 결과 입력

- 상위 5개 ID / rating / price: P-03842 / 5.0 / 13,900 · P-08761 / 5.0 / 107,200 · P-07634 / 5.0 / 132,300 · P-05962 / 5.0 / 138,300 · P-06457 / 5.0 / 184,900
- 1차 정렬이 올바른가: 예. 최상위가 rating 5.0이고 아래로 갈수록 rating이 내려간다(다음 구간 4.9).
- rating 동률에서 2차 정렬이 적용된 사례: rating 5.0인 문서들이 price 13,900 → 107,200 → 132,300 → 138,300 → 184,900 오름차순으로 정렬됐다. 1차 값이 같을 때 2차 기준(price asc)이 적용됨.
- 동률이 없다면 2차 정렬을 확인할 수 있는 방법: 해당 없음(동률 존재). 일반적으로는 1차 정렬 field 값이 모두 다른 좁은 결과에서 2차 field만 바꿔 순서 변화 유무를 보거나, `_source`에 두 field를 함께 표시해 확인한다.

## (공통) 문제 2 — 정렬 우선순위 교환

문제 1과 같은 검색 결과를 가격이 낮은 순서로 먼저 정렬하고, 가격이 같으면 평점이 높은 순서로 정렬하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "price", "rating", "in_stock"],
  "query": { "match": { "name": "무선" } },
  "sort": [
    { "price": "asc" },
    { "rating": "desc" }
  ]
}
```

### 비교 결과

- 변경 후 상위 5개 ID / price / rating: P-01490 / 10,900 / 2.9 · P-05738 / 12,900 / 4.9 · P-05218 / 13,300 / 4.9 · P-08586 / 13,700 / 2.3 · P-03842 / 13,900 / 5.0
- 순서가 달라진 문서: 상위권이 완전히 교체됐다. 문제 1에서 1위였던 P-03842는 5위로 내려가고, 문제 1 상위권에 없던 P-01490·P-05738·P-05218·P-08586이 새로 올라왔다. 이제 저가 상품이 먼저 나오고 rating은 뒤섞인다.
- 검색 hit 집합도 달라졌는가: 아니오. `query`가 `match: name=무선`으로 동일해 일치 문서 505건 집합은 그대로다. `sort` 기준만 바뀌어 같은 집합의 순서가 재배열됐다.

## (공통) 문제 3 — highlight와 표시 field 구현

`name`, `description`에서 `무선 이어폰`을 검색하되 `name`에 3배 boost를 적용하세요. 최대 5건을 반환하고 결과 카드용 field만 `_source`에 포함하며 `name`, `description`에 highlight를 적용하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "_source": ["product_id", "name", "price", "rating"],
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name^3", "description"]
    }
  },
  "highlight": {
    "fields": {
      "name": {},
      "description": {}
    }
  }
}
```

### 결과 입력

- `_source` field 목록: product_id, name, price, rating (카드 표시용 4개)
- highlight가 생성된 문서 ID와 field: P-00241, P-00305, P-00529, P-00617, P-00777 — 5건 모두 `name` field에만 highlight 생성(예: `SoundLab 프리미엄 <em>무선</em> <em>이어폰</em>`)
- `_source`와 highlight의 차이: `_source`는 저장된 원본 값 그대로이고, `highlight`는 매칭된 token을 `<em>...</em>`로 감싼 조각(fragment)만 돌려준다. 화면에서 강조 표시에 쓰고 원본 값은 `_source`에서 읽는다.
- highlight가 없는 hit가 있다면 이유 추정: `description` highlight는 5건 모두 생성되지 않았다. 이 상품들의 `description`에는 "무선"/"이어폰" token이 없어 매칭이 `name`에서만 일어났기 때문이다.

## (개인) 문제 4 — 자기 결과 정렬·카드 설계

자기 서비스에서 중요한 1차·2차 정렬 기준과 결과 카드 field 3~5개를 선택해 Search API를 구현하세요.

### 역할·검증 기준

- 정렬 가능한 mapping type을 사용합니다.
- 1차·2차 정렬의 업무적 이유를 설명합니다.
- 실제 상위 5개 값으로 순서를 검증합니다.

### API와 결과 입력

```http
GET kbo-players/_search
{
  "size": 5,
  "_source": ["P_ID", "P_NM", "TEAM_NM", "AVG", "HR"],
  "query": {
    "bool": {
      "filter": [ { "term": { "P_TYPE": "hitter" } } ]
    }
  },
  "sort": [
    { "AVG": "desc" },
    { "HR": "desc" }
  ]
}
```

- 정렬 field·방향·이유: 1차 `AVG` desc — 타자 평가에서 타율이 가장 기본 지표라 높은 순으로. 2차 `HR` desc — 타율이 같을 때 장타력(홈런)이 많은 선수를 위로.
- 카드 field와 이유: `P_ID`(식별자), `P_NM`(이름=제목), `TEAM_NM`(소속 판단), `AVG`·`HR`(성적 판단). 투수 지표(ERA·WHIP 등)는 타자 카드에 불필요해 제외.
- 상위 5개 정렬 검증: PLAYER-03101(KT, 0.380, 47) · PLAYER-01648(KIA, 0.380, 43) · PLAYER-02657(롯데, 0.380, 41) · PLAYER-04754(삼성, 0.380, 28) · PLAYER-00750(LG, 0.379, 51). AVG 0.380 동률 4건이 HR 47→43→41→28 내림차순으로 정렬됐고, 5번째부터 AVG가 0.379로 낮아짐 → 1차·2차 정렬 모두 정상.

## (개인) 문제 5 — 자기 highlight 또는 표시 최적화

자기 text 검색에 highlight를 적용하세요. text 검색이 없는 프로젝트라면 `_source` 최소화 전후를 비교하세요.

### 역할·검증 기준

- 검색 field와 highlight field의 관계가 타당해야 합니다.
- 원본 데이터와 강조 조각을 구분합니다.
- 사용자 판단에 실제로 도움이 되는지 평가합니다.

### API와 결과 입력

```http
GET kbo-players/_search
{
  "size": 5,
  "_source": ["P_ID", "P_NM", "profile"],
  "query": {
    "match": { "profile": "내야수" }
  },
  "highlight": {
    "fields": { "profile": {} }
  }
}
```

- 선택한 방식과 이유: `profile`(text)에 `match` 검색 + 같은 `profile` field에 highlight. 검색 대상 field와 강조 field를 일치시켜야 사용자가 "왜 이 문서가 걸렸는지"를 바로 확인할 수 있다.
- 실제 결과: `hits.total.value` 1230. 상위 5건(PLAYER-00001, 00002, 00004, 00016, 00017)의 highlight가 `두산 소속 <em>내야수</em> 선수입니다.` 처럼 "내야수"만 강조됐다.
- 사용자에게 유용한가: 결과가 1,230건으로 많을 때 어떤 단어로 매칭됐는지 즉시 보여 준다는 점은 유용하다. 다만 `profile`이 짧은 정형 문장이라 강조 효과 자체는 제한적이다.
- 개선할 점: `profile`이 "X 소속 Y 선수입니다" 형태로 규격화돼 있어, 포지션을 거르려면 `POSITION`(keyword) `term` filter가 더 정확하다. highlight는 자유 서술 field가 생겼을 때 더 값어치가 있다.
