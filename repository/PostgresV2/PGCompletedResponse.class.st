Class {
	#name : #PGCompletedResponse,
	#superclass : #PGAbstractStringResponse,
	#category : #PostgresV2
}

{ #category : #printing }
PGCompletedResponse >> displayOn: aStream [

	aStream nextPutAll: value.

]

{ #category : #accessing }
PGCompletedResponse >> eventName [
	^#CompletedResponse
]
