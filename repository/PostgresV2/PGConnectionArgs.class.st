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
		'debugTty'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGConnectionArgs class >> hostname: host portno: port databaseName: database userName: user password: pwd [

	^self new setHostname: host portno: port databaseName: database userName: user password: pwd extraArgs: nil debugTty: nil

]

{ #category : #'instance creation' }
PGConnectionArgs class >> hostname: host portno: port databaseName: database userName: user password: pwd extraArgs: extra debugTty: debug [

	^self new setHostname: host portno: port databaseName: database userName: user password: pwd extraArgs: extra debugTty: debug

]

{ #category : #accessing }
PGConnectionArgs >> databaseName [
	^databaseName
]

{ #category : #accessing }
PGConnectionArgs >> debugTty [
	^debugTty
]

{ #category : #accessing }
PGConnectionArgs >> extraArgs [
	^extraArgs
]

{ #category : #accessing }
PGConnectionArgs >> hostname [
	^hostname
]

{ #category : #accessing }
PGConnectionArgs >> password [
	^password
]

{ #category : #accessing }
PGConnectionArgs >> portno [
	^portno
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
