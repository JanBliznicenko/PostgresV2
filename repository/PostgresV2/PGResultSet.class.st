Class {
	#name : #PGResultSet,
	#superclass : #Object,
	#instVars : [
		'result',
		'completedResponse',
		'rowDescription',
		'rows'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGResultSet class >> new [
	self error: 'should not use'
]

{ #category : #'instance creation' }
PGResultSet class >> on: aResult [

	^ self basicNew initialize
		result: aResult;
		yourself.

]

{ #category : #accessing }
PGResultSet >> completedResponse [
	"Answer the value of completedResponse"

	^ completedResponse
]

{ #category : #accessing }
PGResultSet >> completedResponse: anObject [
	"Set the value of completedResponse"

	completedResponse := anObject
]

{ #category : #accessing }
PGResultSet >> dataRows [

	^rows collect: [ :e | e dataRow ]
]

{ #category : #printing }
PGResultSet >> displayResultSetOn: aStream [

	completedResponse isNil ifFalse: [
		completedResponse displayOn: aStream.
		aStream cr.
	].
	rowDescription isNil ifFalse: [
		self displayRowDescriptionOn: aStream.
		aStream cr; nextPutAll: '----------'; cr.
		self displayRowsOn: aStream.
		aStream nextPut: $(.
		rows size printOn: aStream.
		aStream nextPutAll: ' row'.
		rows size > 1 ifTrue: [aStream nextPut: $s].
		aStream nextPut: $); cr; cr.
	].

]

{ #category : #printing }
PGResultSet >> displayRowDescriptionOn: aStream [

	rowDescription displayOn: aStream.

]

{ #category : #printing }
PGResultSet >> displayRowsOn: aStream [

	rows do: [:each | each displayOn: aStream. aStream cr.].

]

{ #category : #initialize }
PGResultSet >> initialize [

	rows := OrderedCollection new.
]

{ #category : #accessing }
PGResultSet >> result [
	"Answer the value of result"

	^ result
]

{ #category : #accessing }
PGResultSet >> result: anObject [
	"Set the value of result"

	result := anObject
]

{ #category : #accessing }
PGResultSet >> rowDescription [
	"Answer the value of rowDescription"

	^ rowDescription
]

{ #category : #accessing }
PGResultSet >> rowDescription: anObject [
	"Set the value of rowDescription"

	rowDescription := anObject
]

{ #category : #accessing }
PGResultSet >> rows [
	"Answer the value of rows"

	^ rows
]

{ #category : #accessing }
PGResultSet >> rows: anObject [
	"Set the value of rows"

	rows := anObject
]

{ #category : #accessing }
PGResultSet >> valueAt: fieldName [

	| i |
	i := rowDescription columnDescriptions findFirst: [:each | each fieldName = fieldName].
	i = 0 ifTrue: [^ nil].
	rows == nil ifTrue: [^ nil].
	^ (rows at: 1) rawData at: i
]
