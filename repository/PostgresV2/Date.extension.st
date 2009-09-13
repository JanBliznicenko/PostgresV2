Extension { #name : #Date }

{ #category : #'*PostgresV2' }
Date class >> year: year month: month day: day [

	^ self
		starting: (DateAndTime year: year month: month day: day)
		duration: (Duration seconds: 86400)
]
