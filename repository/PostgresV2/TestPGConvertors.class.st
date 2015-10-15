Class {
	#name : #TestPGConvertors,
	#superclass : #TestCase,
	#category : #PostgresV2
}

{ #category : #tests }
TestPGConvertors >> testInetConverter [
	"self debug: #testInetConverter"
	
	"See also http://www.postgresql.org/docs/7.4/static/datatype-datetime.html"
	
	| input address |
	input := '132.2.0.133'.
	
	self shouldnt: [ address := PGConnection inetConverter value: input ] raise: Error.
	self assert: address class = PGIPv4Address.
	self assert: address asSqlString = input.
]

{ #category : #tests }
TestPGConvertors >> testTimestampWithTimezoneConverter [
	"self debug: #testTimestampWithTimezoneConverter"
	
	"See also http://www.postgresql.org/docs/7.4/static/datatype-datetime.html"
	
	| t1 t2 o1 o2 t3 o3 t4 o4 |
	t1 := '2007-06-25 11:12:22.802085+02'.
	t2 := '2009-12-14 18:08:24+01'.
	t3 := '2009-12-14 03:04:05-08:30'.
	t4 := '2009-12-14 04:05:06.789-3'.
	
	self shouldnt: [ o1 := PGConnection timestampWithTimezoneConverter value: t1 ] raise: Error.
	self assert: o1 year = 2007.
	self assert: o1 month = 6.
	self assert: o1 dayOfMonth = 25.
	self assert: o1 hour = 11.
	self assert: o1 minutes = 12.
	self assert: o1 seconds = 22.
	self assert: o1 nanoSecond = 802085000.
	self assert: o1 offset hours = 2.
	self assert: o1 offset minutes = 0.
	self assert: o1 offset seconds = 0.
	self assert: o1 asSqlString = '2007-06-25T11:12:22.802085+02:00'.
	
	self shouldnt: [ o2 := PGConnection timestampWithTimezoneConverter value: t2 ] raise: Error.
	self assert: o2 year = 2009.
	self assert: o2 month = 12.
	self assert: o2 dayOfMonth = 14.
	self assert: o2 hour = 18.
	self assert: o2 minutes = 8.
	self assert: o2 seconds = 24.
	self assert: o2 nanoSecond = 0.
	self assert: o2 offset hours = 1.
	self assert: o2 offset minutes = 0.
	self assert: o2 offset seconds = 0.
	self assert: o2 asSqlString =  '2009-12-14T18:08:24+01:00'.
	
	self shouldnt: [ o3 := PGConnection timestampWithTimezoneConverter value: t3 ] raise: Error.
	self assert: o3 year = 2009.
	self assert: o3 month = 12.
	self assert: o3 dayOfMonth = 14.
	self assert: o3 hour = 3.
	self assert: o3 minutes = 4.
	self assert: o3 seconds = 5.
	self assert: o3 nanoSecond = 0.
	self assert: o3 offset hours = -8.
	self assert: o3 offset minutes = -30.
	self assert: o3 offset seconds = 0.
	self assert: o3 asSqlString = '2009-12-14T03:04:05-08:30'.
	
	self shouldnt: [ o4 := PGConnection timestampWithTimezoneConverter value: t4 ] raise: Error.
	self assert: o4 offset hours = -3.
	self assert: o4 offset minutes = 0.
	self assert: o4 offset seconds = 0.
	self assert: o4 nanoSecond = 789000000.
	self assert: o4 asSqlString = '2009-12-14T04:05:06.789-03:00'
]
