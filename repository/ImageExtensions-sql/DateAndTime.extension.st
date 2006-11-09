Extension { #name : #DateAndTime }

{ #category : #'*ImageExtensions-sql' }
DateAndTime >> sqlString [

	^'''', self printString, ''''
]
