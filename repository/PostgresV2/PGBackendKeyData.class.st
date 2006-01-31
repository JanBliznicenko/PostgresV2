Class {
	#name : #PGBackendKeyData,
	#superclass : #PGPacket,
	#instVars : [
		'processId',
		'secretKey'
	],
	#category : #PostgresV2
}

{ #category : #accessing }
PGBackendKeyData >> eventName [
	^#BackendKeyData
]

{ #category : #printing }
PGBackendKeyData >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'processId='; nextPutAll: processId printString;
		nextPutAll: ',secretKey='; nextPutAll: secretKey printString;
		nextPutAll: ')'

]

{ #category : #accessing }
PGBackendKeyData >> processId [
	^processId
]

{ #category : #accessing }
PGBackendKeyData >> processId: anInteger [
	processId := anInteger
]

{ #category : #receiving }
PGBackendKeyData >> receiveFrom: aStream [

	processId := self readInt32From: aStream.
	secretKey := self readInt32From: aStream.

]

{ #category : #accessing }
PGBackendKeyData >> secretKey [
	^secretKey
]

{ #category : #accessing }
PGBackendKeyData >> secretKey: anInteger [
	secretKey := anInteger
]
