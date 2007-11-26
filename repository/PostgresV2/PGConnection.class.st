"
Copyright (c) 2001-2003 by Yanni Chiu. All Rights Reserved.

Instances of PGConnection implement a client interface to a PostgreSQL backend.
See the ""Frontend/Backend Protocol"" chapter in the ""PostgreSQL Programmer's Guide"" for more information.
"
Class {
	#name : #PGConnection,
	#superclass : #PGActiveObject,
	#instVars : [
		'socket',
		'readBuffer',
		'readIndex',
		'lastReadIndex',
		'writeBuffer',
		'processId',
		'secretKey',
		'sql',
		'functionCallOid',
		'functionCallArgs',
		'copyStream',
		'result',
		'connectionArgs',
		'notificationSubscribers',
		'fieldConverters',
		'sqlStringConverter'
	],
	#classVars : [
		'DefaultTraceLevel',
		'DefaultConnectionArgs'
	],
	#category : #PostgresV2
}

{ #category : #initialization }
PGConnection class >> buildDefaultConnectionArgs [

	^ PGConnectionArgs
		hostname: 'localhost'
		portno: 5432
		databaseName: 'test'
		userName: 'postgres'
		password: 'secret'

]

{ #category : #initialization }
PGConnection class >> buildDefaultFieldConverters [
	"The type oid's can be found using:
		SELECT oid,typname from pg_type
	Also, see the source code file:
		.../src/include/catalog/pg_type.h
	"
	| converters dateBlock timestampBlock timetzBlock timestamptzBlock |

	converters := IdentityDictionary new.

	#(16 "bool" 1000 "_bool")
		do: [:each | converters at: each put: [:s | s = 't' or: [s = 'T']]].

	#(18 "char" 1002 "_char" 1042 "bpchar")
		do: [:each | converters at: each put: [:s | s]].

	#(20 "int8" 21 "int2" 23 "int4" 1005 "_int2" 1007 "_int4" 1016 "_int8")
		do: [:each | converters at: each put: [:s | Number readFrom: (ReadStream on: s)]].

	#(700 "float4" 701 "float8" 1021 "_float4" 1022 "_float8" 1700 "numeric")
		do: [:each | converters at: each put: [:s | (Number readFrom: (ReadStream on: s)) asFloat]].

	dateBlock :=
		[:s | Date
				newDay: (s copyFrom: 9 to: 10) asInteger
				month: (s copyFrom: 6 to: 7) asInteger
				year: (s copyFrom: 1 to: 4) asInteger].
	#(1082 "date" 1182 "_date")
		do: [:each | converters at: each put: dateBlock].

	#(1083 "time" 1183 "_time")
		do: [:each | converters at: each put: [:s | Time readFrom: (ReadStream on: s)]].

	timestampBlock :=
		[:s |	DateAndTime
				year: (s copyFrom: 1 to: 4) asInteger
				month: (s copyFrom: 6 to: 7) asInteger
				day: (s copyFrom: 9 to: 10) asInteger
				hour: (s copyFrom: 12 to: 13) asInteger
				minute: (s copyFrom: 15 to: 16) asInteger
				second: (s copyFrom: 18 to: 19) asInteger].
	#(1114 "timestamp" 1115 "_timestamp")
		do: [:each | converters at: each put: timestampBlock].

	timetzBlock :=
		[:s | | list |
			list := (s subStrings: ':') collect:[:i | i asInteger].
			Time fromSeconds: ((list at: 1) * 3600) + ((list at: 2) * 60) + (list at: 3)].
	#(1266 "timetz" 1270 "_timetz")
		do: [:each | converters at: each put: timetzBlock].

	timestamptzBlock :=
		[:s | | direction offset |
			direction := (s charAt: 23) = $- ifTrue: [-1] ifFalse: [1].
			offset := Duration
				days: 0
				hours: (s copyFrom: 21 to: 22) asInteger * direction
				minutes: (s copyFrom: 24 to: 25) asInteger * direction
				seconds: 0.
			DateAndTime
				year: (s copyFrom: 1 to: 4) asInteger
				month: (s copyFrom: 6 to: 7) asInteger
				day: (s copyFrom: 9 to: 10) asInteger
				hour: (s copyFrom: 12 to: 13) asInteger
				minute: (s copyFrom: 15 to: 16) asInteger
				second: (s copyFrom: 18 to: 19) asInteger
				offset: offset].
	#(1184 "timestamptz " 1185 "_timestamptz")
		do: [:each | converters at: each put: timestamptzBlock].

	^ converters

]

{ #category : #initialization }
PGConnection class >> buildStateTransitionTable [
	"self resetStateTransitionTable"

	^#(
	(Created (
		(Startup Startup)))
	(Startup (
		(AuthenticationKerberosV4 UnsupportedAuthentication)
		(AuthenticationKerberosV5 UnsupportedAuthentication)
		(AuthenticationCleartextPassword SendingCleartextPassword)
		(AuthenticationCryptPassword UnsupportedAuthentication)
		(AuthenticationMD5Password	SendingMD5Password)
		(AuthenticationSCMCredential UnsupportedAuthentication)
		(AuthenticationOk AuthenticationOk)
		(ConnectionFailed ConnectionFailed)
		(Terminate Terminated)
		(ErrorResponse TerminalError)))
	(SendingCleartextPassword (
		(AuthenticationOk AuthenticationOk)
		(Terminate Terminated)
		(ErrorResponse TerminalError)))
	(SendingMD5Password (
		(AuthenticationOk AuthenticationOk)
		(Terminate Terminated)
		(ErrorResponse TerminalError)))
	(UnsupportedAuthentication (
		(Terminate Terminated)))
	(AuthenticationOk (
		(BackendKeyData GotBackendKeyData)
		(Terminate Terminated)
		(ErrorResponse TerminalError)))
	(GotBackendKeyData (
		(ReadyForQuery ReadyForQuery)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(ReadyForQuery (
		(Query Querying)
		(FunctionCall FunctionCall)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(Querying (
		(CursorResponse GotCursor)
		(CopyOutResponse GotCopyOut)
		(CopyInResponse GotCopyIn)
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(FunctionCall (
		(FunctionResultResponse GotFunctionResult)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(GotCursor (
		(RowDescription GotRowDescription)
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(GotRowDescription (
		(AsciiRow GotRow)
		(BinaryRow GotRow)
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(GotRow (
		(AsciiRow GotRow)
		(BinaryRow GotRow)
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(GotCopyOut (
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(GotCopyIn (
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(GotFunctionResult (
		(ReadyForQuery ReadyForQuery)
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(GotCompleted (
		(ReadyForQuery ReadyForQuery)
		(CursorResponse GotCursor)
		(CompletedResponse GotCompleted)
		(Terminate Terminated)
		(ErrorResponse ErrorResponse)))
	(Terminated (
		(Startup Startup)))
	(ConnectionFailed (
		(Startup Startup)
		(Query EventIgnored)
		(FunctionCall EventIgnored)
		(Terminate EventIgnored)))
	(ErrorResponse (
		(Terminate Terminated)
		(ReadyForQuery ReadyForQuery)
		(CompletedResponse GotCompleted)))
	(TerminalError (
		))
	)
	inject: Dictionary new
	into: [:table :each |
		table
			at: (each at: 1)
			put: ((each at: 2)
					inject: Dictionary new
					into: [:stateTransitions :transition |
						stateTransitions at: (transition at: 1) put: (transition at: 2).
						stateTransitions]).
		table].

]

{ #category : #accessing }
PGConnection class >> defaultConnectionArgs [
	DefaultConnectionArgs isNil ifTrue: [DefaultConnectionArgs := self buildDefaultConnectionArgs].
	^ DefaultConnectionArgs

]

{ #category : #accessing }
PGConnection class >> defaultConnectionArgs: aConnectionArgs [
	"self defaultConnectionArgs: nil"

	DefaultConnectionArgs := aConnectionArgs

]

{ #category : #accessing }
PGConnection class >> defaultTraceLevel [
	DefaultTraceLevel isNil ifTrue: [DefaultTraceLevel := 0].
	^DefaultTraceLevel
]

{ #category : #accessing }
PGConnection class >> defaultTraceLevel: anInteger [
	"
	PGConnection defaultTraceLevel: 0.
	PGConnection defaultTraceLevel: 2.
	PGConnection defaultTraceLevel: 5.
	PGConnection defaultTraceLevel: 8.
	PGConnection defaultTraceLevel: 10.
	"

	DefaultTraceLevel := anInteger
]

{ #category : #'instance creation' }
PGConnection class >> new [

	^self basicNew initialize

]

{ #category : #accessing }
PGConnection >> addNotificationSubscriber: aNotificationSubscriber [

	^ self notificationSubscribers add: aNotificationSubscriber

]

{ #category : #api }
PGConnection >> cancelRequest [
	"Issue a cancel request. Open a new connection to the server and send a CancelRequest message."

	self sendCancel.

]

{ #category : #'as yet unclassified' }
PGConnection >> clientEncoding: aSymbol [
	sqlStringConverter := [
		:sqlString| 
		sqlString convertToEncoding: aSymbol
	].
	#(25 1043) do: [
		:each| 
		self fieldConverters  at: each put: [
			:s | 
			s convertFromEncoding: aSymbol
		]
	].	

]

{ #category : #'private-actions' }
PGConnection >> closeSocket [

	self closeSocket: socket

]

{ #category : #'private-actions' }
PGConnection >> closeSocket: aSocket [

	trace >= 2
		ifTrue: [ self log: 'closeSocket' text: 'hostname: ', connectionArgs hostname, ':', connectionArgs portno printString ].
	trace >= 2
		ifTrue: [ self log: 'closeSocket' text: 'socket: ', aSocket printString ].

	aSocket closeAndDestroy.

	trace >= 2
		ifTrue: [ self log: 'closeSocket' text: 'socket: ', aSocket printString ].

]

{ #category : #accessing }
PGConnection >> connectionArgs [
	^connectionArgs
]

{ #category : #accessing }
PGConnection >> connectionArgs: aConnectionArgs [
	connectionArgs := aConnectionArgs
]

{ #category : #api }
PGConnection >> copy: copySql withStream: aStream [

	"The syntax of a COPY command is:

	COPY [ BINARY ] table [ WITH OIDS ]
		FROM { 'filename' | stdin }
		[ [USING] DELIMITERS 'delimiter' ]
		[ WITH NULL AS 'null string' ]

	COPY [ BINARY ] table [ WITH OIDS ]
		TO { 'filename' | stdout }
		[ [USING] DELIMITERS 'delimiter' ]
		[ WITH NULL AS 'null string' ]

	The 'stdin' or 'stdout' option must be used, not the 'filename' option.
	'aStream' will supply the COPY...FROM input.
	'aStream' will received the COPY...TO output.
	"

	sql := copySql.
	copyStream := aStream.
	self queueEvent: #Query.
	self saProcessEventsUntil: #(ReadyForQuery ConnectionFailed).
	^ result

]

{ #category : #'private-actions' }
PGConnection >> copyInDataRows [
	"copyStream is initially positioned at the start of a data rows stream.
	The contents are sent down the socket.

	In a stream of data rows, each row is terminatated by a Byte1('\n').
	A sequence of Byte1('\\'), Byte1('.'), Byte1('\n') is the last line.
	"

	trace >= 8
		ifTrue: [ self log: 'copyInDataRows' text: copyStream contents printString ].

	socket sendData: copyStream contents.
	"socket sendData: (String with: $\ with: $. with: Character lf)."

]

{ #category : #'private-actions' }
PGConnection >> copyOutDataRows [

	| ch lf notDone pch ppch |
	lf := Character lf.
	notDone := true.
	pch := $x.
	ch := $x.
	[notDone] whileTrue: [
		ppch := pch.
		pch := ch.
		ch := self next.
		copyStream nextPut: ch.
		((ch = lf and: [pch = $.]) and: [ppch = $\])
			ifTrue: [notDone := false].
	].


]

{ #category : #accessing }
PGConnection >> copyStream [
	^copyStream
]

{ #category : #accessing }
PGConnection >> copyStream: aStream [
	copyStream := aStream
]

{ #category : #api }
PGConnection >> execute: sqlString [

	trace >= 2 ifTrue: [self log: 'execute' text: sqlString].

	self isConnected ifFalse: [ self error: 'Connection not valid' ].

	sql := sqlStringConverter value: sqlString.
	self queueEvent: #Query.
	self saProcessEventsUntil: #(ReadyForQuery ConnectionFailed).

	"There's an extra result set, so nuke it here."
	result resultSets size > 0
		ifTrue: [ result resultSets removeLast ].

	^ result

]

{ #category : #accessing }
PGConnection >> fieldConverterAt: typeOid [
	^ fieldConverters at: typeOid ifAbsent: [nil]

]

{ #category : #accessing }
PGConnection >> fieldConverterAt: typeOid put: converter [
	fieldConverters at: typeOid put: converter

]

{ #category : #accessing }
PGConnection >> fieldConverters [
	^ fieldConverters
]

{ #category : #accessing }
PGConnection >> fieldConverters: anObject [
	fieldConverters := anObject
]

{ #category : #api }
PGConnection >> functionCall: oid arguments: arguments [

	functionCallOid := oid.
	functionCallArgs := arguments.
	self queueEvent: #FunctionCall.
	self saProcessEventsUntil: #(ReadyForQuery ConnectionFailed).
	^ result

]

{ #category : #'initialize/release' }
PGConnection >> initialize [

	| readBufferSize |

	super initialize.

	trace := self class defaultTraceLevel.
	readBufferSize := 8096.
	readBuffer := String new: readBufferSize.
	readIndex := readBufferSize + 1.
	lastReadIndex := readBufferSize.

	self fieldConverters: self class buildDefaultFieldConverters.
	result := PGResult on: self.

	sqlStringConverter := [:sqlString| sqlString].
	"^ self"

]

{ #category : #accessing }
PGConnection >> isConnected [
	^ socket notNil and: [ socket isConnected]
]

{ #category : #'private-actions' }
PGConnection >> next [
	readIndex >= lastReadIndex 
		ifTrue: 
			[trace >= 10 
				ifTrue: [self log: 'next' text: '**** filling read buffer ****'].
			"(Delay forMilliseconds: 500) wait."
			socket waitForDataFor: Socket standardTimeout.
			
			[(lastReadIndex := socket receiveDataInto: readBuffer) = 0 
				ifTrue: 
					[trace >= 10 
						ifTrue: [self log: 'next' text: '**** zero length received from socket ****'].
					(Delay forMilliseconds: 100) wait].
			lastReadIndex = 0] 
					whileTrue.
			readIndex := 0.
			trace >= 10 
				ifTrue: 
					[self log: 'next' text: '**** read ' , lastReadIndex printString , ' ****']].
	readIndex := readIndex + 1.
	trace >= 10 
		ifTrue: 
			[self log: 'next'
				text: 'readIndex=' , readIndex printString , ',lastReadIndex=' 
						, lastReadIndex printString , ',ch=' 
						, (readBuffer at: readIndex) printString].
	^readBuffer at: readIndex
]

{ #category : #'private-actions' }
PGConnection >> nextEvent [

	| pkt noticeFlag |

	[
		pkt := self receivePacket.
		(noticeFlag := #(NoticeResponse NotificationResponse) includes: pkt eventName)
			ifTrue: [ self notifySubscribers: pkt ].
		noticeFlag.
	] whileTrue.
	^ pkt

]

{ #category : #accessing }
PGConnection >> notificationSubscribers [

	notificationSubscribers isNil ifTrue: [ notificationSubscribers := OrderedCollection new ].
	^ notificationSubscribers

]

{ #category : #'private-actions' }
PGConnection >> notifySubscribers: pkt [

	notificationSubscribers isNil
		ifTrue: [ self logInfo: 'NOTIFICATION: ', pkt printString ]
		ifFalse: [ notificationSubscribers do: [:each | each receive: pkt from: self ]].

]

{ #category : #'private-actions' }
PGConnection >> openSocket [
	| newSocket |
	trace >= 2 
		ifTrue: 
			[self log: 'openSocket'
				text: 'hostname: ' , connectionArgs hostname , ':' 
						, connectionArgs portno printString].
	Socket initializeNetwork.
	newSocket := Socket newTCP.
	newSocket 
		connectTo: (NetNameResolver addressForName: connectionArgs hostname
				timeout: 15)
		port: connectionArgs portno.
	newSocket waitForConnectionFor: Socket standardTimeout ifTimedOut: [newSocket := nil].
	trace >= 2 
		ifTrue: [self log: 'openSocket' text: 'socket: ' , newSocket printString].
	^newSocket
]

{ #category : #'private-actions' }
PGConnection >> receivePacket [

	| typeCode packet |

	typeCode := self next.
	trace >= 5
		ifTrue: [ self log: 'packet typeCode=' text: typeCode printString ].

	packet := PGPacket newPacket: typeCode.

	packet == nil
		ifTrue: [packet := #UnknownPacket]
		ifFalse: [packet receiveFrom: self ].

	trace >= 5
		ifTrue: [ self log: 'receivePacket' text: packet printString ].

	^ packet

]

{ #category : #'private-actions' }
PGConnection >> resetResult [
	"Clear the result, a new query or function call will follow."

	result
		reset;
		addResultSet.

]

{ #category : #accessing }
PGConnection >> result [
	^result
]

{ #category : #accessing }
PGConnection >> result: aResult [
	result := aResult
]

{ #category : #'private-actions' }
PGConnection >> sendCancel [

	| cancelRequestSocket |

	trace >= 2
		ifTrue: [ self log: 'sendCancel' text: 'processId=', processId printString ].

	cancelRequestSocket := self openSocket.
	self sendPacket: (PGCancelRequest processId: processId secretKey: secretKey) on: cancelRequestSocket.
	self closeSocket: cancelRequestSocket.

]

{ #category : #'private-actions' }
PGConnection >> sendPacket: aPacket on: aSocket [

	| s |
	s := WriteStream on: String new.
	aPacket writeOn: s.

	trace >= 5
		ifTrue: [
			self log: 'sendPacket' text: aPacket printString.
			trace >= 10 ifTrue: [self log: 'sendPacket' text: s contents printString].
		].

	aSocket sendData: s contents.

]

{ #category : #'private-actions' }
PGConnection >> sendStartup [

	self sendPacket: (PGStartupPacket databaseName: connectionArgs databaseName userName: connectionArgs userName) on: socket.

]

{ #category : #'private-actions' }
PGConnection >> sendTerminate [

	self sendPacket: PGTerminate new on: socket.

]

{ #category : #'private-states' }
PGConnection >> stAuthenticationOk: event [

	"Do nothing"

]

{ #category : #'private-states' }
PGConnection >> stCantHappen: event [
	"Try to send the terminate packet, then close the socket"

	self isConnected ifTrue: [ self sendTerminate ].
	socket isNil ifFalse: [ self closeSocket ].
	super stCantHappen: event.

]

{ #category : #'private-states' }
PGConnection >> stConnectionFailed: event [

	"Do nothing"

]

{ #category : #'private-states' }
PGConnection >> stErrorResponse: event [

	result errorResponse: event.

]

{ #category : #'private-states' }
PGConnection >> stFunctionCall: event [

	self resetResult.
	self sendPacket: (PGFunctionCall oid: functionCallOid arguments: functionCallArgs) on: socket.

]

{ #category : #'private-states' }
PGConnection >> stGotBackendKeyData: backendKeyData [
	"event is a BackendKeyData packet."

	processId := backendKeyData processId.
	secretKey := backendKeyData secretKey.

]

{ #category : #'private-states' }
PGConnection >> stGotCompleted: event [

	result completedResponse: event.

	"This causes an extra result set to be added.
	But a result set has to be available at this point,
	given the current state machine.
	"
	result addResultSet.

]

{ #category : #'private-states' }
PGConnection >> stGotCopyIn: event [

	self copyInDataRows.

]

{ #category : #'private-states' }
PGConnection >> stGotCopyOut: event [

	self copyOutDataRows.

]

{ #category : #'private-states' }
PGConnection >> stGotCursor: event [

	"Do nothing"

]

{ #category : #'private-states' }
PGConnection >> stGotFunctionResult: event [

	result functionResult: event.

]

{ #category : #'private-states' }
PGConnection >> stGotRow: event [

	result rows add: event.

]

{ #category : #'private-states' }
PGConnection >> stGotRowDescription: event [

	result rowDescription: event.

]

{ #category : #'private-states' }
PGConnection >> stQuerying: event [

	self resetResult.
	self sendPacket: (PGQuery sql: sql) on: socket.

]

{ #category : #'private-states' }
PGConnection >> stReadyForQuery: event [

	"Do nothing"

]

{ #category : #'private-states' }
PGConnection >> stSendingCleartextPassword: event [

	self sendPacket: (PGPasswordPacket password: connectionArgs password) on: socket.

]

{ #category : #'private-states' }
PGConnection >> stSendingMD5Password: event [ 
	"MD5 authentication as explain in http://archives.postgresql.org/pgsql-novice/2003-05/msg00305.php"
	| hashedCredentials hashedMessage |

	hashedCredentials := (MD5 hashMessage: (connectionArgs password, connectionArgs userName)) hex asLowercase.
	hashedMessage := 'md5', (MD5 hashMessage: (hashedCredentials, event salt asString)) hex asLowercase.

	self	sendPacket: (PGPasswordPacket password: hashedMessage) on: socket.

]

{ #category : #'private-states' }
PGConnection >> stStartup: event [

	self resetResult.
	socket := self openSocket.
	socket isNil
		ifTrue: [ self generateEvent: #ConnectionFailed to: self ]
		ifFalse: [ self sendStartup ].

]

{ #category : #'private-states' }
PGConnection >> stTerminalError: event [

	result errorResponse: event.
	self closeSocket: socket.
	socket := nil.

]

{ #category : #'private-states' }
PGConnection >> stTerminated: event [

	self sendTerminate.
	self closeSocket: socket.
	socket := nil.

]

{ #category : #'private-states' }
PGConnection >> stUnsupportedAuthentication: event [

	"result errorResponse: 'Unsupported authentication method: ', event eventName."

	PGUnsupportedAuthentication signal: 'Unsupported authentication method: ', event eventName.

]

{ #category : #api }
PGConnection >> startup [

	self connectionArgs isNil ifTrue: [
		self connectionArgs: self class defaultConnectionArgs.
	].
	self connectionArgs clientEncoding ifNotNil: [
		self clientEncoding: self connectionArgs clientEncoding.
	].
	self queueEvent: #Startup.
	self saProcessEventsUntil: #(ReadyForQuery ConnectionFailed TerminalError UnsupportedAuthentication).
	^ result

]

{ #category : #api }
PGConnection >> terminate [

	self queueEvent: #Terminate.
	self saProcessEventsUntil: #(Terminated ConnectionFailed).

]
