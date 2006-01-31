Class {
	#name : #PGCursorResponse,
	#superclass : #PGAbstractStringResponse,
	#category : #PostgresV2
}

{ #category : #accessing }
PGCursorResponse >> eventName [
	^#CursorResponse
]
