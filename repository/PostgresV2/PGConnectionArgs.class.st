Class {
	#name : #PGConnectionArgs,
	#superclass : #Object,
	#instVars : [
		'hostname',
		'portno',
		'databaseName',
		'userName',
		'password',
		'extraArgs',
		'debugTty',
		'clientEncoding'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGConnectionArgs class >> hostname: host portno: port databaseName: database userName: user password: pwd [
	^(self new)
		hostname: host;
		portno: port;
		databaseName: database;
		userName: user;
		password: pwd;
		yourself
]

{ #category : #'instance creation' }
PGConnectionArgs class >> hostname: host portno: port databaseName: database userName: user password: pwd extraArgs: extra debugTty: debug [
	^(self new)
		hostname: host;
		portno: port;
		databaseName: database;
		userName: user;
		password: pwd;
		extraArgs: extra;
		debugTty: debug;
		yourself
]

{ #category : #'as yet unclassified' }
PGConnectionArgs >> clientEncoding [
	^ clientEncoding
]

{ #category : #'as yet unclassified' }
PGConnectionArgs >> clientEncoding: aSymbol [
	clientEncoding := aSymbol
]

{ #category : #accessing }
PGConnectionArgs >> databaseName [
	^databaseName
]

{ #category : #accessing }
PGConnectionArgs >> databaseName: anObject [
	databaseName := anObject
]

{ #category : #accessing }
PGConnectionArgs >> debugTty [
	^debugTty
]

{ #category : #accessing }
PGConnectionArgs >> debugTty: anObject [
	debugTty := anObject
]

{ #category : #accessing }
PGConnectionArgs >> extraArgs [
	^extraArgs
]

{ #category : #accessing }
PGConnectionArgs >> extraArgs: anObject [
	extraArgs := anObject
]

{ #category : #accessing }
PGConnectionArgs >> hostname [
	^hostname
]

{ #category : #accessing }
PGConnectionArgs >> hostname: anObject [
	hostname := anObject
]

{ #category : #accessing }
PGConnectionArgs >> password [
	^password
]

{ #category : #accessing }
PGConnectionArgs >> password: anObject [
	password := anObject
]

{ #category : #accessing }
PGConnectionArgs >> portno [
	^portno
]

{ #category : #accessing }
PGConnectionArgs >> portno: anObject [
	portno := anObject
]

{ #category : #'private-initialize' }
PGConnectionArgs >> setHostname: host portno: port databaseName: database userName: user password: pwd extraArgs: extra debugTty: debug [

	hostname := host.
	portno := port.
	databaseName := database.
	userName := user.
	password := pwd.
	extraArgs := extra.
	debugTty := debug.
	^self
]

{ #category : #accessing }
PGConnectionArgs >> userName [
	^userName
]

{ #category : #accessing }
PGConnectionArgs >> userName: anObject [
	userName := anObject
]
