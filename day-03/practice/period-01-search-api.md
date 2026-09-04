# 1교시 실습 — Search API 기본

## (공통) 문제 1 — 제공 코드 실행·응답 읽기

다음 요청을 실행하세요.

```http
GET /products/_search
{
  "size": 5,
  "query": { "match_all": {} }
}
```

### 결과 입력

- HTTP 성공 여부: 성공 (200 OK, `timed_out: false`, `_shards.failed: 0`)
- `hits.total.value`: 10000
- `hits.hits`에 반환된 문서 수: 5
- 첫 번째 문서의 `_id`: P-00001
- 첫 번째 문서의 `_source` field 3개: `product_id`, `name`, `category` (그 외 brand·price·rating·review_count·in_stock·tags·description·created_at·updated_at 포함, 모든 문서 공통 12개 field)
- `hits.total.value`와 반환 문서 수가 다를 수 있는 이유: `hits.total.value`는 query에 일치하는 전체 문서 수(10000)이고, `hits.hits`는 `size`(=5)로 잘라낸 한 페이지만 담기 때문. `size`를 늘리지 않는 한 둘은 다를 수 있다.

## (공통) 문제 2 — 반환 개수와 field 직접 구현

`products` index의 전체 문서 중 최대 3건만 반환하고, `_source`에는 `product_id`, `name`, `price`, `in_stock`만 포함하는 Search API를 작성하고 실행하세요.

### API 전체 입력

```http
GET products/_search
{
  "size": 3,
  "_source": [
    "product_id",
    "name",
    "price",
    "in_stock"
  ],
  "query": {
    "match_all": {}
  }
}
```

### 결과 입력

- 반환 문서 수: 3
- `_source`에 요구하지 않은 field가 포함됐는가: 아니오. 반환된 `_source`에는 `product_id`, `name`, `price`, `in_stock` 4개만 존재하고 category·brand·rating 등은 빠졌다.
- 검증한 문서 ID:P-0003, P-0004, P-0008 (실제 반환: P-00003, P-00004, P-00008)

## (공통) 문제 3 — 정렬이 포함된 전체 조회 구현

`products` index의 전체 문서 중 최대 10건을 `price`가 낮은 순서로 반환하세요. `_source`에는 `product_id`, `name`, `price`만 포함하세요.

### API 전체 입력

```http
GET products/_search
{
  "size": 10,
  "_source": [
    "product_id",
    "name",
    "price"
  ],
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "price": {
        "order": "asc"
      }
    }
  ]
}
```

### 결과 입력

- 첫 3개 문서의 ID와 price: P-00431, 5900  P-06599, 5900   P-06549, 5900
- 오름차순 여부: O
- 두 문서의 price가 같을 때 순서가 고정된다고 말할 수 있는가? 근거: 고정된다고 말할 수 없다. price 동률(5900) 3건의 순서가 요청마다 P-00431, P-06599, P-06479 / P-06549 등으로 흔들렸다. 2차 정렬 기준(tie-breaker)을 지정하지 않으면 내부 `_doc`(shard·segment 저장 순서)로 결정되며 이는 세그먼트 병합 등에 따라 바뀔 수 있다. 안정적 순서가 필요하면 `_id` 같은 2차 sort를 추가해야 한다.

## (개인) 문제 4 — 자기 index의 첫 Search API

자기 index의 전체 문서 중 최대 5건을 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 실제 자기 index 이름을 사용합니다.
- `_count`와 `hits.total.value`를 비교합니다.
- `size`와 전체 일치 문서 수를 구분해 설명합니다.

### API와 결과 입력

```http
GET kbo-players/_search
{
  "size": 5,
  "query": {
    "match_all": {}
  }
}
```

- 자기 index: `kbo-players`
- `_count`: 5000 (`GET kbo-players/_count` → `{"count":5000}`)
- `hits.total.value`: 5000
- 반환 문서 수: 5 (PLAYER-00001 ~ PLAYER-00005)
- 판정과 근거: 정상. `_count`와 `hits.total.value`가 5000으로 일치해 전체 문서 수가 같다. 반환 문서 수(5)는 `size` 제한값일 뿐 전체 일치 수와 다르며, `size`는 "한 번에 가져올 개수", `hits.total.value`는 "조건에 맞는 전체 개수"로 구분된다.

## (개인) 문제 5 — 결과 카드 field 설계

자기 서비스에서 검색 결과 카드 한 개를 보여 준다고 가정하세요. 사용자가 클릭 여부를 결정하는 데 필요한 field 3~5개만 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 선택한 field가 자기 mapping과 실제 문서에 존재해야 합니다.
- 식별자, 제목 역할, 판단용 정보가 포함되어야 합니다.
- 불필요한 field를 하나 이상 제외하고 이유를 설명합니다.

### API와 결과 입력

```http
GET kbo-players/_search
{
  "size": 5,
  "_source": ["P_ID", "P_NM", "TEAM_NM", "POSITION", "AVG"],
  "query": {
    "match_all": {}
  }
}
```

- 포함한 field와 이유: `P_ID`(식별자 — 상세 페이지 이동/중복 판별), `P_NM`(제목 역할 — 선수 이름), `TEAM_NM`·`POSITION`(판단용 — 어느 팀 어느 포지션 선수인지로 클릭 여부 결정), `AVG`(판단용 — 타율로 성적 가늠)
- 제외한 field와 이유: `WHIP`, `ERA`, `SV`, `SO` 등 투수 세부 지표 — 카드 단계에서는 정보 과다이고 타자 카드에서는 의미가 약해 상세 화면으로 미룸. `SEASON`도 카드 클릭 판단에 불필요해 제외.
- 실제 반환 문서 ID: PLAYER-00001, PLAYER-00002, PLAYER-00003, PLAYER-00004, PLAYER-00005
- 완료 판정: 통과. 반환된 `_source`에 지정한 5개 field만 존재(예: PLAYER-00002 → 삼성 / 내야수 / AVG 0.332)하고 식별자·제목·판단 정보가 모두 포함됨.
