Class {
	#name : #PGCopyOutResponse,
	#superclass : #PGPacket,
	#category : #PostgresV2
}

{ #category : #accessing }
PGCopyOutResponse >> eventName [
	^#CopyOutResponse
]
