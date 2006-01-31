Class {
	#name : #PGEmptyQueryResponse,
	#superclass : #PGAbstractStringResponse,
	#category : #PostgresV2
}

{ #category : #accessing }
PGEmptyQueryResponse >> eventName [
	^#EmptyQueryResponse
]
