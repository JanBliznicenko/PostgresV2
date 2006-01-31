Class {
	#name : #PGCopyInResponse,
	#superclass : #PGPacket,
	#category : #PostgresV2
}

{ #category : #accessing }
PGCopyInResponse >> eventName [
	^#CopyInResponse
]
