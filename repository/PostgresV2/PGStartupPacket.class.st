Class {
	#name : #PGStartupPacket,
	#superclass : #PGPacket,
	#instVars : [
		'version',
		'databaseName',
		'userName',
		'extraArgs',
		'debugTty'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGStartupPacket class >> databaseName: database userName: user [

	^self new
		setDatabaseName: database userName: user;
		yourself
]

{ #category : #accessing }
PGStartupPacket >> byteCount [
	^296

]

{ #category : #accessing }
PGStartupPacket >> databaseName [
	^databaseName

]

{ #category : #accessing }
PGStartupPacket >> databaseName: aString [
	databaseName := aString

]

{ #category : #accessing }
PGStartupPacket >> debugTty [
	^debugTty
]

{ #category : #accessing }
PGStartupPacket >> debugTty: aString [
	debugTty := aString
]

{ #category : #accessing }
PGStartupPacket >> extraArgs [
	^extraArgs
]

{ #category : #accessing }
PGStartupPacket >> extraArgs: aString [
	extraArgs := aString
]

{ #category : #printing }
PGStartupPacket >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'databaseName='; nextPutAll: databaseName printString;
		nextPutAll: ',userName='; nextPutAll: userName printString;
		nextPutAll: ',extraArgs='; nextPutAll: extraArgs printString;
		nextPutAll: ',debugTty='; nextPutAll: debugTty printString;
		nextPutAll: ',version='; nextPutAll: version printString;
		nextPutAll: ')'

]

{ #category : #'private-initialize' }
PGStartupPacket >> setDatabaseName: database userName: user [

	^self
		version: (2 bitShift: 16); "major=2 minor=0"
		databaseName: database;
		userName: user;
		yourself
]

{ #category : #accessing }
PGStartupPacket >> userName [
	^userName
]

{ #category : #accessing }
PGStartupPacket >> userName: aString [
	userName := aString
]

{ #category : #accessing }
PGStartupPacket >> version [
	^version

]

{ #category : #accessing }
PGStartupPacket >> version: anInteger [
	version := anInteger

]

{ #category : #sending }
PGStartupPacket >> writeOn: aStream [

	self writeInt32: self byteCount on: aStream.
	self writeInt32: self version on: aStream.
	self writeLimString: self databaseName size: 64 on: aStream.
	self writeLimString: self userName size: 32 on: aStream.
	self writeLimString: self extraArgs size: 64 on: aStream.
	self writeLimString: nil size: 64 on: aStream. "unused"
	self writeLimString: self debugTty size: 64 on: aStream.

]
