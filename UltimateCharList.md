# Ultimate Character List #

### a-zA-Z, interleaved w/ interesting characters ###
```
a狗bبcշdकeुfकुg犬h개iگjдkטlém𠅜nopqrstuvwxyzABCDEFGHIJKLMNOP
狗: Chinese Simplified (dog) (U+72D7)
ب: ARABIC LETTER BEH (U+0628)
շ: ARMENIAN SMALL LETTER SHA (U+0577)
क: Hindi (base character), DEVANAGARI LETTER KA (U+0915)
ु: Hindi (combining character), DEVANAGARI VOWEL SIGN U (U+0941)
कु: Hindi (combining character sequence with 2 previous Hindi chars)
犬: Japanese (dog) (U+72AC)
개: Korean (dog) (U+AC1C)
گ: ARABIC LETTER GAF (U+06AF)
д: CYRILLIC SMALL LETTER DE (U+0434)
ט: HEBREW LETTER TET (U+05D8)
é: LATIN SMALL LETTER E WITH ACUTE (U+00E9)
ĕ: LATIN SMALL LETTER E WITH BREVE (U+0115)
♂: MALE SIGN (U+2642)
𠅜: U+2015C (needs surrogate pair in UTF-16)
```


### Weird scenarios in SQL Server w/ COLLATE SQL_Latin1_General_CP1_CI_AS ###
```
These are equal
á: Latin small letter a with acute (U+00E1)
á: Latin small letter a (U+0061), followed by Combining acute accent (U+0301) 

These are equal to N''... Crazy!
‪: LEFT-TO-RIGHT EMBEDDING (U+202A)
ț: LATIN SMALL LETTER T WITH COMMA BELOW (U+021B)
𠅜: U+2015C (needs surrogate pair in UTF-16)

For this character:
์: THAI CHARACTER THANTHAKHAT (U+0E4C)
N'์abc' <> N'abc', but N'a์bc' = N'abc'
```
