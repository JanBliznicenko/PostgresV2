Class {
	#name : #PGAbstractStringResponse,
	#superclass : #PGPacket,
	#instVars : [
		'value'
	],
	#category : #PostgresV2
}

{ #category : #printing }
PGAbstractStringResponse >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'value='; nextPutAll: value printString;
		nextPutAll: ')'

]

{ #category : #receiving }
PGAbstractStringResponse >> receiveFrom: aStream [

	value := self readStringFrom: aStream.

]

{ #category : #accessing }
PGAbstractStringResponse >> value [
	^value
]
