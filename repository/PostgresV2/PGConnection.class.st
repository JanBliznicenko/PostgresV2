"
Instances of PGConnection implement a client interface to a PostgreSQL backend.
See the ""Frontend/Backend Protocol"" chapter in the ""PostgreSQL Programmer's Guide"" for more information.


!License
Oringinally created by  in 2001-2003. Released under MIT.

Copyright (c) 2001-2003 Yanni Chiu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the ""Software""), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
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
		'sqlStringConverter',
		'receivingTextConverter'
	],
	#classVars : [
		'DefaultConnectionArgs',
		'DefaultTraceLevel'
	],
	#category : #PostgresV2
}

{ #category : #converters }
PGConnection class >> booleanArrayConverter [

	^[ :s | 
		| readStream |
		readStream := s readStream.
		readStream next.
		Array streamContents: [ :stream | 
			[ readStream atEnd or: [ readStream peek = $} ] ] whileFalse: [
				stream nextPut: (self nextBooleanFrom: readStream) ] ] ].


]

{ #category : #converters }
PGConnection class >> booleanConverter [

	^[ :s | s = 't' or: [ s = 'T' ] ]
]

{ #category : #initialization }
PGConnection class >> buildDefaultConnectionArgs [

	^ PGConnectionArgs
		hostname: 'localhost'
		portno: 5432
		databaseName: 'sodbxtest'
		userName: 'sodbxtest'
		password: 'sodbxtest'

]

{ #category : #initialization }
PGConnection class >> buildDefaultFieldConverters [
	"The type oid's can be found using:
		SELECT oid,typname from pg_type
	Also, see the source code file:
		.../src/include/catalog/pg_type.h
	"
	| converters |
	converters := IdentityDictionary new.
	#(
		(booleanConverter (16 "boolean"))
		(booleanArrayConverter (1000 "boolean[]"))
		(characterConverter (18 "char" 1002 "_char" 1042 "bpchar")) "fix the array converter!"
		(integerConveter (20 "int8" 21 "int2" 23 "int4"))
		(integerArrayConveter (1005 "_int2[]" 1007 "_int4[]" 1016 "_int8[]"))
		(stringArrayConveter (1009)) "doesn't handle nulls"
		(floatConverter (700 "float4" 701 "float8" 1021 "_float4" 1022 "_float8")) "fix the array converter"
		(numericConverter (1700 "numeric")) "fix it, it returns a float now"
		(dateConverter (1082 "date" 1182 "_date")) "fix the array converter"
		(timeConverter (1083 "time" 1183 "_time")) "fix the array converter"
		(timestampConverter (1114 "timestamp" 1115 "_timestamp")) "fix the array converter"
		(timeWithTimezoneConverter (1266 "timetz" 1270 "_timetz")) "probably omits the timezone. fix the array converter"
		(timestampWithTimezoneConverter (1184 "timestamptz " 1185 "_timestamptz")) "fix the array converter"
		(jsonConverter (114 114))
	) do: [ :each |
		each second do: [ :typeOid |
			converters at: typeOid put: (self perform: each first) ] ].
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
	inject: IdentityDictionary new
	into: [:table :each |
		table
			at: (each at: 1)
			put: ((each at: 2)
					inject: IdentityDictionary new
					into: [:stateTransitions :transition |
						stateTransitions at: (transition at: 1) put: (transition at: 2).
						stateTransitions]).
		table].

]

{ #category : #converters }
PGConnection class >> characterConverter [

	^[ :s | s ]
]

{ #category : #converters }
PGConnection class >> dateConverter [ 

	^[:s |
		Date
			year: (s copyFrom: 1 to: 4) asInteger
			month: (s copyFrom: 6 to: 7) asInteger
			day: (s copyFrom: 9 to: 10) asInteger ]

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

{ #category : #converters }
PGConnection class >> floatConverter [

	^[ :s | (Number readFrom: (ReadStream on: s)) asFloat ]
]

{ #category : #converters }
PGConnection class >> integerArrayConveter [

	^[:s | 
		| readStream |
		readStream := s readStream.
		readStream next.
		Array streamContents: [ :stream | 
			[ readStream atEnd or: [ readStream peek = $} ] ] whileFalse: [ 
				stream nextPut: (self readIntegerFrom: readStream).
				readStream next ] ] ]

]

{ #category : #converters }
PGConnection class >> integerConveter [

	^[ :s | self readIntegerFrom: (ReadStream on: s) ].

]

{ #category : #converters }
PGConnection class >> jsonConverter [
 
	^[:string | Json readFrom: string readStream ]


]

{ #category : #'instance creation' }
PGConnection class >> new [

	^self basicNew initialize

]

{ #category : #private }
PGConnection class >> nextBooleanFrom: readStream [

	| firstChar result |
	firstChar := readStream next.
	result := firstChar caseOf: { 
		[ $t ] -> [ true ].
		[ $T ] -> [ true ].
		[ $f ] -> [ false ].
		[ $F ] -> [ false ].
		[ $N ] -> [ 
			(readStream next: 3) = 'ULL' ifFalse: [
				self parseError ].
			nil ] }.
	readStream skip: 1.
	^result
]

{ #category : #private }
PGConnection class >> nextDateAndTimeFrom: string [
	"Accepted format: 'YYYY-MM-DD HH:MM:SS[.ss...s][(+|-)HH]' fractional seconds and timezone are optional"
	"#( '1967-08-07 18:50:12+02' '1967-08-07 18:50:12' '1967-08-07 18:50:12.12+02' 
		'1967-08-07 18:50:12.123+02' '1967-08-07 18:50:12.123456' ) 
		collect: [ :each | self nextDateAndTimeFrom: each ] "
	
	| stream parser parseInteger direction fractionalSeconds offset |
	stream := ReadStream on: string.
	parser := NumberParser on: stream.
	parseInteger := [ :from :to | 
		stream setFrom: from to: to. 
		parser nextUnsignedIntegerBase: 10 ].
	fractionalSeconds := 0.
	offset := DateAndTime localOffset.
	string size > 19 
		ifTrue: [ | offsetStart |
			(string at: 20) = $.
				ifTrue: [
					offsetStart := 21.
					[ offsetStart <= string size and: [ (string at: offsetStart) isDigit ] ]
						whileTrue: [ offsetStart := offsetStart + 1 ].
					offsetStart > 21 ifTrue: [ fractionalSeconds := parseInteger value: 21 value: offsetStart - 1 ] ]
				ifFalse: [ 
					offsetStart := 20 ].
			offsetStart <= string size
				ifTrue: [	
					direction := (string at: offsetStart) = $- ifTrue: [ -1 ] ifFalse: [ 1 ].
					offset := Duration hours: (parseInteger value: offsetStart + 1 value: string size) * direction ] ].
	^ DateAndTime
		year: (parseInteger value: 1 value: 4)
		month: (parseInteger value: 6 value: 7)
		day: (parseInteger value: 9 value: 10)
		hour: (parseInteger value: 12 value: 13)
		minute: (parseInteger value: 15 value: 16)
		second: (parseInteger value: 18 value: 19)
		nanoSecond: fractionalSeconds * (10 raisedToInteger: (9 - fractionalSeconds numberOfDigits))
		offset: offset
]

{ #category : #private }
PGConnection class >> nextStringFrom: readStream [

	| escape |
	^String streamContents: [ :stream |
		readStream peek = $" 
			ifFalse: [ 
				[ #($, $}) includes: readStream peek ] whileFalse: [ 
					stream nextPut: readStream next ] ]
			ifTrue: [
				escape := false.
				readStream skip: 1.
				[ escape not and: [ readStream peek = $" ] ] whileFalse: [ 
					| character |
					character := readStream next.
					escape 
						ifTrue: [
							stream nextPut: character.
							escape := false ]
						ifFalse: [
							escape := character = $\.
							escape ifFalse: [ stream nextPut: character ] ].
					].
				readStream skip: 1 ].
		readStream skip: 1 " drop comma or curlybrace " ]
]

{ #category : #converters }
PGConnection class >> numericConverter [
	"This should convert the value to ScaledDecimal"

	^[ :s | (Number readFrom: (ReadStream on: s)) asFloat ]
]

{ #category : #private }
PGConnection class >> readIntegerFrom: readStream [

	| next result sign |
	readStream atEnd ifTrue: [ ^self parseError ].
	readStream peek caseOf: {
		[ $- ] -> [
			sign := -1.
			readStream skip: 1 ].
		[ $N ] -> [
			(readStream next: 4) = 'NULL' ifTrue: [ ^nil].
			self parseError ]}
		otherwise: [ sign := 1 ].
	result := 0.
	[ (next := readStream next) == nil or: [
		(next := next asciiValue - 48) < 0 or: [
			next > 9 ] ] ] whileFalse: [
		result := result * 10 + next ].
	readStream skip: -1.
	^result * sign

]

{ #category : #converters }
PGConnection class >> stringArrayConveter [

	^[ :s |
		| readStream |
		readStream := s readStream.
		readStream next.
		Array streamContents: [ :stream | 
			[ readStream atEnd or: [ readStream peek = $} ] ] whileFalse: [
				stream nextPut: (self nextStringFrom: readStream) ] ] ]
]

{ #category : #tests }
PGConnection class >> testConvertersWith: aPGConnection [

	{ 
		'select b::boolean from (values (true), (false), (null)) t(b)' -> #(true false nil).
		'select array[true, false, null]::boolean[]' -> #((true false nil)).
		'select i::integer from (values (-1), (1), (null), (1234567890)) t(i)' -> #(-1 1 nil 1234567890).
		'select array[1, 2, null, -1]::integer[]' -> #((1 2 nil -1)).
		"'select array[''foo'', ''bar'', null, ''baz'']::text[]' -> #(('foo' 'bar' nil 'baz'))"
		'select d::date from (values (''1234-12-30''), (null), (''2009-01-31'')) t(d)' -> { Date year: 1234 month: 12 day: 30. nil. Date year: 2009 month: 1 day: 31 }.
		
	} do: [ :each |
		| dataRows |
		dataRows := (aPGConnection executeAndCheckResult: each key) dataRows.
		self assert: (dataRows collect: [ :row | row at: 1 ]) asArray = each value ]
	
]

{ #category : #converters }
PGConnection class >> timeConverter [ 

	^[ :s | Time readFrom: (ReadStream on: s) ]
]

{ #category : #converters }
PGConnection class >> timeWithTimezoneConverter [
 
	^[:s |
		| list |
		list := (s subStrings: ':') collect:[:i | i asInteger].
		Time fromSeconds: ((list at: 1) * 3600) + ((list at: 2) * 60) + (list at: 3) ]


]

{ #category : #converters }
PGConnection class >> timestampConverter [ 

	^[:s | self nextDateAndTimeFrom: s]
]

{ #category : #converters }
PGConnection class >> timestampWithTimezoneConverter [

	^[ :s | self nextDateAndTimeFrom: s]
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

	sqlStringConverter := [ :sqlString | 
		sqlString convertToEncoding: aSymbol ].
	receivingTextConverter := TextConverter newForEncoding: aSymbol.
	#(25 1043) do: [ 	:each | 
		self fieldConverters  at: each put: [ :s | 
			s convertFromWithConverter: receivingTextConverter ] ].	

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

	sql := sqlString convertToWithConverter: receivingTextConverter. "sqlStringConverter value: sqlString."
	self queueEvent: #Query.
	self saProcessEventsUntil: #(ReadyForQuery ConnectionFailed).

	"There's an extra result set, so nuke it here."
	result resultSets size > 0
		ifTrue: [ result resultSets removeLast ].

	^ result

]

{ #category : #api }
PGConnection >> execute: sqlString withRowBlock: aRowBlock [
	"Iterate thru resultset with block (for each row) without loading all bulk resultset data into memory (internal arrays). Implemented by database CURSORs.
	Row block has 2 parameters: 
		1) row description (PGRowDescription - column names, data types etc.)
		2) row data (OrderedCollection)"
	| cursorName rslt rowDesc rows |
	cursorName := 'squeakTempCursor', Time now nanoSecond asString.
	self executeAndCheckResult: 'BEGIN WORK'.
	[ 	self executeAndCheckResult: 'DECLARE ', cursorName, ' CURSOR FOR ', sqlString asString.
		[ 
			[	rslt := self executeAndCheckResult: 'FETCH FORWARD 5000 FROM ', cursorName.
				rowDesc := rslt resultSets first rowDescription.
				rows := rslt resultSets first rows.
				rows size > 0.
			] whileTrue: [
				rows do: [ :row | aRowBlock value: rowDesc value: row data ].				
				].						
		] ensure: [ self executeAndCheckResult: 'CLOSE ', cursorName ]
	] ensure: [ self executeAndCheckResult: 'COMMIT WORK' ].
	

]

{ #category : #api }
PGConnection >> executeAndCheckResult: sqlString [
	"Same as execute: but check responce - throw exception if error in responce" 
	| res |
	res := self execute: sqlString.
	(res errorResponse isKindOf: PGErrorResponse) ifTrue: [ Error signal: res errorResponse value ].
	^ res.

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
			socket waitForData. "For: Socket standardTimeout."
			
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
	] ifNil: [
		self clientEncoding: #utf8
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
