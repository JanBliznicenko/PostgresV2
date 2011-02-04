Extension { #name : #DateAndTime }

{ #category : #'*PostgresV2' }
DateAndTime >> julianDayNumber: anInteger [

	jdn := anInteger
]

{ #category : #'*PostgresV2' }
DateAndTime >> nanos: anInteger [

	nanos := anInteger
]

{ #category : #'*PostgresV2' }
DateAndTime >> offset: anInteger [

	offset := anInteger
]

{ #category : #'*PostgresV2' }
DateAndTime >> seconds: anInteger [

	seconds := anInteger
]

{ #category : #'*PostgresV2' }
DateAndTime class >> year: year month: month day: day [
	"Optimized version"
	
	| monthIndex daysInMonth p q r s julianDayNumber |
	monthIndex := month isInteger ifTrue: [month] ifFalse: [Month indexOfMonth: month].
	daysInMonth := Month
		daysInMonth: monthIndex
		forYear: year.
	day < 1 ifTrue: [self error: 'day may not be zero or negative'].
	day > daysInMonth ifTrue: [self error: 'day is after month ends']. 	
	
	p := (monthIndex - 14) quo: 12.
	q := year + 4800 + p.
	r := monthIndex - 2 - (12 * p).
	s := (year + 4900 + p) quo: 100.

	julianDayNumber :=
 		( (1461 * q) quo: 4 ) +
			( (367 * r) quo: 12 ) -
 				( (3 * s) quo: 4 ) +
 					( day - 32075 ).
	^self basicNew
		julianDayNumber: julianDayNumber;
		seconds: 0;
		nanos: 0;
		offset: self localOffset;
		yourself
]
