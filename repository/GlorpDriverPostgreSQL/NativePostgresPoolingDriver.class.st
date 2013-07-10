"
A GlorpOpenDBXDriverPoolingDriver is a driver that pools DBXConnections. I am based on code from VWPoolingDatbaseAccessor and code from the Glorp-Seaside pacakge. On statup, I will make #maxConnections connections to the underlying database and store these connections in a pool. If connections become stale or disconnected, they are flushed from the pool, and new connections are created. 

I rely on a SelmaConnectionPool to manage the pool of connections. 

Evaluate PharoDatabaseAccessor DefaultDriver: GlorpOpenDBXDriverPoolingDriver in your database connection code, to use me.

Instance Variables
	isInTransaction:		aBoolean
	loginCredentials:	aLogin
	maxConnections:	anIntger

isInTransaction
	- Tracks if we are in a transaction

loginCredentials
	- I save this Login object, in case I need to get more DB connections

maxConnections
	- Maximum number of DBXConnections to pool
"
Class {
	#name : #NativePostgresPoolingDriver,
	#superclass : #NativePostgresDriver,
	#instVars : [
		'isInTransaction',
		'loginCredentials',
		'logging'
	],
	#classVars : [
		'SelmaPools'
	],
	#category : #GlorpDriverPostgreSQL
}

{ #category : #'as yet unclassified' }
NativePostgresPoolingDriver class >> poolFor: aLogin [
	"Get the appropriate connection pool - one per set of logins"
	^ self selmaPools
		"DO NOT use aLogin here as the key because it's #= checks for equal password. And if password are cleaned because
		passwords are discarded (connections are secure), this gives false. So if we want to use aLogin for key, they have to be 
		set secure: false. For this purpose we use #connectString."
		at: aLogin connectString
		ifAbsentPut: [ NativePostgresConnectionPool new ] 



]

{ #category : #'class variables' }
NativePostgresPoolingDriver class >> resetAllPools [
	self selmaPools valuesDo: [ :each | each reset ].
	SelmaPools := nil.
]

{ #category : #'class variables' }
NativePostgresPoolingDriver class >> selmaPools [
	SelmaPools ifNil:[ self selmaPools: Dictionary new].
	^ SelmaPools
]

{ #category : #'class variables' }
NativePostgresPoolingDriver class >> selmaPools: aDictionary [
	SelmaPools := aDictionary
]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> acquireConnection [
	^ self acquireConnectionIfError: [:error | error pass]
]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> acquireConnectionIfError: errorBlock [
	(connection notNil and: [ connection isConnected]) ifTrue: [ ^ connection ].
	^ self connectionPool acquireConnectionIfError: errorBlock.
]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> basicExecuteSQLString: aString [
	^ self withConnectionDo: [ super basicExecuteSQLString: aString]
]

{ #category : #transactions }
NativePostgresPoolingDriver >> beginTransaction [
	isInTransaction := true.
	connection ifNil:[
		connection:=self acquireConnection
	].
	super beginTransaction.	
	self log: 'DBXPoolingDriver - has started a transaction'


]

{ #category : #transactions }
NativePostgresPoolingDriver >> commitTransaction [
	isInTransaction := false.
	[super commitTransaction] ensure:[self releaseConnection].
	self log: 'DBXPoolingDriver - has committed a transaction $'

]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> connect: aLogin [

	self loginCredentials: aLogin.
	self connectionPool connect: aLogin.
	connection:= self acquireConnection.
]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> connectionPool [
	"Get the appropriate connection pool - one per set of logins"
	^ self class poolFor: self loginCredentials 
		
]

{ #category : #initialize }
NativePostgresPoolingDriver >> initialize [
	super initialize.
	isInTransaction := false.

]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> isConnected [
	^ true
]

{ #category : #transactions }
NativePostgresPoolingDriver >> isInTransaction [
	^connection notNil and: [isInTransaction]
]

{ #category : #logging }
NativePostgresPoolingDriver >> log: aStringOrBlock [
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
NativePostgresPoolingDriver >> logging [
	^ logging ifNil:[logging := false]
]

{ #category : #accessing }
NativePostgresPoolingDriver >> logging: anObject [
	logging := anObject
]

{ #category : #accessing }
NativePostgresPoolingDriver >> loginCredentials [
	^ loginCredentials
]

{ #category : #accessing }
NativePostgresPoolingDriver >> loginCredentials: anObject [
	loginCredentials := anObject
]

{ #category : #login }
NativePostgresPoolingDriver >> logout [
	"self log: 'DBXPoolingDriver - logging out'.
	self connectionPool reset."
	

]

{ #category : #printing }
NativePostgresPoolingDriver >> printOn: aStream [
	super printOn: aStream.

	aStream
		nextPutAll: ' loginCredentials: ';
		print: loginCredentials.
	aStream
		nextPutAll: ' isInTransaction: ';
		print: isInTransaction.
	aStream
		nextPutAll: ' logging: ';
		print: logging.
	aStream
		nextPutAll: ' connection: ';
		print: connection.
	aStream
		nextPutAll: ' maxConnections: ';
		print: maxConnections.
	aStream
		nextPutAll: ' database: ';
		print: database
]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> releaseConnection [

	connection ifNil:[
		self error: 'DBXPoolingDriver - ERROR Releasing the connection, but its already nil ERROR'.
		^ self.
	].

	connection ifNotNil:[
		self isInTransaction ifTrue:[
			self error: 'DBXPoolingDriver -- Returning a connection that has an open Transaction '.
			^ self
			"self commitTransaction"
		].
		
		"Connection cleanUp."
		self connectionPool addConnection: connection.
		self log: 'DBXPoolingDriver - Connection is returned  to pool and setting current pointer to nil '.
		connection := nil
	]
]

{ #category : #transactions }
NativePostgresPoolingDriver >> rollbackTransaction [
	isInTransaction := false.
	[super rollbackTransaction] ensure:[self releaseConnection]. 
	self log: 'DBXPoolingDriver - has rolled back  a transaction'
]

{ #category : #'connection-pooling' }
NativePostgresPoolingDriver >> withConnectionDo: aBlock [

	connection isNil ifTrue: [
		connection:=self acquireConnection.
	].

	"If we are in a transaction, then we should not release the connection here, rather wait for the commit or rollback to release it"
	isInTransaction ifTrue:[
		^ aBlock value
	].
      
	[ ^ aBlock value ] ensure: [ self releaseConnection ]
]
