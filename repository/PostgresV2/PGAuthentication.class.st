Class {
	#name : #PGAuthentication,
	#superclass : #PGPacket,
	#instVars : [
		'type',
		'salt'
	],
	#category : #PostgresV2
}

{ #category : #accessing }
PGAuthentication >> eventName [

	type > 6 ifTrue: [self error: 'Unknown authentication type'].

	^#(
		AuthenticationOk
		AuthenticationKerberosV4
		AuthenticationKerberosV5
		AuthenticationCleartextPassword
		AuthenticationCryptPassword
		AuthenticationMD5Password
		AuthenticationSCMCredential
	) at: (type + 1)

]

{ #category : #printing }
PGAuthentication >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'type='; nextPutAll: type printString;
		nextPutAll: ',salt='; nextPutAll: salt printString;
		nextPutAll: ')'

]

{ #category : #receiving }
PGAuthentication >> receiveFrom: connection [

	type := self readInt32From: connection.
	type == 4 ifTrue: [ salt := self readInt16From: connection ].
	type == 5 ifTrue: [ salt := self readInt32From: connection ].

]

{ #category : #accessing }
PGAuthentication >> salt [
	^salt
]

{ #category : #accessing }
PGAuthentication >> salt: anInteger [
	salt := anInteger
]

{ #category : #accessing }
PGAuthentication >> type [
	^type
]

{ #category : #accessing }
PGAuthentication >> type: anInteger [
	type := anInteger
]
