Extension { #name : #ScaledDecimal }

{ #category : #'*PostgresV2' }
ScaledDecimal >> asSqlString [
	^self asString copyUpTo: $s
]

{ #category : #'*PostgresV2' }
ScaledDecimal class >> fromSqlString: aString [
	| afterComma |
	afterComma := aString copyAfterLast: $..
	^self readFrom: aString , 's' , afterComma size asString
]
