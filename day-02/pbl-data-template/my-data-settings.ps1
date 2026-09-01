# 메모장에서 '=' 오른쪽 값과 field 규칙만 자신의 주제에 맞게 바꿉니다.
# 이 파일은 생성기가 읽는 PowerShell 변수 설정입니다. 제공된 형식을 유지하고 값과 규칙만 수정합니다.
$IndexName = 'kbo-players'
$DocumentCount = 5000
$Seed = 20260901
$IdPrefix = 'PLAYER'
$IdField = 'P_ID'
$SampleCount = 30
# choice와 tags 규칙이 참조하는 도메인별 후보 목록입니다.
$Vocabularies = [ordered]@{
  teams = @('삼성', 'KIA', 'LG', '두산', '키움', 'SSG', 'NC', '롯데', '한화', 'KT')
  positions = @('투수', '포수', '내야수', '외야수')
  surnames = @('김', '이', '박', '최', '정', '강', '조', '윤')
}
# 문서는 위에서 아래 순서로 만들어집니다.
# template는 앞에서 만든 field와 {{sequence}}을 사용할 수 있습니다.
$FieldRules = @(
  @{ Name = 'P_ID'; Kind = 'id'; Digits = 5 }
  @{ Name = 'surname'; Kind = 'choice'; Source = 'surnames' }
  @{ Name = 'P_NM'; Kind = 'template'; Template = '{{surname}}선수{{sequence}}' }
  @{ Name = 'TEAM_NM'; Kind = 'choice'; Source = 'teams' }
  @{ Name = 'P_TYPE'; Kind = 'weighted_choice'; Values = @(
      @{ Value = 'hitter'; Weight = 60 },
      @{ Value = 'pitcher'; Weight = 40 }
    ) }
  @{ Name = 'POSITION'; Kind = 'choice'; Source = 'positions' }
  @{ Name = 'STATUS'; Kind = 'weighted_choice'; Values = @(
      @{ Value = '현역'; Weight = 70 },
      @{ Value = '은퇴'; Weight = 30 }
    ) }
  @{ Name = 'SEASON'; Kind = 'integer'; Min = 1982; Max = 2025 }
  @{ Name = 'G'; Kind = 'integer'; Min = 1; Max = 144 }
  @{ Name = 'AVG'; Kind = 'decimal'; Min = 0.180; Max = 0.380; Digits = 3 }
  @{ Name = 'HR'; Kind = 'integer'; Min = 0; Max = 55 }
  @{ Name = 'RBI'; Kind = 'integer'; Min = 0; Max = 140 }
  @{ Name = 'SB'; Kind = 'integer'; Min = 0; Max = 70 }
  @{ Name = 'OPS'; Kind = 'decimal'; Min = 0.500; Max = 1.100; Digits = 3 }
  @{ Name = 'ERA'; Kind = 'decimal'; Min = 1.50; Max = 6.50; Digits = 2 }
  @{ Name = 'W'; Kind = 'integer'; Min = 0; Max = 20 }
  @{ Name = 'SV'; Kind = 'integer'; Min = 0; Max = 40 }
  @{ Name = 'SO'; Kind = 'integer'; Min = 0; Max = 220 }
  @{ Name = 'WHIP'; Kind = 'decimal'; Min = 0.90; Max = 1.80; Digits = 2 }
  @{ Name = 'profile'; Kind = 'template'; Template = '{{TEAM_NM}} 소속 {{POSITION}} 선수입니다.' }
)
