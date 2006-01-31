Class {
	#name : #PGColumnDescription,
	#superclass : #PGPacket,
	#instVars : [
		'fieldName',
		'typeOid',
		'typeSize',
		'typeModifier'
	],
	#category : #PostgresV2
}

{ #category : #printing }
PGColumnDescription >> displayOn: aStream [

	aStream nextPutAll: fieldName.

]

{ #category : #accessing }
PGColumnDescription >> eventName [
	^#ColumnDescription
]

{ #category : #accessing }
PGColumnDescription >> fieldName [
	^ fieldName
]

{ #category : #printing }
PGColumnDescription >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'fieldName='; nextPutAll: fieldName printString;
		nextPutAll: ',typeOid='; nextPutAll: typeOid printString;
		nextPutAll: ',typeSize='; nextPutAll: typeSize printString;
		nextPutAll: ',typeModifier='; nextPutAll: typeModifier printString;
		nextPutAll: ')'

]

{ #category : #receiving }
PGColumnDescription >> receiveFrom: connection [

	fieldName := self readStringFrom: connection.
	typeOid := self readInt32From: connection.
	typeSize := self readInt16From: connection.
	typeModifier := self readInt32From: connection.

]

{ #category : #accessing }
PGColumnDescription >> typeModifier [
	^ typeModifier
]

{ #category : #accessing }
PGColumnDescription >> typeOid [
	^ typeOid
]

{ #category : #accessing }
PGColumnDescription >> typeSize [
	^ typeSize
]
