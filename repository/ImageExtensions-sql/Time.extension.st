Extension { #name : #Time }

{ #category : #'*ImageExtensions-sql' }
Time >> sqlString [

	^self print24 printString
]
