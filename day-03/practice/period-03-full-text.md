# 3교시 실습 — 전문 검색 확장

## (공통) 문제 1 — 제공 코드로 여러 field 검색

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name", "description"]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 505
- 상위 3개 ID·name: P-000241 SoundLab 프리미엄 무선 이어폰, P-00305 Auralis 실속형 무선 이어폰, P-00529 NeoTech 스마트 무선 이어폰
- 각 문서가 name·description 중 어디에서 의도와 연결되는가: name
- 상위 3개 관련/보류/무관 판정: 3건 모두 **관련**. P-00241 "SoundLab 프리미엄 무선 이어폰", P-00305 "Auralis 실속형 무선 이어폰", P-00529 "NeoTech 스마트 무선 이어폰" 으로 `name`에 "무선"과 "이어폰"이 모두 들어가 검색 의도와 직접 일치한다.

## (공통) 문제 2 — field boost 직접 구현

문제 1과 같은 조건을 유지하되 `name` 일치를 `description`보다 3배 중요하게 보는 Search API를 작성하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": [
        "name^3",
        "description"
      ]
    }
  }
}
```

### 비교 결과

- 변경 전 상위 3개 ID: P-000241 SoundLab 프리미엄 무선 이어폰, P-00305 Auralis 실속형 무선 이어폰, P-00529 NeoTech 스마트 무선 이어폰
- 변경 후 상위 3개 ID: P-00241, P-00305, P-00529 (변경 전과 동일, `_score` 모두 20.28로 동률)
- 순위가 달라진 문서와 이유: 없음. 상위권 문서는 "무선 이어폰"이 `name`에만 있고 `description`에는 없어, `name^3` boost 유무와 상관없이 `name` 매칭 점수만으로 순위가 정해진다.
- boost가 사용자 의도에 유리했는가: 이 검색어에서는 중립(효과 없음). 다만 `description`에도 "무선 이어폰"이 들어간 문서가 많은 검색어라면 `name` 일치 상품을 위로 끌어올려 유리하게 작동한다.

## (공통) 문제 3 — 구문 검색 직접 구현

`products` index의 `name`에서 `무선 이어폰`이라는 단어 순서와 인접성을 중요하게 검색하세요. `slop`은 0, 최대 5건으로 구현하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "match_phrase": {
      "name": {
        "query": "무선 이어폰",
        "slop": 0
      }
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 249
- 상위 문서 ID·name:  P-00241 SoundLab 프리미엄 무선 이어폰 (이하 P-00305, P-00529, P-00617, P-00777)
- 문제 1보다 결과가 같거나 줄어든 이유: 문제 1의 `multi_match`는 "무선" 또는 "이어폰" token 중 하나만 있어도 매칭됐지만, `match_phrase` + `slop:0`은 "무선" 바로 뒤에 "이어폰"이 인접(순서·위치 일치)해야 한다. 두 token이 떨어져 있거나 하나만 있는 문서가 빠져 505 → 249로 줄었다.
- 구문 의도에 맞지 않는 문서가 있는가: 없음. 상위 결과의 `name`이 모두 "... 무선 이어폰" 형태로 두 단어가 정확히 인접해 있다.

## (개인) 문제 4 — 여러 text field 검색

자기 프로젝트에서 같은 사용자 검색어가 적용될 수 있는 text field 2개 이상을 선택해 전문 검색을 구현하세요.

### 역할·검증 기준

- 각 field의 서비스 역할을 설명합니다.
- 상위 3개 문서를 사람이 평가합니다.
- 한 field만 필요한 도메인이라면 `match`를 선택하고 그 이유를 적어도 됩니다.

### API와 결과 입력

```http
GET /kbo-players/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "삼성",
      "fields": [
        "P_NM",
        "profile"
      ]
    }
  }
}
```

- 사용자 질문·검색어: 삼성
- 선택 field와 역할:P_NM:선수의 이름을 검색하는 field, profile:선수의 소속구단 및 포지션 field
- 상위 3개 판정: profile: "삼성 소속 내야수 선수입니다.","삼성 소속 포수 선수입니다."
- query 선택 근거:P_NM과 profile 두 개의 text field에 동일한 사용자 검색어를 적용해야 하므로 multi_match를 선택하였다

## (개인) 문제 5 — boost 또는 phrase 가설 검증

자기 검색에서 field boost 또는 phrase 중 하나를 선택해 기본 요청과 비교하세요.

### 역할·검증 기준

- 같은 index·데이터·검색어·size를 유지합니다.
- 한 요소만 변경합니다.
- 결과가 바뀌지 않아도 실제 결과대로 기록합니다.

### API와 결과 입력

```http
GET /kbo-players/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "삼성",
      "fields": [
        "profile"
      ]
    }
  }
}
```

- 선택한 가설: 삼성이라는 검색어는 선수 이름(P_NM)보다 선수의 소속 구단 정보가 담긴 profile에서 더 잘 검색될 것이다.
- 변경 전·후 상위 3개: 변경 전(fields: P_NM, profile): PLAYER-00002, PLAYER-00003, PLAYER-00006 / 변경 후(fields: profile): PLAYER-00002, PLAYER-00003, PLAYER-00006 (동일, `_score` 2.31, `hits.total.value` 496로 변화 없음)
- 개선/보류/악화 판정: 보류 (결과 변화 없음)
- 판정 근거: 선수 이름이 "박선수1" 같은 형식이라 `P_NM`에는 "삼성" token이 없다. 따라서 변경 전에도 점수는 `profile` 매칭만으로 계산됐고, `fields`에서 `P_NM`을 제거해도 total·상위 문서·`_score`가 그대로다. "삼성"은 실제로 `profile`에서만 검색된다는 가설은 지지되지만, 요청 결과 수치 자체는 달라지지 않았다.
