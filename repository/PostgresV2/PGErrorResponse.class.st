Class {
	#name : #PGErrorResponse,
	#superclass : #PGAbstractStringResponse,
	#category : #PostgresV2
}

{ #category : #accessing }
PGErrorResponse >> eventName [
	^#ErrorResponse
]
