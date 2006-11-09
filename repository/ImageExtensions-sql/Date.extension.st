Extension { #name : #Date }

{ #category : #'*ImageExtensions-sql' }
Date >> sqlString [

	^self yyyymmdd printString
]
