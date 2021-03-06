Class {
	#name : #PGPasswordPacket,
	#superclass : #PGPacket,
	#instVars : [
		'password'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGPasswordPacket class >> password: aString [

	^self new
		password: aString;
		yourself.

]

{ #category : #accessing }
PGPasswordPacket >> password [
	^password
]

{ #category : #accessing }
PGPasswordPacket >> password: aString [
	password := aString
]

{ #category : #printing }
PGPasswordPacket >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'password='; nextPutAll: password printString;
		nextPutAll: ')'
]

{ #category : #sending }
PGPasswordPacket >> writeOn: aStream [

	"Add 5 for the 32bit size header, and add 1 for the '\0' after the string"

	self writeInt32: self password size + 5 on: aStream.
	self writeString: self password on: aStream.

]
