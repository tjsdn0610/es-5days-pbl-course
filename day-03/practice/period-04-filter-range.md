# 4교시 실습 — 정확 조건과 경계

## (공통) 문제 1 — 제공 코드로 세 filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "term": { "in_stock": true } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 380
- 확인한 문서 ID 3개: P-00025, P-00129, P-00185
- 각 문서의 category / in_stock / price: 전자기기/true/53800, 전자기기/true/146400, 전자기기/true,162800
- 조건을 위반한 문서가 있는가: 없음. 반환 10건 모두 category=전자기기, in_stock=true, price 53,800~189,900으로 세 filter를 모두 만족한다.

## (공통) 문제 2 — 경계 포함 범위 직접 구현

`products`에서 category가 `전자기기`이고 가격이 50,000원 이상 200,000원 이하인 상품을 검색하세요. 최대 10건을 반환하고 `product_id`, `name`, `category`, `price`만 표시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": [
    "product_id",
    "name",
    "category",
    "price"
  ],
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "category": "전자기기"
          }
        },
        {
          "range": {
            "price": {
              "gte": 50000,
              "lte": 200000
            }
          }
        }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 440
- 최소·최대 price: 59400/151100
- 50,000 또는 200,000 경계 문서 존재 여부와 ID: 없음. `category=전자기기` 이면서 `price`가 정확히 50000 또는 200000인 문서를 검색하면 0건이다(집합 내 실제 최소 50,700 / 최대 199,500). 따라서 이 조건에는 경계값에 딱 걸리는 문서가 존재하지 않는다.

## (공통) 문제 3 — 경계 제외 범위 직접 구현

문제 2에서 다른 조건은 모두 그대로 유지하고 가격 조건만 50,000원 초과 200,000원 미만으로 바꾸세요. 한 요소만 변경해야 합니다.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": [
    "product_id",
    "name",
    "category",
    "price"
  ],
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "category": "전자기기"
          }
        },
        {
          "range": {
            "price": {
              "gt": 50000,
              "lt": 200000
            }
          }
        }
      ]
    }
  }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: 440 / 440
- 빠진 경계 문서 ID: 없음
- 경계 문서가 없어 결과가 같다면 확인한 근거: `gte/lte`(포함)와 `gt/lt`(제외)의 total이 둘 다 440으로 같다. `category=전자기기 AND price in {50000, 200000}` 정확 일치 검색이 0건이므로, 경계값에 걸리는 문서가 없어 연산자만 바꿔도 결과가 동일하다.

## (개인) 문제 4 — 자기 정확 조건 2개

자기 데이터에서 정확 조건으로 사용할 field 2개를 선택해 두 조건을 모두 만족하는 검색을 구현하세요.

### 역할·검증 기준

- keyword·boolean 등 실제 mapping type에 적합해야 합니다.
- 실행 전 포함 예상 문서 1개와 제외 예상 문서 1개를 정합니다.
- 실행 후 `_source`로 판정합니다.

### API와 결과 입력

```http
GET /kbo-players/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "TEAM_NM": "삼성"
          }
        },
        {
          "term": {
            "STATUS": "현역"
          }
        }
      ]
    }
  }
}
```

- field·type·값 2개:TEAM_NM: 선수의 소속 구단을 정확하게 검색, STATUS: 선수의 현재 상태(현역/은퇴)를 정확하게 검색 (둘 다 `keyword`, 값 `삼성` / `현역`)
- 기대 ID / 제외 ID: 포함 예상 PLAYER-00002(삼성·현역) / 제외 예상 PLAYER-00001(두산·현역 — TEAM_NM 불일치)
- 실제 결과와 판정: `hits.total.value` 355. 반환 문서의 `_source`가 모두 TEAM_NM=삼성 & STATUS=현역이고, PLAYER-00002는 결과에 포함, PLAYER-00001은 미포함 → 예상과 일치, 통과.

## (개인) 문제 5 — 자기 범위와 경계 실험

자기 데이터의 numeric 또는 date field를 선택해 포함 경계와 제외 경계 요청을 각각 구현하세요.

### 역할·검증 기준

- 실제 데이터의 최소·최대 또는 의미 있는 경계값을 먼저 확인합니다.
- `gte/lte`와 `gt/lt` 외 조건은 동일하게 유지합니다.
- 경계 문서가 없으면 fixture 설계 또는 부재 근거를 기록합니다.

### API와 결과 입력

```http
GET /kbo-players/_search
{
  "size": 10,
  "query": {
    "range": {
      "SEASON": {
        "gte": 2000,
        "lte": 2020
      }
    }
  }
}
```

- field / type / 경계값:2000/2020 (`SEASON`, `integer`, 전체 범위 1982~2025)
- 포함 요청 total / 제외 요청 total: `gte:2000, lte:2020` → 2399 / `gt:2000, lt:2020` → 2165
- 달라진 문서 ID: SEASON=2000인 119건(예: PLAYER-00006, PLAYER-00083, PLAYER-00130)과 SEASON=2020인 115건이 제외 요청에서 빠졌다 (2399 − 2165 = 234).
- 경계 판정: 경계값 문서 존재. `gte/lte`는 2000·2020년을 포함하고 `gt/lt`는 제외하므로, 연산자 선택에 따라 234건만큼 결과가 달라진다.
