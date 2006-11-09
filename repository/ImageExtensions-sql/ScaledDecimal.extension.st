Extension { #name : #ScaledDecimal }

{ #category : #'*ImageExtensions-sql' }
ScaledDecimal >> sqlString [
	^self printStringWithoutSPart
]
