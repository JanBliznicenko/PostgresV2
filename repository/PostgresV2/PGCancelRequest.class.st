Class {
	#name : #PGCancelRequest,
	#superclass : #PGPacket,
	#instVars : [
		'processId',
		'secretKey'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGCancelRequest class >> processId: pid secretKey: secretKey [

	^self new
		processId: pid;
		secretKey: secretKey;
		yourself.

]

{ #category : #accessing }
PGCancelRequest >> eventName [
	^#CancelRequest
]

{ #category : #accessing }
PGCancelRequest >> processId [
	^processId
]

{ #category : #accessing }
PGCancelRequest >> processId: anInteger [
	processId := anInteger
]

{ #category : #accessing }
PGCancelRequest >> secretKey [
	^secretKey
]

{ #category : #accessing }
PGCancelRequest >> secretKey: anInteger [
	secretKey := anInteger
]

{ #category : #sending }
PGCancelRequest >> writeOn: aStream [
	"Write a cancel request on the stream."

	"80877102 - The cancel request code.
	The value is chosen to contain 1234 in the most significant 16 bits,
	and 5678 in the least 16 significant bits. (To avoid confusion,
	this code must not be the same as any protocol version number.)
	"

	self writeInt32: 16 on: aStream.
	self writeInt32: 80877102 on: aStream. "major=1234, minor=5678"
	self writeInt32: self processId on: aStream.
	self writeInt32: self secretKey on: aStream.

]
