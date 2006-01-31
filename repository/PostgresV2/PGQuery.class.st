Class {
	#name : #PGQuery,
	#superclass : #PGPacket,
	#instVars : [
		'queryString'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGQuery class >> sql: aString [

	^self new
		queryString: aString;
		yourself.

]

{ #category : #accessing }
PGQuery >> eventName [
	^#Query
]

{ #category : #printing }
PGQuery >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'queryString='; nextPutAll: queryString printString;
		nextPutAll: ')'
]

{ #category : #accessing }
PGQuery >> queryString [
	^queryString
]

{ #category : #accessing }
PGQuery >> queryString: aString [
	queryString := aString
]

{ #category : #sending }
PGQuery >> writeOn: aStream [

	self writeByte: $Q on: aStream.
	self writeString: self queryString on: aStream.

]
