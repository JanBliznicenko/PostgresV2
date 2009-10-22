Class {
	#name : #NativePostgresDriver,
	#superclass : #DatabaseDriver,
	#category : #GlorpDriverPostgreSQL
}

{ #category : #'as yet unclassified' }
NativePostgresDriver >> basicExecuteSQLString: aString [
	| result rowCollection |
	aString ifEmpty: [^ReadStream on: Array new].
	result := connection execute: aString.
	result errorResponse notNil
		ifTrue:
			[self externalDatabaseErrorSignal signal: result errorResponse value].
	rowCollection := OrderedCollection new.
	result rows do: [:ea | rowCollection add: ea data asArray].
 	^ReadStream on: rowCollection asArray
]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> beginTransaction [
	connection execute: 'BEGIN TRANSACTION'
]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> commitTransaction [
	connection execute: 'COMMIT TRANSACTION'
]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> connect: aLogin [

	connection  := self connectionClass new.
	connection  connectionArgs: (self connectionArgsFromCurrentLogin: aLogin).
	^ connection  startup.
	
		
]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> connectionArgsFromCurrentLogin: aLogin [

	"connect string looks like  hostname:portNumber_db-name. :portNumber is optional"
	| str portIndex index dbIndex |
	str := aLogin connectString.
	portIndex := index := str indexOf: $:.
	dbIndex := str indexOf: $_.
	index = 0 ifTrue: [index := dbIndex].
	^(Dialect smalltalkAt: #PGConnectionArgs)
		hostname: (str copyFrom: 1 to: index - 1)
		portno: (portIndex = 0 ifTrue: [5432] ifFalse: [(str copyFrom: portIndex + 1 to: dbIndex - 1) asNumber])
		databaseName: (str copyFrom: dbIndex + 1 to: str size)
		userName: aLogin username
		password: aLogin password
]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> connectionClass [
^ PGConnection

]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> logout [
connection terminate.
]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> rollbackTransaction [
	connection execute: 'ROLLBACK TRANSACTION'
]

{ #category : #'as yet unclassified' }
NativePostgresDriver >> rowCount [

	|count|
	count := 0.
	self connection result resultSets
		do: [:each| count := count + 
			(each completedResponse value subStrings: (Array with: Character space)) last asInteger].
	^count
]
