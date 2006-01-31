Class {
	#name : #PGReadyForQuery,
	#superclass : #PGPacket,
	#category : #PostgresV2
}

{ #category : #accessing }
PGReadyForQuery >> eventName [
	^#ReadyForQuery
]
