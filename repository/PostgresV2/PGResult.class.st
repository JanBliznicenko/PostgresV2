Class {
	#name : #PGResult,
	#superclass : #Object,
	#instVars : [
		'connection',
		'resultSets',
		'errorResponse',
		'functionResult'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGResult class >> new [
	^ self error: 'should not use'

]

{ #category : #'instance creation' }
PGResult class >> on: aConnection [

	^ self basicNew initialize
		connection: aConnection;
		yourself.

]

{ #category : #'accessing-convenience' }
PGResult >> addResultSet [

	resultSets add: (PGResultSet on: self).

]

{ #category : #'accessing-convenience' }
PGResult >> completedResponse [

	^ self lastResultSet completedResponse
]

{ #category : #'accessing-convenience' }
PGResult >> completedResponse: value [

	self lastResultSet completedResponse: value
]

{ #category : #accessing }
PGResult >> connection [
	^ connection
]

{ #category : #accessing }
PGResult >> connection: value [
	connection := value
]

{ #category : #'accessing-convenience' }
PGResult >> dataRows [

	^ self lastResultSet ifNotNilDo: [ :rs |
		rs dataRows ]
]

{ #category : #printing }
PGResult >> displayResultOn: aStream [

	errorResponse isNil ifFalse: [
		aStream nextPutAll: errorResponse value.
		aStream cr].

	resultSets do: [:each | each displayResultSetOn: aStream].

]

{ #category : #accessing }
PGResult >> errorResponse [
	^ errorResponse
]

{ #category : #accessing }
PGResult >> errorResponse: value [
	errorResponse := value
]

{ #category : #accessing }
PGResult >> functionResult [
	^ functionResult
]

{ #category : #accessing }
PGResult >> functionResult: value [
	functionResult := value
]

{ #category : #initialize }
PGResult >> initialize [

	resultSets := OrderedCollection new.

]

{ #category : #'accessing-convenience' }
PGResult >> lastResultSet [

	^resultSets
		ifEmpty: [ nil ]
		ifNotEmpty: [ resultSets last ]
]

{ #category : #initialize }
PGResult >> reset [
	"Clear the previous results in preparation to hold new query results."

	"There's an opportunity to tweak the code here for performance.
	If the result sets are cleared each time, then there's a lot of
	re-allocation. But, if the old results are just cleared, an earlier
	large result set may cause a large collection to remain in memory.
	Maybe it's just better to let GC handle it.
	"

	self errorResponse: nil.
	self functionResult: nil.
	resultSets := OrderedCollection new.

]

{ #category : #accessing }
PGResult >> resultSets [
	^ resultSets
]

{ #category : #accessing }
PGResult >> resultSets: value [
	resultSets := value
]

{ #category : #'accessing-convenience' }
PGResult >> rowDescription [

	^ self lastResultSet rowDescription
]

{ #category : #'accessing-convenience' }
PGResult >> rowDescription: aRowDescription [

	| rs |

	rs := self lastResultSet.
	rs rowDescription: aRowDescription.
	rs result: self.
	aRowDescription resultSet: rs.

]

{ #category : #'accessing-convenience' }
PGResult >> rows [

	^ self lastResultSet rows
]

{ #category : #'accessing-convenience' }
PGResult >> rows: value [

	self lastResultSet rows: value
]
