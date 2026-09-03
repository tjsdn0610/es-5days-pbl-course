# 5교시 실습 — bool 검색

## (공통) 문제 1 — 제공 코드로 must·filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "name": "무선" } }],
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

- `hits.total.value`: 74
- 상위 3개 ID·name: P-00025 / MobiCore 컴팩트 무선 이어폰, P-00129 / Auralis 스마트 무선 이어폰, P-00369 / SoundLab 데일리 무선 이어폰
- 세 filter의 실제 값: category : 전자기기, in_stock : true, price 50000~200000
- must와 filter의 역할 차이: must : name필드에 "무선"이라는 검색어가 포함되는 문서를 찾음. filter : category,in_stock,price조건을 만족하는 문서 남김

## (공통) 문제 2 — 조건 제거 실험 직접 구현

문제 1의 요청에서 `in_stock` filter만 제거한 API를 작성하세요. 다른 조건은 바꾸지 마세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "name": "무선"
          }
        }
      ],
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

### 비교 결과

- 변경 전 total / 변경 후 total: 74 / 83
- 새로 포함된 문서 ID·in_stock: P-00457 / MobiCore 데일리 무선 이어폰 → in_stock: false
                               P-00521 / NeoTech 스마트 무선 이어폰 → in_stock: false
- 변화가 없다면 데이터 근거:
- 제거한 조건의 역할:

## (공통) 문제 3 — should 조건 직접 구현

category가 `전자기기`인 문서 중 `name`에 `무선`이 있거나 `in_stock=true`인 조건을 최소 하나 만족하도록 bool API를 작성하세요. `minimum_should_match`를 명시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "category": "전자기기"
          }
        }
      ],
      "should": [
        {
          "match": {
            "name": "무선"
          }
        },
        {
          "term": {
            "in_stock": true
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 1097
- 무선이지만 품절인 문서 존재 여부:
- 무선이 아니지만 재고가 있는 문서 존재 여부:
- should 조건 판정: name에 무선 또는 in_stock=true 중 최소 1개를 만족하면 통과. 따라서 조건은 category=전자기기 AND (name에 무선 OR in_stock=true)

## (개인) 문제 4 — 자기 bool 검색

자기 사용자 질문 하나를 검색 의도와 정확 조건으로 분해해 bool 요청을 구현하세요.

### 역할·검증 기준

- must 0~1개, filter 2개 이상을 사용합니다.
- 각 field와 query 선택 이유를 mapping type으로 설명합니다.
- 반환 문서 3개 이상을 실제 값으로 검증합니다.

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
        },
        {
          "term": {
            "POSITION": "내야수"
          }
        }
      ]
    }
  }
}
```

- 사용자 질문: 삼성 소속이고 현역인 내야수 선수를 찾아줘
- must와 이유:
- filter 2개와 이유:
  TEAM_NM → 삼성: 소속팀이 정확히 삼성인 선수만 검색하기 위해 term 사용
  STATUS → 현역: 선수 상태가 정확히 현역인 선수만 검색하기 위해 term 사용
  POSITION → 내야수: 포지션이 정확히 내야수인 선수만 검색하기 위해 term 사용
- 실제 검증 결과:   선수 ID	선수명	팀	상태	포지션
              PLAYER-00002	윤선수2	삼성	현역	내야수
              PLAYER-00017	이선수17	삼성	현역	내야수
              PLAYER-00028	강선수28	삼성	현역	내야수

## (개인) 문제 5 — 조건 역할 검증

개인 문제 4에서 filter 하나를 제거하고 전후 결과를 비교하세요. 추가로 원래 조건에서 제외되어야 하는 문서 1개를 독립 요청으로 확인하세요.

### 역할·검증 기준

- 한 번에 filter 하나만 제거합니다.
- 새로 포함된 문서의 실제 값을 확인합니다.
- 제외 문서는 원래 bool 결과에 포함되지 않아야 합니다.

### API와 결과 입력

```http

```

- 제거한 filter:
- 전/후 total:
- 새로 포함된 ID와 값:
- 제외 확인 ID와 근거:
