"
A SelmaConnectionPool is a simple connection pool that can be used to store and retieve stored DBXConnection objects

Instance Variables
	queue:		SharedQueue

queue
	- The SharedQueue object what the actual connections are stored

"
Class {
	#name : #NativePostgresConnectionPool,
	#superclass : #Object,
	#instVars : [
		'queue',
		'loginCredentials',
		'maxConnections',
		'logging'
	],
	#category : #GlorpDriverPostgreSQL
}

{ #category : #api }
NativePostgresConnectionPool >> acquireConnectionIfError: errorBlock [
      | connection |

	connection := self nextAvailableConnection.
	connection ifNil: [
		"All connections are stale and have been purged, grab some fresh ones"
		self connect: self loginCredentials. 
		connection := self nextAvailableConnection.
	].

	^ connection

]

{ #category : #api }
NativePostgresConnectionPool >> addConnection: aConnection [ 
	(aConnection notNil and: [aConnection isConnected])
	ifTrue: [
		self queue nextPut: aConnection
	]
	ifFalse:[
		self error: 'Attempting to add an invalid or closed connection to the pool'
	]
]

{ #category : #maintenance }
NativePostgresConnectionPool >> cleanPool [
	|stream|
	"flushes connections that have closed whilst idle in the pool"
"	stream := WriteStream on: String new.
	self printOn: stream.
	Transcript show: stream contents;cr."
	self queue flushAllSuchThat: [:each | each isConnected not]
]

{ #category : #'connection-pooling' }
NativePostgresConnectionPool >> connect: aLogin [
	| nativeDriver connection size fillPoolSize|
	
	self loginCredentials: aLogin.

	size := self queue size.
	fillPoolSize := self maxConnections - size.

	1 to: fillPoolSize do:[:n |
		nativeDriver := NativePostgresDriver new. 
		connection := nativeDriver connectionClass new.
		connection connectionArgs: (nativeDriver connectionArgsFromCurrentLogin: aLogin).
		connection startup.
		self addConnection: connection.
		self log: 'DBXPoolingDriver - Added one new connection to the Selma Pool. Connection # ',n asString.
	].

      
]

{ #category : #logging }
NativePostgresConnectionPool >> log: aStringOrBlock [
	"Log an arbitrary string"
	| string |
	self logging ifFalse: [^self].
	string := aStringOrBlock isString
		ifTrue: [aStringOrBlock]
		ifFalse: [aStringOrBlock value].
	string size > 4000 ifTrue: [string := string copyFrom: 1 to: 4000].
	Transcript
		cr;
		show: string.
]

{ #category : #accessing }
NativePostgresConnectionPool >> logging [
	^ logging ifNil:[logging := false]
]

{ #category : #accessing }
NativePostgresConnectionPool >> logging: anObject [
	logging := anObject
]

{ #category : #accessing }
NativePostgresConnectionPool >> loginCredentials [
	^ loginCredentials
]

{ #category : #accessing }
NativePostgresConnectionPool >> loginCredentials: anObject [
	loginCredentials := anObject
]

{ #category : #accessing }
NativePostgresConnectionPool >> maxConnections [
	^ maxConnections ifNil:[maxConnections := 4]
]

{ #category : #accessing }
NativePostgresConnectionPool >> maxConnections: anObject [
	maxConnections := anObject
]

{ #category : #'connection-pooling' }
NativePostgresConnectionPool >> nextAvailableConnection [
	| connection |
	
	"Remove any stale connections in this pool"
	self cleanPool.

	[self queue isEmpty]
		whileFalse: [connection := self queue nextOrNil.
			(connection notNil and: [ connection isConnected ])
				ifTrue: [
					^ connection
			]
		].
	^ nil

]

{ #category : #printing }
NativePostgresConnectionPool >> printOn: aStream [ 
	super printOn: aStream.
	aStream
		nextPutAll: ' ( SelmaPool has ';
		print: self queue size;
		nextPutAll: ' used slots)'
]

{ #category : #accessing }
NativePostgresConnectionPool >> queue [
	^ queue ifNil: [queue := SharedQueue new]
]

{ #category : #accessing }
NativePostgresConnectionPool >> queue: anObject [ 
	queue := anObject
]

{ #category : #maintenance }
NativePostgresConnectionPool >> reset [
	"Removes and closes any connections in the pool"
	|connection|
	[self queue isEmpty]
		whileFalse: [connection := self queue nextOrNil.
			connection notNil 
				ifTrue: [
					connection isConnected ifTrue: [ connection terminate].
					connection := nil.
				]
		].
	queue := nil
]

{ #category : #accessing }
NativePostgresConnectionPool >> size [
	^ self queue size
]
